import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    _markAllAsRead();
  }

  // Jab user screen khole, sab messages ko "Read" kar dein
  Future<void> _markAllAsRead() async {
    var unreadDocs = await FirebaseFirestore.instance
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadDocs.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  // Single Notification delete karne ke liye
  Future<void> _deleteNotification(String docId) async {
    await FirebaseFirestore.instance.collection('notifications').doc(docId).delete();
  }

  // Saari notifications delete karne ke liye
  Future<void> _clearAllNotifications() async {
    var allDocs = await FirebaseFirestore.instance.collection('notifications').get();
    for (var doc in allDocs.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Notifications", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: const Text("Clear All", style: TextStyle(color: Colors.white)),
                  content: const Text("Do you want to delete all notifications?", style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () {
                        _clearAllNotifications();
                        Navigator.pop(context);
                      }, 
                      child: const Text("Clear All", style: TextStyle(color: Colors.redAccent))
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white12, height: 1.0),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white24));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, color: Colors.white24, size: 80),
                  SizedBox(height: 20),
                  Text("No new notifications", style: TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String title = data['title'] ?? 'System Update';
              String message = data['message'] ?? '';
              Timestamp? createdAt = data['createdAt'] as Timestamp?;
              bool isRead = data['isRead'] ?? false;
              
              String timeStr = "Just now";
              if (createdAt != null) {
                timeStr = timeago.format(createdAt.toDate());
              }

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
                onDismissed: (direction) {
                  _deleteNotification(doc.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Notification deleted"), duration: Duration(seconds: 1)),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white.withOpacity(0.05) : Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isRead ? Colors.white12 : Colors.blueAccent.withOpacity(0.3), 
                      width: 0.5
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isRead ? Colors.white12 : Colors.blueAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isRead ? Icons.notifications_none : Icons.notifications_active, 
                          color: isRead ? Colors.white38 : Colors.blueAccent, 
                          size: 24
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title, 
                                    style: TextStyle(
                                      color: isRead ? Colors.white70 : Colors.white, 
                                      fontSize: 16, 
                                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold
                                    )
                                  )
                                ),
                                Text(timeStr, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message, 
                              style: TextStyle(
                                color: isRead ? Colors.white38 : Colors.white70, 
                                fontSize: 14, 
                                height: 1.4
                              )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
