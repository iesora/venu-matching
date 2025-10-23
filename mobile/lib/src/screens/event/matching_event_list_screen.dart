import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'eventDetail.dart';
import '../../widgets/custom_snackbar.dart';
import 'create_event_bottom_sheet.dart';

class MatchingEventListScreen extends HookWidget {
  final int matchingId;

  const MatchingEventListScreen({
    Key? key,
    required this.matchingId,
  }) : super(key: key);

  // userType をページ全体で使うために static 変数で定義
  static String? userType;

  // relationType を取得し、userType に格納する
  static Future<void> initializeUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userType = prefs.getString('relationType');
    } catch (e) {
      print('ユーザータイプの取得に失敗: $e');
      userType = null;
    }
  }

  Future<RequestorType?> _getUserRequestorType() async {
    // userType がまだ取得されていなければ取得
    if (userType == null) {
      await initializeUserType();
    }
    if (userType == 'venue') {
      return RequestorType.venue;
    } else if (userType == 'creator') {
      return RequestorType.creator;
    }
    return null;
  }

  void _showCreateEventBottomSheet(
    BuildContext context,
    ValueNotifier<List<dynamic>> events,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
  ) async {
    final requestorType = await _getUserRequestorType();

    if (requestorType == null) {
      showAnimatedSnackBar(
        context,
        message: 'ユーザータイプの取得に失敗しました',
        type: SnackBarType.error,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: CreateEventBottomSheet(
            matchingId: matchingId,
            requestorType: requestorType,
            onSuccess: () {
              _fetchMatchingEvents(events, isLoading, errorMessage, context);
            },
          ),
        );
      },
    );
  }

  Future<void> _fetchMatchingEvents(
    ValueNotifier<List<dynamic>> events,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
    BuildContext context,
  ) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      // userType もここで取得する（すでに取得済みならスキップ）
      if (userType == null) {
        userType = prefs.getString('relationType');
      }

      if (token == null) {
        showAnimatedSnackBar(
          context,
          message: 'ログイン情報の取得に失敗しました',
          type: SnackBarType.error,
        );
        return;
      }

      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/event/matching/$matchingId'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        events.value = data;
        isLoading.value = false;
      } else {
        isLoading.value = false;
        errorMessage.value = 'イベントの取得に失敗しました (${response.statusCode})';
        showAnimatedSnackBar(
          context,
          message: 'イベントの取得に失敗しました',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'ネットワークエラーが発生しました';
      showAnimatedSnackBar(
        context,
        message: 'ネットワークエラーが発生しました',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _acceptRequest(
    int eventId,
    ValueNotifier<List<dynamic>> events,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
    BuildContext context,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      if (userType == null) {
        userType = prefs.getString('relationType');
      }

      if (token == null) {
        showAnimatedSnackBar(
          context,
          message: 'ログイン情報の取得に失敗しました',
          type: SnackBarType.error,
        );
        return;
      }

      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/event/status'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'eventId': eventId, 'acceptStatus': 'accepted'}),
      );

      if (response.statusCode == 200) {
        showAnimatedSnackBar(
          context,
          message: 'イベントリクエストを承認しました',
          type: SnackBarType.success,
        );
        await _fetchMatchingEvents(
            events, isLoading, errorMessage, context); // データを再取得
      } else {
        showAnimatedSnackBar(
          context,
          message: 'イベントリクエストの承認に失敗しました',
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

  Future<void> _rejectRequest(
    int eventId,
    ValueNotifier<List<dynamic>> events,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
    BuildContext context,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      if (userType == null) {
        userType = prefs.getString('relationType');
      }

      if (token == null) {
        showAnimatedSnackBar(
          context,
          message: 'ログイン情報の取得に失敗しました',
          type: SnackBarType.error,
        );
        return;
      }

      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/event/status'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'eventId': eventId, 'acceptStatus': 'rejected'}),
      );

      if (response.statusCode == 200) {
        showAnimatedSnackBar(
          context,
          message: 'イベントリクエストを拒否しました',
          type: SnackBarType.deleteSuccess,
        );
        await _fetchMatchingEvents(
            events, isLoading, errorMessage, context); // データを再取得
      } else {
        showAnimatedSnackBar(
          context,
          message: 'イベントリクエストの拒否に失敗しました',
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

  @override
  Widget build(BuildContext context) {
    final events = useState<List<dynamic>>([]);
    final isLoading = useState<bool>(true);
    final errorMessage = useState<String?>(null);
    final eventTabIndex = useState<int>(0);
    final requestedByCreatorEvents = useState<List<dynamic>>([]);
    final requestedByVenueEvents = useState<List<dynamic>>([]);
    final acceptedEvents = useState<List<dynamic>>([]);
    final userTypeState = useState<String?>(userType);

    useEffect(() {
      // ユーザータイプ初期化
      MatchingEventListScreen.initializeUserType().then((_) {
        userTypeState.value = userType;
      });
      _fetchMatchingEvents(events, isLoading, errorMessage, context);
      return null;
    }, []);

    //更新ボタン現在表示してない
    // final refreshEvents = useCallback(() {
    //   return _fetchMatchingEvents(events, isLoading, errorMessage, context);
    // }, [events, isLoading, errorMessage]);

    // イベントデータをタブ別に分類
    void _categorizeEvents() {
      final allEvents = events.value;
      // 承認待ちのイベントからクリエイター発か会場発か分ける
      final pendingEventsList =
          allEvents.where((event) => event['status'] == 'pending').toList();
      requestedByCreatorEvents.value = pendingEventsList
          .where((event) => event['requestorType'] == 'creator')
          .toList();
      requestedByVenueEvents.value = pendingEventsList
          .where((event) => event['requestorType'] == 'venue')
          .toList();
      acceptedEvents.value =
          allEvents.where((event) => event['status'] == 'accepted').toList();
    }

    // イベントデータが更新されたときに分類を実行
    useEffect(() {
      _categorizeEvents();
      return null;
    }, [events.value]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('イベント管理'),
        backgroundColor: const Color(0xFFD5C0AA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildEventTabs(
        eventTabIndex,
        requestedByCreatorEvents,
        requestedByVenueEvents,
        acceptedEvents,
        events,
        isLoading,
        errorMessage,
        context,
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              _showCreateEventBottomSheet(
                  context, events, isLoading, errorMessage);
            },
            heroTag: "create_event",
            child: const Icon(Icons.add),
          ),
          // const SizedBox(width: 16),
          // FloatingActionButton(
          //   onPressed: () => refreshEvents(),
          //   heroTag: "refresh_events",
          //   child: const Icon(Icons.refresh),
          // ),
        ],
      ),
    );
  }

  Widget _buildEventTabButton(
    String label,
    int index,
    ValueNotifier<int> eventTabIndex,
    BuildContext context,
  ) {
    final bool selected = eventTabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          eventTabIndex.value = index;
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

  Widget _buildEventTabContent(
    ValueNotifier<int> eventTabIndex,
    ValueNotifier<List<dynamic>> requestedByCreatorEvents,
    ValueNotifier<List<dynamic>> requestedByVenueEvents,
    ValueNotifier<List<dynamic>> acceptedEvents,
    ValueNotifier<List<dynamic>> events,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
    BuildContext context,
  ) {
    List<dynamic> data;
    String emptyText;

    if (eventTabIndex.value == 0) {
      data = userType == 'creator'
          ? requestedByVenueEvents.value
          : requestedByCreatorEvents.value;
      emptyText = '承認待ちのイベントはありません';
    } else if (eventTabIndex.value == 1) {
      data = userType == 'creator'
          ? requestedByCreatorEvents.value
          : requestedByVenueEvents.value;
      emptyText = 'リクエスト済みのイベントはありません';
    } else {
      data = acceptedEvents.value;
      emptyText = '承認済みのイベントはありません';
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
                  final event = data[index];
                  if (eventTabIndex.value == 0) {
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
                              title: Text(event['title'] ?? 'タイトル未設定',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((event['description'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        event['description'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Row(
                                      children: [
                                        Text('開催日時:'),
                                        const SizedBox(width: 4),
                                        Text(
                                          (() {
                                            final dateTimeStr =
                                                event['startDate'];
                                            if (dateTimeStr == null ||
                                                dateTimeStr.isEmpty) {
                                              return '';
                                            }
                                            try {
                                              final dt =
                                                  DateTime.parse(dateTimeStr)
                                                      .toLocal();
                                              return '${dt.month.toString().padLeft(2, '0')}/'
                                                  '${dt.day.toString().padLeft(2, '0')} '
                                                  '${dt.hour.toString().padLeft(2, '0')}:'
                                                  '${dt.minute.toString().padLeft(2, '0')}';
                                            } catch (_) {
                                              return dateTimeStr;
                                            }
                                          })(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16, bottom: 0, left: 0, right: 0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: TextButton.icon(
                                            onPressed: () async {
                                              await _rejectRequest(
                                                  event['id'],
                                                  events,
                                                  isLoading,
                                                  errorMessage,
                                                  context);
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
                                              backgroundColor:
                                                  Colors.transparent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
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
                                              await _acceptRequest(
                                                  event['id'],
                                                  events,
                                                  isLoading,
                                                  errorMessage,
                                                  context);
                                            },
                                            icon: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            ),
                                            label: const Text('承認',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor,
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailScreen(
                                      eventId: event['id'] as int,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                          //     event, events, isLoading, errorMessage, context),
                        ));
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
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        title: Text(
                          event['title'] ?? 'タイトル未設定',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((event['description'] ?? '')
                                .toString()
                                .isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  event['description'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Row(
                                children: [
                                  Text('開催日時:'),
                                  const SizedBox(width: 4),
                                  Text(
                                    (() {
                                      final dateTimeStr = event['startDate'];
                                      if (dateTimeStr == null ||
                                          dateTimeStr.isEmpty) {
                                        return '';
                                      }
                                      try {
                                        final dt = DateTime.parse(dateTimeStr)
                                            .toLocal();
                                        return '${dt.month.toString().padLeft(2, '0')}/'
                                            '${dt.day.toString().padLeft(2, '0')} '
                                            '${dt.hour.toString().padLeft(2, '0')}:'
                                            '${dt.minute.toString().padLeft(2, '0')}';
                                      } catch (_) {
                                        return dateTimeStr;
                                      }
                                    })(),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailScreen(
                                eventId: event['id'] as int,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }),
              ),
      ),
    );
  }

  Widget _buildEventTabs(
    ValueNotifier<int> eventTabIndex,
    ValueNotifier<List<dynamic>> requestedByCreatorEvents,
    ValueNotifier<List<dynamic>> requestedByVenueEvents,
    ValueNotifier<List<dynamic>> acceptedEvents,
    ValueNotifier<List<dynamic>> events,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
    BuildContext context,
  ) {
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
                      _buildEventTabButton('リクエスト', 0, eventTabIndex, context),
                      _buildEventTabButton('承認待ち', 1, eventTabIndex, context),
                      _buildEventTabButton('承認済み', 2, eventTabIndex, context),
                    ],
                  ),
                ),
                // タブ内容
                _buildEventTabContent(
                  eventTabIndex,
                  requestedByCreatorEvents,
                  requestedByVenueEvents,
                  acceptedEvents,
                  events,
                  isLoading,
                  errorMessage,
                  context,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
