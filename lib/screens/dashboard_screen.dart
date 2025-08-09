import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'profile_screen.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<GalleryImage> _images = [];
  bool _loading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchAndSetImages();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchAndSetImages(showLoading: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAndSetImages({bool showLoading = true}) async {
    if (showLoading) setState(() => _loading = true);
    try {
      final images = await fetchImages();
      setState(() {
        _images = images;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _manualRefresh() async {
    await _fetchAndSetImages();
  }

  Future<List<GalleryImage>> fetchImages() async {
    try {
      final response = await http
          .get(Uri.parse('https://intruder.micteejay.com.ng/get_images.php'));
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;

        // Check if the response contains an error message
        if (responseBody.contains('"status":"error"')) {
          print('API returned error: $responseBody');
          // Return empty list instead of throwing exception
          return [];
        }

        try {
          final List<dynamic> data = jsonDecode(responseBody);
          return data
              .where((item) =>
                  item is Map<String, dynamic> &&
                  (item['filename']?.toString().isNotEmpty ?? false) &&
                  (item['url']?.toString().isNotEmpty ?? false) &&
                  (item['timestamp']?.toString().isNotEmpty ?? false))
              .map((item) => GalleryImage.fromJson(item))
              .toList();
        } catch (e) {
          print('Error parsing JSON: $e');
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Network error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final displayName = user?.displayName;
    final email = user?.email;
    ValueNotifier<bool> isLoggingOut = ValueNotifier(false);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 8),
            const Text('Intruder Cam App'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: isLoggingOut,
            builder: (context, loading, child) {
              return IconButton(
                icon: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.logout),
                onPressed: loading
                    ? null
                    : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Logout'),
                            content:
                                const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          isLoggingOut.value = true;
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                          isLoggingOut.value = false;
                        }
                      },
                tooltip: 'Logout',
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB31217), // Red
              Color(0xFF6A0572), // Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      if (photoUrl != null)
                        CircleAvatar(
                          backgroundImage: NetworkImage(photoUrl),
                          radius: 28,
                        )
                      else
                        const CircleAvatar(
                          child: Icon(Icons.person, size: 32),
                          radius: 28,
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (displayName != null)
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (email != null)
                              Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _manualRefresh,
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : _images.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.photo_library,
                                      color: Colors.white70,
                                      size: 64,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No images found.',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pull down to refresh',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: _images.length,
                                itemBuilder: (context, index) {
                                  final img = _images[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      final deleted =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              FullScreenImageViewGallery(
                                            images: List<GalleryImage>.from(
                                                _images),
                                            initialIndex: index,
                                          ),
                                        ),
                                      );
                                      if (deleted == true) {
                                        _fetchAndSetImages(showLoading: false);
                                      }
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        elevation: 6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              child: Image.network(
                                                img.url,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Center(
                                                        child: Icon(Icons
                                                            .broken_image)),
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              child: Text(
                                                img.filename,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              child: Text(
                                                img.timestamp,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB31217),
        onPressed: () async {
          // Test in-app notification
          await NotificationService().testInAppNotification();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Test notification sent! Check your notification panel.')),
          );
        },
        tooltip: 'Test Notification',
        child: const Icon(Icons.notifications),
      ),
    );
  }
}

class GalleryImage {
  final String filename;
  final String url;
  final String timestamp;

  GalleryImage(
      {required this.filename, required this.url, required this.timestamp});

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      filename: json['filename']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }
}

// Add a new widget for full screen image view
class FullScreenImageViewGallery extends StatefulWidget {
  final List<GalleryImage> images;
  final int initialIndex;

  const FullScreenImageViewGallery({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<FullScreenImageViewGallery> createState() =>
      _FullScreenImageViewGalleryState();
}

class _FullScreenImageViewGalleryState
    extends State<FullScreenImageViewGallery> {
  late PageController _controller;
  late int _currentIndex;
  late List<GalleryImage> _images;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: _currentIndex);
    _images = List<GalleryImage>.from(widget.images);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _images.isNotEmpty ? _images[_currentIndex].filename : '',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Image'),
                  content:
                      const Text('Are you sure you want to delete this image?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final filename = _images[_currentIndex].filename;
                final response = await http.post(
                  Uri.parse('https://intruder.micteejay.com.ng/delete.php'),
                  body: {'filename': filename},
                );
                if (response.statusCode == 200 &&
                    response.body.contains('success')) {
                  setState(() {
                    _images.removeAt(_currentIndex);
                    if (_currentIndex >= _images.length && _currentIndex > 0) {
                      _currentIndex--;
                    }
                  });
                  if (_images.isEmpty) {
                    Navigator.of(context)
                        .pop(true); // return true to trigger refresh
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image deleted successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete image')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(_images.length !=
                widget.images.length), // return true if deleted
          ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: _images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final img = _images[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: InteractiveViewer(
                  child: Image.network(
                    img.url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.white, size: 64)),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  img.timestamp,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
