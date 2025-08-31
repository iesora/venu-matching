import 'package:flutter/material.dart';
import 'package:mobile/src/plugins/swipe_stack/swipe_stack.dart';
import 'package:mobile/src/screens/editLikeFace.dart';
import 'package:mobile/src/screens/notification.dart';
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

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({Key? key}) : super(key: key);

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final GlobalKey<SwipeStackState> _swipeKey = GlobalKey<SwipeStackState>();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _notifications = [];
  List<int> _likedUserIds = [];
  bool _isLoading = true;
  bool _isUnreadNotifiationExist = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _checkUnreadNotification();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLikeFaceDialog();
    });
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/user/recommend-list'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _users = data.map((user) => user as Map<String, dynamic>).toList();
        _users.shuffle();
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
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/matching/request'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'toUserId': userIds[0],
        }),
      );

      if (response.statusCode == 201) {
        _createNotification(userIds);
        print('いいねの作成に成功しました');
      } else {
        print('いいねの作成に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('いいねの作成に失敗しました: $e');
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

  void _showLikeFaceDialog() {
    if (mounted &&
        !Navigator.of(context)
            .widget
            .toString()
            .contains('SelectHobbyScreen')) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("好みの設定"),
            content: const Text("あなた好みの顔写真を設定しましょう！"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("閉じる"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditLikeFaceScreen()),
                  );
                },
                child: const Text("設定する"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leadingWidth: 140,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Image.asset(
              'assets/images/sashimeshi_title_logo.png',
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(
                    _isUnreadNotifiationExist
                        ? Icons.notifications
                        : Icons.notifications_none,
                    color: Colors.white),
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
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showUsers(),
    );
  }

  /*
  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "通知",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_notifications.isNotEmpty)
                ..._notifications.take(3).map((notification) {
                  return ListTile(
                    leading: const Icon(Icons.notifications,
                        color: Colors.deepOrange),
                    title: Text(notification["content"] ?? ""),
                    trailing: Text(
                      _formatTimestamp(
                          DateTime.parse(notification["createdAt"])),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      // 通知をタップしたときの処理
                      Navigator.pop(context); // モーダルを閉じる
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("通知: ${notification["title"]}")),
                      );
                    },
                  );
                }).toList(),
              if (_notifications.length > 3)
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // 全ての通知を見る画面に遷移する処理を追加可能
                    },
                    child: const Text("すべての通知を見る"),
                  ),
                ),
              if (_notifications.isEmpty)
                const Center(
                  child:
                      Text("通知はありません。", style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),
        );
      },
    );
  }
  */

  Widget _showUsers() {
    if (_users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ユーザーが見つかりませんでした。',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
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
