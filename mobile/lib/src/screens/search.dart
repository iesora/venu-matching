import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/venu/venu_card.dart';
import 'package:mobile/src/widgets/creater/creater_card.dart';
import 'package:mobile/src/screens/request/requestFromCreater.dart'; // 追加
import 'package:mobile/src/screens/request/requestFromVenu.dart'; // 追加
import 'package:mobile/src/screens/creator/creator_detail_screen.dart';
import 'package:mobile/src/screens/venu/venue_detail_screen.dart';

class SearchScreen extends HookWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final venuList = useState<List<dynamic>>([]);
    final creatorList = useState<List<dynamic>>([]);
    final isLoading = useState<bool>(false);

    // 会場一覧を取得する関数
    Future<void> fetchVenues() async {
      isLoading.value = true;
      final url = Uri.parse("${dotenv.get('API_URL')}/venue");
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

    // クリエーター一覧を取得する関数
    Future<void> fetchCreators() async {
      isLoading.value = true;
      final url = Uri.parse("${dotenv.get('API_URL')}/creator");
      try {
        final response =
            await http.get(url, headers: {'Content-Type': 'application/json'});
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          creatorList.value = data;
        } else {
          print('エラー: ${response.statusCode}');
        }
      } catch (e) {
        print('例外が発生しました: $e');
      } finally {
        isLoading.value = false;
      }
    }

    // 初回マウント時に会場一覧とクリエーター一覧を取得
    useEffect(() {
      fetchVenues();
      fetchCreators();
      return null;
    }, []);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('検索'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '会場一覧'),
              Tab(text: 'クリエーター一覧'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            isLoading.value
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RequestFromCreater(
                                    venuId: venu['id'],
                                  ),
                                ),
                              );
                            },
                            onTap: () {
                              if (venu['id'] == null) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VenueDetailScreen(
                                    venueId: venu['id'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : creatorList.value.isEmpty
                    ? const Center(child: Text('クリエーターが見つかりませんでした'))
                    : ListView.builder(
                        itemCount: creatorList.value.length,
                        itemBuilder: (context, index) {
                          final creator = creatorList.value[index];
                          return CreatorCard(
                            creator: creator,
                            onRequest: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RequestFromVenuScreen(
                                    createrId: creator['id'],
                                  ),
                                ),
                              );
                            },
                            onTap: () {
                              if (creator['id'] == null) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreatorDetailScreen(
                                    creatorId: creator['id'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            fetchVenues();
            fetchCreators();
          },
          tooltip: '再読み込み',
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
