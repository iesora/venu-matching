import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // InAppWebViewを使用するためのインポート
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

class EventCreatorsScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const EventCreatorsScreen({
    Key? key,
    required this.eventId,
    required this.eventTitle,
  }) : super(key: key);

  @override
  _EventCreatorsScreenState createState() => _EventCreatorsScreenState();
}

class _EventCreatorsScreenState extends State<EventCreatorsScreen> {
  List<dynamic> creatorEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventDetail();
  }

  Future<void> fetchEventDetail() async {
    final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/event/detail/${widget.eventId}'));

    if (response.statusCode == 200) {
      setState(() {
        final eventDetail = json.decode(response.body);
        creatorEvents =
            (eventDetail['creatorEvents'] as List?)?.cast<dynamic>() ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('イベント詳細の取得に失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.eventTitle} の参加クリエイター'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: creatorEvents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ce = creatorEvents[index];
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
                    title: Text(name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
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
