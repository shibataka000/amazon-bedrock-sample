package main

import (
	"context"
	"errors"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagent"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagentruntime"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagentruntime/types"
)

type BedrockClient struct {
	agent        *bedrockagent.Client
	agentrumtime *bedrockagentruntime.Client
}

func newBedrockClient(ctx context.Context) (*BedrockClient, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return nil, err
	}
	return &BedrockClient{
		agent:        bedrockagent.NewFromConfig(cfg),
		agentrumtime: bedrockagentruntime.NewFromConfig(cfg),
	}, nil
}

func (c *BedrockClient) getAgentID(ctx context.Context, agentName string) (string, error) {
	output, err := c.agent.ListAgents(ctx, &bedrockagent.ListAgentsInput{})
	if err != nil {
		return "", err
	}
	for _, agent := range output.AgentSummaries {
		if *agent.AgentName == agentName {
			return *agent.AgentId, nil
		}
	}
	return "", errors.New("agent not found")
}

func (c *BedrockClient) invokeAgent(ctx context.Context, agentName string, AgentAliasID string, inputText string) ([]byte, error) {
	agentID, err := c.getAgentID(ctx, agentName)
	if err != nil {
		return nil, err
	}
	sessionID := "TSTSESSIONID"
	output, err := c.agentrumtime.InvokeAgent(ctx, &bedrockagentruntime.InvokeAgentInput{
		AgentAliasId:               aws.String(AgentAliasID),
		AgentId:                    aws.String(agentID),
		SessionId:                  aws.String(sessionID),
		BedrockModelConfigurations: nil,
		EnableTrace:                aws.Bool(true),
		EndSession:                 nil,
		InputText:                  aws.String(inputText),
		MemoryId:                   nil,
		SessionState:               nil,
		SourceArn:                  nil,
		StreamingConfigurations:    nil,
	})
	if err != nil {
		return nil, err
	}
	response := []byte{}
	stream := output.GetStream()
	for event := range stream.Events() {
		switch v := event.(type) {
		case *types.ResponseStreamMemberChunk:
			response = append(response, v.Value.Bytes...)
		case *types.ResponseStreamMemberFiles:
		case *types.ResponseStreamMemberReturnControl:
		case *types.ResponseStreamMemberTrace:
		default:
			return nil, errors.New("unknown type")
		}
	}
	return response, stream.Close()
}

func main() {
	ctx := context.Background()
	client, err := newBedrockClient(ctx)
	if err != nil {
		panic(err)
	}
	response, err := client.invokeAgent(ctx, "wheather-forecaster", "TSTALIASID", "東京の気温を教えてください。")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(response))
}
