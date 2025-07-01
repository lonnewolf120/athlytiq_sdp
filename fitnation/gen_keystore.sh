#!/bin/bash

# Variables (customize these as needed)
KEYSTORE_FILE="athlytiq.jks"
ALIAS="athlytiq"
KEYPASS="ac123321ca"
STOREPASS="ac123321ca"
DAYS_VALID=10000
DNAME="CN=Semaphore, OU=Semaphore, O=Semaphore, L=Dhaka, S=Dhaka, C=Bangladesh"

# Generate the keystore
keytool -genkeypair -v \
  -keystore $KEYSTORE_FILE \
  -alias $ALIAS \
  -keyalg RSA \
  -keysize 2048 \
  -validity $DAYS_VALID \
  -keypass $KEYPASS \
  -storepass $STOREPASS \
  -dname "$DNAME"

# Verify the keystore
keytool -list -v -keystore $KEYSTORE_FILE -storepass $STOREPASS 