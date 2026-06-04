import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin_service.dart';

class LibraryList extends StatelessWidget {
  final Function(String, Map<String, dynamic>) onEditTap;

  const LibraryList({super.key, required this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('wallpapers').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.white24));
        }
        var docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text("No artworks yet.", style: TextStyle(color: Colors.white54));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var doc = docs[index];
            var data = doc.data() as Map<String, dynamic>;
            String name = data['name'] ?? 'Artwork';
            String imageUrl = data['imageUrl'] ?? '';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => Container(width: 60, height: 60, color: Colors.white10),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text("4K • 2.4MB", style: TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                    onPressed: () => onEditTap(doc.id, data),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.redAccent.withOpacity(0.8), size: 20),
                    onPressed: () => _deleteWallpaper(context, doc.id),
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  void _deleteWallpaper(BuildContext context, String docId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Delete Artwork?", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this wallpaper?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
        ],
      )
    );

    if (confirm == true) {
      try {
        await AdminService.deleteWallpaper(docId);
        if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wallpaper deleted"), backgroundColor: Colors.green));
      } catch(e) {
        if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete"), backgroundColor: Colors.red));
      }
    }
  }
}
