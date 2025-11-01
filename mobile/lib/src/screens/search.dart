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
import 'package:mobile/src/widgets/custom_snackbar.dart';

class SearchScreen extends HookWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final venuList = useState<List<dynamic>>([]);
    final creatorList = useState<List<dynamic>>([]);
    final isLoading = useState<bool>(false);
    final loginType = useState<String?>(null);
    final loginRelationId = useState<int?>(null);
    final likedVenueIds = useState<Set<int>>(<int>{});
    final likedCreatorIds = useState<Set<int>>(<int>{});
    final likeIdByTarget = useState<Map<String, int>>(<String, int>{});

    Future<void> fetchLoginInfo() async {
      final pref = await SharedPreferences.getInstance();
      final type = pref.getString('relationType');
      final relationId = pref.getInt('relationId');
      loginType.value = type;
      loginRelationId.value = relationId;
    }

    // いいね一覧を取得
    // Future<void> fetchMyLikes() async {
    //   try {
    //     final prefs = await SharedPreferences.getInstance();
    //     final token = prefs.getString('userToken');
    //     final myType = prefs.getString('relationType');
    //     final myId = prefs.getInt('relationId');
    //     if (token == null || myType == null || myId == null) {
    //       return;
    //     }
    //     final url = Uri.parse("${dotenv.get('API_URL')}/like/me/$myType/$myId");
    //     final res = await http.get(url, headers: {
    //       'Content-Type': 'application/json',
    //       'Authorization': 'Bearer $token',
    //     });
    //     if (res.statusCode == 200) {
    //       final List<dynamic> data = json.decode(res.body);
    //       final venues = <int>{};
    //       final creators = <int>{};
    //       final idMap = <String, int>{};
    //       for (final item in data) {
    //         // 返却: like.id と venue/creator のいずれか
    //         final likeId = item['id'] as int?;
    //         final venue = item['venue'];
    //         final creator = item['creator'];
    //         if (venue != null && venue is Map && venue['id'] is int) {
    //           final vId = venue['id'] as int;
    //           venues.add(vId);
    //           if (likeId != null) idMap['venue:$vId'] = likeId;
    //         }
    //         if (creator != null && creator is Map && creator['id'] is int) {
    //           final cId = creator['id'] as int;
    //           creators.add(cId);
    //           if (likeId != null) idMap['creator:$cId'] = likeId;
    //         }
    //       }
    //       likedVenueIds.value = venues;
    //       likedCreatorIds.value = creators;
    //       likeIdByTarget.value = idMap;
    //     }
    //   } catch (_) {}
    // }

    Future<void> toggleVenueLike(int venueId) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final myType = prefs.getString('relationType');
      final myId = prefs.getInt('relationId');
      if (token == null || myType == null || myId == null) return;

      final key = 'venue:$venueId';
      final isLiked = likedVenueIds.value.contains(venueId);
      if (isLiked) {
        final likeId = likeIdByTarget.value[key];
        if (likeId == null) return;
        final url = Uri.parse("${dotenv.get('API_URL')}/like/$likeId");
        final res = await http.delete(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });
        if (res.statusCode == 200 || res.statusCode == 204) {
          final updatedLikedVenueIds = Set<int>.from(likedVenueIds.value)
            ..remove(venueId);
          likedVenueIds.value = updatedLikedVenueIds;
          final map = Map<String, int>.from(likeIdByTarget.value);
          map.remove(key);
          likeIdByTarget.value = map;
        }
      } else {
        final url = Uri.parse("${dotenv.get('API_URL')}/like");
        final body = jsonEncode({
          'targetType': 'venue',
          'targetId': venueId,
        });
        final res = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body);
        if (res.statusCode == 200 || res.statusCode == 201) {
          final item = json.decode(res.body);
          final likeId = item['id'] as int?;
          final updatedLikedVenueIds = Set<int>.from(likedVenueIds.value)
            ..add(venueId);
          likedVenueIds.value = updatedLikedVenueIds;
          if (likeId != null) {
            final map = Map<String, int>.from(likeIdByTarget.value);
            map[key] = likeId;
            likeIdByTarget.value = map;
          }
        }
      }
    }

    Future<void> toggleCreatorLike(int creatorId) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final myType = prefs.getString('relationType');
      final myId = prefs.getInt('relationId');
      if (token == null || myType == null || myId == null) return;

      final key = 'creator:$creatorId';
      final isLiked = likedCreatorIds.value.contains(creatorId);
      if (isLiked) {
        final likeId = likeIdByTarget.value[key];
        if (likeId == null) return;
        final url = Uri.parse("${dotenv.get('API_URL')}/like/$likeId");
        final res = await http.delete(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });
        if (res.statusCode == 200 || res.statusCode == 204) {
          final updated = Set<int>.from(likedCreatorIds.value)
            ..remove(creatorId);
          likedCreatorIds.value = updated;
          final map = Map<String, int>.from(likeIdByTarget.value);
          map.remove(key);
          likeIdByTarget.value = map;
        }
      } else {
        final url = Uri.parse("${dotenv.get('API_URL')}/like");
        final body = jsonEncode({
          'targetType': 'creator',
          'targetId': creatorId,
        });
        final res = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body);
        if (res.statusCode == 200 || res.statusCode == 201) {
          final item = json.decode(res.body);
          final likeId = item['id'] as int?;
          final updated = Set<int>.from(likedCreatorIds.value)..add(creatorId);
          likedCreatorIds.value = updated;
          if (likeId != null) {
            final map = Map<String, int>.from(likeIdByTarget.value);
            map[key] = likeId;
            likeIdByTarget.value = map;
          }
        }
      }
    }

    // 会場一覧を取得する関数
    Future<void> fetchVenues() async {
      isLoading.value = true;
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');
        if (token == null) {
          print('トークンが取得できませんでした');
          return;
        }
        var url = Uri.parse("${dotenv.get('API_URL')}/venue/list");
        //作成途中なので一旦全true
        if (loginType.value == 'creator') {
          url = Uri.parse(
              //クリエイターからの場合はマッチングの有無も取得
              "${dotenv.get('API_URL')}/venue/list/by-creator/${loginRelationId.value.toString()}");
        } else {
          url = Uri.parse("${dotenv.get('API_URL')}/venue/list");
        }
        final response = await http.get(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          venuList.value = data;
          final likedVenueIds = data
              .where((item) => item['isLiked'] == true)
              .map((item) => item['id'] as int)
              .toSet();
          likedVenueIds.value = likedVenueIds;
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
      var url = Uri.parse("${dotenv.get('API_URL')}/creator/list");
      if (loginType.value == 'venue') {
        url = Uri.parse(
            "${dotenv.get('API_URL')}/creator/list/by-venue/${loginRelationId.value.toString()}");
      }
      try {
        final response = await http.get(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          creatorList.value = data;
          final likedCreatorIds = data
              .where((item) => item['isLiked'] == true)
              .map((item) => item['id'] as int)
              .toSet();
          likedCreatorIds.value = likedCreatorIds;
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
      fetchLoginInfo();
      fetchVenues();
      fetchCreators();
      return null;
    }, []);

    // クリエーターにマッチングリクエストを送信（JWTユーザー→toUserId）
    Future<void> requestMatching(String requestorType,
        {int? venueId, int? creatorId}) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final relationId = prefs.getInt('relationId');
      if (token == null) {
        print('トークンが取得できませんでした');
        showAnimatedSnackBar(
          context,
          message: 'ログイン情報の取得に失敗しました',
          type: SnackBarType.error,
        );
        return;
      }
      if (relationId == null) {
        print('relationTypeまたはrelationIdが取得できませんでした');
        showAnimatedSnackBar(
          context,
          message: 'リクエストに失敗しました',
          type: SnackBarType.error,
        );
        return;
      }
      if (requestorType == 'creator') {
        if (venueId == null) {
          showAnimatedSnackBar(
            context,
            message: '会場を取得できませんでした',
            type: SnackBarType.error,
          );
          return;
        }
      } else {
        if (creatorId == null) {
          showAnimatedSnackBar(
            context,
            message: 'クリエイターを取得できませんでした',
            type: SnackBarType.error,
          );
          return;
        }
      }
      final url = Uri.parse("${dotenv.get('API_URL')}/matching/request");
      try {
        final body = {
          'requestorType': requestorType,
          'creatorId': requestorType == 'creator' ? relationId : creatorId,
          'venueId': requestorType == 'venue' ? relationId : venueId,
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
          showAnimatedSnackBar(
            context,
            message: 'リクエストを送信しました',
            type: SnackBarType.success,
          );
        } else if (response.statusCode == 510) {
          print('リクエストエラー: ${response}');
          showAnimatedSnackBar(
            context,
            message: 'すでにオファーが存在します',
            type: SnackBarType.error,
          );
        } else {
          print('リクエストエラー: ${response.statusCode}');
          // toaster.showToast('リクエストエラー: ${response.statusCode}');
          showAnimatedSnackBar(
            context,
            message: 'リクエスト中にエラーが発生しました',
            type: SnackBarType.error,
          );
        }
      } catch (e) {
        print('リクエスト中に例外が発生しました: $e');
        // toaster.showToast('リクエスト中に例外が発生しました: $e');
        showAnimatedSnackBar(
          context,
          message: 'リクエスト中にエラーが発生しました',
          type: SnackBarType.error,
        );
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('検索'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '会場'),
              Tab(text: 'クリエーター'),
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
                            isRequestButtonVisible:
                                loginType.value == 'creator',
                            isRequestButtonEnabled: venu['matchings'] == null ||
                                venu['matchings'].length == 0,
                            isLiked:
                                likedVenueIds.value.contains(venu['id'] as int),
                            onLike: () async {
                              if (venu['id'] is int) {
                                await toggleVenueLike(venu['id'] as int);
                              }
                            },
                            onRequest: () async {
                              final venueId = venu['id'];
                              final relationType =
                                  await SharedPreferences.getInstance().then(
                                      (prefs) =>
                                          prefs.getString('relationType'));
                              if (relationType == 'venue') {
                                print('会場にはリクエストを送信できません');
                                return;
                              } else if (relationType == 'creator') {
                                if (venueId is int) {
                                  requestMatching(relationType!,
                                      venueId: venueId);
                                } else {
                                  print('会場IDが取得できませんでした');
                                }
                              } else {
                                print('ユーザー情報が取得できませんでした');
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
                            isRequestButtonVisible: loginType.value == 'venue',
                            isRequestButtonEnabled:
                                creator['matchings'] == null ||
                                    creator['matchings'].length == 0,
                            isLiked: likedCreatorIds.value
                                .contains(creator['id'] as int),
                            onLike: () async {
                              if (creator['id'] is int) {
                                await toggleCreatorLike(creator['id'] as int);
                              }
                            },
                            onRequest: () async {
                              final relationType =
                                  await SharedPreferences.getInstance().then(
                                      (prefs) =>
                                          prefs.getString('relationType'));
                              final creatorId = creator['id'];
                              if (relationType == 'creator') {
                                print('クリエイターにはリクエストを送信できません');
                              } else if (relationType == 'venue') {
                                if (creatorId is int) {
                                  requestMatching(relationType!,
                                      creatorId: creatorId);
                                } else {
                                  print('クリエイターIDが取得できませんでした');
                                }
                              } else {
                                print('ユーザー情報が取得できませんでした');
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
      ),
    );
  }
}
