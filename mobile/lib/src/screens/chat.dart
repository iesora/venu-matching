import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
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
import 'package:mobile/src/widgets/custom_snackbar.dart';

class ChatScreen extends StatefulWidget {
  final int groupId;
  const ChatScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<types.Message> _messages = [];
  late types.User _user;
  Map<String, dynamic>? _groupInfo;
  bool _isMessageSendable = true;
  int _currentPoint = 0;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _initialize();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _refreshMessages();
      }
    });
  }

  Future<void> _refreshMessages() async {
    print("refreshMessages");
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      final response = await http.get(
        Uri.parse(
            '${dotenv.get('API_URL')}/messages?groupId=${widget.groupId}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final messages = (jsonDecode(response.body) as List).map((e) {
          final data = e as Map<String, dynamic>;
          final authorImage = data['author']?['avatar'] ?? "";

          if (data['type'] == 'image') {
            return types.ImageMessage(
              author: types.User(
                id: (data['author']?['id'] ?? '').toString(),
                imageUrl: authorImage.isNotEmpty ? authorImage : null,
              ),
              createdAt:
                  DateTime.parse(data['createdAt']).millisecondsSinceEpoch,
              id: data['id'].toString(),
              name: data['name'] ?? '',
              uri: data['url'] ?? '',
              size: 200 * 200,
              width: 200,
            );
          }

          return types.TextMessage(
            author: types.User(
              id: (data['author']?['id'] ?? '').toString(),
              imageUrl: authorImage.isNotEmpty ? authorImage : null,
            ),
            id: data['id'].toString(),
            text: data['text'] ?? '',
            createdAt: DateTime.parse(data['createdAt']).millisecondsSinceEpoch,
          );
        }).toList();

        if (messages.length != _messages.length ||
            (messages.isNotEmpty &&
                _messages.isNotEmpty &&
                messages.first.id != _messages.first.id)) {
          setState(() {
            _messages = messages;
          });
        }
      }
    } catch (e) {
      print('メッセージの更新に失敗しました: $e');
    }
  }

  Future<void> _initialize() async {
    await _getGroupDetail();
    if (_groupInfo != null) {
      if (_groupInfo!["me"]!["sex"] == Sex.MALE.value ||
          (_groupInfo!["me"]!["sex"] == Sex.FEMALE.value &&
              _groupInfo!["otherUser"]!["sex"] == Sex.FEMALE.value)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showChatDialog();
        });
      }
    }
  }

  Future<void> _getGroupDetail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/group?groupId=${widget.groupId}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _groupInfo = jsonDecode(response.body);
          _isMessageSendable = _groupInfo!["response"];
          _currentPoint = _groupInfo!["me"]!["point"];
        });
      } else {
        throw Exception('グループユーザー情報の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      if (mounted) {
        showAnimatedSnackBar(
          context,
          message: 'グループユーザー情報の取得に失敗しました',
          type: SnackBarType.error,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createLike() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/matching/response'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fromUserId': _groupInfo?["otherUser"]?["id"],
          'isMatching': true,
        }),
      );

      if (response.statusCode == 200) {
        print('マッチングに成功しました');
      } else {
        print('マッチングに失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('マッチングに失敗しました: $e');
    }
  }

  Future<void> _createNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/notification'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': _groupInfo?["otherUser"]?["id"],
          'chatGroupId': widget.groupId,
          'notificationType': NotificationType.CHAT.value,
        }),
      );

      if (response.statusCode == 201) {
        print('通知の送信に成功しました');
      } else {
        print('通知の送信に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('通知の送信に失敗しました: $e');
    }
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
  }

  Future<String?> _uploadImageToServer(String imagePath) async {
    print("imagePath: $imagePath");
    final url = Uri.parse('https://mglamsdglaskl.help/subdir/');
    var request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imagePath,
      ),
    );
    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      return responseBody;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Widget _customImageMessageBuilder(
    types.ImageMessage imageMessage, {
    required int messageWidth,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _handleMessageTap(context, imageMessage),
          child: imageMessage.uri.startsWith('http')
              ? Image.network(
                  imageMessage.uri,
                  width: messageWidth.toDouble(),
                  height: messageWidth.toDouble(),
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(imageMessage.uri),
                  width: messageWidth.toDouble(),
                  height: messageWidth.toDouble(),
                  fit: BoxFit.cover,
                ),
        ),
        if (imageMessage.metadata != null &&
            imageMessage.metadata?["isUploading"] == true)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );
    if (result == null) return;

    final imageUrl = await _uploadImageToServer(result.path);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/messages'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': const Uuid().v4(),
          'text': "",
          'url': imageUrl,
          'groupId': widget.groupId,
          'type': 'image',
        }),
      );
      if (response.statusCode == 201) {
        final tempId = const Uuid().v4();
        final tempMessage = types.ImageMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          height: 0,
          id: tempId,
          name: result.name,
          size: 0,
          uri: result.path,
          width: 0,
          metadata: {"isUploading": true},
        );
        _addMessage(tempMessage);
        if (imageUrl != null) {
          final bytes = await result.readAsBytes();
          final image = await decodeImageFromList(bytes);
          final index = _messages.indexWhere((element) => element.id == tempId);
          if (index != -1) {
            final updatedMessage =
                (_messages[index] as types.ImageMessage).copyWith(
              height: image.height.toDouble(),
              size: bytes.length,
              uri: imageUrl,
              width: image.width.toDouble(),
              metadata: {"isUploading": false},
            );
            setState(() {
              _messages[index] = updatedMessage;
            });
            _createNotification();
            if (_groupInfo?["me"]?["sex"] == Sex.MALE.value ||
                (_groupInfo?["me"]?["sex"] == Sex.FEMALE.value &&
                    _groupInfo?["otherUser"]?["sex"] == Sex.FEMALE.value)) {
              setState(() {
                print("abcdef");
                _currentPoint -= 50;
              });
            }
          }
        } else {
          final index = _messages.indexWhere((element) => element.id == tempId);
          if (index != -1) {
            setState(() {
              _messages.removeAt(index);
            });
          }
          _showInsufficientPointDialog();
        }
      } else {
        _showInsufficientPointDialog();
      }
    } catch (e) {
      print("メッセージの送信に失敗しました");
    }

    /*
    final tempId = const Uuid().v4();
    final tempMessage = types.ImageMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      height: 0,
      id: tempId,
      name: result.name,
      size: 0,
      uri: result.path,
      width: 0,
      metadata: {"isUploading": true},
    );
    _addMessage(tempMessage);

    final imageUrl = await _uploadImageToServer(result.path);

    if (imageUrl != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final index = _messages.indexWhere((element) => element.id == tempId);
      if (index != -1) {
        final updatedMessage =
            (_messages[index] as types.ImageMessage).copyWith(
          height: image.height.toDouble(),
          size: bytes.length,
          uri: imageUrl,
          width: image.width.toDouble(),
          metadata: {"isUploading": false},
        );
        setState(() {
          _messages[index] = updatedMessage;
        });
        _createNotification();
        if (_groupInfo?["me"]?["sex"] == Sex.MALE.value) {
          setState(() {
            _currentPoint -= 50;
          });
        }
      }
    } else {
      final index = _messages.indexWhere((element) => element.id == tempId);
      if (index != -1) {
        setState(() {
          _messages.removeAt(index);
        });
      }
      _showInsufficientPointDialog();
    }
    */
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.ImageMessage) {
      _showImageModal(context, message.uri);
    } else if (message is types.FileMessage) {
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

  void _showImageModal(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4,
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  )
                : Image.file(
                    File(imageUrl),
                    fit: BoxFit.contain,
                  ),
          ),
        );
      },
    );
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

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/messages'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': const Uuid().v4(),
          'text': message.text,
          'groupId': widget.groupId,
          'type': 'text',
        }),
      );
      if (response.statusCode == 201) {
        _addMessage(textMessage);
        _createNotification();
        if (_groupInfo?["me"]?["sex"] == Sex.MALE.value ||
            (_groupInfo?["me"]?["sex"] == Sex.FEMALE.value &&
                _groupInfo?["otherUser"]?["sex"] == Sex.FEMALE.value)) {
          setState(() {
            _currentPoint -= 50;
          });
        }
      } else {
        _showInsufficientPointDialog();
      }
    } catch (e) {
      print("メッセージの送信に失敗しました");
    }
  }

  void _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    final response = await http.get(
      Uri.parse('${dotenv.get('API_URL')}/messages?groupId=${widget.groupId}'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final messages = (jsonDecode(response.body) as List).map((e) {
      final data = e as Map<String, dynamic>;
      final authorImage = data['author']?['avatar'] ?? "";

      if (data['type'] == 'image') {
        return types.ImageMessage(
          author: types.User(
            id: (data['author']?['id'] ?? '').toString(),
            imageUrl: authorImage.isNotEmpty ? authorImage : null,
          ),
          createdAt: DateTime.parse(data['createdAt']).millisecondsSinceEpoch,
          id: data['id'].toString(),
          name: data['name'] ?? '',
          uri: data['url'] ?? '',
          size: 200 * 200, // 1MB
          width: 200, // 一般的な画像の幅
        );
      }

      return types.TextMessage(
        author: types.User(
          id: (data['author']?['id'] ?? '').toString(),
          imageUrl: authorImage.isNotEmpty ? authorImage : null,
        ),
        id: data['id'].toString(),
        text: data['text'] ?? '',
        createdAt: DateTime.parse(data['createdAt']).millisecondsSinceEpoch,
      );
    }).toList();

    setState(() {
      _messages = messages;
    });
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
        iconTheme: const IconThemeData(color: Colors.black),
        title: GestureDetector(
          onTap: () {
            if (_groupInfo?["otherUser"]?["id"] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailScreen(
                    userId: _groupInfo!["otherUser"]["id"],
                  ),
                ),
              );
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_groupInfo?["otherUser"]?["nickname"] ?? ""}',
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Noto Sans JP',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.black,
                size: 20,
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        actions: [
          if (_groupInfo != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '残り $_currentPoint pt',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Noto Sans JP',
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!_isMessageSendable)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              _groupInfo?["otherUser"]?["avatar"] != null
                                  ? NetworkImage(
                                      _groupInfo?["otherUser"]?["avatar"])
                                  : null,
                          backgroundColor: Colors.grey,
                          // radius: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'このユーザーとマッチングしていないため、メッセージを送信できません。マッチングしますか？',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Noto Sans JP',
                              fontSize: 12,
                            ),
                            softWrap: true,
                          ),
                        ),
                        SizedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              _createLike();
                              setState(() {
                                _isMessageSendable = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
                              'マッチングする',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Chat(
                    messages: _messages,
                    onAttachmentPressed: _handleAttachmentPressed,
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
                    imageMessageBuilder: _customImageMessageBuilder,
                  ),
                ),
              ],
            ),
    );
  }
}
