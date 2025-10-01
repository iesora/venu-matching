import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestFromCreater extends HookWidget {
  final int venuId; // ルートパラメーターとしてvenuIdを受け取る

  const RequestFromCreater({Key? key, required this.venuId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading = useState<bool>(false);
    final creatorData = useState<List<dynamic>?>(null);
    final selectedCreator = useState<Map<String, dynamic>?>(null);

    // 自分に紐づいているクリエーターを取得する関数
    Future<void> fetchCreator() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final userId = prefs.getInt('userId');
      if (token == null) {
        print('トークンが取得できませんでした');
        return;
      }
      isLoading.value = true;
      final url = Uri.parse(
          "${dotenv.get('API_URL')}/creator/user/${userId.toString()}");
      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List<dynamic>;
          creatorData.value = data;
          print('クリエーターデータ: $data');
        } else {
          print('エラー: ${response.statusCode}');
        }
      } catch (e) {
        print('例外が発生しました: $e');
      } finally {
        isLoading.value = false;
      }
    }

    // クリエーターにリクエストを送信する関数
    Future<void> requestToCreator() async {
      if (selectedCreator.value == null) {
        print('クリエーターが選択されていません');
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      if (token == null) {
        print('トークンが取得できませんでした');
        return;
      }
      final url =
          Uri.parse("${dotenv.get('API_URL')}/matching/request/creator");
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(
              {'creatorId': selectedCreator.value!['id'], 'venueId': venuId}),
        );
        if (response.statusCode == 200) {
          print('リクエストが成功しました');
        } else {
          print('リクエストエラー: ${response.statusCode}');
        }
      } catch (e) {
        print('リクエスト中に例外が発生しました: $e');
      }
    }

    // 初回マウント時にクリエーターを取得
    useEffect(() {
      fetchCreator();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('リクエスト from Venu'),
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : creatorData.value != null
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: creatorData.value!.length,
                        itemBuilder: (context, index) {
                          final creator = creatorData.value![index];
                          return Card(
                            color: Colors.white, // カードの背景を白に設定
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 5,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                creator['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                '説明: ${creator['description'] ?? 'なし'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                if (selectedCreator.value == creator) {
                                  selectedCreator.value = null;
                                  print(
                                      'クリエーターの選択が解除されました: ${creator['name']}');
                                } else {
                                  selectedCreator.value = creator;
                                  print('選択されたクリエーター: ${creator['name']}');
                                }
                              },
                              selected: selectedCreator.value == creator,
                              selectedTileColor: Colors.blue.shade50,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: requestToCreator,
                        child: const Text('リクエストを送信'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Text('クリエーター情報が見つかりませんでした'),
                ),
    );
  }
}
