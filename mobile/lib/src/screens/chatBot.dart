import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:mobile/src/screens/notification.dart';
import 'package:mobile/utils/userInfo.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/screens/userDetail.dart';
import 'package:mobile/src/widgets/custom_dialog.dart';
import 'package:mobile/src/widgets/web_view_page.dart';
import 'package:mobile/src/screens/createThread.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  List<types.Message> _messages = [];
  late types.User _user;
  List<dynamic>? _chatBotResponse;
  bool _isMessageSendable = true;
  int _currentPoint = 0;
  bool _isLoading = true;
  String? _botTypingMessageId; // タイピング中のメッセージIDを保持するための変数
  String _formattedResponse = '';
  bool _isUnreadNotifiationExist = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _postChatBot(String message) async {
    try {
      final token = dotenv.get('PERPLEXITY_API_KEY');
      final response = await http.post(
        Uri.parse('https://api.perplexity.ai/chat/completions'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'sonar',
          'messages': [
            {
              "role": "system",
              "content":
                  "JSON形式で返答して下さい。説明は必要ありません。{'id': 'primary_key', 'name': '飲食店名', 'address': '住所', 'description': '説明'}の配列で返答して下さい。ユーザーの提案に基づいて、おすすめの日本の飲食店の提案を行って下さい。"
            },
            {
              'role': 'user',
              'content':
                  "あなたは飲食店提案のプロです。次のメッセージに基づいて、おすすめの飲食店を提案して下さい。「$message」 "
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> dataList = jsonDecode(response.body);
        if (dataList['choices'] is List &&
            (dataList['choices'] as List).isNotEmpty) {
          final botResponse = dataList['choices'][0]['message']['content'];

          print("botResponse: ${botResponse}");

          // 先頭の ```json と末尾の ``` を削除
          final cleanedText = botResponse
              .replaceAll(RegExp(r'^```json\s*'), '')
              .replaceAll(RegExp(r'\s*```$'), '');

          // JSON 文字列としてパース
          final data = jsonDecode(cleanedText);

          print("data: ${data}");

          setState(() {
            _chatBotResponse = data;
            _messages
                .removeWhere((element) => element.id == _botTypingMessageId);
          });

          // data配列内の全ての項目に対してホットペッパーAPIを呼び出し、情報を取得する
          if (data is List && data.isNotEmpty) {
            // 各レストランの情報をまとめたリストを作成
            List<Map<String, String>> restaurants = [];
            for (var restaurant in data) {
              String restaurantUrl =
                  await _getRestaurantInfo(restaurant['name']);
              restaurants.add({
                'name': restaurant['name'],
                'address': restaurant['address'],
                'description': restaurant['description'],
                'url': restaurantUrl,
              });
            }
            // カスタムメッセージとして送信（※ flutter_chat_types の CustomMessage を利用）
            _addMessage(
              types.CustomMessage(
                author: const types.User(id: 'bot'),
                createdAt: DateTime.now().millisecondsSinceEpoch,
                id: const Uuid().v4(),
                metadata: {
                  'restaurants': restaurants,
                },
                // customType プロパティなどを付与することも可能です（ライブラリのサポート状況によります）
              ),
            );
          }
        } else {
          throw Exception('応答が正しい形式ではありません');
        }
      } else {
        throw Exception('チャットボットの応答取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      if (mounted) {
        showAnimatedSnackBar(
          context,
          message: 'チャットボットの応答取得に失敗しました',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<String> _getRestaurantInfo(String restaurantName) async {
    try {
      final token = dotenv.get('HOTPEPPER_API_KEY');
      final response = await http.get(
        Uri.parse(
            'https://webservice.recruit.co.jp/hotpepper/shop/v1/?key=$token&keyword=$restaurantName&count=1&format=json'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // data['results']?['shop'] が null の場合は空のリストを使用する
        final shopList = (data['results']?['shop'] as List?) ?? [];
        if (shopList.isNotEmpty) {
          final restaurantUrl = shopList[0]['urls']?['pc'] ?? "";
          return restaurantUrl;
        } else {
          // shopList が空の場合
          return "";
        }
      } else {
        throw Exception('チャットボットの応答取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      throw Exception('チャットボットの応答取得に失敗しました');
    }
  }

  Future<void> _checkUnreadNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/notification/check-unread'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      setState(() {
        _isUnreadNotifiationExist = data["isUnreadNotificationExist"];
      });
    } catch (e) {
      print('通知情報の取得に失敗しました: $e');
    }
  }

  Future<void> _initialize() async {
    _checkUnreadNotification();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //_showChatDialog();
      _sendBotInitialMessage();
    });
  }

  void _showChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          icon: const Icon(Icons.info_outline, size: 40, color: Colors.blue),
          title: 'チャットに関して',
          message: 'チャットでは、1回のメッセージ送信につき50ptが必要です。',
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInsufficientPointDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          icon: const Icon(Icons.warning, size: 40, color: Colors.red),
          title: 'ポイント不足',
          message: 'ポイントが不足しています。アカウント画面からポイントを追加してください。',
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages = [message, ..._messages];
    });
    print("messages: ${_messages}");
  }

  void _sendBotInitialMessage() {
    final botMessage = types.TextMessage(
      author: const types.User(id: 'bot'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: "こんにちは！ここでは私が条件に合うおすすめの飲食店を提案させていただきます。例:「岡山で美味しい洋食のお店を教えて」",
    );
    _addMessage(botMessage);
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );
    print('送信されたメッセージ: ${textMessage.text} (author.id: ${_user.id})');
    _addMessage(textMessage);

    // ユーザー送信後、ボットの応答待ちの間「...」を表示する
    final typingMessageId = const Uuid().v4();
    _botTypingMessageId = typingMessageId;
    final typingMessage = types.TextMessage(
      author: types.User(id: 'bot'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: typingMessageId,
      text: 'チャットボットが考え中です...',
    );
    _addMessage(typingMessage);
    _postChatBot(message.text);
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          icon: const Icon(Icons.info_outline, size: 40, color: Colors.blue),
          title: 'チャットボットに関して',
          message: '本チャットボットが提供する情報は正確ではない可能性があります。使用する際は必ずご自身で情報の確認をお願いいたします。',
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    _user = types.User(
      id: (authState.userInfo?['id'] ?? '').toString(),
      imageUrl: authState.userInfo?['avatar'],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/sashimeshi_horizontal_title_logo.png',
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(
                  _isUnreadNotifiationExist
                      ? Icons.notifications
                      : Icons.notifications_none,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationScreen()),
                  );
                  setState(() {
                    _isUnreadNotifiationExist = false;
                  });
                },
              ),
              if (_isUnreadNotifiationExist)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Chat(
                  messages: _messages,
                  onMessageTap: _handleMessageTap,
                  onPreviewDataFetched: _handlePreviewDataFetched,
                  onSendPressed: _handleSendPressed,
                  showUserAvatars: true,
                  showUserNames: true,
                  user: _user,
                  theme: const DefaultChatTheme(
                    backgroundColor: Colors.white,
                  ),
                  inputOptions: InputOptions(
                    enabled: _isMessageSendable,
                  ),
                  bubbleBuilder: (
                    child, {
                    required types.Message message,
                    required bool nextMessageInGroup,
                  }) {
                    // カスタムメッセージでレストラン情報が含まれている場合
                    if (message is types.CustomMessage &&
                        message.metadata != null &&
                        message.metadata!.containsKey('restaurants')) {
                      final List<dynamic> restaurants =
                          message.metadata!['restaurants'] as List<dynamic>;
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: restaurants.map((restaurant) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF42A5F5),
                                    Color(0xFFAB47BC),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        restaurant['name'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 12,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${restaurant['address'] ?? ''}',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey[600]),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${restaurant['description'] ?? ''}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      trailing: (restaurant['url'] != null &&
                                              (restaurant['url'] as String)
                                                  .startsWith('http'))
                                          ? IconButton(
                                              icon:
                                                  const Icon(Icons.open_in_new),
                                              onPressed: () async {
                                                final url = restaurant['url']!;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        WebViewPage(
                                                      title: '店舗情報',
                                                      url: url,
                                                      automaticallyImplyLeading:
                                                          true,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : null,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                        left: 16.0,
                                        right: 16.0,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            // 「この店で募集する！」ボタン押下時にCreateThreadModalを表示し、店舗情報を初期値として渡す
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (BuildContext context) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom,
                                                  ),
                                                  child: CreateThreadModal(
                                                    initialRestaurantName:
                                                        restaurant['name'],
                                                    initialRestaurantAddress:
                                                        restaurant['address'],
                                                    initialRestaurantUrl:
                                                        restaurant['url'],
                                                    onSuccess: () {
                                                      // ボタン押下後の任意の処理（必要な場合）
                                                    },
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: const Text(
                                            'この店で募集する！',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }
                    // ここ以降は既存の処理（botの場合やユーザーの場合のバブル表示）
                    if (message.author.id == 'bot') {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF5F6D),
                              Color(0xFFFFC371),
                              Color(0xFFFF5F6D),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: child,
                        ),
                      );
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: DefaultTextStyle(
                          style: const TextStyle(color: Colors.white),
                          child: child,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 8.0,
            right: 8.0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Powered by ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WebViewPage(
                            title: 'ホットペッパーグルメ Webサービス',
                            url: 'https://webservice.recruit.co.jp',
                            automaticallyImplyLeading: true,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'ホットペッパーグルメ Webサービス',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
