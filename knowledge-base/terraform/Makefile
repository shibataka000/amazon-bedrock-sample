.DEFAULT_GOAL := sync

.PHONY: sync
sync:
	aws s3 sync ./books s3://$(shell terraform output -raw data_source_s3_bucket_name)
	aws bedrock-agent start-ingestion-job --knowledge-base-id "$(shell terraform output -raw konowledge_base_id)" --data-source-id "$(shell terraform output -raw data_source_id)"

.PHONY: get-ingestion-job
get-ingestion-job:
	aws bedrock-agent get-ingestion-job --knowledge-base-id "$(shell terraform output -raw konowledge_base_id)" --data-source-id "$(shell terraform output -raw data_source_id)" --ingestion-job-id "ENTER_INGESTION_JOB_ID_HERE"
