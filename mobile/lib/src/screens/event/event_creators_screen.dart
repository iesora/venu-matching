import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // InAppWebViewを使用するためのインポート

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web View'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}

class EventCreatorsScreen extends StatelessWidget {
  final int eventId;
  final String eventTitle;
  final List<dynamic> initialCreatorEvents;

  const EventCreatorsScreen({
    Key? key,
    required this.eventId,
    required this.eventTitle,
    required this.initialCreatorEvents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = initialCreatorEvents
        .map(
            (e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$eventTitle の参加クリエイター'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ce = items[index];
          final creator = ce['creator'];
          if (creator == null) {
            return const SizedBox.shrink();
          }
          final String name = creator['name'] ?? '未設定';
          final String? image = creator['imageUrl'];
          final String? description = creator['description'];
          final String? website = creator['website'];

          return Card(
            elevation: 1,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                backgroundImage: image != null && image.isNotEmpty
                    ? NetworkImage(image)
                    : null,
                child: image == null || image.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: description != null && description.isNotEmpty
                  ? Text(description,
                      maxLines: 2, overflow: TextOverflow.ellipsis)
                  : null,
              onTap: website != null && website.isNotEmpty
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewPage(
                              url:
                                  "https://buy.stripe.com/test_bJedRbdvEdLyaLp7YzcIE00"),
                        ),
                      );
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
