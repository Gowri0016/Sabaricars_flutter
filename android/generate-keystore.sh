#!/bin/bash
# Keystore Generation Script for Sabari Cars Android App
# This script helps generate a secure digital signing key for Google Play Store submission
#
# Prerequisites:
# - Java Development Kit (JDK) must be installed
# - keytool should be available in your PATH (comes with JDK)
#
# Usage: Run this script from the android/ directory
# Example: cd android && bash generate-keystore.sh

set -e

echo ""
echo "========================================"
echo "Sabari Cars - Keystore Generation"
echo "========================================"
echo ""

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo "ERROR: keytool not found. Please ensure Java Development Kit (JDK) is installed."
    echo "Download JDK from: https://www.oracle.com/java/technologies/downloads/"
    exit 1
fi

# Create keystore directory if it doesn't exist
mkdir -p keystore
echo "Using keystore directory: keystore/"

# Generate keystore
echo ""
echo "Generating keystore file..."
echo "Please provide the following information when prompted:"
echo ""

keytool -genkey -v -keystore keystore/sabaricars.jks \
    -keyalg RSA -keysize 2048 -validity 10950 \
    -alias sabaricars_key

echo ""
echo "========================================"
echo "Keystore generated successfully!"
echo "========================================"
echo ""
echo "Location: android/keystore/sabaricars.jks"
echo ""
echo "IMPORTANT SECURITY REMINDERS:"
echo "1. Store the keystore file securely - do NOT share it publicly"
echo "2. Remember the passwords you entered - you'll need them for releases"
echo "3. DO NOT commit key.properties to version control"
echo "4. The .gitignore already protects sensitive files"
echo "5. Keep backups of your keystore in a secure location"
echo ""
echo "Next steps:"
echo "1. Update android/key.properties with your passwords"
echo "2. Run: flutter build apk --release  (for APK)"
echo "   or: flutter build appbundle --release  (for Play Store)"
echo ""
