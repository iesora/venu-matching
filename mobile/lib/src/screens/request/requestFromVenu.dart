import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestFromVenuScreen extends HookWidget {
  final int createrId; // ルートパラメーターとしてcreaterIdを受け取る

  const RequestFromVenuScreen({Key? key, required this.createrId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading = useState<bool>(false);
    final venueData = useState<List<dynamic>?>(null);
    final selectedVenue = useState<Map<String, dynamic>?>(null);

    // 自分に紐づいている会場を取得する関数
    Future<void> fetchVenue() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final userId = prefs.getInt('userId');
      if (token == null) {
        print('トークンが取得できませんでした');
        return;
      }
      isLoading.value = true;
      final url = Uri.parse(
          "${dotenv.get('API_URL')}/venu?userId=${userId.toString()}");
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
          venueData.value = data;
          print('会場データ: $data');
        } else {
          print('エラー: ${response.statusCode}');
        }
      } catch (e) {
        print('例外が発生しました: $e');
      } finally {
        isLoading.value = false;
      }
    }

    // 会場にリクエストを送信する関数
    Future<void> requestToVenue() async {
      if (selectedVenue.value == null) {
        print('会場が選択されていません');
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      if (token == null) {
        print('トークンが取得できませんでした');
        return;
      }
      final url = Uri.parse("${dotenv.get('API_URL')}/matching/request/venu");
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'venuId': selectedVenue.value!['id']}),
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

    // 初回マウント時に会場を取得
    useEffect(() {
      fetchVenue();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('リクエスト from Venu'),
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : venueData.value != null
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: venueData.value!.length,
                        itemBuilder: (context, index) {
                          final venue = venueData.value![index];
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
                                venue['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                '説明: ${venue['description'] ?? 'なし'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                if (selectedVenue.value == venue) {
                                  selectedVenue.value = null;
                                  print('会場の選択が解除されました: ${venue['name']}');
                                } else {
                                  selectedVenue.value = venue;
                                  print('選択された会場: ${venue['name']}');
                                }
                              },
                              selected: selectedVenue.value == venue,
                              selectedTileColor: Colors.green.shade50,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: requestToVenue,
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
                  child: Text('会場情報が見つかりませんでした'),
                ),
    );
  }
}
