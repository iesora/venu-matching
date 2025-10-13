import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:mobile/src/screens/request/requestFromVenu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatorDetailScreen extends StatefulWidget {
  final int creatorId;

  const CreatorDetailScreen({Key? key, required this.creatorId})
      : super(key: key);

  @override
  State<CreatorDetailScreen> createState() => _CreatorDetailScreenState();
}

class _CreatorDetailScreenState extends State<CreatorDetailScreen> {
  Map<String, dynamic>? _creator;
  bool _isLoading = true;
  String _loginType = '';
  int? _loginRelationId;

  @override
  void initState() {
    super.initState();
    _fetchCreator();
    _fetchLoginMode();
  }

  Future<void> _fetchLoginMode() async {
    final prefs = await SharedPreferences.getInstance();
    _loginType = prefs.getString('relationType') ?? '';
    _loginRelationId = prefs.getInt('relationId');
  }

  Future<void> _fetchCreator() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/creator/${widget.creatorId}'),
        headers: const {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _creator = json.decode(response.body) as Map<String, dynamic>;
        });
      }
    } catch (_) {
      // noop（簡易実装）
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _hero() {
    final image = _creator?['imageUrl'] as String?;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: image != null && image.isNotEmpty
          ? Image.network(
              image,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.person, size: 40)),
              ),
            )
          : Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.person, size: 40)),
            ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _content() {
    final name = (_creator?['name'] as String?) ?? 'クリエーター';
    final description = (_creator?['description'] as String?) ?? '';
    final email = (_creator?['email'] as String?) ?? '';
    final phone = (_creator?['phoneNumber'] as String?) ?? '';
    final website = (_creator?['website'] as String?) ?? '';
    final social = (_creator?['socialMediaHandle'] as String?) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hero(),
        Card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child:
                        Text(description, style: const TextStyle(fontSize: 14)),
                  ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('連絡先',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                _infoRow(Icons.mail, email),
                _infoRow(Icons.call, phone),
                _infoRow(Icons.language, website),
                _infoRow(Icons.alternate_email, social),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_creator?['name'] ?? 'クリエーター詳細'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _creator == null
              ? const Center(child: Text('クリエーター情報が見つかりません'))
              : SingleChildScrollView(child: _content()),
      bottomNavigationBar: _creator == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Visibility(
                    visible: _loginType == 'venue' && _loginRelationId != null,
                    child: ElevatedButton(
                      onPressed: () async {
                        final toUserId = _creator?['user'] != null
                            ? _creator!['user']['id'] as int?
                            : null;
                        if (toUserId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('送信先ユーザーが見つかりません')));
                          return;
                        }
                        try {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('userToken');
                          if (token == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ログインが必要です')));
                            return;
                          }
                          if (_loginType != 'venue' ||
                              _loginRelationId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('会場名義でログインしてください')));
                            return;
                          }
                          final url = Uri.parse(
                              "${dotenv.get('API_URL')}/matching/request");
                          final body = {
                            'requestorType': _loginType,
                            'creatorId': _creator?['id'],
                            'venueId': _loginRelationId,
                          };
                          final res = await http.post(
                            url,
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $token',
                            },
                            body: jsonEncode(body),
                          );
                          if (res.statusCode == 201 || res.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('リクエストを送信しました')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('送信に失敗しました (${res.statusCode})')));
                          }
                        } catch (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ネットワークエラー')));
                        }
                      },
                      child: const Text('リクエスト'),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
