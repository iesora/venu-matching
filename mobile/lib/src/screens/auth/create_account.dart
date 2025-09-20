import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/src/screens/auth/select_hobby_screen.dart';
import 'package:mobile/utils/userInfo.dart';
import 'package:mobile/src/widgets/default_button.dart';
import 'package:mobile/src/widgets/terms_of_service_row.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:mobile/src/helpers/auth_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class CreateAccountScreen extends StatefulWidget {
  final String email;
  final String? sex;
  final String certificateImagePath;
  const CreateAccountScreen(
      {Key? key,
      this.sex,
      required this.email,
      required this.certificateImagePath})
      : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _selectedBirthDate;
  Prefecture? _selectedPrefecture;
  BodyType? _selectedBodyType;
  MaritalStatus? _selectedMaritalStatus;

  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
            'email': widget.email,
            'password': _passwordController.text,
          }),
        );

        final responseData = jsonDecode(response.body);
        final token = responseData['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userToken', token);
        Provider.of<AuthState>(context, listen: false).login(responseData);
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

  Future<void> _createUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
    } else {
      return;
    }

    try {
      // ユーザー情報の更新
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/user'), // TODO: 実際のユーザーIDを設定
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email,
          'nickname': _nicknameController.text,
          'sex': widget.sex,
          'birthDate': _selectedBirthDate?.toIso8601String(),
          'prefecture': _selectedPrefecture?.value,
          'height': int.tryParse(_heightController.text),
          'bodyType': _selectedBodyType?.value,
          'maritalStatus': _selectedMaritalStatus?.value,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        showAnimatedSnackBar(
          context,
          message: 'アカウントを作成しました',
          type: SnackBarType.success,
        );
        _handleSignIn();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SelectHobbyScreen()),
        );
      } else {
        throw Exception('アカウントの作成に失敗しました');
      }
    } catch (e) {
      showAnimatedSnackBar(
        context,
        message: 'エラーが発生しました',
        type: SnackBarType.error,
      );
    }
  }

  Future<String?> _uploadImageToServer() async {
    // アップロード開始前にローディング状態を有効にする
    setState(() {
      _isLoading = true;
    });

    print("certificateImagePath: ${widget.certificateImagePath}");
    final url = Uri.parse(
        'https://upload-file-dating-certificate-584693937256.asia-northeast1.run.app');
    var request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        widget.certificateImagePath,
      ),
    );
    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 201) {
        _createUser();
        return responseBody;
      } else {
        showAnimatedSnackBar(
          context,
          message: '証明書のアップロードに失敗しました',
          type: SnackBarType.error,
        );
        throw Exception('証明書のアップロードに失敗しました');
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    } finally {
      // アップロード処理完了後にローディング状態を解除する
      setState(() {
        _isLoading = false;
      });
    }
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[100]!,
            ],
          ),
        ),
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
                    "アカウント作成",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 28),
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
                            controller: _nicknameController,
                            decoration: const InputDecoration(
                              labelText: "ニックネーム",
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepOrangeAccent),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                            style: const TextStyle(color: Colors.black),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'ニックネームを入力してください';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          FormField<DateTime>(
                            validator: (value) {
                              if (_selectedBirthDate == null) {
                                return '誕生日を選択してください';
                              }
                              // 年齢計算
                              DateTime today = DateTime.now();
                              int age = today.year - _selectedBirthDate!.year;
                              if (today.month < _selectedBirthDate!.month ||
                                  (today.month == _selectedBirthDate!.month &&
                                      today.day < _selectedBirthDate!.day)) {
                                age--;
                              }
                              if (age < 18) {
                                return '未成年の方はアカウントを作成できません';
                              }
                              return null;
                            },
                            builder: (FormFieldState<DateTime> state) {
                              return InkWell(
                                onTap: () async {
                                  await _selectDate(context);
                                  state.didChange(_selectedBirthDate);
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: '誕生日',
                                    errorText: state.errorText,
                                    border: const OutlineInputBorder(),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.deepOrangeAccent),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                  ),
                                  child: Text(
                                    _selectedBirthDate != null
                                        ? '${_selectedBirthDate!.year}年${_selectedBirthDate!.month}月${_selectedBirthDate!.day}日'
                                        : '誕生日を選択してください',
                                    style: TextStyle(
                                        color: _selectedBirthDate != null
                                            ? Colors.black
                                            : Colors.grey),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<Prefecture>(
                            decoration: const InputDecoration(
                              labelText: '都道府県',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepOrangeAccent),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Colors.black),
                            value: _selectedPrefecture,
                            items: Prefecture.values.map((prefecture) {
                              return DropdownMenuItem(
                                value: prefecture,
                                child: Text(prefecture.japanName),
                              );
                            }).toList(),
                            onChanged: (Prefecture? newValue) {
                              setState(() {
                                _selectedPrefecture = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return '都道府県を選択してください';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              labelText: "身長(cm)（任意）",
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepOrangeAccent),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.black),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (int.tryParse(value) == null) {
                                  return '有効な数値を入力してください';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<BodyType>(
                            decoration: const InputDecoration(
                              labelText: '体型（任意）',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepOrangeAccent),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Colors.black),
                            value: _selectedBodyType,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text("未設定"),
                              ),
                              ...BodyType.values.map((bodyType) {
                                return DropdownMenuItem(
                                  value: bodyType,
                                  child: Text(bodyType.japanName),
                                );
                              })
                            ],
                            onChanged: (BodyType? newValue) {
                              setState(() {
                                _selectedBodyType = newValue;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<MaritalStatus>(
                            decoration: const InputDecoration(
                              labelText: '婚姻状況（任意）',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepOrangeAccent),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Colors.black),
                            value: _selectedMaritalStatus,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text("未設定"),
                              ),
                              ...MaritalStatus.values.map((maritalStatus) {
                                return DropdownMenuItem(
                                  value: maritalStatus,
                                  child: Text(maritalStatus.japanName),
                                );
                              })
                            ],
                            onChanged: (MaritalStatus? newValue) {
                              setState(() {
                                _selectedMaritalStatus = newValue;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: "パスワード",
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepOrangeAccent),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                            obscureText: true,
                            style: const TextStyle(color: Colors.black),
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
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(
                              labelText: "パスワード（確認）",
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepOrangeAccent),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                            obscureText: true,
                            style: const TextStyle(color: Colors.black),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'パスワードを入力してください';
                              }
                              if (value.length < 8) {
                                return 'パスワードは8文字以上で入力してください';
                              }
                              if (_passwordController.text != value) {
                                return 'パスワードが一致していません';
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
                      onPressed: () {
                        _uploadImageToServer();
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "アカウント作成",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
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
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ja'),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }
}
