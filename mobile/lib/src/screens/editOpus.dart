import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class EditOpusBottomSheet extends StatefulWidget {
  final Map<String, dynamic> opus;
  final int creatorId;
  final Function? onSuccess;

  const EditOpusBottomSheet({
    Key? key,
    required this.opus,
    required this.creatorId,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<EditOpusBottomSheet> createState() => _EditOpusBottomSheetState();
}

class _EditOpusBottomSheetState extends State<EditOpusBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
//   File? _selectedImage;
  Uint8List? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.opus['name'] ?? '';
    _descriptionController.text = widget.opus['description'] ?? '';
    _nameController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty && _nameController.text.length <= 50;
  }

  Future<void> _pickImage() async {
    try {
      print('pickImage');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final imageFile = File(image.path);
        //この下でエラー
        final bytes = await imageFile.readAsBytes();
        // final fileName = file.path.split('/').last;
        // print("image: ${file.path}");
        setState(() {
          _selectedImage = bytes;
        });
      }
    } catch (e) {
      print('画像選択エラー: $e');
      showAnimatedSnackBar(
        context,
        message: '画像の選択に失敗しました',
        type: SnackBarType.error,
      );
    }
  }

//   Future<String?> _uploadImage(File imageFile) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('userToken');

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('${dotenv.get('API_URL')}/upload/image'),
//       );

//       request.headers['Authorization'] = 'Bearer $token';
//       request.files.add(
//         await http.MultipartFile.fromPath('file', imageFile.path),
//       );

//       var response = await request.send();

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseBody = await response.stream.bytesToString();
//         final data = jsonDecode(responseBody);
//         return data['url'];
//       } else {
//         throw Exception('画像のアップロードに失敗しました');
//       }
//     } catch (e) {
//       print('画像アップロードエラー: $e');
//       return null;
//     }
//   }
  Future<String?> _uploadImageToServer(File imageFile) async {
    final url = Uri.parse(
        'https://upload-file-dating-584693937256.asia-northeast1.run.app');
    print("save image");
    var request = http.MultipartRequest('POST', url);

    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      final fileName = imageFile.path.split('/').last;
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
          imageFile.path,
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

  Future<void> _updateOpus() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      String? imageUrl = widget.opus['imageUrl'];

      // 新しい画像が選択されている場合はアップロード
      if (_selectedImage != null) {
        // final uploadedUrl = await _uploadImageToServer(_selectedImage!);
        // if (uploadedUrl != null) {
        //   imageUrl = uploadedUrl;
        // }
      }

      final response = await http.patch(
        Uri.parse(
            '${dotenv.get('API_URL')}/creator/${widget.creatorId}/opus/${widget.opus['id']}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }

        Navigator.pop(context);

        showAnimatedSnackBar(
          context,
          message: '作品を更新しました',
          type: SnackBarType.success,
        );
      } else {
        throw Exception('作品の更新に失敗しました');
      }
    } catch (e) {
      print('エラー: $e');
      showAnimatedSnackBar(
        context,
        message: '作品の更新に失敗しました',
        type: SnackBarType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteOpus() async {
    // 確認ダイアログを表示
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('作品を削除'),
          content: const Text('本当にこの作品を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      final response = await http.delete(
        Uri.parse(
            '${dotenv.get('API_URL')}/creator/${widget.creatorId}/opus/${widget.opus['id']}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }

        Navigator.pop(context);

        showAnimatedSnackBar(
          context,
          message: '作品を削除しました',
          type: SnackBarType.success,
        );
      } else {
        throw Exception('作品の削除に失敗しました');
      }
    } catch (e) {
      print('エラー: $e');
      showAnimatedSnackBar(
        context,
        message: '作品の削除に失敗しました',
        type: SnackBarType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 667.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // モーダルのハンドル
                Center(
                  child: Container(
                    width: 30,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ヘッダー
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '作品編集',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: _isLoading ? null : _deleteOpus,
                          iconSize: 20,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                          iconSize: 18,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 画像プレビュー
                Center(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _pickImage,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey[400]!, width: 1),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (widget.opus['imageUrl'] != null &&
                                  widget.opus['imageUrl'].toString().isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.opus['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate,
                                              size: 40, color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text('画像を選択',
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate,
                                          size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('画像を選択',
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 作品名入力
                Row(
                  children: [
                    const Icon(
                      Icons.palette,
                      size: 12,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '作品名',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  maxLength: 50,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '作品名を入力',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    counterText: '${_nameController.text.length}/50',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '作品名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 作品説明入力
                Row(
                  children: [
                    const Icon(
                      Icons.description,
                      size: 12,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '作品説明',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLength: 500,
                  maxLines: 5,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '作品の説明を入力（任意）',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    counterText: '${_descriptionController.text.length}/500',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 24),

                // 保存ボタン
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed:
                        (_isFormValid && !_isLoading) ? _updateOpus : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '保存',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
