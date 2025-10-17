# Notification Testing Guide

This guide explains how to test the notification system in the Senorita app.

## Test Screen

A dedicated test screen has been created at:
`lib/screens/tmp_rovodev_notification_test_screen.dart`

This screen provides a UI to test all notification types without needing multiple devices.

## How to Access the Test Screen

### Option 1: Add Temporary Navigation Button

Add this code to any screen where you want quick access (e.g., `HomeScreen` or `ProfileDisplayScreen`):

```dart
// Add this import at the top
import 'package:senorita/screens/tmp_rovodev_notification_test_screen.dart';

// Add this button somewhere in your widget tree
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationTestScreen(),
      ),
    );
  },
  child: const Text('Test Notifications'),
),
```

### Option 2: Add to Debug Menu

If you have a debug/settings screen, add navigation to `NotificationTestScreen`.

### Option 3: Direct Navigation from Console

You can also navigate programmatically during development.

## What the Test Screen Does

The test screen provides the following functionality:

### 1. **Status Display**
- Shows current user information
- Displays FCM token status
- Shows available test users with FCM tokens

### 2. **Test Notification Buttons**

#### 💬 Test Message Notification
- Sends a test chat message notification
- Uses the first available test user as recipient
- Tests the `notify-message` Edge Function

#### ☕ Test Meetup Request
- Sends a test meetup request notification
- Tests the `notify-meetup-request` Edge Function

#### 🎉 Test Meetup Accepted
- Sends a test meetup acceptance notification
- Tests the `notify-meetup-accepted` Edge Function

#### 🔔 Test Custom Notification
- Sends a custom notification with custom title/body
- Tests the `send-notification` Edge Function

### 3. **Utility Functions**

#### 🔍 Check Permissions
- Verifies notification permissions on the device
- Tells you if notifications are enabled or disabled

#### 🔄 Refresh FCM Token
- Requests a new FCM token from Firebase
- Updates the token in Firestore

#### 📋 Reload Test Users
- Refreshes the list of available test users
- Useful if new users have been added

## Testing Requirements

### Prerequisites

1. **Two User Accounts**: 
   - You need at least 2 user accounts with completed onboarding
   - Both users should have FCM tokens registered

2. **Physical Devices**:
   - Notifications work best on physical devices
   - Emulators/simulators have limited notification support

3. **Internet Connection**:
   - Active internet connection required
   - Both devices should have good connectivity

4. **Supabase Edge Functions**:
   - All Edge Functions must be deployed
   - FCM_SERVER_KEY must be set in Supabase environment variables

### Testing Flow

1. **Device A (Sender)**:
   - Login with User A
   - Open the Notification Test Screen
   - Click any test notification button

2. **Device B (Receiver)**:
   - Login with User B (who has FCM token)
   - Keep app open OR put it in background
   - Wait for notification to arrive

3. **Expected Behavior**:
   - **Foreground**: SnackBar appears with notification
   - **Background**: System notification appears in notification tray
   - **Terminated**: System notification appears, opens app when tapped

## Verification Steps

### Step 1: Check FCM Token
```
1. Open test screen
2. Verify status shows "FCM Token: Present"
3. If missing, click "Refresh FCM Token"
```

### Step 2: Check Permissions
```
1. Click "Check Permissions"
2. Should show "✅ Notifications are enabled"
3. If not, enable in device settings
```

### Step 3: Test Message Notification
```
1. Click "Test Message Notification"
2. Check console logs for success message
3. Receiver device should get notification
4. Tap notification to verify navigation to chat screen
```

### Step 4: Test Meetup Notifications
```
1. Click "Test Meetup Request" or "Test Meetup Accepted"
2. Check console logs for success
3. Receiver should get appropriate notification
```

### Step 5: Test Custom Notification
```
1. Click "Test Custom Notification"
2. Verify notification with custom title/body
3. Check that notification data is passed correctly
```

## Console Logs to Watch For

### Success Indicators
```
✅ Message notification sent successfully
✅ Meetup request notification sent successfully
✅ Meetup accepted notification sent successfully
📱 Got FCM Token: [token]
🔔 Foreground message received!
```

### Error Indicators
```
❌ Failed to send notification
⚠️ Receiver does not have FCM token
❌ Failed to get auth token
⚠️ No test users available with FCM tokens
```

## Common Test Issues

### Issue 1: "No test users available"
**Solution**: 
- Ensure other users have completed onboarding
- Verify other users have FCM tokens saved
- Click "Reload Test Users"

### Issue 2: "Notification sent but not received"
**Possible Causes**:
- Receiver doesn't have FCM token
- FCM_SERVER_KEY is incorrect in Supabase
- Notification permissions denied on receiver device
- Receiver app is force-stopped (Android)

**Solutions**:
- Check receiver's FCM token in Firestore
- Verify FCM_SERVER_KEY in Supabase Dashboard
- Check notification permissions on receiver device
- Restart receiver app

### Issue 3: "Notifications work in foreground but not background"
**Possible Causes**:
- Background message handler not registered
- App in battery optimization (Android)
- Background app refresh disabled (iOS)

**Solutions**:
- Verify background handler in main.dart
- Exclude app from battery optimization
- Enable background app refresh in iOS settings

### Issue 4: "Navigation not working on notification tap"
**Possible Causes**:
- Navigator key not initialized
- Context not available
- Missing required data in notification payload

**Solutions**:
- Verify navigatorKey is set in MaterialApp
- Check notification data includes all required fields
- Review console logs for navigation errors

## Testing Checklist

Before marking notifications as complete:

- [ ] FCM token is saved to Firestore on login
- [ ] All test notification types send successfully
- [ ] Notifications appear in foreground (SnackBar)
- [ ] Notifications appear in background (system tray)
- [ ] Notifications appear when app is terminated
- [ ] Tapping notification navigates correctly
- [ ] Message notifications open correct chat
- [ ] Meetup accepted notifications open correct chat
- [ ] Custom notifications work as expected
- [ ] Tested on Android device
- [ ] Tested on iOS device
- [ ] Console logs show no errors
- [ ] Edge Functions are working correctly

## After Testing

### Cleanup

Once testing is complete:

1. **Remove Test Screen Navigation**:
   - Remove any temporary buttons added to access test screen
   
2. **Keep Test Screen for Development**:
   - The test screen can remain in the codebase for future testing
   - It's prefixed with `tmp_rovodev_` for easy identification

3. **Remove Test Screen (Optional)**:
   ```bash
   # If you want to remove it completely
   rm lib/screens/tmp_rovodev_notification_test_screen.dart
   ```

## Production Notes

**Important**: The test screen is for development/testing only.

Before releasing to production:
- Remove any test navigation buttons from user-facing screens
- Consider adding the test screen to a hidden debug menu
- Or remove the test screen entirely

## Need Help?

If you encounter issues:

1. Check console logs for detailed error messages
2. Verify Supabase Edge Function logs
3. Test FCM directly using Firebase Console
4. Ensure all environment variables are set correctly
5. Review the NOTIFICATION_SETUP_GUIDE.md for configuration issues
