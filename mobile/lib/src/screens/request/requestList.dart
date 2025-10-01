import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        Uri.parse('${dotenv.get('API_URL')}/matching/request'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _requests =
              data.map((request) => request as Map<String, dynamic>).toList();
        });
      } else {
        print('リクエストの取得に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('リクエストの取得に失敗しました: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(int matchingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/matching/request/$matchingId'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('リクエストの承諾に成功しました');
        _fetchRequests(); // 更新されたリクエストを再取得
      } else {
        print('リクエストの承諾に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('リクエストの承諾に失敗しました: $e');
    }
  }

  Future<void> _rejectRequest(int matchingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.patch(
        Uri.parse(
            '${dotenv.get('API_URL')}/matching/request/$matchingId/reject'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('リクエストの拒否に成功しました');
        _fetchRequests();
      } else {
        print('リクエストの拒否に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('リクエストの拒否に失敗しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('リクエスト一覧'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showRequests(),
    );
  }

  Widget _showRequests() {
    if (_requests.isEmpty) {
      return const Center(
        child: Text('リクエストがありません'),
      );
    }

    return ListView.builder(
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        final fromUser = request['fromUser'];
        final createdAt = request['requestAt'] ?? request['createdAt'];
        final title =
            fromUser != null ? 'リクエスト元: ユーザー #${fromUser['id']}' : 'リクエスト';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(title),
            subtitle: Text(createdAt?.toString() ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _rejectRequest(request['id']),
                  child: const Text('拒否'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _acceptRequest(request['id']),
                  child: const Text('承諾'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 旧ダイアログ関数は不要になったため削除
}
