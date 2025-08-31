import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/src/screens/searchUser.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/profile_card.dart';
import 'userDetail.dart';
import 'notification.dart';

class FindUserScreen extends StatefulWidget {
  const FindUserScreen({Key? key}) : super(key: key);

  @override
  State<FindUserScreen> createState() => _FindUserScreenState();
}

class _FindUserScreenState extends State<FindUserScreen> {
  List<Map<String, dynamic>> _users = [];
  // ユーザーIDといいね状態を管理するマップ
  Map<int, bool> _likeStatus = {};
  bool _isLoading = true;
  bool _isUnreadNotifiationExist = false;
  // 前回検索時のフィルター条件を保持する変数
  Map<String, dynamic>? _searchFilters;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _checkUnreadNotification();
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

  Future<void> _fetchUsers({Map<String, dynamic>? filters}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      String url = '${dotenv.get('API_URL')}/user/recommend-list';
      if (filters != null && filters.isNotEmpty) {
        // filtersの各値を文字列へ変換してクエリパラメータを作成
        final uri = Uri.parse(url).replace(
          queryParameters:
              filters.map((key, value) => MapEntry(key, value.toString())),
        );
        url = uri.toString();
        print('url: $url');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _users = data.map((user) => user as Map<String, dynamic>).toList();
        });
      } else {
        print('ユーザー一覧の取得に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('ユーザー一覧の取得中にエラーが発生しました: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // いいね処理を実装
  Future<void> _toggleLike(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      // すでにいいね済みの場合は何もしない
      if (_likeStatus[userId] == true) {
        return;
      }

      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/matching/request'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'toUserId': userId,
        }),
      );

      if (response.statusCode == 201) {
        // いいね成功
        setState(() {
          _likeStatus[userId] = true; // いいね状態を更新
        });
        _createNotification(userId);
        showAnimatedSnackBar(
          context,
          message: 'いいねしました！',
          type: SnackBarType.success,
        );
      } else {
        showAnimatedSnackBar(
          context,
          message: 'いいねに失敗しました',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print('いいねの作成に失敗しました: $e');
    }
  }

  // 通知の作成
  Future<void> _createNotification(int userId) async {
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
          'userId': userId,
          'notificationType': 'LIKE',
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

  void _navigateToUserDetail(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(userId: userId),
      ),
    ).then((_) {
      // ユーザー詳細画面から戻ってきたとき、以前設定された検索フィルターがあればそれを用いて再取得する
      _fetchUsers(filters: _searchFilters);
    });
  }

  // ユーザーの年齢を計算する関数
  int _calculateAge(String? birthDateString) {
    if (birthDateString == null || birthDateString.isEmpty) {
      return 0;
    }

    final DateTime birthDate = DateTime.parse(birthDateString);
    final DateTime today = DateTime.now();

    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // アカウント作成日が2週間以内かチェックする関数
  bool _isNewUser(String? createdAtString) {
    if (createdAtString == null || createdAtString.isEmpty) {
      return false;
    }

    final DateTime createdAt = DateTime.parse(createdAtString);
    final DateTime today = DateTime.now();
    final DateTime twoWeeksAgo = today.subtract(const Duration(days: 14));

    return createdAt.isAfter(twoWeeksAgo);
  }

  // ユーザー検索モーダルを表示するメソッド
  void _openSearchModal() async {
    final filters = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SearchUserModal(initialFilters: _searchFilters);
      },
    );
    if (filters != null) {
      setState(() {
        // 新たな検索条件を状態として保持
        _searchFilters = filters;
      });
      // ここで API を呼び出して検索結果を更新
      _fetchUsers(filters: _searchFilters);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
            onPressed: _openSearchModal,
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(
                  _isUnreadNotifiationExist
                      ? Icons.notifications
                      : Icons.notifications_none,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ユーザーが見つかりませんでした',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontFamily: 'Noto Sans JP',
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final userId = user['id'];
                      // 年齢を計算
                      final userAge = _calculateAge(user['birthDate']);
                      // アカウント作成日時を確認
                      final isNewUser = _isNewUser(user['createdAt']);
                      // いいね状態を取得
                      final isLiked = _likeStatus[userId] ?? false;

                      return Stack(
                        children: [
                          // ユーザーの写真（カード本体）- タップでユーザー詳細へ
                          GestureDetector(
                            onTap: () => _navigateToUserDetail(userId),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: NetworkImage(
                                    user['avatar'] ??
                                        'https://via.placeholder.com/150',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // 下部に年齢と都道府県を表示
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        '${userAge}歳 ${user['prefecture'] ?? ""}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // NEW アイコン（左上）
                          if (isNewUser)
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                          // ハートアイコン（右上）- タップでいいね
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => _toggleLike(userId),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  // いいね状態によってアイコンを変更
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.pink,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}
