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
import 'package:mobile/src/widgets/custom_snackbar.dart';

class EditLikeFaceScreen extends StatefulWidget {
  @override
  State<EditLikeFaceScreen> createState() => _EditLikeFaceScreenState();
}

class _EditLikeFaceScreenState extends State<EditLikeFaceScreen> {
  XFile? _pickedFile;
  CroppedFile? _croppedFile;
  List<Map<String, dynamic>> imageUrls = [];
  static const int maxImages = 9; // 最大

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
          List<dynamic> images = data['userLikeFaces'];
          images.map((image) {
            if (image != null) {
              print('ImageUrl: ${image["imageUrl"]}');
              imageUrls.add({
                "imageUrl": image["imageUrl"],
                "likeFaceId": image["id"], // IDを保存
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

  Future<void> _addUserLikeFace(String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/user/like-face'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          imageUrls.add({
            "imageUrl": imageUrl,
            "likeFaceId": data["id"],
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

  Future<void> _deleteImage(int likeFaceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.delete(
        Uri.parse('${dotenv.get('API_URL')}/user/like-face'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'likeFaceId': likeFaceId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          imageUrls.removeWhere((image) => image['likeFaceId'] == likeFaceId);
        });
        print('写真の削除に成功しました');
      } else {
        print('写真の削除に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('写真の削除に失敗しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 共通のInputDecorationを定義
    const inputDecoration = InputDecoration(
      labelStyle: TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      border: OutlineInputBorder(),
      fillColor: Colors.white10,
      filled: true,
    );

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.grey),
          title: const Text(
            '好みの顔写真の編集',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Noto Sans JP',
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
        ),
        body: _body());
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GridView.builder(
        itemCount:
            imageUrls.length < maxImages ? imageUrls.length + 1 : maxImages,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 列数を指定
          crossAxisSpacing: 4.0, // 横方向の余白
          mainAxisSpacing: 16.0, // 縦方向の余白
        ),
        itemBuilder: (BuildContext context, int index) {
          if (index < imageUrls.length) {
            return _imageCard(imageUrls[index]);
          } else {
            return _uploaderCard();
          }
        },
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
                      backgroundColor: Colors.grey[800],
                      //radius: 8.0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12.0,
                        ),
                        onPressed: () {
                          print("likeFaceId: ${image["likeFaceId"]!}");
                          _showDeleteImageDialog(image["likeFaceId"] as int);
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
    //final screenWidth = MediaQuery.of(context).size.width;
    //final screenHeight = MediaQuery.of(context).size.height;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 120,
        maxHeight: 120,
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
                _cropImage();
              },
              backgroundColor: const Color(0xFFBC764A),
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
                // dashPattern: const [8, 4],
                // color: Colors.grey,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '顔写真を追加',
                        style: kIsWeb
                            ? Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(color: Colors.grey[500], fontSize: 10)
                            : Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Colors.grey[500], fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () {
                          _uploadImage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
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

  Future<void> _cropImage() async {
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
          _addUserLikeFace(imageUrl);
          _clear();
          log('Uploaded cropped image: $imageUrl');
        }
      }
    }
  }

  Future<void> _uploadImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
      // 画像選択後すぐにクロップモードを開始
      await _cropImage();
    }
  }

  Future<String?> _uploadImageToServer(String imagePath) async {
    final url = Uri.parse('https://mglamsdglaskl.help/subdir/');
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

  void _showDeleteImageDialog(int likeFaceId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('写真の削除'),
          content: const Text('本当に写真を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                _deleteImage(likeFaceId);
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('削除'),
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
