import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../wallpaper/wallpaper_details_screen.dart';
import '../auth/login_screen.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: Colors.white24, size: 80),
              const SizedBox(height: 20),
              const Text("Login Required", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                child: const Text("LOGIN NOW"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Downloads", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white24));
          
          List downloads = [];
          if (userSnapshot.data!.exists) {
            downloads = (userSnapshot.data!.data() as Map<String, dynamic>)['downloads'] ?? [];
          }

          if (downloads.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_for_offline_outlined, color: Colors.white24, size: 80),
                  SizedBox(height: 20),
                  Text("No Downloads Yet", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('wallpapers').snapshots(),
            builder: (context, wallSnapshot) {
              if (!wallSnapshot.hasData) return const SizedBox();
              var downloadedDocs = wallSnapshot.data!.docs.where((doc) => downloads.contains(doc.id)).toList();

              return MasonryGridView.count(
                padding: const EdgeInsets.all(15),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: downloadedDocs.length,
                itemBuilder: (context, index) {
                  var doc = downloadedDocs[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WallpaperDetailsScreen(
                      imageUrl: doc['imageUrl'],
                      wallpaperName: doc['name'] ?? "Wallpaper",
                      wallpaperId: doc.id,
                    ))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(doc['imageUrl'], fit: BoxFit.cover),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
