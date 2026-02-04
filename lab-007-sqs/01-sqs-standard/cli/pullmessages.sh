#!/bin/bash

# Get SQS Queue URL
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

echo "Message sent successfully!"

# Pull messages from SQS
echo ""
echo "Pulling messages from SQS queue..."

aws sqs receive-message \
    --queue-url "$QUEUE_URL" \
    --max-number-of-messages 10 \
    --wait-time-seconds 20 \
    --query 'Messages[*].[MessageId,Body]' \
    --output table

    # Extract and delete messages from queue
    read -p "Do you want to delete the messages? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        aws sqs receive-message \
            --queue-url "$QUEUE_URL" \
            --max-number-of-messages 10 \
            --wait-time-seconds 20 \
            --query 'Messages[*].[MessageId,ReceiptHandle]' \
            --output text | 
        while read MessageId ReceiptHandle; do
            if [ -n "$ReceiptHandle" ]; then
                aws sqs delete-message \
                    --queue-url "$QUEUE_URL" \
                    --receipt-handle "$ReceiptHandle"
                echo "Message $MessageId deleted successfully"
            fi
        done
    else
        echo "Messages were not deleted"
    fi


