import 'package:flutter/material.dart';

class VenuCard extends StatelessWidget {
  final Map<String, dynamic> venu;
  final VoidCallback onRequest;
  final VoidCallback? onTap;
  final bool? isRequestButtonVisible;

  const VenuCard({
    Key? key,
    required this.venu,
    required this.onRequest,
    this.onTap,
    this.isRequestButtonVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            venu['imageUrl'] != null
                ? Image.network(
                    venu['imageUrl'],
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 180,
                    alignment: Alignment.center,
                    color: Colors.grey,
                    child: const Icon(
                      Icons.location_on,
                      size: 48,
                      color: Colors.white70,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venu['name'] ?? '名称未設定',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venu['address'] ?? '住所不明',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (venu['capacity'] != null)
                    Text(
                      '収容人数: ${venu['capacity']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  if (venu['contact'] != null)
                    Text(
                      '連絡先: ${venu['contact']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 8),
                  Visibility(
                    visible: isRequestButtonVisible ?? true,
                    child: ElevatedButton(
                      onPressed: onRequest,
                      child: const Text('リクエスト'),
                    ),
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
