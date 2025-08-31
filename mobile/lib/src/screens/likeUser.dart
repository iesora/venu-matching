import 'package:flutter/material.dart';
import 'package:mobile/src/plugins/swipe_stack/swipe_stack.dart';
import 'package:mobile/src/screens/notification.dart';
import 'package:mobile/src/widgets/profile_card.dart';
import 'package:mobile/src/datas/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mobile/utils/userInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:mobile/src/widgets/cicle_button.dart';
import 'package:mobile/src/screens/searchUser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/screens/userDetail.dart';

class LikeUserScreen extends StatefulWidget {
  const LikeUserScreen({Key? key}) : super(key: key);

  @override
  State<LikeUserScreen> createState() => _LikeUserScreenState();
}

class _LikeUserScreenState extends State<LikeUserScreen> {
  final GlobalKey<SwipeStackState> _swipeKey = GlobalKey<SwipeStackState>();
  List<Map<String, dynamic>> _users = [];
  List<int> _likedUserIds = [];
  bool _isLoading = true;
  bool _isUnreadNotifiationExist = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _checkUnreadNotification();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/user/liked'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _users = data
            .map((matching) => matching['fromUser'] as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('ユーザー一覧の取得に失敗しました: $e');
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

  Future<void> _createLikes(List<int> userIds) async {
    if (userIds.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/matching/response'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fromUserId': userIds[0],
          'isMatching': true,
        }),
      );

      if (response.statusCode == 200) {
        _createNotification(userIds);
        print('マッチングに成功しました');
      } else {
        print('マッチングに失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('マッチングに失敗しました: $e');
    }
  }

  Future<void> _createNotification(List<int> userIds) async {
    if (userIds.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/notification'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userIds[0],
          'notificationType': NotificationType.LIKE.value,
        }),
      );

      if (response.statusCode == 201) {
        print('通知の送信に成功しました');
      } else {
        print('通知の送信に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('通知の送信に失敗しました: $e');
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
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
          : _showUsers(),
    );
  }

  Widget _showUsers() {
    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'いいねされているユーザーがいません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontFamily: 'Noto Sans JP',
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        SwipeStack(
            key: _swipeKey,
            children: _users.map((userDoc) {
              return SwiperItem(
                  builder: (SwiperPosition position, double progress) {
                return ProfileCard(
                  page: 'discover',
                  position: position,
                  user: userDoc,
                );
              });
            }).toList(),
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            translationInterval: 6,
            scaleInterval: 0.03,
            stackFrom: StackFrom.None,
            onEnd: () {
              //_createLikes();
              debugPrint("onEnd");
            },
            onSwipe: (int index, SwiperPosition position) {
              switch (position) {
                case SwiperPosition.None:
                  break;
                case SwiperPosition.Left:
                  break;
                case SwiperPosition.Right:
                  _createLikes([_users[index]['id']]);
                  break;
              }
            }),

        /// Swipe buttons
        Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: swipeButtons(context),
            )),
      ],
    );
  }

  /// Build swipe buttons
  Widget swipeButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Left button
            cicleButton(
              bgColor: Colors.deepOrange.withAlpha(230),
              padding: 8,
              icon: const Icon(Icons.close, size: 35, color: Colors.white),
              onTap: () {
                final cardIndex = _swipeKey.currentState!.currentIndex;
                if (cardIndex != -1) {
                  _swipeKey.currentState!.swipeLeft();
                }
              },
            ),

            const SizedBox(width: 10),

            /// Swipe right and like user
            cicleButton(
              bgColor: Colors.deepOrange.withAlpha(230),
              padding: 8,
              icon: const Icon(Icons.favorite_border,
                  size: 35, color: Colors.white),
              onTap: () async {
                final cardIndex = _swipeKey.currentState!.currentIndex;
                if (cardIndex != -1) {
                  _swipeKey.currentState!.swipeRight();
                }
              },
            ),

            const SizedBox(width: 10),

            /// User detail button
            cicleButton(
              bgColor: Colors.deepOrange.withAlpha(230),
              padding: 8,
              icon: const Icon(Icons.person, size: 35, color: Colors.white),
              onTap: () async {
                final cardIndex = _swipeKey.currentState!.currentIndex;
                if (cardIndex != -1) {
                  final userId = _users[cardIndex]['id'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailScreen(userId: userId),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
