import 'package:flutter/material.dart';
import 'package:mobile/src/app.dart';
import 'package:mobile/src/plugins/swipe_stack/swipe_stack.dart';
import 'package:mobile/src/screens/account.dart';
import 'package:mobile/src/screens/bookmark.dart';
import 'package:mobile/src/screens/chat.dart';
import 'package:mobile/src/screens/threadDetail.dart';
import 'package:mobile/src/screens/userDetail.dart';
import 'package:mobile/src/widgets/profile_card.dart';
import 'package:mobile/src/datas/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mobile/utils/userInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:mobile/src/widgets/cicle_button.dart';
import 'searchUser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/notification/list'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _notifications = data
            .map((notification) => notification as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('通知の取得に失敗しました: $e');
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
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          '通知',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Noto Sans JP',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showNotifications(),
    );
  }

  Widget _showNotifications() {
    if (_notifications.isEmpty) {
      return Center(
        child: Text(
          '通知がありません',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontFamily: 'Noto Sans JP',
          ),
        ),
      );
    }

    return ListView.separated(
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => Container(
              child: Divider(
                height: 1,
                color: Colors.grey[200],
              ),
            ),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return InkWell(
            onTap: () {
              if (notification["isUnread"]) {
                setState(() {
                  notification["isUnread"] = false;
                });
              }
              if (notification["notificationType"] ==
                  NotificationType.CHAT.value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                          groupId: int.parse(
                              notification['chatGroup']!["id"].toString()))),
                );
              }
              if (notification["notificationType"] ==
                  NotificationType.LIKE.value) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailScreen(
                          userId: int.parse(
                              notification['likeUser']!["id"].toString())),
                    ));
              }
              if (notification["notificationType"] ==
                  NotificationType.NEWS.value) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyStatefulWidget(),
                    ));
              }
              if (notification["notificationType"] ==
                  NotificationType.COMMENT.value) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThreadDetailScreen(
                          threadId: int.parse(
                              notification['threadComment']!["thread"]!["id"]
                                  .toString())),
                    ));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color:
                    notification["isUnread"] ? Colors.white : Colors.grey[100],
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
                                  DateTime.parse(notification['createdAt'])),
                              style: TextStyle(
                                fontSize: 12,
                                color: notification["isUnread"]
                                    ? Colors.black
                                    : Colors.grey[700],
                                fontWeight: notification["isUnread"]
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification['content'] ?? '',
                                style: TextStyle(
                                  color: notification["isUnread"]
                                      ? Colors.black
                                      : Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: notification["isUnread"]
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
