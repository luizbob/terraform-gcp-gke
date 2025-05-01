#!/bin/bash

# Variables
RABBITMQ_USER="admin"
# RABBITMQ_PASSWORD=$(gcloud secrets versions access latest --secret="rabbitmq-password")
RABBITMQ_PASSWORD="adminPassword" #THIS CONFIG IS ONLY AS EXAMPLE AND SHOULD NOT BE USED ON PRODUCTION ENVIRONMENTS 
RABBITMQ_NAMESPACE="rabbitmq"
RABBITMQ_SERVICE="rabbitmq"
RABBITMQ_PORT="5672"

# Set up port forwarding
echo "Setting up port forwarding for RabbitMQ..."
kubectl port-forward -n ${RABBITMQ_NAMESPACE} svc/${RABBITMQ_SERVICE} ${RABBITMQ_PORT}:${RABBITMQ_PORT} &
PF_PID=$!

# Wait for port forwarding to establish
sleep 5

# Test RabbitMQ connectivity
echo "Testing RabbitMQ connectivity..."
if command -v amqp-declare-queue &> /dev/null; then
    if amqp-declare-queue --url="amqp://${RABBITMQ_USER}:${RABBITMQ_PASSWORD}@localhost:${RABBITMQ_PORT}" -q "test-queue"; then
        echo "RabbitMQ validation successful!"
    else
        echo "RabbitMQ validation failed!"
    fi
else
    echo "amqp-tools not found. Installing..."
    sudo apt-get update && sudo apt-get install -y amqp-tools
    
    if amqp-declare-queue --url="amqp://${RABBITMQ_USER}:${RABBITMQ_PASSWORD}@localhost:${RABBITMQ_PORT}" -q "test-queue"; then
        echo "RabbitMQ validation successful!"
    else
        echo "RabbitMQ validation failed!"
    fi
fi

# Clean up
kill $PF_PID