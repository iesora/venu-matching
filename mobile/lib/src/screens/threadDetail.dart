import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mobile/src/screens/userDetail.dart';
import 'package:mobile/utils/userInfo.dart';
import 'package:mobile/src/widgets/custom_dialog.dart';
import 'package:mobile/src/widgets/web_view_page.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

enum ButtonType {
  like("like"),
  liked("liked");

  const ButtonType(this.value);
  final String value;
}

class ThreadDetailScreen extends StatefulWidget {
  final int threadId;
  const ThreadDetailScreen({Key? key, required this.threadId})
      : super(key: key);

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  Map<String, dynamic>? _threadData;
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  int? _myUserId;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderExpanded = true;

  @override
  void initState() {
    super.initState();
    _fetchThreadDetail();
    _fetchUserDetail();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _fetchThreadDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      final response = await http.get(
        Uri.parse(
            '${dotenv.get('API_URL')}/thread/detail?threadId=${widget.threadId}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _threadData = data;
          _comments =
              List<Map<String, dynamic>>.from(data['threadComments'] ?? []);
          _isLoading = false;
        });
        // データ取得後に最下部にスクロール
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        print('スレッド詳細の取得に失敗しました: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('スレッド詳細の取得に失敗しました: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/user'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);

        setState(() {
          _myUserId = userData['id'];
        });
      } else {
        throw Exception('ユーザー情報の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      showAnimatedSnackBar(
        context,
        message: 'ユーザー情報の取得に失敗しました',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/thread/comment'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'threadId': widget.threadId,
          'content': _commentController.text,
        }),
      );

