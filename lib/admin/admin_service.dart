import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class AdminService {
  static const String cloudName = "dzl4zsiag";
  static const String uploadPreset = "wallora_preset";

  // Upload new wallpaper
  static Future<void> uploadWallpaper({
    required File imageFile,
    required String name,
    required String category,dekho
  }) async {
    final cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
    CloudinaryResponse response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(imageFile.path, folder: 'wallpapers'),
    );

    await FirebaseFirestore.instance.collection('wallpapers').add({
      'imageUrl': response.secureUrl,
      'name': name.trim(),
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Edit existing wallpaper
  static Future<void> editWallpaper({
    required String docId,
    required String newName,
    required String newCategory,
  }) async {
    await FirebaseFirestore.instance.collection('wallpapers').doc(docId).update({
      'name': newName.trim(),
      'category': newCategory,
    });
  }

  // Delete wallpaper
  static Future<void> deleteWallpaper(String docId) async {
    await FirebaseFirestore.instance.collection('wallpapers').doc(docId).delete();
  }
}
