import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/src/screens/editAccountImage.dart';
import 'package:mobile/src/screens/editHobby.dart';
import 'package:mobile/src/screens/notification.dart';
import 'package:mobile/src/screens/other.dart';
import 'package:mobile/src/screens/userDetail.dart';
import 'package:mobile/utils/userInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/screens/subscription_screen.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';
import 'package:mobile/src/screens/editProfile.dart';
import 'package:mobile/src/screens/editPreferOppositeSex.dart';
import 'package:mobile/src/screens/editPreferSameSex.dart';

class AccountScreen extends StatefulWidget {
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? profileImageUrl; // サンプル画像を設定
  Map<String, dynamic>? _userData;
  List<String> _hobbies = [];
  bool shouldRefetch = false;
  bool _isUnreadNotifiationExist = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    _checkUnreadNotification();
  }

  Future<void> _initialize() async {
    await _fetchUserDetail(); // ユーザー情報を取得
    if (_userData != null) {
      await _fetchUserHobbies(); // ユーザー情報がある場合のみ趣味を取得
    }
  }

  Future<void> _fetchUserDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/user'), // TODO: ユーザーIDを動的に設定
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);
          if (_userData != null) {
            profileImageUrl = _userData!['avatar'];
          }
        });
      } else {
        throw Exception('ユーザー情報の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      if (mounted) {
        showAnimatedSnackBar(
          context,
          message: 'ユーザー情報の取得に失敗しました',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _fetchUserHobbies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse(
            '${dotenv.get('API_URL')}/hobby/user-hobby?userId=${_userData!["id"]}'), // ユーザーIDを動的に設定
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _hobbies = List<String>.from(
              jsonDecode(response.body).map((hobby) => hobby['name']));
        });
      } else {
        throw Exception('趣味の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      if (mounted) {
        showAnimatedSnackBar(
          context,
          message: '趣味の取得に失敗しました',
          type: SnackBarType.error,
        );
      }
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

  Future<void> _addUserPoint(int point) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/user/change-point'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "id": _userData!["id"],
          'point': point,
        }),
      );

      if (response.statusCode == 200) {
        print('ポイントの追加に成功しました');
        _fetchUserDetail(); // ユーザー情報を再取得
      } else {
        print('ポイントの追加に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('ポイントの追加に失敗しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0.0,
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
                    color: Colors.white),
                onPressed: () {
                  /**
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationScreen()),
                  );
                  setState(() {
                    _isUnreadNotifiationExist = false;
                  });
                   */
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
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OtherScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _body(),
            if (_userData != null) ...[
              const SizedBox(height: 16.0),
              Text(
                '${_userData!['nickname']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _calculateAge(_userData!['birthDate']).toString() + '歳',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  if (_userData!['prefecture'] != null)
                    const SizedBox(width: 12.0),
                  Text(
                    _userData!['prefecture'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  if (_userData!['sex'] != null) const SizedBox(width: 12.0),
                  Text(
                    _getSexDisplay(_userData!['sex']),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              _hobbiesSection(),
              // 新たな導線を追加
              const SizedBox(height: 16.0),
              _navigationLinks(),
            ],
            const SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  if (_userData != null) ...[
                    //const SizedBox(width: 16.0),
                    Expanded(
                      child: _pointsSection(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _profileWithEditIcon(),
          ),
        ],
      ),
    );
  }

  Widget _profileWithEditIcon() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        profileImageUrl != null ? _profileImage() : _defaultProfileImage(),
        Positioned(
          bottom: 8,
          right: 8,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.deepOrangeAccent,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.white),
              onPressed: () async {
                shouldRefetch = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAccountImageScreen(),
                      ),
                    ) ??
                    false;
                if (shouldRefetch) {
                  _fetchUserDetail();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileImage() {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * 0.9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          profileImageUrl!,
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
            return _defaultProfileImage();
          },
        ),
      ),
    );
  }

  Widget _defaultProfileImage() {
    return const SizedBox(
      width: 200,
      height: 200,
      child: Icon(
        Icons.account_circle,
        size: 100,
        color: Colors.grey,
      ),
    );
  }

  // 加入プラン表示用ウィジェット
  Widget _subscriptionPlan() {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: SizedBox(
        height: 160,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '現在のプラン',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24.0),
              if (_userData != null && _userData!['plan'] != null)
                Text(
                  '${_userData!['plan']['planType'] ?? PlanType.BASIC.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 8.0),
                ),
                child: const Text(
                  'プラン変更',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ポイント表示用ウィジェット
  Widget _pointsSection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: SizedBox(
        height: 160,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '残りポイント',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20.0),
              if (_userData != null)
                Text(
                  '${_userData!['point'] ?? '0'} pt',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  shouldRefetch = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubscriptionScreen(),
                        ),
                      ) ??
                      false;
                  if (shouldRefetch) {
                    _fetchUserDetail();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 6.0),
                ),
                child: const Text(
                  'ポイント追加',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 趣味表示用ウィジェット
  Widget _hobbiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '趣味・興味',
          style: TextStyle(fontSize: 12, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6.0),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4.0,
          children: _hobbies.map((hobby) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: Chip(
                label: Text(
                  hobby,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                      color: Colors.deepPurpleAccent, width: 1.0),
                ),
              ),
            );
          }).toList()
            ..add(
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: IconButton(
                  icon: const Icon(Icons.edit,
                      size: 12, color: Colors.deepOrangeAccent),
                  onPressed: () async {
                    shouldRefetch = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditHobbyScreen(
                                  userId:
                                      int.parse(_userData!["id"].toString()))),
                        ) ??
                        false;
                    if (shouldRefetch) {
                      _fetchUserHobbies();
                    }
                  },
                ),
              ),
            ),
        ),
        const SizedBox(height: 4.0),
      ],
    );
  }

  // ポイント追加ダイアログを表示するメソッド
  void _showAddPointDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ポイント追加'),
          content: const Text('ポイントを追加しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                _addUserPoint(1000); // ポイント追加メソッドを呼び出す
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _navigationLinks() {
    final List<Map<String, dynamic>> navigationItems = [
      {
        'icon': Icons.account_circle,
        'color': Colors.green,
        'title': '自分のプロフィールの確認',
        'targetWidget': UserDetailScreen(
          userId: int.parse(_userData!["id"].toString()),
        ),
      },
      {
        'icon': Icons.person,
        'color': Colors.deepPurpleAccent,
        'title': '基本プロフィールの編集',
        'targetWidget': EditProfileScreen(),
      },
      {
        'icon': Icons.favorite,
        'color': Colors.pinkAccent,
        'title': '好みの異性条件の編集',
        'targetWidget': EditPreferOppositeSexScreen(),
      },
      {
        'icon': Icons.people,
        'color': Colors.blueAccent,
        'title': '好みの同性条件の編集',
        'targetWidget': EditPreferSameSexScreen(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 背景色を白に設定
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 0), // 影を全体に均等表示
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: navigationItems.asMap().entries.map((entry) {
            int index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'],
                      color: item['color'],
                      size: 24,
                    ),
                  ),
                  title: Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                  ),
                  onTap: () async {
                    shouldRefetch = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => item['targetWidget'],
                          ),
                        ) ??
                        false;
                    if (shouldRefetch) {
                      _fetchUserDetail();
                    }
                  },
                ),
                if (index != navigationItems.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // 誕生日から年齢を計算するメソッド
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

  // 性別の表示形式を取得するメソッド
  String _getSexDisplay(String? sex) {
    if (sex == null) return '';

    switch (sex) {
      case 'male':
        return '男性';
      case 'female':
        return '女性';
      case 'lesbian':
        return 'レズビアン';
      case 'gay':
        return 'ゲイ';
      case 'bisexual':
        return 'バイセクシャル';
      case 'transgender':
        return 'トランスジェンダー';
      case 'questioning':
        return 'クエスチョニング';
      default:
        return '';
    }
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
