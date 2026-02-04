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

echo "Digite a mensagem para enviar para a fila SQS:"
read MESSAGE_BODY
    
# Send message to SQS
aws sqs send-message \
    --queue-url "$QUEUE_URL" \
    --message-body "$MESSAGE_BODY"
echo "Message sent successfully!"

if [ -z "$QUEUE_URL" ]; then
    echo "Error: Could not retrieve SQS Queue URL"
    exit 1
fi

echo "Queue URL: $QUEUE_URL"

# Send message to SQS
aws sqs send-message \
    --queue-url "$QUEUE_URL" \
    --message-body "Hello from SQS Lab"

echo "Message sent successfully!"