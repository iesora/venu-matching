import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/src/screens/notification.dart';
import 'dart:convert';
import 'chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({Key? key}) : super(key: key);

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;
  bool shouldRefetch = false;
  bool _isUnreadNotifiationExist = false;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
    _checkUnreadNotification();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/group/list'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _rooms = data
              .map((group) => {
                    'id': group['id'].toString(),
                    'name': group['name'],
                    'avatar': group['otherUser']?['avatar'] ??
                        'https://via.placeholder.com/150',
                    'latestMessage': group['latestMessage'] ?? '',
                    'unreadMessageCount': group['unreadMessageCount'] ?? 0,
                    'latestMessageTime': group['chatMessages'] != null &&
                            (group['chatMessages'] as List).isNotEmpty
                        ? group['chatMessages'].last['createdAt']
                        : null,
                    'otherUserNickname': group['otherUser']?['nickname'] ?? '',
                    'updatedAt': group['updatedAt'],
                  })
              .toList()
            ..sort((a, b) => DateTime.parse(b['updatedAt'])
                .compareTo(DateTime.parse(a['updatedAt'])));
        });
      } else {
        print('グループ一覧の取得に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('グループ一覧の取得に失敗しました: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkUnreadNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/notification/check-unread'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      setState(() {
        _isUnreadNotifiationExist = data["isUnreadNotificationExist"];
      });
    } catch (e) {
      print('通知情報の取得に失敗しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/sashimeshi_horizontal_title_logo.png',
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(
                    _isUnreadNotifiationExist
                        ? Icons.notifications
                        : Icons.notifications_none,
                    color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationScreen()),
                  );
                  setState(() {
                    _isUnreadNotifiationExist = false;
                  });
                },
              ),
              if (_isUnreadNotifiationExist)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showRooms(),
    );
  }

  Widget _showRooms() {
    if (_rooms.isEmpty) {
      return Center(
        child: Text(
          'チャットがありません',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontFamily: 'Noto Sans JP',
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _rooms.length,
      separatorBuilder: (context, index) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Divider(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return InkWell(
          onTap: () async {
            shouldRefetch = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatScreen(groupId: int.parse(room['id'].toString())),
                  ),
                ) ??
                false;
            if (shouldRefetch) {
              _fetchRooms();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(
                      room['avatar'] ?? 'https://via.placeholder.com/150'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            room['otherUserNickname'],
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Noto Sans JP'),
                          ),
                          Text(
                            _formatMessageTime(room['latestMessageTime']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room['latestMessage'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (room['unreadMessageCount'] > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                room['unreadMessageCount'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatMessageTime(String? timestamp) {
    if (timestamp == null) return '';

    final messageTime = DateTime.parse(timestamp).toLocal();
    final now = DateTime.now();

    // 日付を比較して、同じ日かどうかを確認
    final isSameDay = messageTime.year == now.year &&
        messageTime.month == now.month &&
        messageTime.day == now.day;

    if (isSameDay) {
      // 今日の場合
      return '${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    } else if (messageTime.year == now.year &&
        messageTime.month == now.month &&
        messageTime.day == now.day - 1) {
      // 昨日の場合
      return '昨日';
    } else if (now.difference(messageTime).inDays < 7) {
      // 1週間以内の場合
      return [
        '日曜日',
        '月曜日',
        '火曜日',
        '水曜日',
        '木曜日',
        '金曜日',
        '土曜日'
      ][messageTime.weekday % 7];
    } else {
      // それ以外の場合
      return '${messageTime.year}/${messageTime.month.toString().padLeft(2, '0')}/${messageTime.day.toString().padLeft(2, '0')}';
    }
  }
}
