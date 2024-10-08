import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ParentDetailCard extends StatelessWidget {
  final String title;
  final String name;
  final String contact;
  final String occupation;
  final String imagePath;

  const ParentDetailCard({
    super.key,
    required this.title,
    required this.name,
    required this.contact,
    required this.occupation,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Column(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imagePath,
                    height: 100,
                    width: 100,
                    placeholder: (context, url) => CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: Image.asset(
                        "assets/placeholder_user.png",
                        height: 60,
                        width: 60,
                      ),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: Image.asset(
                        'assets/placeholder_user.png',
                        height: 60,
                        width: 60,
                      ),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          contact,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      const Icon(Icons.work, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          occupation,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
