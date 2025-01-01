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

func (c *BedrockClient) getKnowledgeBaseID(ctx context.Context, knowledgeBaseName string) (string, error) {
	output, err := c.agent.ListKnowledgeBases(ctx, &bedrockagent.ListKnowledgeBasesInput{})
	if err != nil {
		return "", err
	}
	for _, kb := range output.KnowledgeBaseSummaries {
		if *kb.Name == knowledgeBaseName {
			return *kb.KnowledgeBaseId, nil
		}
	}
	return "", errors.New("knowledge-base not found")
}

func (c *BedrockClient) retrieve(ctx context.Context, knowledgeBaseName string, query string) error {
	knowledgeBaseID, err := c.getKnowledgeBaseID(ctx, knowledgeBaseName)
	if err != nil {
		return err
	}
	output, err := c.agentrumtime.Retrieve(ctx, &bedrockagentruntime.RetrieveInput{
		KnowledgeBaseId: aws.String(knowledgeBaseID),
		RetrievalQuery: &types.KnowledgeBaseQuery{
			Text: aws.String(query),
		},
		GuardrailConfiguration: nil,
		NextToken:              nil,
		RetrievalConfiguration: nil,
	})
	if err != nil {
		return err
	}
	for i, result := range output.RetrievalResults {
		fmt.Printf("========== RetrievalResults: %d ==========\n", i)
		fmt.Println(*result.Content.Text)
		fmt.Println()
		for key, value := range result.Metadata {
			b, err := value.MarshalSmithyDocument()
			if err != nil {
				return err
			}
			fmt.Println(key, string(b))
		}
		fmt.Println()
	}
	return nil
}

func (c *BedrockClient) retrieveAndGenerate(ctx context.Context, knowledgeBaseName string, inputText string, modelARN string) error {
	knowledgeBaseID, err := c.getKnowledgeBaseID(ctx, knowledgeBaseName)
	if err != nil {
		return err
	}
	output, err := c.agentrumtime.RetrieveAndGenerate(ctx, &bedrockagentruntime.RetrieveAndGenerateInput{
		Input: &types.RetrieveAndGenerateInput{
			Text: aws.String(inputText),
		},
		RetrieveAndGenerateConfiguration: &types.RetrieveAndGenerateConfiguration{
			Type: types.RetrieveAndGenerateTypeKnowledgeBase,
			KnowledgeBaseConfiguration: &types.KnowledgeBaseRetrieveAndGenerateConfiguration{
				KnowledgeBaseId: aws.String(knowledgeBaseID),
				ModelArn:        aws.String(modelARN),
			},
		},
	})
	if err != nil {
		return err
	}
	fmt.Println("========== Output ==========")
	fmt.Println(*output.Output.Text)

	fmt.Println("========== RetrievedReferences ==========")
	for _, citation := range output.Citations {
		for i, ref := range citation.RetrievedReferences {
			for key, value := range ref.Metadata {
				b, err := value.MarshalSmithyDocument()
				if err != nil {
					return err
				}
				fmt.Printf("%d %s %s\n", i, key, string(b))
			}
			fmt.Println()
		}
	}
	return nil
}

func main() {
	ctx := context.Background()

	client, err := newBedrockClient(ctx)
	if err != nil {
		panic(err)
	}

	knowledgeBaseName := "library"
	query := "あなたは書籍「スタッフエンジニアの道」に精通した司書です。あなたは書籍「スタッフエンジニアの道」に関する質問を受け取り、書籍「スタッフエンジニアの道」の内容から質問に最も関係のある箇所を抜粋し、要約して回答します。書籍「スタッフエンジニアの道」では、大局的な思考に精通し、大きなプロジェクトを実行し、周囲をレベルアップさせるには、どのような「人間的な」スキルが必要と書かれていますか。"
	modelARN := "arn:aws:bedrock:ap-northeast-1::foundation-model/anthropic.claude-3-5-sonnet-20240620-v1:0"

	fmt.Println("Retrieve")
	if err := client.retrieve(ctx, knowledgeBaseName, query); err != nil {
		panic(err)
	}

	fmt.Println("RetrieveAndGenerate")
	if err := client.retrieveAndGenerate(ctx, knowledgeBaseName, query, modelARN); err != nil {
		panic(err)
	}
}
