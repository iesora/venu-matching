import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'matchingEventList.dart'; // イベント一覧画面のインポート

class MatchingListScreen extends HookWidget {
  const MatchingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completedMatchings = useState<List<dynamic>>([]);
    final isLoading = useState<bool>(false);

    // マッチング済み一覧を取得する関数
    Future<void> fetchCompletedMatchings() async {
      isLoading.value = true;
      final url = Uri.parse("${dotenv.get('API_URL')}/matching/completed");
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');
        final response = await http.get(url, headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        });
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          completedMatchings.value = data;
        } else {
          print('エラー: ${response.statusCode}');
        }
      } catch (e) {
        print('例外が発生しました: $e');
      } finally {
        isLoading.value = false;
      }
    }

    // 初回マウント時にマッチング済み一覧を取得
    useEffect(() {
      fetchCompletedMatchings();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('マッチング済み一覧'),
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: completedMatchings.value.length,
              itemBuilder: (context, index) {
                final matching = completedMatchings.value[index];
                return ListTile(
                  title: Text('会場: ${matching['venu']['name']}'),
                  subtitle: Text('クリエーター: ${matching['creator']['name']}'),
                  trailing: Text('マッチング日: ${matching['matchingAt']}'),
                  onTap: () {
                    // カードをクリックした時にイベント一覧画面に遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchingEventListScreen(
                          matchingId: matching['id'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
