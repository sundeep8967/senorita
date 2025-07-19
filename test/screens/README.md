# Dating App Test Screens

## Available Test Screens:

### 1. Kate Profile (Dark Theme)
### 2. Yura Profile (Gradient Theme)  
### 3. Friends Nearby (Location-based)
### 4. Swinglove (Social Feed)

## How to run test screens:

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Add a sample image:**
   - Add `kate.jpg` image to the `assets/` folder
   - Or replace the AssetImage with NetworkImage for testing

3. **Run any test screen:**
   ```bash
   # Kate Profile (Dark theme with background image)
   flutter run test/screens/run_dating_profile_test.dart
   
   # Yura Profile (Gradient theme with avatars)
   flutter run test/screens/run_yura_profile_test.dart
   
   # Friends Nearby (Location-based discovery)
   flutter run test/screens/run_friends_nearby_test.dart
   
   # Swinglove (Social feed with friends and matches)
   flutter run test/screens/run_swinglove_test.dart
   ```

## What this screen demonstrates:

- **Full-screen profile layout** with background image
- **Overlay text and UI elements** on top of image
- **Modern dating app UI** with action buttons
- **Google Fonts integration** (Montserrat)
- **Responsive design** with proper positioning

## Features:
- ✅ Background image with dark overlay
- ✅ Profile name and age display
- ✅ Interest tags as chips
- ✅ Bio text with proper styling
- ✅ Action buttons (close, like, star)
- ✅ Top navigation bar
- ✅ Modern Material Design

## Notes:
- The screen is now error-free and ready to run
- Google Fonts dependency has been added to pubspec.yaml
- Assets folder is configured
- All deprecated `withOpacity` calls have been updated to `withValues`

Replace `assets/kate.jpg` with an actual image to see the full effect!