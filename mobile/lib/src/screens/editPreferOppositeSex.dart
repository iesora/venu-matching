import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/utils/userInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class EditPreferOppositeSexScreen extends StatefulWidget {
  @override
  _EditPreferOppositeSexScreenState createState() =>
      _EditPreferOppositeSexScreenState();
}

class _EditPreferOppositeSexScreenState
    extends State<EditPreferOppositeSexScreen> {
  // 異性向け好み条件の変数
  HeightType? _selectedPreferredHeightType;
  BodyType? _selectedPreferredBodyType;
  ActivityType? _selectedPreferredActivityType;
  Income? _selectedPreferredIncome;

  final _preferredFoodController = TextEditingController();

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
        Uri.parse('${dotenv.get('API_URL')}/user'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          if (data['preferredOppositeSexHeightType'] != null) {
            _selectedPreferredHeightType = HeightType.values.firstWhere(
              (ht) => ht.value == data['preferredOppositeSexHeightType'],
              orElse: () => HeightType.UNDER_170,
            );
          }
          if (data['preferredOppositeSexBodyType'] != null) {
            _selectedPreferredBodyType = BodyType.values.firstWhere(
              (bt) => bt.value == data['preferredOppositeSexBodyType'],
              orElse: () => BodyType.NORMAL,
            );
          }
          if (data['preferredOppositeSexActivityType'] != null) {
            _selectedPreferredActivityType = ActivityType.values.firstWhere(
              (at) => at.value == data['preferredOppositeSexActivityType'],
              orElse: () => ActivityType.INDOOR,
            );
          }
          if (data['preferredOppositeSexIncome'] != null) {
            _selectedPreferredIncome = Income.values.firstWhere(
              (inc) => inc.value == data['preferredOppositeSexIncome'],
              orElse: () => Income.UNDER_100,
            );
          }
          _preferredFoodController.text =
              data['preferredOppositeSexFood'] ?? '';
        });
      } else {
        throw Exception('異性の好み条件の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      showAnimatedSnackBar(
        context,
        message: '異性の好み条件の取得に失敗しました',
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
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'preferredOppositeSexHeightType': _selectedPreferredHeightType?.value,
          'preferredOppositeSexBodyType': _selectedPreferredBodyType?.value,
          'preferredOppositeSexActivityType':
              _selectedPreferredActivityType?.value,
          'preferredOppositeSexIncome': _selectedPreferredIncome?.value,
          'preferredOppositeSexFood': _preferredFoodController.text,
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
      print('エラーが発生しました: $e');
      showAnimatedSnackBar(
        context,
        message: 'エラーが発生しました',
        type: SnackBarType.error,
      );
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

  @override
  void dispose() {
    _preferredFoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // EditProfileScreenと同様のInputDecoration
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
      appBar: AppBar(
        title: const Text(
          '好みの異性条件の編集',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Noto Sans JP',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // カスタムの戻るアイコン
          onPressed: () {
            Navigator.pop(context, true); // 戻る際にtrueを返す
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('好みの条件'),
            const SizedBox(height: 8),
            DropdownButtonFormField<HeightType?>(
              decoration: inputDecoration.copyWith(
                labelText: '好みの身長 (cm)',
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              value: _selectedPreferredHeightType,
              items: [
                const DropdownMenuItem<HeightType?>(
                  value: null,
                  child: Text('設定しない'),
                ),
                ...HeightType.values.map((heightType) {
                  return DropdownMenuItem(
                    value: heightType,
                    child: Text(heightType.japanName),
                  );
                }),
              ],
              onChanged: (HeightType? newValue) {
                setState(() {
                  _selectedPreferredHeightType = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BodyType?>(
              decoration: inputDecoration.copyWith(
                labelText: '好みの体型',
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              value: _selectedPreferredBodyType,
              items: [
                const DropdownMenuItem<BodyType?>(
                  value: null,
                  child: Text('設定しない'),
                ),
                ...BodyType.values.map((bodyType) {
                  return DropdownMenuItem(
                    value: bodyType,
                    child: Text(bodyType.japanName),
                  );
                }),
              ],
              onChanged: (BodyType? newValue) {
                setState(() {
                  _selectedPreferredBodyType = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ActivityType?>(
              decoration: inputDecoration.copyWith(
                labelText: '好みの活動タイプ',
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              value: _selectedPreferredActivityType,
              items: [
                const DropdownMenuItem<ActivityType?>(
                  value: null,
                  child: Text('設定しない'),
                ),
                ...ActivityType.values.map((activityType) {
                  return DropdownMenuItem(
                    value: activityType,
                    child: Text(activityType.japanName),
                  );
                }),
              ],
              onChanged: (ActivityType? newValue) {
                setState(() {
                  _selectedPreferredActivityType = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Income?>(
              decoration: inputDecoration.copyWith(
                labelText: '好みの年収',
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              value: _selectedPreferredIncome,
              items: [
                const DropdownMenuItem<Income?>(
                  value: null,
                  child: Text('設定しない'),
                ),
                ...Income.values.map((income) {
                  return DropdownMenuItem(
                    value: income,
                    child: Text(income.japanName),
                  );
                }),
              ],
              onChanged: (Income? newValue) {
                setState(() {
                  _selectedPreferredIncome = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _preferredFoodController,
              style: const TextStyle(color: Colors.black),
              decoration: inputDecoration.copyWith(
                labelText: '好みの食べ物',
              ),
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
                child: const Text(
                  '保存',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
