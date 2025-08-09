import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../screens/dashboard_screen.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Navigate to profile screen
  void navigateToProfile() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
    }
  }

  // Navigate to dashboard/gallery
  void navigateToDashboard() {
    if (navigatorKey.currentState != null) {
      // Pop to root and navigate to dashboard
      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
  }

  // Navigate to gallery (same as dashboard for now)
  void navigateToGallery() {
    navigateToDashboard();
  }

  // Navigate to full screen image viewer
  void navigateToFullScreenImage(List<GalleryImage> images, int initialIndex) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => FullScreenImageViewGallery(
            images: images,
            initialIndex: initialIndex,
          ),
        ),
      );
    }
  }

  // Handle notification navigation
  void handleNotificationNavigation(String type) {
    switch (type) {
      case 'profile_update':
        navigateToProfile();
        break;
      case 'new_image':
      case 'welcome':
        navigateToDashboard();
        break;
      default:
        navigateToDashboard();
    }
  }
} 