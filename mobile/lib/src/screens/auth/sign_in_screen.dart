import 'package:mobile/src/screens/auth/select_hobby_screen.dart';
import 'package:mobile/src/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:mobile/src/widgets/default_button.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:mobile/src/helpers/auth_state.dart';
import 'package:mobile/src/screens/auth/send_verification_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/screens/dateSpot.dart';
import 'package:mobile/src/app.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';
import 'package:mobile/src/screens/auth/terms_of_service_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('${dotenv.get('API_URL')}/auth/login'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );
        print('response.statusCode: ${response.statusCode}');
        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          final token = responseData['token'];
          final userId = responseData['id'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userToken', token);
          await prefs.setInt('userId', userId);
          Provider.of<AuthState>(context, listen: false).login(responseData);

          // ナビゲーションを修正
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MyStatefulWidget(
                  initialIndex: 0), // 修正後：ThreadScreenが表示される
            ),
            (route) => false,
          );
          showAnimatedSnackBar(
            context,
            message: 'ログインに成功しました',
            type: SnackBarType.success,
          );
        } else {
          showAnimatedSnackBar(
            context,
            message: 'ログインに失敗しました',
            type: SnackBarType.error,
          );
        }
      } catch (e) {
        showAnimatedSnackBar(
          context,
          message: 'ログインに失敗しました',
          type: SnackBarType.error,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                // 上部の余白を調整
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                // ロゴ (※背景が明るくなるため、必要に応じてロゴ画像を変更してください)
                Image.asset(
                  'assets/images/sashimeshi_vertical_title_logo.png',
                  width: 400,
                  height: 160,
                ),
                // ロゴと入力フォームの間の余白を調整
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                // フォーム
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "メールアドレス",
                          hintText: "example@email.com",
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.grey),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.deepOrangeAccent),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          labelStyle: const TextStyle(color: Colors.grey),
                          hintStyle: TextStyle(color: Colors.grey[600]),
                        ),
                        style: const TextStyle(color: Colors.black),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'メールアドレスを入力してください';
                          }
                          if (!value.contains('@')) {
                            return '有効なメールアドレスを入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "パスワード",
                          hintText: "8文字以上で入力してください",
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.grey),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.deepOrangeAccent),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          labelStyle: const TextStyle(color: Colors.grey),
                          hintStyle: TextStyle(color: Colors.grey[600]),
                        ),
                        style: const TextStyle(color: Colors.black),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'パスワードを入力してください';
                          }
                          if (value.length < 8) {
                            return 'パスワードは8文字以上で入力してください';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: DefaultButton(
                    backgroundColor: Colors.deepOrangeAccent,
                    onPressed: _handleSignIn,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "ログイン",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // パスワードリセット画面への遷移
                  },
                  child: const Text(
                    "パスワードをお忘れの方",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TermsOfServiceScreen()),
                    );
                  },
                  child: const Text(
                    "新規登録",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
                TermsOfServiceRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
