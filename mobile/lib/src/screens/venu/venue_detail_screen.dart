import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VenueDetailScreen extends StatefulWidget {
  final int venueId;

  const VenueDetailScreen({Key? key, required this.venueId}) : super(key: key);

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  Map<String, dynamic>? _venue;
  bool _isLoading = true;
  String _loginType = '';
  int? _loginRelationId;

  @override
  void initState() {
    super.initState();
    _fetchVenue();
    _fetchLoginMode();
  }

  Future<void> _fetchLoginMode() async {
    final prefs = await SharedPreferences.getInstance();
    _loginType = prefs.getString('relationType') ?? '';
    _loginRelationId = prefs.getInt('relationId');
  }

  Future<void> _fetchVenue() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/venue/${widget.venueId}'),
        headers: const {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _venue = json.decode(response.body) as Map<String, dynamic>;
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
    final image = _venue?['imageUrl'] as String?;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: image != null && image.isNotEmpty
          ? Image.network(
              image,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.apartment, size: 40)),
              ),
            )
          : Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.apartment, size: 40)),
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
    final name = (_venue?['name'] as String?) ?? '会場';
    final description = (_venue?['description'] as String?) ?? '';
    final address = (_venue?['address'] as String?) ?? '';
    final tel = (_venue?['tel'] as String?) ?? '';
    final availableTime = (_venue?['availableTime'] as String?) ?? '';
    final facilities = (_venue?['facilities'] as String?) ?? '';
    final capacity = (_venue?['capacity']?.toString()) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hero(),
        SizedBox(
          width: double.infinity,
          child: Card(
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
                      child: Text(description,
                          style: const TextStyle(fontSize: 14)),
                    ),
                ],
              ),
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
                const Text('会場情報',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                _infoRow(Icons.location_on, address),
                _infoRow(Icons.call, tel),
                _infoRow(
                    Icons.groups, capacity.isNotEmpty ? '収容人数: $capacity' : ''),
                _infoRow(Icons.access_time,
                    availableTime.isNotEmpty ? '利用時間: $availableTime' : ''),
                _infoRow(Icons.handyman,
                    facilities.isNotEmpty ? '設備: $facilities' : ''),
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
        title: Text(_venue?['name'] ?? '会場詳細'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _venue == null
              ? const Center(child: Text('会場情報が見つかりません'))
              : SingleChildScrollView(child: _content()),
      bottomNavigationBar: _venue == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Visibility(
                    visible:
                        _loginType == 'creator' && _loginRelationId != null,
                    child: ElevatedButton(
                      onPressed: () async {
                        final toUserId = _venue?['user'] != null
                            ? _venue!['user']['id'] as int?
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
                          final loginRelationId = prefs.getInt('relationId');
                          final loginType = prefs.getString('relationType');
                          if (loginType != 'creator' ||
                              loginRelationId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('クリエイターでログインしてください')));
                            return;
                          }
                          final url = Uri.parse(
                              "${dotenv.get('API_URL')}/matching/request");
                          final body = {
                            'requestorType': loginType,
                            'creatorId': loginRelationId,
                            'venueId': _venue?['id'],
                          };
                          final response = await http.post(
                            url,
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $token',
                            },
                            body: jsonEncode(body),
                          );
                          if (response.statusCode == 200 ||
                              response.statusCode == 201) {
                            print('リクエストが成功しました');
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('リクエストを送信しました')));
                          } else {
                            print('リクエストエラー: ${response.statusCode}');
                            // toaster.showToast('リクエストエラー: ${response.statusCode}');
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('リクエスト中にエラーが発生しました')));
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
