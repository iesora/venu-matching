import 'package:mobile/src/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:mobile/src/widgets/default_button.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mobile/src/screens/auth/send_verification_screen.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  TermsOfServiceScreenState createState() => TermsOfServiceScreenState();
}

class TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _agreed = false;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
          'https://dating-demo-web-584693937256.asia-northeast1.run.app/terms-of-service'));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                "利用規約",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "本サービスをご利用いただくには、利用規約に同意する必要があります。",
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: WebViewWidget(controller: _controller),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _agreed,
                onChanged: (bool? value) {
                  setState(() {
                    _agreed = value ?? false;
                  });
                },
                title: const Text("利用規約に同意する"),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                width: double.infinity,
                child: DefaultButton(
                  backgroundColor: Colors.deepOrangeAccent,
                  onPressed: _agreed && !_isLoading
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SendVerificationScreen()),
                          );
                        }
                      : null,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "次へ",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
    );
  }
}
