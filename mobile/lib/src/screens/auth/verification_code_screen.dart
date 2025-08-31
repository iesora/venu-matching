import 'package:mobile/src/screens/auth/create_account.dart';
import 'package:mobile/src/screens/auth/select_sex_screen.dart';
import 'package:mobile/src/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:mobile/src/widgets/default_button.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  const VerificationCodeScreen({Key? key, required this.email})
      : super(key: key);

  @override
  VerificationCodeScreenState createState() => VerificationCodeScreenState();
}

class VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleVerification() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('${dotenv.get('API_URL')}/auth/verificate'),
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
              message: '認証に成功しました',
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
          body: jsonEncode(<String, String>{'email': widget.email}),
        );
        if (response.statusCode == 201) {
          showAnimatedSnackBar(
            context,
            message: '認証コードを再送しました',
            type: SnackBarType.info,
          );
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
                    "認証コードの入力",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "${widget.email} に送信した認証コードを入力して下さい。",
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
                            controller: _codeController,
                            decoration: InputDecoration(
                              labelText: "認証コード",
                              hintText: "例) 000000",
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.grey),
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[400]!),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepOrangeAccent),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              labelStyle: const TextStyle(color: Colors.black),
                              hintStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            style: const TextStyle(color: Colors.black),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
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
                      onPressed: _handleVerification,
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
                    onPressed: _handleSendVerification,
                    child: const Text(
                      "認証コードを再送する",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
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
