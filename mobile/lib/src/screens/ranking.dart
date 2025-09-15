import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Map<String, dynamic>> _creators = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCreators();
  }

  Future<void> _fetchCreators() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/creator'),
        headers: const {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _creators = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'クリエイターの取得に失敗しました (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ネットワークエラーが発生しました';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ランキング'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'クリエイター'),
              Tab(text: 'ユーザー'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _buildList(_creators, isCreator: true),
            _buildList([], isCreator: false), // ユーザーのダミーデータは削除
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items,
      {required bool isCreator}) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: const Icon(Icons.person),
            ),
            title: Text(item['name'] as String),
            subtitle: Text(item['description'] ?? '説明なし'),
            onTap: () {},
          ),
        );
      },
    );
  }
}
