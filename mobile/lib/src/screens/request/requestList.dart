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
        return ListTile(
          title: Text(request['content'] ?? 'No Content'),
          subtitle: Text(request['createdAt'] ?? 'No Date'),
          onTap: () {
            _showConfirmationDialog(request['id']);
          },
        );
      },
    );
  }

  void _showConfirmationDialog(int matchingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('リクエストを承諾しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('いいえ'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _acceptRequest(matchingId);
              },
              child: const Text('はい'),
            ),
          ],
        );
      },
    );
  }
}
