# DashboardScreen

Main gallery screen that displays images, handles refresh, and links to profile and full-screen image viewer.

## Features
- Auto-refresh every 30 seconds
- Manual pull-to-refresh
- Grid gallery with filename and timestamp
- Open full-screen viewer on tap
- Delete images from the full-screen viewer
- Test in-app notifications via FAB

## Data Model
```dart
class GalleryImage {
  final String filename;
  final String url;
  final String timestamp;
}
```
Loaded from the API: `https://intruder.micteejay.com.ng/get_images.php`.

## Actions
- AppBar profile tap → navigates to `ProfileScreen`
- Grid item tap → opens `FullScreenImageViewGallery`
- FAB → `NotificationService().testInAppNotification()`

## Error Handling
- Network/parse failures show empty state and log details