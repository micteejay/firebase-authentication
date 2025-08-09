# Intruder Cam App 📸

A Flutter-based security camera monitoring application that allows users to view and manage security camera images with real-time notifications.

## 🚀 Features

### 🔐 Authentication
- **Firebase Authentication** integration
- Email/password login and signup
- Google Sign-In support
- Secure user profile management
- Biometric authentication support

### 📱 Core Features
- **Real-time Image Gallery**: View security camera images in a grid layout
- **Full-Screen Image Viewer**: Zoom, pan, and interact with images
- **Image Management**: Delete images directly from the app
- **Auto-refresh**: Images automatically refresh every 30 seconds
- **Pull-to-refresh**: Manual refresh functionality

### 🔔 Push Notifications
- **OneSignal Integration** for push notifications
- **In-App Notifications** using Flutter Local Notifications
- **Smart Navigation**: Click notifications to open specific images in full-screen
- **Notification Types**:
  - Welcome notifications
  - Profile update confirmations
  - New image alerts
  - Test notifications

### 🎨 User Interface
- **Modern Design**: Gradient backgrounds with red and purple theme
- **Responsive Layout**: Works on various screen sizes
- **Custom App Logo**: Camera-themed branding throughout the app
- **Smooth Animations**: Enhanced user experience

## 📋 Prerequisites

Before running this app, make sure you have:

- **Flutter SDK** (version 3.0 or higher)
- **Dart SDK** (version 2.17 or higher)
- **Android Studio** or **VS Code**
- **Firebase Project** with Authentication enabled
- **OneSignal Account** for push notifications

## 🛠️ Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd firebase-authentication
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication with Email/Password and Google Sign-In
4. Download `google-services.json` and place it in `android/app/`

#### Configure Firebase
1. Add your Firebase configuration to the project
2. Enable Cloud Firestore (if needed for future features)

### 4. OneSignal Setup

#### Create OneSignal App
1. Go to [OneSignal Dashboard](https://app.onesignal.com/)
2. Create a new app
3. Get your App ID and API Key
4. Update the OneSignal configuration in `lib/services/notification_service.dart`

#### Update OneSignal Configuration
```dart
// In lib/services/notification_service.dart
static const String _appId = 'YOUR_ONESIGNAL_APP_ID';
static const String _apiKey = 'YOUR_ONESIGNAL_API_KEY';
```

### 5. API Configuration

#### Update Image API Endpoint
Update the image fetching URL in `lib/screens/dashboard_screen.dart`:
```dart
final response = await http.get(
  Uri.parse('YOUR_IMAGE_API_ENDPOINT'),
);
```

## 🏃‍♂️ Running the App

### Development Mode
```bash
flutter run
```

### Build APK
```bash
flutter build apk
```

### Build App Bundle (for Play Store)
```bash
flutter build appbundle
```

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   ├── start_screen.dart     # Welcome/landing screen
│   ├── auth_screen.dart      # Login/signup screen
│   ├── dashboard_screen.dart # Main gallery screen
│   ├── profile_screen.dart   # User profile management
│   └── splash_screen.dart    # Loading screen
├── services/
│   ├── notification_service.dart    # OneSignal & local notifications
│   ├── navigation_service.dart      # Global navigation
│   └── image_navigation_service.dart # Image navigation
└── widgets/
    └── auth/
        └── auth_form.dart    # Authentication form
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:
```env
FIREBASE_PROJECT_ID=your_project_id
ONESIGNAL_APP_ID=your_onesignal_app_id
ONESIGNAL_API_KEY=your_onesignal_api_key
IMAGE_API_ENDPOINT=your_image_api_endpoint
```

### App Branding
- **App Name**: "Intruder Cam App"
- **Package Name**: `com.example.authentifaction_app`
- **Version**: 1.0.0+1

## 📊 Dependencies

### Core Dependencies
- `flutter`: ^3.0.0
- `firebase_core`: any
- `firebase_auth`: any
- `cloud_firestore`: ^5.6.9
- `onesignal_flutter`: ^5.1.2
- `flutter_local_notifications`: ^16.3.2
- `http`: ^1.2.1
- `image_picker`: ^1.0.7

### UI Dependencies
- `animated_text_kit`: ^4.2.1
- `device_preview`: ^1.2.0
- `cupertino_icons`: ^1.0.2

### Authentication Dependencies
- `local_auth`: ^2.1.7
- `flutter_secure_storage`: ^9.0.0
- `google_sign_in`: ^6.1.5

## 🔔 Notification System

### OneSignal Push Notifications
- **App-to-User**: Send notifications to specific users
- **Broadcast**: Send notifications to all users
- **Rich Notifications**: Include custom data for navigation

### Local Notifications
- **In-App Alerts**: Show notifications while using the app
- **Test Notifications**: Built-in testing functionality
- **Custom Channels**: Android notification channels

### Notification Types
1. **Welcome**: Sent when user first logs in
2. **Profile Update**: Confirms successful profile changes
3. **New Image**: Alerts when new security images are available
4. **Test**: For testing notification functionality

## 🎯 Usage

### Getting Started
1. Launch the app
2. Sign up or log in with your credentials
3. Grant notification permissions when prompted
4. View your security camera images in the gallery

### Using the Gallery
- **View Images**: Tap any image to open in full-screen
- **Navigate**: Swipe left/right to browse images
- **Delete**: Use the delete button in full-screen view
- **Refresh**: Pull down to refresh the gallery

### Testing Notifications
- Tap the notification bell icon (floating action button)
- Check your device's notification panel
- Verify in-app notifications appear

### Profile Management
- Tap your profile picture in the dashboard
- Edit your display name and email
- Update your profile picture
- Change your password

## 🔒 Security Features

- **Firebase Authentication**: Secure user authentication
- **Biometric Support**: Fingerprint/face recognition
- **Secure Storage**: Encrypted local data storage
- **HTTPS API**: Secure image fetching

## 🐛 Troubleshooting

### Common Issues

#### Notifications Not Working
1. Check OneSignal configuration
2. Verify notification permissions
3. Test with the built-in test button
4. Check device notification settings

#### Images Not Loading
1. Verify API endpoint is accessible
2. Check network connectivity
3. Review API response format
4. Check console logs for errors

#### Authentication Issues
1. Verify Firebase configuration
2. Check Google Sign-In setup
3. Ensure proper SHA-1 fingerprints
4. Review Firebase console logs

### Debug Mode
Enable debug logging:
```dart
// In lib/services/notification_service.dart
OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
```

## 📈 Future Enhancements

- [ ] **Real-time Updates**: WebSocket integration for live image updates
- [ ] **Image Upload**: Allow users to upload images
- [ ] **Video Support**: Add video playback functionality
- [ ] **Motion Detection**: AI-powered motion detection alerts
- [ ] **Multi-camera Support**: Manage multiple camera feeds
- [ ] **Cloud Storage**: Firebase Storage integration
- [ ] **Offline Mode**: Cache images for offline viewing
- [ ] **Analytics**: User behavior tracking
- [ ] **Dark Mode**: Theme customization
- [ ] **Multi-language**: Internationalization support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- **Email**: [your-email@example.com]
- **Issues**: [GitHub Issues](https://github.com/your-username/firebase-authentication/issues)
- **Documentation**: [Project Wiki](https://github.com/your-username/firebase-authentication/wiki)

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Firebase** for authentication and backend services
- **OneSignal** for push notification services
- **Flutter Community** for excellent packages

---

**Made with ❤️ using Flutter**