FROM confluentinc/cp-kafka:7.4.0

# Copy configurations
COPY config/server.properties /etc/kafka/server.properties
COPY scripts/start-kafka.sh /usr/bin/start-kafka.sh

# Make the startup script executable
RUN chmod +x /usr/bin/start-kafka.sh

# Expose the ports for Kafka and Zookeeper
EXPOSE 9092 2181

# Set the default command to the startup script
CMD ["/usr/bin/start-kafka.sh"]