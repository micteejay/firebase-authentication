# ImageNavigationService

A singleton providing convenience helpers for opening images or galleries in the app's full-screen image viewer.

## Import
```dart
import 'package:your_app/services/image_navigation_service.dart';
```

## Getting Started
Ensure your app uses the global `NavigationService().navigatorKey` as shown in its docs.

## Public API

### constructor/factory
- `factory ImageNavigationService()` returns the singleton instance.

### openImageInFullScreen
```dart
void openImageInFullScreen({
  required String imageUrl,
  required String filename,
  required String timestamp,
})
```
Packages a single `GalleryImage` and opens the full-screen viewer at index 0.

### openImageGalleryWithSelection
```dart
void openImageGalleryWithSelection({
  required List<GalleryImage> allImages,
  required int selectedIndex,
})
```
Opens the full-screen viewer with the provided list and selection.

## Examples

### Open a downloaded image
```dart
ImageNavigationService().openImageInFullScreen(
  imageUrl: 'https://example.com/images/cam1.jpg',
  filename: 'cam1.jpg',
  timestamp: DateTime.now().toIso8601String(),
);
```

### Open an existing gallery and focus a specific image
```dart
final images = [
  GalleryImage(filename: 'a.jpg', url: 'https://example.com/a.jpg', timestamp: '...'),
  GalleryImage(filename: 'b.jpg', url: 'https://example.com/b.jpg', timestamp: '...'),
];
ImageNavigationService().openImageGalleryWithSelection(
  allImages: images,
  selectedIndex: 1,
);
```