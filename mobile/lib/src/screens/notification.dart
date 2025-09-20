import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class RequestListScreen extends StatefulWidget {
  const RequestListScreen({Key? key}) : super(key: key);

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/request'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _requests =
            data.map((request) => request as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('リクエストの取得に失敗しました: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'リクエスト一覧',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showRequests(),
    );
  }

  Widget _showRequests() {
    if (_requests.isEmpty) {
      return Center(
        child: Text(
          'リクエストがありません',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontFamily: 'Noto Sans JP',
          ),
        ),
      );
    }

    return ListView.separated(
        itemCount: _requests.length,
        separatorBuilder: (context, index) => Container(
              child: Divider(
                height: 1,
                color: Colors.grey[200],
              ),
            ),
        itemBuilder: (context, index) {
          final request = _requests[index];
          return InkWell(
            onTap: () {
              // リクエストの詳細画面に遷移する処理をここに追加
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTimestamp(
                                  DateTime.parse(request['createdAt'])),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                request['content'] ?? '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 3,
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
        });
  }

  String _formatTimestamp(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays <= 7) {
      return '${difference.inDays}日前';
    } else {
      return DateFormat('yyyy/MM/dd').format(createdAt); // 1週間以上は日付表示
    }
  }
}
