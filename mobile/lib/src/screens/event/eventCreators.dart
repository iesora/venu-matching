import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EventCreatorsScreen extends StatefulWidget {
  final int eventId;
  final String? eventTitle;
  final List<dynamic>? initialCreatorEvents;

  const EventCreatorsScreen({
    Key? key,
    required this.eventId,
    this.eventTitle,
    this.initialCreatorEvents,
  }) : super(key: key);

  @override
  _EventCreatorsScreenState createState() => _EventCreatorsScreenState();
}

class _EventCreatorsScreenState extends State<EventCreatorsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> creators = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // initialCreatorEvents があればそれを利用。なければAPI取得
    if (widget.initialCreatorEvents != null &&
        widget.initialCreatorEvents!.isNotEmpty) {
      final parsed = _parseCreatorEvents(widget.initialCreatorEvents!);
      setState(() {
        creators = parsed;
        isLoading = false;
      });
      return;
    }
    await _fetchCreators();
  }

  List<Map<String, dynamic>> _parseCreatorEvents(List<dynamic> events) {
    return events
        .map(
            (e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e))
        .map((e) => e['creator'] as Map<String, dynamic>?)
        .where((c) => c != null)
        .map((c) => c!)
        .toList();
  }

  Future<void> _fetchCreators() async {
    try {
      final res = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/event/detail/${widget.eventId}'),
      );
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final ce = (body['creatorEvents'] as List?)?.cast<dynamic>() ?? [];
        final parsed = _parseCreatorEvents(ce);
        setState(() {
          creators = parsed;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showSnack('参加クリエイターの取得に失敗しました');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnack('ネットワークエラーが発生しました');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventTitle == null
            ? '参加クリエイター一覧'
            : '${widget.eventTitle} の参加クリエイター'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : creators.isEmpty
              ? const Center(child: Text('参加クリエイターが見つかりません'))
              : RefreshIndicator(
                  onRefresh: _fetchCreators,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: creators.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final c = creators[index];
                      final String name = c['name'] ?? '名称未設定';
                      final String? image = c['imageUrl'];
                      final String? description = c['description'];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: image != null && image.isNotEmpty
                              ? NetworkImage(image)
                              : null,
                          child: image == null || image.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: description == null || description.isEmpty
                            ? null
                            : Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                        onTap: () {
                          // クリエイター詳細があればここに遷移処理を追加
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
