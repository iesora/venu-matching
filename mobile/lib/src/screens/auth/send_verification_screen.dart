import 'package:mobile/src/screens/auth/verification_code_screen.dart';
import 'package:mobile/src/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:mobile/src/widgets/default_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class SendVerificationScreen extends StatefulWidget {
  const SendVerificationScreen({super.key});

  @override
  SendVerificationScreenState createState() => SendVerificationScreenState();
}

class SendVerificationScreenState extends State<SendVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendVerification() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('${dotenv.get('API_URL')}/auth/send-verification'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'email': _emailController.text,
          }),
        );
        if (response.statusCode == 201) {
          showAnimatedSnackBar(
            context,
            message: '認証コードを送信しました',
            type: SnackBarType.success,
          );
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VerificationCodeScreen(email: _emailController.text),
              ));
        } else {
          throw Exception('認証コードの送信に失敗しました');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
                  Text(
                    "アカウント登録",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "登録するメールアドレスを入力して下さい。入力したメールアドレス宛てに認証コードを送信します。",
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
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
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepOrangeAccent),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              labelStyle: TextStyle(color: Colors.grey[800]),
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    width: double.infinity,
                    child: DefaultButton(
                      backgroundColor: Colors.deepOrangeAccent,
                      onPressed: _handleSendVerification,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "次へ",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text(
                      "ログイン画面に戻る",
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
      ),
    );
  }
}
