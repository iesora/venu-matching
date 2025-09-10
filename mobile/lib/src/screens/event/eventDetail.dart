import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventDetailScreen extends StatefulWidget {
  final int eventId;

  EventDetailScreen({required this.eventId});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Map<String, dynamic>? eventDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventDetail();
  }

  Future<void> fetchEventDetail() async {
    final response = await http
        .get(Uri.parse('http://yourapiurl.com/event/detail/${widget.eventId}'));

    if (response.statusCode == 200) {
      setState(() {
        eventDetail = json.decode(response.body);
        isLoading = false;
      });
    } else {
      // エラーハンドリング
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
        title: Text('イベント詳細'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : eventDetail != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventDetail!['name'] ?? 'イベント名なし',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        eventDetail!['description'] ?? '説明なし',
                        style: TextStyle(fontSize: 16),
                      ),
                      // 他のイベント詳細情報をここに追加
                    ],
                  ),
                )
              : Center(child: Text('イベント詳細が見つかりません')),
    );
  }
}
