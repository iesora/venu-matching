import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
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
import 'event/matching_event_list_screen.dart';

class ChatScreen extends StatefulWidget {
  final int matchingId;
  const ChatScreen({required this.matchingId, Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<types.Message> _messages = [];
  late types.User _user;
  Map<String, dynamic>? _groupInfo;
  bool _isMessageSendable = true;
  int _currentPoint = 1000; // デフォルトポイント
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // ダミーのグループ情報を設定
    setState(() {
      _groupInfo = {
        "otherUser": {
          "id": "other_user_id",
          "nickname": "チャット相手",
          "avatar": null,
          "sex": Sex.FEMALE.value,
        },
        "me": {
          "id": "current_user_id",
          "sex": Sex.MALE.value,
          "point": _currentPoint,
        },
        "response": true,
      };
      _isMessageSendable = true;
    });

    // 初期メッセージを追加（デモ用）
    _addInitialMessages();
  }

  void _addInitialMessages() {
    final otherUser = types.User(
      id: _groupInfo!["otherUser"]["id"],
      imageUrl: _groupInfo!["otherUser"]["avatar"],
    );

    final initialMessages = [
      types.TextMessage(
        author: otherUser,
        createdAt: DateTime.now()
            .subtract(const Duration(minutes: 5))
            .millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: 'こんにちは！よろしくお願いします。',
      ),
      types.TextMessage(
        author: otherUser,
        createdAt: DateTime.now()
            .subtract(const Duration(minutes: 3))
            .millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: 'お疲れ様です！',
      ),
    ];

    setState(() {
      _messages = initialMessages;
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages = [message, ..._messages];
    });
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

    // ポイントチェック
    if (_currentPoint < 50) {
      _showInsufficientPointDialog();
      return;
    }

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

    // 画像の詳細を取得してメッセージを更新
    try {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final index = _messages.indexWhere((element) => element.id == tempId);
      if (index != -1) {
        final updatedMessage =
            (_messages[index] as types.ImageMessage).copyWith(
          height: image.height.toDouble(),
          size: bytes.length,
          width: image.width.toDouble(),
          metadata: {"isUploading": false},
        );
        setState(() {
          _messages[index] = updatedMessage;
          // ポイントを減らす
          if (_groupInfo?["me"]?["sex"] == Sex.MALE.value ||
              (_groupInfo?["me"]?["sex"] == Sex.FEMALE.value &&
                  _groupInfo?["otherUser"]?["sex"] == Sex.FEMALE.value)) {
            _currentPoint -= 50;
          }
        });
      }
    } catch (e) {
      print('画像の処理に失敗しました: $e');
      // エラーの場合、メッセージを削除
      final index = _messages.indexWhere((element) => element.id == tempId);
      if (index != -1) {
        setState(() {
          _messages.removeAt(index);
        });
      }
    }
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
    // ポイントチェック
    if (_currentPoint < 50) {
      _showInsufficientPointDialog();
      return;
    }

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    // ポイントを減らす
    if (_groupInfo?["me"]?["sex"] == Sex.MALE.value ||
        (_groupInfo?["me"]?["sex"] == Sex.FEMALE.value &&
            _groupInfo?["otherUser"]?["sex"] == Sex.FEMALE.value)) {
      setState(() {
        _currentPoint -= 50;
      });
    }
  }

  void _showInsufficientPointDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          icon: const Icon(Icons.warning, size: 40, color: Colors.orange),
          title: 'ポイント不足',
          message: 'メッセージを送信するのに十分なポイントがありません。',
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
      id: (authState.userInfo?['id'] ?? 'current_user_id').toString(),
      imageUrl: authState.userInfo?['avatar'],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                child: IconButton(
                  icon: const Icon(Icons.event, color: Colors.black),
                  tooltip: "イベントリスト",
                  onPressed: () {
                    print('presss button');
                    // イベントリスト画面に遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchingEventListScreen(
                          matchingId: widget.matchingId,
                        ),
                      ),
                    );
                  },
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
