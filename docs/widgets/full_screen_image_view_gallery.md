# FullScreenImageViewGallery

A stateful viewer for swiping through `GalleryImage` items in full screen with zoom and delete support.

## Import
```dart
// The widget is defined in the same file as DashboardScreen in this codebase.
import 'package:your_app/screens/dashboard_screen.dart';
```

## Constructor
```dart
const FullScreenImageViewGallery({
  Key? key,
  required List<GalleryImage> images,
  required int initialIndex,
})
```
- `images`: list of gallery items to view
- `initialIndex`: which image to display first

## Behavior
- PageView for left/right navigation
- `InteractiveViewer` for pinch-zoom
- Delete button posts to `https://intruder.micteejay.com.ng/delete.php` and removes image locally on success
- Close button returns to previous screen. Returns `true` if a deletion occurred to allow the caller to refresh.

## Example
```dart
final deleted = await Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => FullScreenImageViewGallery(
      images: images,
      initialIndex: 0,
    ),
  ),
);
if (deleted == true) {
  // reload images
}
```