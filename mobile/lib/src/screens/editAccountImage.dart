import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:mobile/utils/userInfo.dart';
import 'other.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_dialog.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class EditAccountImageScreen extends StatefulWidget {
  @override
  State<EditAccountImageScreen> createState() => _EditAccountImageScreenState();
}

class _EditAccountImageScreenState extends State<EditAccountImageScreen> {
  XFile? _pickedFile;
  CroppedFile? _croppedFile;
  List<Map<String, dynamic>> imageUrls = [];
  String _currentAvatar = "";
  static const int maxImages = 6; // 最大
  bool _isAvatar = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetail();
  }

  Future<void> _fetchUserDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/user'), // TODO: ユーザーIDを動的に設定
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          Map<String, dynamic> data = jsonDecode(response.body);
          _currentAvatar = data["avatar"];
          List<dynamic> images = data['userMedia'];
          images.map((image) {
            if (image != null) {
              print('ImageUrl: ${image["mediaUrl"]}');
              imageUrls.add({
                "imageUrl": image["mediaUrl"],
                "mediaId": image["id"], // IDを保存
              });
            }
          }).toList();
        });
      } else {
        throw Exception('ユーザー情報の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      if (mounted) {
        showAnimatedSnackBar(
          context,
          message: 'ユーザー情報の取得に失敗しました',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _addUserMedia(String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/user/media'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mediaUrl': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          imageUrls.add({
            "imageUrl": imageUrl,
            "mediaId": data["id"],
          });
        });
        print('写真の追加に成功しました');
      } else {
        print('写真の追加に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('写真の追加に失敗しました: $e');
    }
  }

  Future<void> _deleteImage(int mediaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.delete(
        Uri.parse('${dotenv.get('API_URL')}/user/media'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mediaId': mediaId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          imageUrls.removeWhere((image) => image['mediaId'] == mediaId);
        });
        print('写真の削除に成功しました');
      } else {
        print('写真の削除に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('写真の削除に失敗しました: $e');
    }
  }

  Future<void> _changeAvatar(String imageUrl) async {
    try {
      // ユーザー情報の更新
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/user'), // TODO: 実際のユーザーIDを設定
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'avatar': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentAvatar = data["avatar"];
        });
        if (imageUrl == "") {
          print('写真の削除に成功しました');
          /*
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('プロフィール写真を削除しました')),
          );
          */
        } else {
          print('写真の削除に失敗しました: ${response.statusCode}');
          /*
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('プロフィール写真を追加しました')),
          );
          */
        }
      } else {
        throw Exception('更新に失敗しました');
      }
    } catch (e) {
      print('プロフィール写真の更新に失敗しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 共通のInputDecorationを定義
    const inputDecoration = InputDecoration(
      labelStyle: TextStyle(color: Colors.black87),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      border: OutlineInputBorder(),
      fillColor: Colors.white,
      filled: true,
    );

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 1.0,
          title: Text(
            'プロフィール画像の編集',
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // カスタムの戻るアイコン
            onPressed: () {
              Navigator.pop(context, true); // 戻る際にtrueを返す
            },
          ),
        ),
        body: _body());
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プロフィール写真セクション
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Text(
                'プロフィール写真',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _avatarImage(),
            const SizedBox(height: 16),
            // その他の写真セクション
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Text(
                'その他の写真',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true, // グリッドの高さをコンテンツに合わせて調整
              physics:
                  const NeverScrollableScrollPhysics(), // GridViewのスクロールを無効化
              itemCount: maxImages,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 16.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                if (index < imageUrls.length) {
                  return _imageCard(imageUrls[index]);
                } else {
                  return _uploaderCard();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCard(Map<String, dynamic> image) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              elevation: 4.0,
              child: Stack(
                children: [
                  Container(
                    child: _image(image["imageUrl"]!),
                  ),
                  Positioned(
                    top: 2.0,
                    right: 2.0,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 12.0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24.0,
                          minHeight: 24.0,
                        ),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 12.0,
                        ),
                        onPressed: () {
                          print("mediaId: ${image["mediaId"]}");
                          _showDeleteImageDialog(image["mediaId"] as int);
                        },
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

  Widget _image(String imageUrl) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 110,
        maxHeight: 110,
      ),
      child: Image.network(imageUrl),
    );
  }

  Widget _menu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () {
            _clear();
          },
          backgroundColor: Colors.redAccent,
          tooltip: 'Delete',
          child: const Icon(Icons.delete),
        ),
        if (_croppedFile == null)
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: FloatingActionButton(
              onPressed: () {
                _cropImage(_isAvatar);
              },
              backgroundColor: Colors.orange.shade300,
              tooltip: 'Crop',
              child: const Icon(Icons.crop),
            ),
          )
      ],
    );
  }

  Widget _uploaderCard() {
    return Center(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.grey[200],
        child: SizedBox(
          width: 90,
          height: 160,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: DottedBorder(
                //radius: const Radius.circular(12.0),
                //borderType: BorderType.RRect,
                //dashPattern: const [8, 4],
                //color: Colors.grey,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '写真を追加',
                        style: kIsWeb
                            ? Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(color: Colors.grey[700], fontSize: 10)
                            : Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Colors.grey[700], fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isAvatar = false;
                          });
                          _uploadImage(_isAvatar);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade300,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarImage() {
    if (_currentAvatar != "") {
      return _avatarCard();
    } else {
      return _avatarUploaderCard();
    }
  }

  Widget _avatarCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              elevation: 4.0,
              child: Stack(
                children: [
                  Container(
                    child: _avatar(),
                  ),
                  Positioned(
                    top: 2.0,
                    right: 2.0,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 16.0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 20.0,
                        ),
                        onPressed: () {
                          _showDeleteImageDialog(null);
                        },
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

  Widget _avatar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 0.8 * screenWidth,
        maxHeight: 0.7 * screenHeight,
      ),
      child: Image.network(_currentAvatar),
    );
  }

  Widget _avatarUploaderCard() {
    return Center(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.grey[200],
        child: SizedBox(
          width: 350,
          height: 350,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: DottedBorder(
                //  radius: const Radius.circular(12.0),
                //borderType: BorderType.RRect,
                //dashPattern: const [8, 4],
                //color: Colors.grey,
                //strokeWidth: 2,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'プロフィール写真',
                        style: kIsWeb
                            ? Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(color: Colors.grey[700], fontSize: 20)
                            : Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Colors.grey[700],
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isAvatar = true;
                          });
                          _uploadImage(_isAvatar);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade300,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(14.0),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage(bool isAvatar) async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPresetCustom(),
            ],
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPresetCustom(),
            ],
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(
              width: 520,
              height: 400,
            ),
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });

        // クロップ後に画像アップロード
        final imageUrl = await _uploadImageToServer(croppedFile.path);
        if (imageUrl != null) {
          if (isAvatar) {
            _changeAvatar(imageUrl);
            setState(() {
              isAvatar = false;
            });
          } else {
            _addUserMedia(imageUrl);
          }
          _clear();
          log('Uploaded cropped image: $imageUrl');
        }
      }
    }
  }

  Future<void> _uploadImage(bool isAvatar) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
      // 画像選択後すぐにクロップモードを開始
      await _cropImage(isAvatar);
    }
  }

  Future<String?> _uploadImageToServer(String imagePath) async {
    final url = Uri.parse(
        'https://upload-file-dating-584693937256.asia-northeast1.run.app');
    print("save image");
    var request = http.MultipartRequest('POST', url);

    if (kIsWeb) {
      final bytes = await File(imagePath).readAsBytes();
      final fileName = imagePath.split('/').last;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imagePath,
        ),
      );
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      return responseBody;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _clear() {
    setState(() {
      _pickedFile = null;
      _croppedFile = null;
    });
  }

  void _showDeleteImageDialog(int? mediaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          icon: const Icon(Icons.delete_outline, size: 40, color: Colors.red),
          title: '写真の削除',
          message: '本当に写真を削除しますか？',
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'キャンセル',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                if (mediaId == null) {
                  _changeAvatar("");
                } else {
                  _deleteImage(mediaId);
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '削除',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
