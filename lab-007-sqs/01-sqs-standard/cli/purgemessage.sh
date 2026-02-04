#!/bin/bash

# Get available SQS queues
QUEUES=$(aws sqs list-queues --query 'QueueUrls[]' --output text)

if [ -z "$QUEUES" ]; then
    echo "Error: No SQS queues found"
    exit 1
fi

# Display available queues
echo "Select SQS Queues:"
select QUEUE_URL in $QUEUES; do
    if [ -n "$QUEUE_URL" ]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

echo "Selected Queue URL: $QUEUE_URL"
echo "Purging all messages from queue..."

# Purge all messages from SQS queue
aws sqs purge-queue --queue-url "$QUEUE_URL"

if [ $? -eq 0 ]; then
    echo "Queue purged successfully!"
else
    echo "Error: Failed to purge queue"
    exit 1
fi
