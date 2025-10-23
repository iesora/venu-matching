import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({Key? key}) : super(key: key);

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingVenues = false;
  bool _isLoadingCreators = false;
  bool _isLoadingRequests = false;
  List<dynamic> _venues = [];
  List<dynamic> _creators = [];
  List<dynamic> _requests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    await Future.wait([
      _fetchVenues(),
      _fetchCreators(),
      _fetchRequests(),
    ]);
  }

  Future<void> _fetchVenues() async {
    setState(() => _isLoadingVenues = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final userId = prefs.getInt('userId');
      if (token == null) return;
      final res = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/venue?userId=${userId ?? ''}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        setState(() => _venues = json.decode(res.body) as List<dynamic>);
      }
    } catch (_) {
    } finally {
      setState(() => _isLoadingVenues = false);
    }
  }

  Future<void> _fetchCreators() async {
    setState(() => _isLoadingCreators = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final userId = prefs.getInt('userId');
      if (token == null) return;
      final res = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/creator/user/${userId ?? ''}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        setState(() => _creators = json.decode(res.body) as List<dynamic>);
      }
    } catch (_) {
    } finally {
      setState(() => _isLoadingCreators = false);
    }
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoadingRequests = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      if (token == null) return;
      final res = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/matching/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List<dynamic>;
        setState(() => _requests = data);
      }
    } catch (_) {
    } finally {
      setState(() => _isLoadingRequests = false);
    }
  }

  Future<void> _acceptRequest(int matchingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      if (token == null) return;
      final res = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/matching/request/$matchingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        await _fetchRequests();
      }
    } catch (_) {}
  }

  Future<void> _rejectRequest(int matchingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      if (token == null) return;
      final res = await http.patch(
        Uri.parse(
            '${dotenv.get('API_URL')}/matching/request/$matchingId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        await _fetchRequests();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ホーム'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '概要'),
              Tab(text: '会場'),
              Tab(text: 'クリエーター'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _overviewTab(),
            _venuesTab(),
            _creatorsTab(),
          ],
        ),
      ),
    );
  }

  Widget _overviewTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('最新リクエスト (5件まで)',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _isLoadingRequests
                      ? const Center(child: CircularProgressIndicator())
                      : (_requests.isEmpty)
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('新しいリクエストはありません',
                                  style: TextStyle(color: Colors.grey)),
                            )
                          : Column(
                              children: _requests
                                  .take(5)
                                  .map((r) => Card(
                                        child: ListTile(
                                          title: Text(
                                            r['fromUser'] != null
                                                ? 'From: ユーザー #${r['fromUser']['id']}'
                                                : 'From: 不明',
                                          ),
                                          subtitle: Text(
                                            (r['requestAt'] ?? r['createdAt'])
                                                    ?.toString() ??
                                                '',
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextButton(
                                                onPressed: () => _rejectRequest(
                                                    r['id'] as int),
                                                child: const Text('拒否'),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () => _acceptRequest(
                                                    r['id'] as int),
                                                child: const Text('承諾'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('会場',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _isLoadingVenues
                      ? const Center(child: CircularProgressIndicator())
                      : _venues.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('会場が見つかりません',
                                  style: TextStyle(color: Colors.grey)),
                            )
                          : Column(
                              children: _venues
                                  .map((v) => ListTile(
                                        leading: const Icon(Icons.apartment),
                                        title: Text(v['name'] ?? ''),
                                        subtitle: Text(v['address'] ?? ''),
                                      ))
                                  .toList(),
                            ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('クリエイター',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _isLoadingCreators
                      ? const Center(child: CircularProgressIndicator())
                      : _creators.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('クリエイターが見つかりません',
                                  style: TextStyle(color: Colors.grey)),
                            )
                          : Column(
                              children: _creators
                                  .map((c) => ListTile(
                                        leading: const Icon(Icons.person),
                                        title: Text(c['name'] ?? ''),
                                        subtitle:
                                            Text(c['description'] ?? '説明なし'),
                                      ))
                                  .toList(),
                            ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _venuesTab() {
    if (_isLoadingVenues) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_venues.isEmpty) {
      return const Center(child: Text('会場が見つかりません'));
    }
    return ListView.builder(
      itemCount: _venues.length,
      itemBuilder: (context, index) {
        final v = _venues[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.apartment),
            title: Text(v['name'] ?? ''),
            subtitle: Text(v['address'] ?? ''),
          ),
        );
      },
    );
  }

  Widget _creatorsTab() {
    if (_isLoadingCreators) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_creators.isEmpty) {
      return const Center(child: Text('クリエイターが見つかりません'));
    }
    return ListView.builder(
      itemCount: _creators.length,
      itemBuilder: (context, index) {
        final c = _creators[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(c['name'] ?? ''),
            subtitle: Text(c['description'] ?? '説明なし'),
          ),
        );
      },
    );
  }
}
