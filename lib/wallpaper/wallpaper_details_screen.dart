import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class WallpaperDetailsScreen extends StatefulWidget {
  final String imageUrl;
  final String wallpaperName;
  final String wallpaperId;

  const WallpaperDetailsScreen({
    super.key,
    required this.imageUrl,
    required this.wallpaperName,
    required this.wallpaperId,
  });

  @override
  State<WallpaperDetailsScreen> createState() => _WallpaperDetailsScreenState();
}

class _WallpaperDetailsScreenState extends State<WallpaperDetailsScreen> {
  static const platform = MethodChannel('com.wallora.wallpaper/set');

  bool isFavorite = false;
  bool isSetting = false;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        List favorites = (doc.data() as Map<String, dynamic>)['favorites'] ?? [];
        if (favorites.contains(widget.wallpaperId)) {
          setState(() => isFavorite = true);
        }
      }
    }
  }

  Future<void> _toggleFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMsg("Please login to save favorites!", isError: true);
      return;
    }

    setState(() => isFavorite = !isFavorite);

    var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    if (isFavorite) {
      await userRef.set({
        'favorites': FieldValue.arrayUnion([widget.wallpaperId])
      }, SetOptions(merge: true));
      _showMsg("Added to Favorites!");
    } else {
      await userRef.update({
        'favorites': FieldValue.arrayRemove([widget.wallpaperId])
      });
      _showMsg("Removed from Favorites!");
    }
  }

  Future<void> setWallpaperNative(int location) async {
    setState(() => isSetting = true);
    try {
      File file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
      final bool result = await platform.invokeMethod('setWallpaper', {
        'filePath': file.path,
        'location': location,
      });
      if (result) {
        _showMsg("Wallpaper Applied Successfully!");
        
        // Track Set Wallpapers in Firestore
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'setWallpapers': FieldValue.increment(1)
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      _showMsg("Error applying wallpaper", isError: true);
    } finally {
      setState(() => isSetting = false);
    }
  }

  Future<void> downloadWallpaper() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() => isDownloading = true);
    try {
      // 1. Download to local storage
      File file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
      
      // 2. Save to gallery
      await Gal.putImage(file.path);

      // 3. Track in Firestore for "Downloads" screen
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'downloads': FieldValue.arrayUnion([widget.wallpaperId])
        }, SetOptions(merge: true));
      }
      
      _showMsg("Saved to Gallery!");
    } catch (e) {
      _showMsg("Failed to save image", isError: true);
    } finally {
      setState(() => isDownloading = false);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    SnackBarUtils.showMsg(context, msg, isError: isError);
  }

  void _showSetOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Wrap(
            children: [
              _buildOption(
                icon: Icons.home_rounded,
                title: "Home Screen",
                onTap: () {
                  Navigator.pop(context);
                  setWallpaperNative(1);
                },
              ),
              _buildOption(
                icon: Icons.lock_rounded,
                title: "Lock Screen",
                onTap: () {
                  Navigator.pop(context);
                  setWallpaperNative(2);
                },
              ),
              _buildOption(
                icon: Icons.screen_lock_landscape_rounded,
                title: "Both Screens",
                onTap: () {
                  Navigator.pop(context);
                  setWallpaperNative(3);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background Image (Move to see hidden sides)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return InteractiveViewer(
                  constrained: false, // Isse wide image screen se bahar ja sakegi taaki move ho sake
                  minScale: 1.0,
                  maxScale: 5.0,
                  panEnabled: true,
                  child: Image.network(
                    widget.imageUrl,
                    height: constraints.maxHeight, // Screen ki height ke barabar
                    fit: BoxFit.fitHeight, // Isse sides crop nahi honge, balki scrollable ho jayenge
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: const Center(child: CircularProgressIndicator(color: Colors.white24)),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // 2. Gradient Overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // 3. Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
          ),

          // 4. Content Area
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title & Subtitle
                Text(
                  widget.wallpaperName,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "By Wallora Artist • 4K Ultra HD",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 15),

                // Tags
                Row(
                  children: [
                    _buildTag("Minimal"),
                    const SizedBox(width: 8),
                    _buildTag("Abstract"),
                    const SizedBox(width: 8),
                    _buildTag("Dark Mode"),
                  ],
                ),
                const SizedBox(height: 25),

                // Action Card (Screenshot jaisa)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _circleActionBtn(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            "Favorite",
                            _toggleFavorite,
                            color: isFavorite ? Colors.red : Colors.white,
                          ),
                          _circleActionBtn(
                            Icons.file_download_outlined,
                            "Download",
                            downloadWallpaper,
                            isLoading: isDownloading,
                          ),
                          _circleActionBtn(
                            Icons.share_outlined,
                            "Share",
                            () => Share.share("Check out this wallpaper: ${widget.imageUrl}"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // BIG SET WALLPAPER BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isSetting ? null : _showSetOptions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: isSetting 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Text("SET AS WALLPAPER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  Widget _circleActionBtn(IconData icon, String label, VoidCallback onTap, {Color color = Colors.white, bool isLoading = false}) {
    return Column(
      children: [
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: isLoading 
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
