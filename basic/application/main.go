package main

import (
	"context"
	"errors"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/bedrockruntime"
	"github.com/aws/aws-sdk-go-v2/service/bedrockruntime/types"
)

var errUnknownType = errors.New("unknown type")

type BedrockClient struct {
	runtime *bedrockruntime.Client
}

func newBedrockClient(ctx context.Context) (*BedrockClient, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return nil, err
	}
	return &BedrockClient{
		runtime: bedrockruntime.NewFromConfig(cfg),
	}, nil
}

func (c *BedrockClient) invokeModel(ctx context.Context, modelID string, body string) ([]byte, error) {
	output, err := c.runtime.InvokeModel(ctx, &bedrockruntime.InvokeModelInput{
		ModelId:                  aws.String(modelID),
		Accept:                   aws.String("application/json"),
		Body:                     []byte(body),
		ContentType:              aws.String("application/json"),
		GuardrailIdentifier:      nil,
		GuardrailVersion:         nil,
		PerformanceConfigLatency: "",
		Trace:                    types.TraceEnabled,
	})
	if err != nil {
		return nil, err
	}
	return output.Body, nil
}

func (c *BedrockClient) invokeModelWithResponseStream(ctx context.Context, modelID string, body string) ([]byte, error) {
	output, err := c.runtime.InvokeModelWithResponseStream(ctx, &bedrockruntime.InvokeModelWithResponseStreamInput{
		ModelId:                  aws.String(modelID),
		Accept:                   aws.String("application/json"),
		Body:                     []byte(body),
		ContentType:              aws.String("application/json"),
		GuardrailIdentifier:      nil,
		GuardrailVersion:         nil,
		PerformanceConfigLatency: "",
		Trace:                    types.TraceEnabled,
	})
	if err != nil {
		return nil, err
	}
	stream := output.GetStream()
	response := []byte{}
	for event := range stream.Events() {
		switch e := event.(type) {
		case *types.ResponseStreamMemberChunk:
			response = append(response, e.Value.Bytes...)
		default:
			return nil, errUnknownType
		}
	}
	return response, stream.Close()
}

func (c *BedrockClient) converse(ctx context.Context, modelID string, contentText string) ([]byte, error) {
	output, err := c.runtime.Converse(ctx, &bedrockruntime.ConverseInput{
		ModelId:                           aws.String(modelID),
		AdditionalModelRequestFields:      nil,
		AdditionalModelResponseFieldPaths: nil,
		GuardrailConfig:                   nil,
		InferenceConfig:                   nil,
		Messages: []types.Message{
			{
				Role: types.ConversationRoleUser,
				Content: []types.ContentBlock{
					&types.ContentBlockMemberText{
						Value: contentText,
					},
				},
			},
		},
		PerformanceConfig: nil,
		PromptVariables:   nil,
		RequestMetadata:   nil,
		System:            nil,
		ToolConfig:        nil,
	})
	if err != nil {
		return nil, err
	}
	response := []byte{}
	switch o := output.Output.(type) {
	case *types.ConverseOutputMemberMessage:
		for _, content := range o.Value.Content {
			switch c := content.(type) {
			case *types.ContentBlockMemberDocument:
			case *types.ContentBlockMemberGuardContent:
			case *types.ContentBlockMemberImage:
			case *types.ContentBlockMemberText:
				response = append(response, []byte(c.Value)...)
			case *types.ContentBlockMemberToolResult:
			case *types.ContentBlockMemberToolUse:
			case *types.ContentBlockMemberVideo:
			default:
				return nil, errUnknownType
			}
		}
	default:
		return nil, errUnknownType
	}
	return response, nil
}

func (c *BedrockClient) converseStream(ctx context.Context, modelID string, contentText string) ([]byte, error) {
	output, err := c.runtime.ConverseStream(ctx, &bedrockruntime.ConverseStreamInput{
		ModelId:                           aws.String(modelID),
		AdditionalModelRequestFields:      nil,
		AdditionalModelResponseFieldPaths: nil,
		GuardrailConfig:                   nil,
		InferenceConfig:                   nil,
		Messages: []types.Message{
			{
				Role: types.ConversationRoleUser,
				Content: []types.ContentBlock{
					&types.ContentBlockMemberText{
						Value: contentText,
					},
				},
			},
		},
		PerformanceConfig: nil,
		PromptVariables:   nil,
		RequestMetadata:   nil,
		System:            nil,
		ToolConfig:        nil,
	})
	if err != nil {
		return nil, err
	}
	stream := output.GetStream()
	response := []byte{}
	for event := range stream.Events() {
		switch e := event.(type) {
		case *types.ConverseStreamOutputMemberContentBlockDelta:
			switch d := e.Value.Delta.(type) {
			case *types.ContentBlockDeltaMemberText:
				response = append(response, []byte(d.Value)...)
			case *types.ContentBlockDeltaMemberToolUse:
			default:
				return nil, errUnknownType
			}
		case *types.ConverseStreamOutputMemberContentBlockStart:
		case *types.ConverseStreamOutputMemberContentBlockStop:
		case *types.ConverseStreamOutputMemberMessageStart:
		case *types.ConverseStreamOutputMemberMessageStop:
		case *types.ConverseStreamOutputMemberMetadata:
		default:
			return nil, errUnknownType
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

	modelID := "arn:aws:bedrock:ap-northeast-1::foundation-model/amazon.titan-text-express-v1"
	body := `{"inputText": ""何か面白い話を100文字以内で教えてください。""}`
	contentText := "何か面白い話を100文字以内で教えてください。"

	fmt.Println("InvokeModel")
	invokeModelResponse, err := client.invokeModel(ctx, modelID, body)
	if err != nil {
		panic(err)
	}
	fmt.Println(string(invokeModelResponse))

	fmt.Println("InvokeModelWithResponseStream")
	invokeModelWithResponseStreamResponse, err := client.invokeModelWithResponseStream(ctx, modelID, body)
	if err != nil {
		panic(err)
	}
	fmt.Println(string(invokeModelWithResponseStreamResponse))

	fmt.Println("Converse")
	converseResponse, err := client.converse(ctx, modelID, contentText)
	if err != nil {
		panic(err)
	}
	fmt.Println(string(converseResponse))

	fmt.Println("ConverseStream")
	converseStreamResponse, err := client.converseStream(ctx, modelID, contentText)
	if err != nil {
		panic(err)
	}
	fmt.Println(string(converseStreamResponse))
}
