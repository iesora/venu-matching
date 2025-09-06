import 'package:flutter/material.dart';

class CreatorCard extends StatelessWidget {
  final Map<String, dynamic> creator;
  final VoidCallback onRequest;

  const CreatorCard({
    Key? key,
    required this.creator,
    required this.onRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (creator['opuses'] != null && creator['opuses'].isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: creator['opuses'].map<Widget>((opus) {
                  return Image.network(
                    opus['imageUrl'],
                    width: 80.0,
                    height: 80.0,
                    fit: BoxFit.cover,
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8.0),
          Text(
            creator['name'],
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            creator['description'],
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8.0),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRequest,
              child: const Text('リクエスト'),
            ),
          ),
        ],
      ),
    );
  }
}
