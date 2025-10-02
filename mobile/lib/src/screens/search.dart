import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/venu/venu_card.dart';
import 'package:mobile/src/widgets/creater/creater_card.dart';
// import 'package:mobile/src/screens/request/requestFromCreater.dart'; // 旧導線
// import 'package:mobile/src/screens/request/requestFromVenu.dart'; // 旧導線
import 'package:mobile/src/screens/creator/creator_detail_screen.dart';
import 'package:mobile/src/screens/venu/venue_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');
        if (token == null) {
          print('トークンが取得できませんでした');
          return;
        }
        final response = await http.get(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      if (token == null) {
        print('トークンが取得できませんでした');
        return;
      }
      final url = Uri.parse("${dotenv.get('API_URL')}/creator");
      try {
        final response = await http.get(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
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

    // クリエーターにマッチングリクエストを送信（JWTユーザー→toUserId）
    Future<void> requestMatchingToUser(int toUserId,
        {int? venueId, int? creatorId}) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      if (token == null) {
        print('トークンが取得できませんでした');
        return;
      }
      final url = Uri.parse("${dotenv.get('API_URL')}/matching/request");
      try {
        final body = {
          'toUserId': toUserId,
          if (venueId != null) 'venueId': venueId,
          if (creatorId != null) 'creatorId': creatorId,
        };
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          print('リクエストが成功しました');
        } else {
          print('リクエストエラー: ${response.statusCode}');
        }
      } catch (e) {
        print('リクエスト中に例外が発生しました: $e');
      }
    }

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
                              final toUserId = venu['user']?['id'];
                              final venueId = venu['id'];
                              if (toUserId is int && venueId is int) {
                                requestMatchingToUser(toUserId,
                                    venueId: venueId);
                              }
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
                              final toUserId = creator['user']?['id'];
                              final creatorId = creator['id'];
                              if (toUserId is int && creatorId is int) {
                                requestMatchingToUser(toUserId,
                                    creatorId: creatorId);
                              }
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
