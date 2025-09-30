# NotificationService

A singleton responsible for initializing OneSignal, handling notification events, and providing helper APIs for in-app/local notifications and user profile tagging.

## Import
```dart
import 'package:your_app/services/notification_service.dart';
```

## Getting Started
Initialize early (in `main()` before `runApp`):
```dart
await NotificationService().initialize();
```

## Public API

### constructor/factory
- `factory NotificationService()` returns the singleton instance.

### initialize
```dart
Future<void> initialize()
```
Initializes local notifications and OneSignal, registers listeners, and prepares click handling.

### setUserTags
```dart
Future<void> setUserTags(Map<String, String> tags)
```
Sets OneSignal user tags for segmentation.

### setUserEmail
```dart
Future<void> setUserEmail(String email)
```
Associates the user email with OneSignal user profile.

### setUserId
```dart
Future<void> setUserId(String userId)
```
Logs in the OneSignal user with your app user identifier.

### logout
```dart
Future<void> logout()
```
Logs out the OneSignal user.

### sendNotificationToUser
```dart
Future<void> sendNotificationToUser({
  required String userId,
  required String title,
  required String message,
  Map<String, dynamic>? additionalData,
})
```
Sends an in-app notification (local notification) targeting a specific user. In the provided codebase, this shows a local notification and logs the intent.

### sendNotificationToAll
```dart
Future<void> sendNotificationToAll({
  required String title,
  required String message,
  Map<String, dynamic>? additionalData,
})
```
Broadcasts an in-app notification to all users (local notification in this app).

### getDeviceState
```dart
Future<dynamic> getDeviceState()
```
Returns OneSignal push subscription info.

### areNotificationsEnabled
```dart
Future<bool> areNotificationsEnabled()
```
True if device has a push token; false otherwise.

### updateUserProfile
```dart
Future<void> updateUserProfile(firebase_auth.User user)
```
Sets OneSignal user id, email, and tags based on the Firebase user.

### sendWelcomeNotification
```dart
Future<void> sendWelcomeNotification(String userName)
```
Sends a personalized welcome notification.

### sendProfileUpdateNotification
```dart
Future<void> sendProfileUpdateNotification()
```
Notifies the user their profile has been updated.

### testInAppNotification
```dart
Future<void> testInAppNotification()
```
Sends a test notification to the currently authenticated user.

### sendNewImageNotification
```dart
Future<void> sendNewImageNotification(String imageName, { String? imageUrl, String? timestamp })
```
Sends a new-image alert with deep-link data for navigation.

## Notification Click Handling
When a notification is clicked, the service reads `additionalData.type` and navigates accordingly:
- `profile_update` → profile screen
- `new_image` → open full-screen image (if URL present) or gallery
- `welcome` → dashboard
- default → dashboard

## Examples

### Initialize in main
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  runApp(const MyApp());
}
```

### Update OneSignal profile after login
```dart
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  await NotificationService().updateUserProfile(user);
}
```

### Send a welcome notification
```dart
await NotificationService().sendWelcomeNotification('Ada');
```

### Send new image notification
```dart
await NotificationService().sendNewImageNotification(
  'camera_2025-09-30_12-00-00.jpg',
  imageUrl: 'https://example.com/images/camera_2025-09-30_12-00-00.jpg',
);
```