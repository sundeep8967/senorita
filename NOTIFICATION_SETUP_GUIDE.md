# Push Notification Setup Guide

This guide explains the platform-specific configurations for push notifications in the Senorita app.

## Overview

The app uses **Firebase Cloud Messaging (FCM)** for push notifications, integrated with **Supabase Edge Functions** for sending notifications server-side.

## Android Configuration

### 1. AndroidManifest.xml

Located at: `android/app/src/main/AndroidManifest.xml`

#### Permissions Added:
```xml
<!-- Permissions for notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

#### FCM Configuration:
```xml
<!-- FCM default notification channel -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="senorita_channel" />

<!-- FCM default notification icon -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@mipmap/ic_launcher" />

<!-- FCM default notification color -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@android:color/holo_blue_light" />

<!-- Firebase Messaging Service -->
<service
    android:name="com.google.firebase.messaging.FirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

### 2. Notification Channel

Located at: `android/app/src/main/res/values/notification_channels.xml`

Defines the default notification channel:
- **Channel ID**: `senorita_channel`
- **Channel Name**: Senorita Notifications
- **Description**: Notifications for messages and meetup requests

### 3. Android 13+ (API 33+)

For Android 13 and above, the `POST_NOTIFICATIONS` permission is required and will be requested at runtime by the app.

## iOS Configuration

### 1. Info.plist

Located at: `ios/Runner/Info.plist`

#### Firebase Configuration:
```xml
<!-- Firebase Cloud Messaging -->
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

#### Background Modes:
```xml
<!-- Background modes for notifications -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
    <string>fetch</string>
</array>
```

#### Notification Permission:
```xml
<!-- Notification permissions -->
<key>NSUserNotificationUsageDescription</key>
<string>We need your permission to send you notifications about new messages and meetup requests.</string>
```

### 2. APNs Certificate

**Important**: For iOS notifications to work in production, you need to:

1. Create an **APNs Authentication Key** or **APNs Certificate** in Apple Developer Console
2. Upload the APNs key/certificate to Firebase Console:
   - Go to Firebase Console → Project Settings → Cloud Messaging
   - Under "Apple app configuration", upload your APNs authentication key
3. Ensure your app's Bundle ID matches the one registered in Firebase

### 3. Capabilities

In Xcode, ensure the following capabilities are enabled:
- **Push Notifications**: Enable in Signing & Capabilities
- **Background Modes**: Enable "Remote notifications"

## Firebase Configuration

### 1. FCM Server Key

The FCM Server Key is stored in `.env`:

```
FCM_SERVER_KEY=your_actual_fcm_server_key_here
```

**Note**: The current value appears to be a project number. You need the actual **Server Key**:

1. Go to Firebase Console → Project Settings → Cloud Messaging
2. Under "Cloud Messaging API (Legacy)", find your **Server key**
3. Copy and paste it into `.env` file

### 2. google-services.json (Android)

Ensure `android/app/google-services.json` is present and up-to-date from Firebase Console.

### 3. GoogleService-Info.plist (iOS)

Ensure `ios/Runner/GoogleService-Info.plist` is present and up-to-date from Firebase Console.

## Testing Notifications

### Test FCM Token Generation

1. Run the app on a physical device (notifications don't work well on simulators/emulators)
2. Check the console logs for:
   ```
   📱 Got FCM Token: [token]
   ✅ FCM token saved to user profile
   ```

### Test Notification Sending

You can test notifications using Firebase Console:

1. Go to Firebase Console → Engage → Cloud Messaging
2. Click "Send your first message"
3. Enter a title and message
4. Select your app
5. Paste the FCM token from the console logs
6. Send the test notification

### Test via App

1. **Message Notification**: Send a chat message to another user
2. **Meetup Request**: Request a meetup with another user
3. **Meetup Accepted**: Accept a meetup request

Check console logs for:
```
✅ Message notification sent successfully
✅ Meetup request notification sent successfully
✅ Meetup accepted notification sent successfully
```

## Notification Types

The app handles three types of notifications:

### 1. New Message (`new_message`)
- **Trigger**: When a user sends a chat message
- **Data**: `chatRoomId`, `senderName`, `senderId`, `messageContent`
- **Action**: Opens chat screen with sender

### 2. Meetup Request (`meetup_request`)
- **Trigger**: When a user requests a meetup
- **Data**: `meetupId`, `requesterName`, `requesterId`
- **Action**: Opens meetup details (to be implemented)

### 3. Meetup Accepted (`meetup_accepted`)
- **Trigger**: When a meetup request is accepted
- **Data**: `meetupId`, `chatRoomId`, `accepterName`, `accepterId`
- **Action**: Opens chat screen with accepter

## Troubleshooting

### Android Issues

1. **Notifications not appearing**:
   - Check if notification permission is granted (Android 13+)
   - Verify `google-services.json` is present
   - Check if app is in battery optimization exclusion list

2. **Background notifications not working**:
   - Ensure background message handler is registered
   - Check device battery saver settings

### iOS Issues

1. **Notifications not appearing**:
   - Verify APNs certificate is uploaded to Firebase
   - Check if notification permission is granted
   - Ensure app's Bundle ID matches Firebase configuration

2. **Background notifications not working**:
   - Verify Background Modes capability is enabled
   - Check that "Remote notifications" is checked in Background Modes

3. **Development vs Production**:
   - Development builds use APNs Sandbox environment
   - Production builds use APNs Production environment
   - Make sure to upload both certificates if using certificate-based auth

### Common Issues

1. **FCM token is null**:
   - Restart the app
   - Check internet connection
   - Verify Firebase configuration files are present

2. **Notifications not sending from Supabase**:
   - Check Supabase Edge Functions are deployed
   - Verify FCM_SERVER_KEY environment variable is set in Supabase
   - Check Edge Function logs in Supabase Dashboard

3. **User not receiving notifications**:
   - Verify user has FCM token saved in Firestore
   - Check user's notification preferences
   - Ensure user is not in Do Not Disturb mode

## Production Checklist

Before releasing to production:

- [ ] Upload APNs certificate to Firebase Console (iOS)
- [ ] Update FCM_SERVER_KEY in `.env` with actual server key
- [ ] Deploy Supabase Edge Functions with correct environment variables
- [ ] Test notifications on physical devices (both Android and iOS)
- [ ] Test all notification types (message, meetup request, meetup accepted)
- [ ] Test foreground, background, and terminated state notifications
- [ ] Verify notification navigation works correctly
- [ ] Test notification permissions on Android 13+
- [ ] Ensure notification icons and colors are correct
- [ ] Test on multiple Android versions (8.0+) and iOS versions (13.0+)

## Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging Plugin](https://pub.dev/packages/firebase_messaging)
- [APNs Documentation](https://developer.apple.com/documentation/usernotifications)
- [Android Notification Channels](https://developer.android.com/develop/ui/views/notifications/channels)
