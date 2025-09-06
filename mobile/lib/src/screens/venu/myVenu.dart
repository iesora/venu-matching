import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/venu/venu_card.dart';
import 'package:mobile/src/screens/venu/AddVenu.dart'; // AddVenu画面のインポート

class MyVenuScreen extends HookWidget {
  const MyVenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final venuList = useState<List<dynamic>>([]);
    final isLoading = useState<bool>(false);

    // 会場一覧を取得する関数
    Future<void> fetchVenues() async {
      isLoading.value = true;
      final url = Uri.parse("${dotenv.get('API_URL')}/venu");
      try {
        final response =
            await http.get(url, headers: {'Content-Type': 'application/json'});
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          venuList.value = data;
        } else {
          print('エラー: ${response.statusCode}');
        }
      } catch (e) {
        print('例外が発生しました: $e');
      } finally {
        isLoading.value = false;
      }
    }

    // 初回マウント時に会場一覧を取得
    useEffect(() {
      fetchVenues();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイ会場一覧'),
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : venuList.value.isEmpty
              ? const Center(child: Text('会場が見つかりませんでした'))
              : ListView.builder(
                  itemCount: venuList.value.length,
                  itemBuilder: (context, index) {
                    final venu = venuList.value[index];
                    return VenuCard(
                      venu: venu,
                      onRequest: () {
                        // リクエストボタンの処理
                        print('リクエストボタンが押されました');
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddVenuScreen()),
          );
        },
        tooltip: '会場追加',
        child: const Icon(Icons.add), // プラスアイコンに変更
      ),
    );
  }
}