      if (response.statusCode == 201) {
        final commentData = jsonDecode(response.body);
        _commentController.clear();
        _fetchThreadDetail();
        // コメント投稿後に最下部にスクロール
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        /*
        showAnimatedSnackBar(
          context,
          message: 'コメントを投稿しました',
          type: SnackBarType.success,
        );
        */
        _createCommentNotification(commentData['id']);
      } else {
        showAnimatedSnackBar(
          context,
          message: 'コメントの投稿に失敗しました',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print('コメントの投稿に失敗しました: $e');
      showAnimatedSnackBar(
        context,
        message: 'コメントの投稿に失敗しました',
        type: SnackBarType.error,
      );
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
        body: jsonEncode({'toUserId': toUserId}),
      );

      if (response.statusCode == 201) {
        showAnimatedSnackBar(
          context,
          message: 'ユーザーをブロックしました',
          type: SnackBarType.success,
        );
        Navigator.pop(context);
        Navigator.pop(context, true);
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

  /*
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
          'toUserId': _threadData?['author']['id'],
        }),
      );

      if (response.statusCode == 201) {
        //_createNotification();
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
          'fromUserId': _threadData?['author']['id'],
          'isMatching': true,
        }),
      );

      if (response.statusCode == 200) {
        //_createNotification();
        print('マッチングに成功しました');
      } else {
        print('マッチングに失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('マッチングに失敗しました: $e');
    }
  }
  */

  Future<void> _createCommentNotification(int commentId) async {
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
          'userId': _threadData?['author']['id'],
          'notificationType': NotificationType.COMMENT.value,
          'threadCommentId': commentId,
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

  Future<void> _showDeleteConfirmDialog(int commentId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          icon: const Icon(Icons.delete_outline, size: 40, color: Colors.red),
          title: 'コメントを削除',
          message: 'コメントを削除しますか？\nこの操作は取り消せません。',
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
                _deleteComment(commentId);
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
                '削除する',
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

  Future<void> _deleteComment(int commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      final response = await http.delete(
        Uri.parse('${dotenv.get('API_URL')}/thread/comment'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'threadCommentId': commentId,
        }),
      );

      if (response.statusCode == 200) {
        _fetchThreadDetail(); // 削除後にスレッドを再読み込み
        showAnimatedSnackBar(
          context,
          message: 'コメントを削除しました',
          type: SnackBarType.success,
        );
      } else {
        showAnimatedSnackBar(
          context,
          message: 'コメントの削除に失敗しました',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print('コメントの削除に失敗しました: $e');
      showAnimatedSnackBar(
        context,
        message: 'コメントの削除に失敗しました',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _showDeleteThreadConfirmDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          icon: const Icon(Icons.warning_amber_rounded,
              size: 40, color: Colors.amber),
          title: 'スレッドを削除',
          message: 'スレッドを削除しますか？\nこの操作は取り消せません。',
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
                _deleteThread();
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
                '削除する',
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

  Future<void> _deleteThread() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      final response = await http.delete(
        Uri.parse('${dotenv.get('API_URL')}/thread'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'threadId': widget.threadId,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        showAnimatedSnackBar(
          context,
          message: 'スレッドを削除しました',
          type: SnackBarType.success,
        );
      } else {
        showAnimatedSnackBar(
          context,
          message: 'スレッドの削除に失敗しました',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print('スレッドの削除に失敗しました: $e');
      showAnimatedSnackBar(
        context,
        message: 'スレッドの削除に失敗しました',
        type: SnackBarType.error,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          '${_threadData?["title"] ?? "スレッド詳細"}',
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Noto Sans JP',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // スレッド部分（修正後）
                _buildThreadHeader(),
                // コメント部分（スクロール可能）
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: _buildCommentsList(),
                  ),
                ),
                // コメント入力部分（固定）
                _buildCommentInput(),
              ],
            ),
    );
  }

  Widget _buildThreadHeader() {
    if (_threadData == null) return const SizedBox();

    return GestureDetector(
      // 縦方向のドラッグで展開／折りたたみを制御
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -200) {
            setState(() {
              _isHeaderExpanded = false;
            });
          } else if (details.primaryVelocity! > 200) {
            setState(() {
              _isHeaderExpanded = true;
            });
          }
        }
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 下部余白を0に設定。これにより、内部コンテンツの下側の余白が小さくなります。
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: _isHeaderExpanded
                    ? _buildFullHeaderContent()
                    : _buildCollapsedHeaderContent(),
              ),
              // 下部のジェスチャーアイコンの余白を最小限に設定
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _isHeaderExpanded = !_isHeaderExpanded;
                  });
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 60,
                    minHeight: 60,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.center,
                    child: Icon(
                      _isHeaderExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // カテゴリー表示部分
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[400]!, Colors.purple[600]!],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag_outlined,
                      size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    _threadData!['purposeCategory'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.restaurant_outlined,
                      size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    _threadData!['foodCategory'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // 都道府県表示を追加
            if (_threadData!['prefecture'] != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.green[600]!],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      _threadData!['prefecture'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // スレッドタイトル
        /*
        Text(
          _threadData!['title'] ?? 'スレッド詳細',
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Noto Sans JP',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        */
        // レストラン情報部分（店舗名、住所、URL など詳細な情報）
        if (((_threadData!['restaurantName'] ?? '') as String).isNotEmpty ||
            ((_threadData!['restaurantAddress'] ?? '') as String).isNotEmpty ||
            ((_threadData!['restaurantUrl'] ?? '') as String).isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (((_threadData!['restaurantName'] ?? '') as String)
                    .isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.store,
                          size: 14, color: Colors.blueAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _threadData!['restaurantName'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                if (((_threadData!['restaurantAddress'] ?? '') as String)
                    .isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.redAccent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _threadData!['restaurantAddress'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (((_threadData!['restaurantUrl'] ?? '') as String)
                    .isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 14, color: Colors.green),
                        const SizedBox(width: 6),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final restaurantUrl =
                                  _threadData!['restaurantUrl'];
                              final uri = Uri.tryParse(restaurantUrl);
                              if (uri == null ||
                                  !(uri.scheme == 'http' ||
                                      uri.scheme == 'https')) {
                                showAnimatedSnackBar(
                                  context,
                                  message: 'URLが正しくありません',
                                  type: SnackBarType.error,
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WebViewPage(
                                      title: '店舗情報',
                                      url: restaurantUrl,
                                      automaticallyImplyLeading: true,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              _threadData!['restaurantUrl'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        // 投稿者情報部分
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (_threadData!['author']['id'] != _myUserId) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailScreen(
                        userId: _threadData!['author']['id'],
                      ),
                    ),
                  );
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.deepOrangeAccent, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      (_threadData!['author']['avatar'] != null &&
                              _threadData!['author']['avatar'].isNotEmpty)
                          ? _threadData!['author']['avatar']
                          : 'https://via.placeholder.com/150',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _threadData!['author']['nickname'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatTimestamp(DateTime.parse(_threadData!['createdAt'])),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        // 追加: 削除ボタンと報告ボタン（ログインユーザーに応じて表示）
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_threadData!['author']['id'] == _myUserId)
                TextButton.icon(
                  onPressed: () => _showDeleteThreadConfirmDialog(),
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 16),
                  label: const Text('削除',
                      style: TextStyle(color: Colors.red, fontSize: 14)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                )
              else ...[
                TextButton.icon(
                  onPressed: () =>
                      _showReportConfirmDialog(_threadData!['author']['id']),
                  icon: const Icon(Icons.flag_outlined,
                      color: Colors.grey, size: 16),
                  label: const Text('報告',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _showBlockConfirmDialog(_threadData!['author']['id']),
                  icon: const Icon(Icons.block, color: Colors.grey, size: 16),
                  label: const Text('ブロック',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ]
            ],
          ),
        ),
        /*
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_myUserId != null)
              _threadData!['author']['id'] == _myUserId
                  ? ElevatedButton(
                      onPressed: _showDeleteThreadConfirmDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'スレッド削除',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _showReportConfirmDialog(
                          _threadData!['author']['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '報告',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
          ],
        ),
        */
      ],
    );
  }

  Widget _buildCollapsedHeaderContent() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_threadData!['author']['id'] != _myUserId) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailScreen(
                    userId: _threadData!['author']['id'],
                  ),
                ),
              );
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.deepOrangeAccent, width: 2),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  (_threadData!['author']['avatar'] != null &&
                          _threadData!['author']['avatar'].isNotEmpty)
                      ? _threadData!['author']['avatar']
                      : 'https://via.placeholder.com/150',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          _threadData!['author']['nickname'] ?? '',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsList() {
    if (_comments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'コメントがありません',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: 'Noto Sans JP',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _comments.length,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Divider(
          color: Colors.grey[300],
          height: 1,
          thickness: 1,
        ),
      ),
      itemBuilder: (context, index) {
        final comment = _comments[index];
        final isMyComment = comment['commentAuthor']['id'] == _myUserId;

        if (comment['isBlocked']) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  // 自分のコメントの場合は遷移しない
                  if (comment['commentAuthor']['id'] != _myUserId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailScreen(
                            userId: comment['commentAuthor']['id']),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: (_threadData != null &&
                            comment['commentAuthor']['id'] ==
                                _threadData!['author']['id'])
                        ? Border.all(color: Colors.deepOrangeAccent, width: 2)
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(
                      comment['commentAuthor']['avatar'] != null &&
                              comment['commentAuthor']['avatar'].isNotEmpty
                          ? comment['commentAuthor']['avatar']
                          : 'https://via.placeholder.com/150',
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment['commentAuthor']['nickname'] ?? '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTimestamp(
                              DateTime.parse(comment['createdAt'])),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment['content'] ?? '',
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!isMyComment) ...[
                          GestureDetector(
                            onTap: () {
                              _showReportConfirmDialog(
                                  comment['commentAuthor']['id']);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _showBlockConfirmDialog(
                                  comment['commentAuthor']['id']);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.block,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (isMyComment) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () =>
                                _showDeleteConfirmDialog(comment['id']),
                            child: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _commentController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 3,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'コメントを入力',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.deepOrangeAccent, Colors.orange],
              ),
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _postComment,
            ),
          ),
        ],
      ),
    );
  }
}
