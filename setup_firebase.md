# Firebase Setup Instructions for Senorita Dating App

## Project Details
- **Project ID**: `senorita-dating-app`
- **Package Name (Android)**: `com.sundeep.senorita`
- **Bundle ID (iOS)**: `com.sundeep.senorita`

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `Senorita Dating App`
4. Project ID will be: `senorita-dating-app`
5. Enable Google Analytics (recommended)
6. Click "Create project"

## Step 2: Add Android App

1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.sundeep.senorita`
3. Enter app nickname: `Senorita Android`
4. Download `google-services.json`
5. Replace the placeholder file at `android/app/google-services.json`

## Step 3: Add iOS App

1. In Firebase Console, click "Add app" → iOS
2. Enter bundle ID: `com.sundeep.senorita`
3. Enter app nickname: `Senorita iOS`
4. Download `GoogleService-Info.plist`
5. Replace the placeholder file at `ios/Runner/GoogleService-Info.plist`
6. Add the file to Xcode project (drag and drop into Runner folder)

## Step 4: Enable Firebase Services

### Authentication
1. Go to Authentication → Sign-in method
2. Enable the following providers:
   - Phone
   - Google
   - Email/Password (optional)

### Firestore Database
1. Go to Firestore Database
2. Click "Create database"
3. Start in test mode (for development)
4. Choose a location (preferably close to your users)

### Storage
1. Go to Storage
2. Click "Get started"
3. Start in test mode
4. Choose same location as Firestore

### Cloud Messaging
1. Go to Cloud Messaging
2. No additional setup required (already configured)

## Step 5: Update Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Profiles are readable by authenticated users
    match /profiles/{profileId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == profileId;
    }
    
    // Matches are readable by participants
    match /matches/{matchId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    // Chats are accessible by participants
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    // Messages within chats
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat images
    match /chat_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Verification images
    match /verification_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 6: Configure Google Sign-In

1. In Firebase Console → Authentication → Sign-in method → Google
2. Enable Google sign-in
3. Add your SHA-1 fingerprint for Android:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
4. Add the SHA-1 to Firebase project settings

## Step 7: Test the Integration

Run the following commands to test:

```bash
flutter clean
flutter pub get
flutter run
```

## Important Notes

- The current configuration files are placeholders with dummy data
- Replace them with actual files from Firebase Console
- Update the `firebase_options.dart` file with real configuration values
- Enable billing in Firebase Console for production use
- Set up proper security rules before going live

## Firestore Collections Structure

The app will create these collections:
- `users` - User authentication data
- `profiles` - User profile information
- `matches` - Match data between users
- `chats` - Chat room information
- `messages` - Chat messages (subcollection of chats)
- `payments` - Payment transaction records

## Next Steps

1. Replace placeholder configuration files
2. Test authentication flow
3. Test Firestore operations
4. Test file uploads to Storage
5. Test push notifications
6. Set up proper security rules
7. Configure analytics and crashlytics (optional)