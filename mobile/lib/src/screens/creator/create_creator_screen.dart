import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class CreateCreatorScreen extends HookWidget {
  const CreateCreatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final emailController = useTextEditingController();
    final websiteController = useTextEditingController();
    final phoneController = useTextEditingController();
    final socialMediaController = useTextEditingController();
    final imageUrlController = useTextEditingController();
    final isLoading = useState<bool>(false);

    Future<void> _createCreator() async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      try {
        isLoading.value = true;
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');

        final creatorData = {
          'name': nameController.text,
          'description': descriptionController.text.isNotEmpty
              ? descriptionController.text
              : null,
          'email':
              emailController.text.isNotEmpty ? emailController.text : null,
          'website':
              websiteController.text.isNotEmpty ? websiteController.text : null,
          'phoneNumber':
              phoneController.text.isNotEmpty ? phoneController.text : null,
          'socialMediaHandle': socialMediaController.text.isNotEmpty
              ? socialMediaController.text
              : null,
          'imageUrl': imageUrlController.text.isNotEmpty
              ? imageUrlController.text
              : null,
        };

        final response = await http.post(
          Uri.parse('${dotenv.get('API_URL')}/creator'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(creatorData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          showAnimatedSnackBar(
            context,
            message: 'クリエイターが正常に作成されました！',
            type: SnackBarType.success,
          );
          Navigator.pop(context, true); // 成功時にtrueを返す
        } else {
          final errorData = jsonDecode(response.body);
          showAnimatedSnackBar(
            context,
            message: errorData['message'] ?? 'クリエイターの作成に失敗しました',
            type: SnackBarType.error,
          );
        }
      } catch (e) {
        print('エラー: $e');
        showAnimatedSnackBar(
          context,
          message: 'クリエイターの作成に失敗しました',
          type: SnackBarType.error,
        );
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'クリエイター登録',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        // elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios),
        //   onPressed: () => Navigator.pop(context),
        // )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // プロフィール画像セクション
              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   elevation: 2,
              //   child: Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: Column(
              //       children: [
              //         const Text(
              //           'プロフィール画像',
              //           style: TextStyle(
              //             fontSize: 16,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //         const SizedBox(height: 16),
              //         CircleAvatar(
              //           radius: 60,
              //           backgroundColor: Colors.grey[200],
              //           backgroundImage: imageUrlController.text.isNotEmpty
              //               ? NetworkImage(imageUrlController.text)
              //               : null,
              //           child: imageUrlController.text.isEmpty
              //               ? const Icon(Icons.person,
              //                   size: 60, color: Colors.grey)
              //               : null,
              //         ),
              //         const SizedBox(height: 16),
              //         TextFormField(
              //           controller: imageUrlController,
              //           decoration: const InputDecoration(
              //             labelText: '画像URL',
              //             hintText: 'https://example.com/image.jpg',
              //             border: OutlineInputBorder(),
              //             prefixIcon: Icon(Icons.image),
              //           ),
              //           validator: (value) {
              //             if (value != null && value.isNotEmpty) {
              //               final uri = Uri.tryParse(value);
              //               if (uri == null || !uri.hasAbsolutePath) {
              //                 return '有効なURLを入力してください';
              //               }
              //             }
              //             return null;
              //           },
              //           onChanged: (value) {
              //             // リアルタイムで画像プレビューを更新
              //           },
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 16),

              // 基本情報セクション
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '基本情報',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'クリエイター名 *',
                          hintText: 'クリエイター名を入力',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'クリエイター名は必須です';
                          }
                          if (value.length > 255) {
                            return '255文字以内で入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: '説明',
                          hintText: 'クリエイターについて説明してください',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 4,
                        maxLength: 1000,
                        validator: (value) {
                          if (value != null && value.length > 1000) {
                            return '1000文字以内で入力してください';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 連絡先情報セクション
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '連絡先情報',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'メールアドレス',
                          hintText: 'example@email.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return '有効なメールアドレスを入力してください';
                            }
                            if (value.length > 255) {
                              return '255文字以内で入力してください';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: '電話番号',
                          hintText: '090-1234-5678',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length > 255) {
                            return '255文字以内で入力してください';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ウェブ情報セクション
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ウェブ情報',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: websiteController,
                        decoration: const InputDecoration(
                          labelText: 'ウェブサイト',
                          hintText: 'https://example.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final uri = Uri.tryParse(value);
                            if (uri == null || !uri.hasAbsolutePath) {
                              return '有効なURLを入力してください';
                            }
                            if (value.length > 255) {
                              return '255文字以内で入力してください';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: socialMediaController,
                        decoration: const InputDecoration(
                          labelText: 'ソーシャルメディア',
                          hintText: '@username',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length > 255) {
                            return '255文字以内で入力してください';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 作成ボタン
              ElevatedButton(
                onPressed: isLoading.value ? null : _createCreator,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
                child: isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'クリエイターを作成',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
