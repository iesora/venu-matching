import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/utils/userInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  DateTime? _selectedDate;
  Prefecture? _selectedPrefecture;
  Income? _selectedIncome;
  BodyType? _selectedBodyType;
  ActivityType? _selectedActivityType;
  Occupation? _selectedOccupation;
  MaritalStatus? _selectedMaritalStatus;
  ConvenientTime? _selectedConvenientTime;
  Sex? _selectedSex;
  final _heightController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _selfIntroductionController = TextEditingController();

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
        final Map<String, dynamic> userData = jsonDecode(response.body);

        setState(() {
          _heightController.text = userData['height']?.toString() ?? '';
          _nicknameController.text = userData['nickname'] ?? '';
          _selfIntroductionController.text = userData['selfIntroduction'] ?? '';

          if (userData['birthDate'] != null) {
            _selectedDate = DateTime.parse(userData['birthDate']);
          } else {
            _selectedDate = null;
          }

          if (userData['prefecture'] != null) {
            _selectedPrefecture = Prefecture.values.firstWhere(
                (p) => p.value == userData['prefecture'],
                orElse: () => Prefecture.TOKYO);
          } else {
            _selectedPrefecture = null;
          }

          if (userData['income'] != null) {
            _selectedIncome = Income.values.firstWhere(
                (i) => i.value == userData['income'],
                orElse: () => Income.UNDER_100);
          } else {
            _selectedIncome = null;
          }

          if (userData['bodyType'] != null) {
            _selectedBodyType = BodyType.values.firstWhere(
                (b) => b.value == userData['bodyType'],
                orElse: () => BodyType.NORMAL);
          } else {
            _selectedBodyType = null;
          }

          if (userData['activityType'] != null) {
            _selectedActivityType = ActivityType.values.firstWhere(
                (a) => a.value == userData['activityType'],
                orElse: () => ActivityType.INDOOR);
          } else {
            _selectedActivityType = null;
          }

          if (userData['occupation'] != null) {
            _selectedOccupation = Occupation.values.firstWhere(
                (o) => o.value == userData['occupation'],
                orElse: () => Occupation.OTHER);
          } else {
            _selectedOccupation = null;
          }

          if (userData['maritalStatus'] != null) {
            _selectedMaritalStatus = MaritalStatus.values.firstWhere(
                (m) => m.value == userData['maritalStatus'],
                orElse: () => MaritalStatus.SINGLE);
          } else {
            _selectedMaritalStatus = null;
          }
          if (userData['convenientTime'] != null) {
            _selectedConvenientTime = ConvenientTime.values.firstWhere(
                (c) => c.value == userData['convenientTime'],
                orElse: () => ConvenientTime.ANYTIME);
          } else {
            _selectedConvenientTime = null;
          }
          if (userData['sex'] != null) {
            _selectedSex = Sex.values.firstWhere(
                (s) => s.value == userData['sex'],
                orElse: () => Sex.MALE);
          } else {
            _selectedSex = null;
          }
        });
      } else {
        throw Exception('ユーザー情報の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      showAnimatedSnackBar(
        context,
        message: 'ユーザー情報の取得に失敗しました',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'birthDate': _selectedDate?.toIso8601String(),
          'prefecture': _selectedPrefecture?.value,
          'height': int.tryParse(_heightController.text),
          'income': _selectedIncome?.value,
          'bodyType': _selectedBodyType?.value,
          'activityType': _selectedActivityType?.value,
          'occupation': _selectedOccupation?.value,
          'nickname': _nicknameController.text,
          'selfIntroduction': _selfIntroductionController.text,
          'maritalStatus': _selectedMaritalStatus?.value,
          'convenientTime': _selectedConvenientTime?.value,
          'sex': _selectedSex?.value,
        }),
      );

      if (response.statusCode == 200) {
        showAnimatedSnackBar(
          context,
          message: '保存しました',
          type: SnackBarType.success,
        );
      } else {
        throw Exception('更新に失敗しました');
      }
    } catch (e) {
      showAnimatedSnackBar(
        context,
        message: 'エラーが発生しました',
        type: SnackBarType.error,
      );
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _nicknameController.dispose();
    _selfIntroductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 白基調の InputDecoration を定義
    final inputDecoration = InputDecoration(
      labelStyle: const TextStyle(color: Colors.black54),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepOrangeAccent),
      ),
      border: const OutlineInputBorder(),
      fillColor: Colors.grey.shade200,
      filled: true,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'プロフィール編集',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // カスタムの戻るアイコン
          onPressed: () {
            Navigator.pop(context, true); // 戻る際にtrueを返す
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('基本情報'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nicknameController,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration.copyWith(
                  labelText: 'ニックネーム',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Sex?>(
                decoration: inputDecoration.copyWith(
                  labelText: '性別',
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                value: _selectedSex,
                items: <DropdownMenuItem<Sex?>>[
                  DropdownMenuItem<Sex?>(
                    value: null,
                    child: Text('設定しない'),
                  ),
                  ...Sex.values.map((sex) {
                    return DropdownMenuItem<Sex?>(
                      value: sex,
                      child: Text(sex.japanName),
                    );
                  }).toList(),
                ],
                onChanged: (Sex? newValue) {
                  setState(() {
                    _selectedSex = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              // 誕生日フィールド
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: inputDecoration.copyWith(
                    labelText: '誕生日',
                  ),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日'
                        : '誕生日を選択してください',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Prefecture?>(
                decoration: inputDecoration.copyWith(
                  labelText: '都道府県',
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                value: _selectedPrefecture,
                items: <DropdownMenuItem<Prefecture?>>[
                  DropdownMenuItem<Prefecture?>(
                    value: null,
                    child: Text('設定しない'),
                  ),
                  ...Prefecture.values.map((prefecture) {
                    return DropdownMenuItem<Prefecture?>(
                      value: prefecture,
                      child: Text(prefecture.japanName),
                    );
                  }).toList(),
                ],
                onChanged: (Prefecture? newValue) {
                  setState(() {
                    _selectedPrefecture = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration.copyWith(
                  labelText: '身長 (cm)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Income?>(
                decoration: inputDecoration.copyWith(
                  labelText: '年収',
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                value: _selectedIncome,
                items: <DropdownMenuItem<Income?>>[
                  DropdownMenuItem<Income?>(
                    value: null,
                    child: Text('設定しない'),
                  ),
                  ...Income.values.map((income) {
                    return DropdownMenuItem<Income?>(
                      value: income,
                      child: Text(income.japanName),
                    );
                  }).toList(),
                ],
                onChanged: (Income? newValue) {
                  setState(() {
                    _selectedIncome = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BodyType?>(
                decoration: inputDecoration.copyWith(
                  labelText: '体型',
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                value: _selectedBodyType,
                items: <DropdownMenuItem<BodyType?>>[
                  DropdownMenuItem<BodyType?>(
                    value: null,
                    child: Text('設定しない'),
                  ),
                  ...BodyType.values.map((bodyType) {
                    return DropdownMenuItem<BodyType?>(
                      value: bodyType,
                      child: Text(bodyType.japanName),
                    );
                  }).toList(),
                ],
                onChanged: (BodyType? newValue) {
                  setState(() {
                    _selectedBodyType = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ActivityType?>(
                decoration: inputDecoration.copyWith(
                  labelText: 'ライフスタイル',
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                value: _selectedActivityType,
                items: <DropdownMenuItem<ActivityType?>>[
                  DropdownMenuItem<ActivityType?>(
                    value: null,
                    child: Text('設定しない'),
                  ),
                  ...ActivityType.values.map((activityType) {
                    return DropdownMenuItem<ActivityType?>(
                      value: activityType,
                      child: Text(activityType.japanName),
                    );
                  }).toList(),
                ],
                onChanged: (ActivityType? newValue) {
                  setState(() {
                    _selectedActivityType = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Occupation?>(
                decoration: inputDecoration.copyWith(
                  labelText: '職業',
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                value: _selectedOccupation,
                items: <DropdownMenuItem<Occupation?>>[
                  DropdownMenuItem<Occupation?>(
                    value: null,
                    child: Text('設定しない'),
                  ),
                  ...Occupation.values.map((occupation) {
                    return DropdownMenuItem<Occupation?>(
                      value: occupation,
                      child: Text(occupation.japanName),
                    );
                  }).toList(),
                ],
                onChanged: (Occupation? newValue) {
                  setState(() {
                    _selectedOccupation = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MaritalStatus?>(
                decoration: inputDecoration.copyWith(
                  labelText: '婚姻状態',
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                value: _selectedMaritalStatus,
                items: <DropdownMenuItem<MaritalStatus?>>[
                  DropdownMenuItem<MaritalStatus?>(
                    value: null,
                    child: Text('設定しない'),
                  ),
                  ...MaritalStatus.values.map((maritalStatus) {
                    String displayName;
                    switch (maritalStatus) {
                      case MaritalStatus.SINGLE:
                        displayName = '独身';
                        break;
                      case MaritalStatus.MARRIED:
                        displayName = '既婚';
                        break;
                      case MaritalStatus.DIVORCED:
                        displayName = '離婚経験あり';
                        break;
                      case MaritalStatus.OTHER:
                        displayName = 'その他';
                        break;
                    }

                    return DropdownMenuItem(
                      value: maritalStatus,
                      child: Text(displayName),
                    );
                  }).toList(),
                ],
                onChanged: (MaritalStatus? newValue) {
                  setState(() {
                    _selectedMaritalStatus = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ConvenientTime?>(
                decoration: inputDecoration.copyWith(
                  labelText: '都合の良い時間帯',
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                value: _selectedConvenientTime,
                items: <DropdownMenuItem<ConvenientTime?>>[
                  DropdownMenuItem<ConvenientTime?>(
                    value: null,
                    child: Text('設定しない'),
                  ),
                  ...ConvenientTime.values.map((convenientTime) {
                    String displayName;
                    switch (convenientTime) {
                      case ConvenientTime.WEEKEND_NIGHT:
                        displayName = '週末の夜';
                        break;
                      case ConvenientTime.WEEKEND_DAYTIME:
                        displayName = '週末の昼間';
                        break;
                      case ConvenientTime.WEEKDAY_DAYTIME:
                        displayName = '平日の昼間';
                        break;
                      case ConvenientTime.WEEKDAY_NIGHT:
                        displayName = '平日の夜';
                        break;
                      case ConvenientTime.ANYTIME:
                        displayName = 'いつでも時間がある';
                        break;
                      case ConvenientTime.IRREGULAR:
                        displayName = '不定期';
                        break;
                      case ConvenientTime.OTHER:
                        displayName = 'その他';
                        break;
                    }

                    return DropdownMenuItem(
                      value: convenientTime,
                      child: Text(displayName),
                    );
                  }).toList(),
                ],
                onChanged: (ConvenientTime? newValue) {
                  setState(() {
                    _selectedConvenientTime = newValue;
                  });
                },
              ),
              const SizedBox(height: 24),
              _sectionHeader('自己紹介文'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _selfIntroductionController,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration.copyWith(
                  labelText: '自己紹介',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                  ),
                  child: const Text('保存',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ja'), // 日本語化
    );
    if (picked != null && picked != _selectedDate) {
      DateTime today = DateTime.now();
      int age = today.year - picked.year;
      if (today.month < picked.month ||
          (today.month == picked.month && today.day < picked.day)) {
        age--;
      }
      if (age < 18) {
        showAnimatedSnackBar(
          context,
          message: '生年月日は18歳未満に設定できません',
          type: SnackBarType.error,
        );
        return;
      }
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
