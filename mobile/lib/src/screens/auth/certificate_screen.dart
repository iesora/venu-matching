import 'package:mobile/src/screens/account.dart';
import 'package:mobile/src/screens/auth/create_account.dart';
import 'package:mobile/src/screens/auth/select_sex_screen.dart';
import 'package:mobile/src/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:mobile/src/widgets/default_button.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile/src/widgets/custom_snackbar.dart';

class CertificateScreen extends StatefulWidget {
  final String email;
  final String? sex;
  const CertificateScreen({Key? key, required this.email, this.sex})
      : super(key: key);

  @override
  CertificateScreenState createState() => CertificateScreenState();
}

class CertificateScreenState extends State<CertificateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  XFile? _pickedFile;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // 画像選択のみを行い、後で「次へ」ボタンでアップロード処理を実行
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print('画像が選択されました:');
      print('ファイル名: ${pickedFile.name}');
      print('ファイルパス: ${pickedFile.path}');
      setState(() {
        _pickedFile = pickedFile;
      });
    } else {
      print('画像の選択がキャンセルされました');
    }
  }

  Future<String?> _uploadImageToServer(String imagePath) async {
    final url = Uri.parse(
        'https://upload-file-dating-certificate-584693937256.asia-northeast1.run.app');
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

  /*
  void _uploadFile() async {
    if (_formKey.currentState!.validate() && _pickedFile != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('送信する画像情報:');
        print('ファイル名: ${_pickedFile?.name}');
        print('ファイルパス: ${_pickedFile?.path}');

        final response = await http.post(
          Uri.parse('http://localhost:3005/save-file'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'email': widget.email,
            'code': _codeController.text,
          }),
        );

        if (response.statusCode == 201) {
          bool isMatchCode = jsonDecode(response.body);
          if (isMatchCode) {
            showAnimatedSnackBar(
              context,
              message: 'ファイルのアップロードに成功しました',
              type: SnackBarType.success,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectSexScreen(email: widget.email),
              ),
            );
          } else {
            showAnimatedSnackBar(
              context,
              message: '認証コードが正しくありません',
              type: SnackBarType.error,
            );
          }
        } else {
          throw Exception('ファイルのアップロードに失敗しました');
        }
      } catch (e) {
        showAnimatedSnackBar(
          context,
          message: 'ネットワークエラーが発生しました',
          type: SnackBarType.error,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  */

  Widget _imageSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DottedBorder(
            // borderType: BorderType.RRect,
            // radius: const Radius.circular(12),
            // dashPattern: const [8, 4],
            // color: Colors.grey,
            child: SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _pickedFile != null ? Icons.check_circle : Icons.image,
                      size: 80,
                      color: Colors.deepOrange.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pickedFile != null ? '画像が選択されました' : 'タップして画像を選択',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "証明書のアップロード",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "本人確認のため、運転免許証やマイナンバーカード、健康保険証などの本人確認書類の画像をアップロードしてください。",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    _imageSection(),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: DefaultButton(
                        backgroundColor: (_pickedFile != null)
                            ? Colors.deepOrangeAccent
                            : Colors.grey,
                        onPressed: _pickedFile != null
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateAccountScreen(
                                      email: widget.email,
                                      sex: widget.sex,
                                      certificateImagePath: _pickedFile!.path,
                                    ),
                                  ),
                                )
                            : null,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "次へ",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TermsOfServiceRow(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
