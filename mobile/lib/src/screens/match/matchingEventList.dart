import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'createEvent.dart'; // CreateEventScreenのインポート

class MatchingEventListScreen extends StatefulWidget {
  final int matchingId;

  const MatchingEventListScreen({Key? key, required this.matchingId})
      : super(key: key);

  @override
  _MatchingEventListScreenState createState() =>
      _MatchingEventListScreenState();
}

class _MatchingEventListScreenState extends State<MatchingEventListScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMatchingEvents();
  }

  Future<void> _fetchMatchingEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse(
            '${dotenv.get('API_URL')}/matching/events/${widget.matchingId}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('userId');
        setState(() {
          _events = data.map((event) {
            final mappedEvent = event as Map<String, dynamic>;
            if (mappedEvent['matchingStatus'] == 'matching') {
              mappedEvent['status'] = 'requesting';
            } else if (mappedEvent['toUser']['id'] == userId) {
              mappedEvent['status'] = 'requested';
            } else if (mappedEvent['fromUser']['id'] == userId) {
              mappedEvent['status'] = 'matched';
            } else {
              mappedEvent['status'] = 'unknown';
            }
            return mappedEvent;
          }).toList();
        });
      } else {
        print('イベントの取得に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('イベントの取得に失敗しました: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(int eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/matching/events/$eventId/accept'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('リクエストが承認されました');
        await _fetchMatchingEvents(); // Refresh the events list
      } else {
        print('リクエストの承認に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('リクエストの承認に失敗しました: $e');
    }
  }

  Future<void> _rejectRequest(int eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/matching/events/$eventId/reject'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('リクエストが拒否されました');
        await _fetchMatchingEvents(); // Refresh the events list
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
        title: const Text('イベント一覧'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: _showEvents()),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateEventScreen(
                            matchingId: widget.matchingId,
                          ),
                        ),
                      );
                    },
                    child: const Text('イベントを作成'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _showEvents() {
    if (_events.isEmpty) {
      return const Center(
        child: Text('イベントがありません'),
      );
    }

    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        Color statusColor;
        switch (event['matchingStatus']) {
          case 'matching':
            statusColor = Colors.green;
            break;
          case 'pending':
            statusColor = Colors.orange;
            break;
          default:
            statusColor = Colors.blue;
        }
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(event['title'] ?? 'No Name',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['description'] ?? 'No Description'),
                Text('開始日: ${event['startDate'] ?? 'No Start Date'}'),
                Text('終了日: ${event['endDate'] ?? 'No End Date'}'),
                Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    event['status'] == 'requesting'
                        ? 'リクエスト中'
                        : event['status'] == 'requested'
                            ? 'リクエスト受取'
                            : event['status'] == 'matched'
                                ? 'マッチング済み'
                                : '不明なステータス',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                if (event['status'] == 'requested')
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _acceptRequest(event['id']),
                        child: const Text('承認'),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () => _rejectRequest(event['id']),
                        child: const Text('拒否'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
