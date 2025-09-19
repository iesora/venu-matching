import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/utils/userInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_view/photo_view.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';
import 'package:mobile/src/widgets/custom_dialog.dart';

enum ButtonType {
  request('いいね！'),
  response('マッチングする！'),
  liked('いいね済み'),
  matching("マッチング済み");

  const ButtonType(this.value);
  final String value;
}

class UserDetailScreen extends StatefulWidget {
  final int userId;
  const UserDetailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  String? profileImageUrl;
  Map<String, dynamic>? _userData;
  List<String> _hobbies = [];
  late TabController _tabController;
  List<Map<String, dynamic>> imageUrls = [];
  bool _isLoading = true;
  bool _isMatchingLoading = true;
  ButtonType? _currentButtonType;

  @override
  void initState() {
    super.initState();
    _fetchUserDetail();
    _fetchUserHobbies();
    _isMatching();
    _tabController = TabController(length: 3, vsync: this); // タブ数を指定
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDetail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse(
            '${dotenv.get('API_URL')}/user/detail?userId=${widget.userId}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);
          Map<String, dynamic> data = jsonDecode(response.body);
          List<dynamic> images = data['userMedia'];
          images.map((image) {
            if (image != null) {
              print('ImageUrl: ${image["mediaUrl"]}');
              imageUrls.add({
                "imageUrl": image["mediaUrl"],
                "mediaId": image["id"],
              });
            }
          }).toList();
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserHobbies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse(
            '${dotenv.get('API_URL')}/hobby/user-hobby?userId=${widget.userId}'),
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

  Future<void> _isMatching() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse(
            '${dotenv.get('API_URL')}/matching/is-matching?userId=${widget.userId}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data["matchingFromUser"] != null) {
            if (data["matchingFromUser"]["isMatching"] == true) {
              _currentButtonType = ButtonType.matching;
            } else {
              _currentButtonType = ButtonType.liked;
            }
          } else if (data["matchingFromOtherUser"] != null) {
            if (data["matchingFromOtherUser"]["isMatching"] == true) {
              _currentButtonType = ButtonType.matching;
            } else {
              _currentButtonType = ButtonType.response;
            }
          } else {
            _currentButtonType = ButtonType.request;
          }
        });
      } else {
        throw Exception('マッチング情報の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      if (mounted) {
        showAnimatedSnackBar(
          context,
          message: 'マッチング情報の取得に失敗しました',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _requestMatching() async {
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
          'toUserId': widget.userId,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _currentButtonType = ButtonType.liked;
        });
        _createNotification();
        print('LIKEに成功しました');
      } else {
        print('LIKEに失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('LIKEに失敗しました: $e');
    }
  }

  Future<void> _responseMatching() async {
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
          'fromUserId': widget.userId,
          'isMatching': true,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _currentButtonType = ButtonType.matching;
        });
        _createNotification();
        print('マッチングに成功しました');
      } else {
        print('マッチングに失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('マッチングに失敗しました: $e');
    }
  }

  Future<void> _createNotification() async {
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
          'userId': widget.userId,
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

  Future<void> _createReport(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/report'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'toUserId': userId,
        }),
      );

      if (response.statusCode == 201) {
        print('報告に成功しました');
        showAnimatedSnackBar(
          context,
          message: 'ユーザーを報告しました',
          type: SnackBarType.success,
        );
      } else {
        print('報告に失敗しました: ${response.statusCode}');
        showAnimatedSnackBar(
          context,
          message: 'ユーザーの報告に失敗しました',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print('報告に失敗しました: $e');
    }
  }

  Future<void> _blockUser(int toUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/block'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'toUserId': toUserId,
        }),
      );

      if (response.statusCode == 201) {
        showAnimatedSnackBar(
          context,
          message: 'ユーザーをブロックしました',
          type: SnackBarType.success,
        );
        Navigator.pop(context);
      } else {
        print('ユーザーのブロックに失敗しました: ${response.body}');
        showAnimatedSnackBar(
          context,
          message: 'ユーザーのブロックに失敗しました',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print('ユーザーのブロックに失敗しました: $e');
      showAnimatedSnackBar(
        context,
        message: 'ユーザーのブロックに失敗しました',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _showReportConfirmDialog(int userId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          icon: const Icon(Icons.report, size: 40, color: Colors.red),
          title: '報告',
          message: 'このユーザーを報告しますか？',
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'キャンセル',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createReport(userId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '報告する',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBlockConfirmDialog(int userId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          icon: Icon(Icons.block, size: 40, color: Colors.grey[800]),
          title: 'ブロック',
          message: 'このユーザーをブロックしますか？\nブロックしたユーザーは表示されなくなります。',
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'キャンセル',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                _blockUser(userId);
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'ブロックする',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
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
            child: _profile(),
          ),
        ],
      ),
    );
  }

  Widget _profile() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        profileImageUrl != null ? _profileImage() : _defaultProfileImage(),
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

  Widget _userDetailTab() {
    return Stack(
      children: [
        SingleChildScrollView(
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
                _horizontalDetailsRow(),
                const SizedBox(height: 16.0),
                _hobbiesSection(),
                const SizedBox(height: 24.0),
                _sectionHeader('基本情報'),
                _userDetailItem('職業', '${_userData!['occupation'] ?? ''}',
                    showUnsetAsDefault: true),
                _userDetailItem(
                    '身長',
                    _userData!['height'] != null
                        ? '${_userData!['height']} cm'
                        : '',
                    showUnsetAsDefault: true),
                _userDetailItem('体型', '${_userData!['bodyType'] ?? ''}',
                    showUnsetAsDefault: true),
                _userDetailItem(
                    'ライフスタイル', '${_userData!['activityType'] ?? ''}',
                    showUnsetAsDefault: true),
                _userDetailItem('年収', '${_userData!['income'] ?? ''}',
                    showUnsetAsDefault: true),
                _userDetailItem(
                    '婚姻状況', _getMaritalStatusText(_userData!['maritalStatus']),
                    showUnsetAsDefault: true),
                _userDetailItem('都合の良い時間帯',
                    _getConvenientTimeText(_userData!['convenientTime']),
                    showUnsetAsDefault: true),
                const SizedBox(height: 16.0),
                _sectionHeader('好みの異性の条件'),
                _userDetailItem('身長',
                    '${_userData!['preferredOppositeSexHeightType'] ?? ''}',
                    showUnsetAsDefault: true),
                _userDetailItem(
                    '体型', '${_userData!['preferredOppositeSexBodyType'] ?? ''}',
                    showUnsetAsDefault: true),
                _userDetailItem('ライフスタイル',
                    '${_userData!['preferredOppositeSexActivityType'] ?? ''}',
                    showUnsetAsDefault: true),
                _userDetailItem(
                    '年収', '${_userData!['preferredOppositeSexIncome'] ?? ''}',
                    showUnsetAsDefault: true),
                _userDetailItem(
                    '食べ物', '${_userData!['preferredOppositeSexFood'] ?? ''}',
                    showUnsetAsDefault: true),
                const SizedBox(height: 16.0),
                _sectionHeader('好みの同性の条件'),
                _userDetailItem(
                    '身長', '${_userData!['preferredSameSexHeightType'] ?? ''}',
                    showUnsetAsDefault: true),
                _userDetailItem(
                    '体型', '${_userData!['preferredSameSexBodyType'] ?? ''}',
                    showUnsetAsDefault: true),
                _userDetailItem('ライフスタイル',
                    '${_userData!['preferredSameSexActivityType'] ?? ''}',
                    showUnsetAsDefault: true),
                _userDetailItem(
                    '年収', '${_userData!['preferredSameSexIncome'] ?? ''}',
                    showUnsetAsDefault: true),
                _userDetailItem(
                    '食べ物', '${_userData!['preferredSameSexFood'] ?? ''}',
                    showUnsetAsDefault: true),
                const SizedBox(height: 16.0),
                _sectionHeader('自己紹介'),
                _userDetailItem(
                    _userData!["selfIntroduction"] != "" ? null : "自己紹介文がありません",
                    '${_userData!['selfIntroduction'] ?? ''}'),
                const SizedBox(height: 54.0),
              ],
              const SizedBox(height: 54.0),
            ],
          ),
        ),
        if (_userData != null && _userData!["isSelf"] == false)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.transparent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentButtonType == ButtonType.liked ||
                      _currentButtonType == ButtonType.matching ||
                      _currentButtonType == null) {
                    null;
                  }
                  if (_currentButtonType == ButtonType.request) {
                    _requestMatching();
                  }
                  if (_currentButtonType == ButtonType.response) {
                    _responseMatching();
                  }
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: _currentButtonType != null
                        ? (_currentButtonType == ButtonType.liked ||
                                _currentButtonType == ButtonType.matching
                            ? Colors.grey
                            : Colors.pink)
                        : Colors.transparent),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentButtonType == ButtonType.response ||
                              _currentButtonType == ButtonType.matching
                          ? Icons.handshake
                          : Icons.thumb_up,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentButtonType?.value ?? '',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _photoTab() {
    if (imageUrls.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '写真がありません',
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
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: GridView.builder(
        itemCount: imageUrls.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 16.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _imageCard(imageUrls[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        title: Text(
          '${_userData?["nickname"] ?? "ユーザー詳細"}',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.block,
              color: Colors.white,
            ),
            onPressed: () {
              _showBlockConfirmDialog(widget.userId);
            },
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(
                  Icons.flag_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  _showReportConfirmDialog(widget.userId);
                },
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor:
              Theme.of(context).tabBarTheme.unselectedLabelColor,
          labelColor: Theme.of(context).tabBarTheme.labelColor,
          indicator: Theme.of(context).tabBarTheme.indicator,
          indicatorSize: Theme.of(context).tabBarTheme.indicatorSize ??
              TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'ユーザー情報'),
            Tab(text: '写真一覧'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                if (_userData != null) _userDetailTab(),
                if (_userData == null)
                  const Center(child: Text("ユーザー情報がありません")),
                _photoTab(),
              ],
            ),
    );
  }

  Widget _horizontalDetailsRow() {
    final List<Widget> children = [];

    final birthDateString = _userData!['birthDate'];
    if (birthDateString != null && birthDateString.isNotEmpty) {
      try {
        final userBirthday = DateTime.parse(birthDateString);
        final now = DateTime.now();
        final int userAge = now.year -
            userBirthday.year -
            (now.month < userBirthday.month ||
                    (now.month == userBirthday.month &&
                        now.day < userBirthday.day)
                ? 1
                : 0);
        children.add(_detailText('$userAge歳'));
      } catch (e) {
        print('生年月日のパースに失敗しました: $e');
      }
    }

    final prefecture = _userData!['prefecture'];
    if (prefecture != null && prefecture.isNotEmpty) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: 16.0));
      }
      children.add(_detailText(prefecture));
    }

    final userSex = _userData!["sex"] != null
        ? (Sex.values.firstWhere((sex) => sex.value == _userData!["sex"],
            orElse: () => Sex.MALE)).japanName
        : "";

    if (userSex.isNotEmpty) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: 16.0));
      }
      children.add(_detailText(userSex));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _detailText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }

  Widget _userDetailItem(String? title, String value,
      {bool showUnsetAsDefault = false}) {
    final isNotSet = value.isEmpty || value == 'null';
    if (isNotSet && !showUnsetAsDefault) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              SizedBox(
                width: 180,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            Expanded(
              child: Text(
                isNotSet ? '（未設定）' : value,
                style: TextStyle(
                  fontSize: 14,
                  color: isNotSet ? Colors.grey : Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

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
          }).toList(),
        ),
        const SizedBox(height: 4.0),
      ],
    );
  }

  Widget _imageCard(Map<String, dynamic> image) {
    if (image["imageUrl"] == null) {
      print("imageUrl: ${image["imageUrl"]}");
      return const Center(child: Text("画像が見つかりません"));
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              elevation: 4.0,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showImageModal(context, image["imageUrl"]),
                    child: _image(image["imageUrl"]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(String imageUrl) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 110,
        maxHeight: 110,
      ),
      child: Image.network(imageUrl),
    );
  }

  void _showImageModal(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _getImageDimensions(imageUrl),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final imageDimensions = snapshot.data as Size;
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                child: AspectRatio(
                  aspectRatio: imageDimensions.width / imageDimensions.height,
                  child: PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Size> _getImageDimensions(String imageUrl) async {
    final image = NetworkImage(imageUrl);
    final completer = Completer<Size>();
    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(
          Size(info.image.width.toDouble(), info.image.height.toDouble()),
        );
      }),
    );
    return completer.future;
  }

  String _getMaritalStatusText(String? status) {
    if (status == null) return '';
    switch (status) {
      case 'single':
        return '独身';
      case 'married':
        return '既婚';
      case 'divorced':
        return '離婚経験あり';
      case 'other':
        return 'その他';
      default:
        return status;
    }
  }

  String _getConvenientTimeText(String? status) {
    if (status == null) return '';
    return ConvenientTime.values
        .firstWhere((c) => c.value == status,
            orElse: () => ConvenientTime.ANYTIME)
        .japanName;
  }
}
