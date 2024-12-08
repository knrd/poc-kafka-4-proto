FROM bitnami/kafka:latest

# Copy certificates with dynamic ownership
COPY --chown=1001:1001 certs/ /bitnami/kafka/config/certs/

# Ensure correct permissions for the files
#RUN chmod -R 640 /bitnami/kafka/config/certs

#USER ${USER_ID}

# Kafka environment variables
ENV KAFKA_CFG_NODE_ID=0
# Set process roles to both broker and controller
ENV KAFKA_CFG_PROCESS_ROLES=broker,controller
# Update the controller quorum with the node id
ENV KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@localhost:9093
# Define the listener for the controller
ENV KAFKA_CFG_CONTROLLER_LISTENER_NAMES=SSL

# Include SASL_PLAINTEXT listener
ENV KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,SSL://:9093,SASL_SSL://:9094,SASL_PLAINTEXT://:9095
ENV KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092,SSL://localhost:9093,SASL_SSL://localhost:9094,SASL_PLAINTEXT://localhost:9095

# Map listener names to security protocols
ENV KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_SSL:SASL_SSL,SASL_PLAINTEXT:SASL_PLAINTEXT

# Updated paths to JKS files
# experiment with PEM
# https://github.com/bitnami/containers/blob/791984b3145338a1e1e2e5b3684b86c6391f523a/bitnami/kafka/3.6/debian-12/rootfs/opt/bitnami/scripts/libkafka.sh#L454
ENV KAFKA_TLS_TYPE=JKS
ENV KAFKA_CFG_SSL_KEYSTORE_PASSWORD=test123
ENV KAFKA_CLIENT_USERS=user
ENV KAFKA_CLIENT_PASSWORDS=password
ENV KAFKA_CLIENT_LISTENER_NAME=SASL_SSL
ENV KAFKA_CERTIFICATE_PASSWORD=test123
ENV KAFKA_CFG_SSL_TRUSTSTORE_PASSWORD=test123

ENV KAFKA_CONTROLLER_USER=controller_user
ENV KAFKA_CONTROLLER_PASSWORD=controller_password

# SASL configurations
ENV KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN
ENV KAFKA_CFG_SASL_ENABLED_MECHANISMS=PLAIN
ENV KAFKA_CFG_SECURITY_INTER_BROKER_PROTOCOL=SASL_SSL

# The ALLOW_PLAINTEXT_LISTENER=no prevents accidental plaintext exposure, but since we explicitly use PLAINTEXT here, this should be adjusted
ENV ALLOW_PLAINTEXT_LISTENER=yes

# Expose ports for each listener
EXPOSE 9092 9093 9094 9095

CMD ["/opt/bitnami/scripts/kafka/run.sh"]

