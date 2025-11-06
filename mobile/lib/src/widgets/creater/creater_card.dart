import 'package:flutter/material.dart';

class CreatorCard extends StatelessWidget {
  final Map<String, dynamic> creator;
  final VoidCallback onRequest;
  final VoidCallback? onTap;
  final bool? isRequestButtonVisible;
  final bool? isRequestButtonEnabled;
  final bool? isLiked;
  final VoidCallback? onLike;

  const CreatorCard({
    Key? key,
    required this.creator,
    required this.onRequest,
    this.onTap,
    this.isRequestButtonVisible,
    this.isRequestButtonEnabled,
    this.isLiked,
    this.onLike,
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
            if (creator['opuses'] != null && creator['opuses'].isNotEmpty)
              SizedBox(
                height: 180,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: creator['opuses'].map<Widget>((opus) {
                      return Container(
                        margin: const EdgeInsets.only(right: 4.0),
                        child: Image.network(
                          opus['imageUrl'],
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 180,
                              height: 180,
                              alignment: Alignment.center,
                              color: Colors.grey,
                              child: const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.white70,
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 180,
                alignment: Alignment.center,
                color: Colors.grey,
                child: const Icon(
                  Icons.person,
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
                    creator['name'] ?? '名前未設定',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    creator['description'] ?? '説明なし',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (creator['specialties'] != null)
                    Text(
                      '専門: ${creator['specialties']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  if (creator['location'] != null)
                    Text(
                      '場所: ${creator['location']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: isRequestButtonVisible ?? true,
                        child: ElevatedButton(
                          onPressed:
                              isRequestButtonEnabled == true ? onRequest : null,
                          child: const Text('リクエスト'),
                        ),
                      ),
                      IconButton(
                        onPressed: onLike,
                        icon: Icon(
                          isLiked == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isLiked == true ? Colors.red : Colors.grey,
                          size: 28,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
