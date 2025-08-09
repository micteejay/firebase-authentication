import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import 'navigation_service.dart';

class ImageNavigationService {
  static final ImageNavigationService _instance = ImageNavigationService._internal();
  factory ImageNavigationService() => _instance;
  ImageNavigationService._internal();

  // Open a single image in full screen
  void openImageInFullScreen({
    required String imageUrl,
    required String filename,
    required String timestamp,
  }) {
    // Create a single image for the full screen viewer
    final singleImage = GalleryImage(
      filename: filename,
      url: imageUrl,
      timestamp: timestamp,
    );

    // Navigate to the full screen viewer with just this image
    NavigationService().navigateToFullScreenImage([singleImage], 0);
  }

  // Open image gallery with a specific image selected
  void openImageGalleryWithSelection({
    required List<GalleryImage> allImages,
    required int selectedIndex,
  }) {
    NavigationService().navigateToFullScreenImage(allImages, selectedIndex);
  }
} 