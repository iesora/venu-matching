import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_dialog.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class BlockListScreen extends StatefulWidget {
  const BlockListScreen({Key? key}) : super(key: key);

  @override
  State<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  List<Map<String, dynamic>> _blockedUsers = [];
  bool _isLoading = true;
  bool shouldRefetch = false;

  @override
  void initState() {
    super.initState();
    _fetchBlockedUsers();
  }

  Future<void> _fetchBlockedUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/block/list'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _blockedUsers = data
              .map((user) => {
                    'id': user['toUser']?['id'].toString(),
                    'name': user['toUser']?['nickname'] as String? ?? '',
                    'avatar': user['toUser']?['avatar'] as String? ??
                        'https://via.placeholder.com/150',
                  })
              .toList();
        });
      } else {
        print('ブロックユーザー一覧の取得に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('ブロックユーザー一覧の取得に失敗しました: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showUnblockConfirmDialog(
      BuildContext context, Map<String, dynamic> blockedUser) {
    showDialog(
      context: context,
      barrierDismissible: false, // モーダルをタップで閉じられないようにする
      builder: (BuildContext context) {
        return CustomDialog(
          icon: const Icon(Icons.delete, size: 40, color: Colors.red),
          title: 'ブロック解除',
          message: "このユーザーのブロックを解除しますか？",
          actions: [
            ElevatedButton(
              onPressed: () {
                _unblockUser(int.parse(blockedUser['id']));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "解除する",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _unblockUser(int toUserId) async {
    print('toUserId: $toUserId');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      final response = await http.delete(
        Uri.parse('${dotenv.get('API_URL')}/block'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'toUserId': toUserId,
        }),
      );

      if (response.statusCode == 200) {
        showAnimatedSnackBar(
          context,
          message: 'ブロックを解除しました',
          type: SnackBarType.success,
        );
        _fetchBlockedUsers();
      } else {
        print('ブロックの解除に失敗しました: ${response.body}');
        showAnimatedSnackBar(
          context,
          message: 'ブロックの解除に失敗しました',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print('ブロックの解除に失敗しました: $e');
      showAnimatedSnackBar(
        context,
        message: 'ブロックの解除に失敗しました',
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'ブロック中のユーザー',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // カスタムの戻るアイコン
          onPressed: () {
            Navigator.pop(context, true); // 戻る際にtrueを返す
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showBlockedUsers(),
    );
  }

  Widget _showBlockedUsers() {
    if (_blockedUsers.isEmpty) {
      return Center(
        child: Text(
          'ブロック中のユーザーがいません',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontFamily: 'Noto Sans JP',
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _blockedUsers.length,
      separatorBuilder: (context, index) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Divider(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
      itemBuilder: (context, index) {
        final blockedUser = _blockedUsers[index];
        return InkWell(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(blockedUser['avatar']),
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
                            blockedUser['name'],
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Noto Sans JP'),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              _showUnblockConfirmDialog(context, blockedUser);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('ブロック解除'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
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
}
