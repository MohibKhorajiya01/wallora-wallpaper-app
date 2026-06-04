import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverviewCards extends StatelessWidget {
  const OverviewCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('wallpapers').snapshots(),
                builder: (context, snapshot) {
                  String count = "0";
                  if (snapshot.hasData) {
                    int length = snapshot.data!.docs.length;
                    count = length >= 1000 ? "${(length / 1000).toStringAsFixed(1)}k" : length.toString();
                  }
                  return _buildMetricCard("TOTAL UPLOADS", count);
                }
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  String count = "0";
                  if (snapshot.hasData) {
                    int length = snapshot.data!.docs.length;
                    count = length >= 1000 ? "${(length / 1000).toStringAsFixed(1)}k" : length.toString();
                  }
                  return _buildMetricCard("TOTAL USERS", count);
                }
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  int totalDownloads = 0;
                  int totalSet = 0;
                  
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      var data = doc.data() as Map<String, dynamic>;
                      
                      // Calculate Downloads
                      if (data.containsKey('downloads') && data['downloads'] is List) {
                        totalDownloads += (data['downloads'] as List).length;
                      }
                      
                      // Calculate Set Wallpapers
                      if (data.containsKey('setWallpapers') && data['setWallpapers'] is num) {
                        totalSet += (data['setWallpapers'] as num).toInt();
                      }
                    }
                  }
                  
                  String downCount = totalDownloads >= 1000 ? "${(totalDownloads / 1000).toStringAsFixed(1)}k" : totalDownloads.toString();
                  String setCount = totalSet >= 1000 ? "${(totalSet / 1000).toStringAsFixed(1)}k" : totalSet.toString();
                  
                  return Row(
                    children: [
                      Expanded(child: _buildMetricCard("TOTAL DOWNLOADS", downCount)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildMetricCard("SET WALLPAPERS", setCount)),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Container(
      height: 105,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white10, // Pure greyscale
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title, 
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60, 
              fontSize: 11, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 1.0
            )
          ),
          const SizedBox(height: 10),
          Text(
            value, 
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 26, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
}
