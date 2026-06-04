import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import '../home/saved_screen.dart';
import '../home/downloads_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout from Wallora?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      )
    );
  }

  void _editUsername() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Edit Username", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter new username",
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                  'displayName': controller.text.trim(),
                }, SetOptions(merge: true));
                if (mounted) Navigator.pop(context);
                setState(() {}); // Refresh UI
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({required IconData icon, required String title, required VoidCallback onTap, Color iconColor = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: user != null 
        ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
        : null,
      builder: (context, snapshot) {
        String displayName = "GUEST USER";
        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          // Priority: Edited Display Name > Original Signup Name > Email prefix
          displayName = data['displayName'] ?? data['name'] ?? user?.email?.split('@')[0].toUpperCase() ?? "GUEST USER";
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12, width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white10,
                  child: Icon(Icons.person, size: 50, color: Colors.white.withOpacity(0.9)),
                ),
              ),
              const SizedBox(height: 15),
              Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(user?.email ?? "guest@wallora.com", style: const TextStyle(color: Colors.white54, fontSize: 14)),
              
              const SizedBox(height: 40),
              
              Container(
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    _buildOptionTile(
                      icon: Icons.favorite_border, 
                      title: "My Wishlist", 
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedScreen(isStandalone: true)))
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    _buildOptionTile(
                      icon: Icons.download_for_offline_outlined, 
                      title: "Downloads", 
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DownloadsScreen()))
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    _buildOptionTile(icon: Icons.settings_outlined, title: "Account Settings", onTap: _editUsername),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Container(
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    _buildOptionTile(
                      icon: Icons.help_outline, 
                      title: "Help & Support", 
                      onTap: () => _showSimpleDialog(context, "Help & Support", "Email us at support@wallora.com for any queries. We are available 24/7.")
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    _buildOptionTile(
                      icon: Icons.info_outline, 
                      title: "About Wallora", 
                      onTap: () => _showSimpleDialog(context, "About Wallora", "Wallora is your premium destination for high-quality 4K wallpapers. Version 1.0.0")
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              Container(
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    _buildOptionTile(
                      icon: Icons.login_rounded, 
                      title: "Login",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    _buildOptionTile(
                      icon: Icons.logout, 
                      title: "Logout", 
                      iconColor: Colors.redAccent,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }
    );
  }

  void _showSimpleDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }
}
