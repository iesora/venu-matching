import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile_screen.dart';
import '../venu/venue_detail_screen.dart';
import '../creator/creator_detail_screen.dart';
import '../../widgets/custom_snackbar.dart';

class MatchingListScreen extends HookWidget {
  const MatchingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading = useState<bool>(false);
    final loginType = useState<String?>(null);
    final loginRelationId = useState<int?>(null);
    final offerTabIndex = useState<int>(0);
    final fromMeMatchingData = useState<List<dynamic>>([]);
    final toMeMatchingData = useState<List<dynamic>>([]);
    final completedMatchingData = useState<List<dynamic>>([]);
    final isLoadingOffer = useState<bool>(true);

    Future<void> _fetchLoginMode() async {
      final prefs = await SharedPreferences.getInstance();
      loginType.value = prefs.getString('relationType');
      if (loginType.value == 'creator' || loginType.value == 'venue') {
        loginRelationId.value = prefs.getInt('relationId');
      } else {
        showAnimatedSnackBar(
          context,
          message: 'ビジネスアカウントでログインしてください',
          type: SnackBarType.error,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
      }
    }

    // --- ここからオファータブUI ---
    Future<void> _fetchOfferData(
        BuildContext context,
        ValueNotifier<List<dynamic>> fromMeMatchingData,
        ValueNotifier<List<dynamic>> toMeMatchingData,
        ValueNotifier<List<dynamic>> completedMatchingData,
        ValueNotifier<bool> isLoadingOffer) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');

        final uri = Uri.parse(
                '${dotenv.get('API_URL')}/matching/request/${loginType.value}/${loginRelationId.value}')
            .replace(queryParameters: {
          'relationType': loginType.value,
          'relationId': loginRelationId.value.toString(),
        });

        final response = await http.get(
          uri,
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          fromMeMatchingData.value = data
              .where((matching) =>
                  matching['requestorType'] != loginType.value &&
                  matching['status'] != 'matching')
              .toList();
          toMeMatchingData.value = data
              .where((matching) =>
                  matching['requestorType'] == loginType.value &&
                  matching['status'] != 'matching')
              .toList();
          completedMatchingData.value = data
              .where((matching) => matching['status'] == 'matching')
              .toList();
        } else {
          throw Exception('オファーデータの取得に失敗しました');
        }
      } catch (e) {
        print('エラーが発生しました: $e');
      } finally {
        isLoadingOffer.value = false;
      }
    }

    // 承認（Accept Matching Request）API通信
    Future<void> _acceptMatchingRequest(int matchingId) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');
        final response = await http.patch(
          Uri.parse('${dotenv.get('API_URL')}/matching/request/$matchingId'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          showAnimatedSnackBar(
            context,
            message: 'オファーを承認しました。',
            type: SnackBarType.success,
          );
          // 承認後にデータ再取得
          isLoadingOffer.value = true;
          await _fetchOfferData(context, fromMeMatchingData, toMeMatchingData,
              completedMatchingData, isLoadingOffer);
        } else {
          showAnimatedSnackBar(
            context,
            message: '承認に失敗しました: ${response.statusCode}',
            type: SnackBarType.error,
          );
        }
      } catch (e) {
        showAnimatedSnackBar(
          context,
          message: 'エラーが発生しました: $e',
          type: SnackBarType.error,
        );
      }
    }

    // 拒否（Reject Matching Request）API通信
    Future<void> _rejectMatchingRequest(int matchingId) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');
        final response = await http.patch(
          Uri.parse(
              '${dotenv.get('API_URL')}/matching/request/$matchingId/reject'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          showAnimatedSnackBar(
            context,
            message: 'オファーを拒否しました。',
            type: SnackBarType.deleteSuccess,
          );
          // 拒否後にデータ再取得
          isLoadingOffer.value = true;
          await _fetchOfferData(context, fromMeMatchingData, toMeMatchingData,
              completedMatchingData, isLoadingOffer);
        } else {
          showAnimatedSnackBar(
            context,
            message: '拒否に失敗しました: ${response.statusCode}',
            type: SnackBarType.error,
          );
        }
      } catch (e) {
        showAnimatedSnackBar(
          context,
          message: 'エラーが発生しました: $e',
          type: SnackBarType.error,
        );
      }
    }

    // useEffect(() {
    //   _fetchOfferData(context, fromMeMatchingData, toMeMatchingData,
    //       completedMatchingData, isLoadingOffer);
    //   return null;
    // }, [selectedVenue.value, selectedCreator.value]);

    Widget _buildOfferTabButton(String label, int index) {
      final bool selected = offerTabIndex.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            offerTabIndex.value = index;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildOfferTabContent() {
      List<dynamic> data;
      String emptyText;
      String partnerType = loginType.value == 'creator' ? 'venue' : 'creator';

      if (offerTabIndex.value == 0) {
        data = fromMeMatchingData.value;
        emptyText = '受信したオファーはありません';
      } else if (offerTabIndex.value == 1) {
        data = toMeMatchingData.value;
        emptyText = '送信したオファーはありません';
      } else {
        data = completedMatchingData.value;
        emptyText = 'マッチングしたオファーはありません';
      }

      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        margin: const EdgeInsets.only(top: 0, bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: data.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text(
                      emptyText,
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                )
              : Column(
                  children: List.generate(data.length, (index) {
                    final item = data[index];

                    // 受信タブだけ承認/拒否ボタン追加
                    if (offerTabIndex.value == 0) {
                      return Container(
                        decoration: BoxDecoration(
                          border: index < data.length - 1
                              ? const Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFE0E0E0),
                                    width: 1,
                                  ),
                                )
                              : null,
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title:
                                  Text(item[partnerType]['name'] ?? 'タイトル未設定'),
                              trailing: Text(
                                item['requestAt'] ?? '',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              onTap: () {
                                // 詳細画面などに遷移する場合はここで
                                if (partnerType == 'venue') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VenueDetailScreen(
                                          venueId: item['venue']['id']),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreatorDetailScreen(
                                          creatorId: item['creator']['id']),
                                    ),
                                  );
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 8, left: 16, right: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        await _rejectMatchingRequest(
                                            item['id']);
                                      },
                                      icon: Icon(Icons.close,
                                          color: Colors.blueGrey[500]!),
                                      label: Text(
                                        '拒否',
                                        style: TextStyle(
                                            color: Colors.blueGrey[500]!),
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.grey,
                                        backgroundColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                            color: Colors.blueGrey[100]!,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 7,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await _acceptMatchingRequest(
                                            item['id']);
                                      },
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                      label: const Text('承認',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          border: index < data.length - 1
                              ? const Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFE0E0E0),
                                    width: 1,
                                  ),
                                )
                              : null,
                        ),
                        child: ListTile(
                          title: Text(item[partnerType]['name'] ?? 'タイトル未設定'),
                          trailing: Text(
                            item['requestAt'] ?? '',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          onTap: () {
                            // 詳細画面などに遷移する場合はここで
                            if (partnerType == 'venue') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VenueDetailScreen(
                                      venueId: item['venue']['id']),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreatorDetailScreen(
                                      creatorId: item['creator']['id']),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }
                  }),
                ),
        ),
      );
    }

    Widget _buildOfferTabs() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        margin: const EdgeInsets.fromLTRB(6, 16, 6, 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // タブバー
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildOfferTabButton('受信', 0),
                        _buildOfferTabButton('送信', 1),
                        _buildOfferTabButton('マッチング', 2),
                      ],
                    ),
                  ),
                  // タブ内容
                  _buildOfferTabContent(),
                ],
              ),
            ],
          ),
        ),
      );
    }

    useEffect(() {
      _fetchLoginMode();
      _fetchOfferData(context, fromMeMatchingData, toMeMatchingData,
          completedMatchingData, isLoadingOffer);
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('マッチング'),
      ),
      body: _buildOfferTabs(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _fetchOfferData(context, fromMeMatchingData,
            toMeMatchingData, completedMatchingData, isLoadingOffer),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
