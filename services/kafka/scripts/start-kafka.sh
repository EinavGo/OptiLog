#!/bin/bash

# Start Zookeeper
zookeeper-server-start /etc/kafka/zookeeper.properties &

# Wait for Zookeeper to be ready
sleep 10

# Start Kafka
kafka-server-start /etc/kafka/server.properties