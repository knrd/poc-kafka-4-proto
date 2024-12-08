#!/bin/bash

# Create a directory for certificates
mkdir -p certs
cd certs

# Create CA key and certificate
openssl req -new -x509 -keyout ca.key -out ca.crt -days 365 -subj "/CN=Test-CA" -nodes

# Create Kafka broker key and CSR
openssl req -new -keyout kafka.truststore.key -out kafka.truststore.csr -subj "/CN=localhost" -nodes

# Sign Kafka broker certificate with the CA
openssl x509 -req -in kafka.truststore.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kafka.truststore.crt -days 365

# Combine broker certificate and private key
cat kafka.truststore.crt kafka.truststore.key > kafka.truststore.pem

# Cleanup
rm kafka.truststore.csr

# Step 1: Create a PKCS12 file from the key and certificate (password is "test123" here)
openssl pkcs12 -export \
    -in kafka.truststore.pem \
    -inkey kafka.truststore.key \
    -out kafka.keystore.p12 \
    -name kafka-broker \
    -password pass:test123
# Step 2: Import the PKCS12 file into a JKS keystore
keytool -importkeystore \
    -deststorepass test123 \
    -destkeypass test123 \
    -destkeystore kafka.keystore.jks \
    -srckeystore kafka.keystore.p12 \
    -srcstoretype PKCS12 \
    -srcstorepass test123 \
    -alias kafka-broker
# Step 3: Import the CA certificate into the JKS truststore
keytool -importcert \
    -file ca.crt \
    -keystore kafka.truststore.jks \
    -storepass test123 \
    -noprompt

