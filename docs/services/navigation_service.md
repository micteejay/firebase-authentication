# NavigationService

A singleton that exposes a global `navigatorKey` and high-level navigation helpers used by notifications and image navigation.

## Import
```dart
import 'package:your_app/services/navigation_service.dart';
```

## Getting Started
Provide the `navigatorKey` to `MaterialApp`:
```dart
MaterialApp(
  navigatorKey: NavigationService().navigatorKey,
  // ...
)
```

## Public API

### constructor/factory
- `factory NavigationService()` returns the singleton instance.

### navigatorKey
```dart
final GlobalKey<NavigatorState> navigatorKey
```
Attach to your `MaterialApp` to enable global navigation.

### navigateToProfile
```dart
void navigateToProfile()
```
Pushes the `ProfileScreen` onto the stack.

### navigateToDashboard
```dart
void navigateToDashboard()
```
Pops to root and navigates to dashboard (home route).

### navigateToGallery
```dart
void navigateToGallery()
```
Alias to `navigateToDashboard` in this codebase.

### navigateToFullScreenImage
```dart
void navigateToFullScreenImage(List<GalleryImage> images, int initialIndex)
```
Pushes the full-screen image gallery starting at `initialIndex`.

### handleNotificationNavigation
```dart
void handleNotificationNavigation(String type)
```
Routes based on a simple `type` string.

## Examples

### Set up in `main.dart`
```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService().navigatorKey,
      home: const DashboardScreen(),
    );
  }
}
```

### Navigate from anywhere
```dart
NavigationService().navigateToProfile();
```

### Open an image in full screen
```dart
final images = [
  GalleryImage(filename: 'img.jpg', url: 'https://example.com/img.jpg', timestamp: '2025-09-30'),
];
NavigationService().navigateToFullScreenImage(images, 0);
```