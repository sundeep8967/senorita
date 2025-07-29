#!/bin/bash

echo "=== Generating SHA fingerprints for release keystore ==="
echo ""

# Check if keystore file exists
KEYSTORE_PATH="android/senorita-release-key.keystore"
if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "❌ Keystore file not found at: $KEYSTORE_PATH"
    echo ""
    echo "Please ensure your keystore file is in the correct location or update the path."
    exit 1
fi

echo "📋 Keystore file found: $KEYSTORE_PATH"
echo ""

# Read keystore properties
KEY_ALIAS=$(grep "keyAlias=" android/key.properties | cut -d'=' -f2)
echo "🔑 Key alias: $KEY_ALIAS"
echo ""

echo "Generating SHA-1 and SHA-256 fingerprints..."
echo "You will be prompted for your keystore password."
echo ""

# Generate SHA-1 and SHA-256 fingerprints
keytool -list -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS"

echo ""
echo "=== Instructions ==="
echo "1. Copy the SHA-1 and SHA-256 fingerprints from the output above"
echo "2. Add them to your Firebase project console:"
echo "   - Go to Project Settings > General > Your apps"
echo "   - Click on your Android app"
echo "   - Add the SHA fingerprints in the 'SHA certificate fingerprints' section"
echo "3. Download the updated google-services.json file"
echo "4. Replace the existing google-services.json in android/app/"