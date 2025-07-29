#!/bin/bash

echo "=== Creating a new release keystore ==="
echo ""

# Keystore details
KEYSTORE_NAME="senorita-release-key.keystore"
KEY_ALIAS="senorita"
KEYSTORE_PATH="android/$KEYSTORE_NAME"

echo "📋 This will create a new keystore with the following details:"
echo "   - Keystore name: $KEYSTORE_NAME"
echo "   - Key alias: $KEY_ALIAS"
echo "   - Location: $KEYSTORE_PATH"
echo ""

# Check if keystore already exists
if [ -f "$KEYSTORE_PATH" ]; then
    echo "⚠️  Keystore already exists at: $KEYSTORE_PATH"
    echo "   If you want to create a new one, please backup or remove the existing file first."
    exit 1
fi

echo "🔐 You will be prompted to enter:"
echo "   - Keystore password (remember this!)"
echo "   - Key password (can be the same as keystore password)"
echo "   - Your details (name, organization, etc.)"
echo ""

# Generate the keystore
keytool -genkey -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS" -keyalg RSA -keysize 2048 -validity 10000

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore created successfully!"
    echo ""
    echo "📋 Now generating SHA fingerprints..."
    echo ""
    
    # Generate SHA fingerprints
    keytool -list -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS"
    
    echo ""
    echo "=== Next Steps ==="
    echo "1. Update your android/key.properties file with the correct passwords"
    echo "2. Copy the SHA-1 and SHA-256 fingerprints from above"
    echo "3. Add them to Firebase Console > Project Settings > Your Android app"
    echo "4. Download the updated google-services.json"
    echo "5. IMPORTANT: Backup your keystore file securely!"
    echo ""
    echo "⚠️  WARNING: Keep your keystore file and passwords safe!"
    echo "   If you lose them, you won't be able to update your app on Google Play Store."
else
    echo "❌ Failed to create keystore"
fi