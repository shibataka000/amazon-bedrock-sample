package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagent"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagentruntime"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagentruntime/types"
)

func main() {
	agentID := os.Args[1]
	ctx := context.Background()

	client, err := newClient(ctx)
	if err != nil {
		log.Fatal(err)
	}

	if err = client.prepareAgent(ctx, agentID); err != nil {
		log.Fatal(err)
	}

	if err = client.invokeAgent(ctx, agentID); err != nil {
		log.Fatal(err)
	}
}

type Client struct {
	bedrockagent        *bedrockagent.Client
	bedrockagentruntime *bedrockagentruntime.Client
}

func newClient(ctx context.Context) (*Client, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return nil, err
	}

	return &Client{
		bedrockagent:        bedrockagent.NewFromConfig(cfg),
		bedrockagentruntime: bedrockagentruntime.NewFromConfig(cfg),
	}, nil
}

func (c *Client) prepareAgent(ctx context.Context, agentID string) error {
	_, err := c.bedrockagent.PrepareAgent(ctx, &bedrockagent.PrepareAgentInput{
		AgentId: aws.String(agentID),
	})
	return err
}

func (c *Client) invokeAgent(ctx context.Context, agentID string) error {
	out, err := c.bedrockagentruntime.InvokeAgent(ctx, &bedrockagentruntime.InvokeAgentInput{
		AgentId:      aws.String(agentID),
		AgentAliasId: aws.String("TSTALIASID"),
		SessionId:    aws.String("TSTSESSIONID"),
		InputText:    aws.String("Hello, World!"),
		EnableTrace:  aws.Bool(true),
	})
	if err != nil {
		return err
	}
	for event := range out.GetStream().Events() {
		fmt.Println(event)
		switch v := event.(type) {
		case *types.ResponseStreamMemberChunk:
			fmt.Println(string(v.Value.Bytes))
		case *types.ResponseStreamMemberFiles:
		case *types.ResponseStreamMemberReturnControl:
		case *types.ResponseStreamMemberTrace:
			fmt.Println(v.Value.Trace)
		}
	}
	return nil
}
