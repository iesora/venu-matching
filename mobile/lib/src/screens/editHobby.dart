import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/src/screens/account.dart';
import 'dart:developer';
import 'package:mobile/utils/userInfo.dart';
import 'other.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class EditHobbyScreen extends StatefulWidget {
  final int userId;
  const EditHobbyScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<EditHobbyScreen> createState() => _EditHobbyScreenState();
}

class _EditHobbyScreenState extends State<EditHobbyScreen> {
  List<Map<String, dynamic>> _hobbies = [];
  final List<Map<String, dynamic>> _selectedHobbies = []; // 選択された趣味のレコードを保持

  @override
  void initState() {
    super.initState();
    _fetchHobbyList();
    _fetchUserHobbies();
  }

  Future<void> _fetchHobbyList() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/hobby/list'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _hobbies = data.map((hobby) {
            return {
              'id': hobby['id'].toString(),
              'name': hobby['name'] ?? '',
            };
          }).toList();
        });
      } else {
        throw Exception('趣味の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      if (mounted) {
        showAnimatedSnackBar(
          context,
          message: '趣味の取得に失敗しました',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _fetchUserHobbies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse(
            '${dotenv.get('API_URL')}/hobby/user-hobby?userId=${widget.userId}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final List<dynamic> data = jsonDecode(response.body); // データをリストとして解析
      setState(() {
        _selectedHobbies.clear(); // 既存データをクリア
        for (var hobby in data) {
          _selectedHobbies.add({
            "id": hobby["id"].toString(),
            "name": hobby["name"] ?? "",
          });
        }
      });
      print("_selectedHobbies: $_selectedHobbies");
    } catch (e) {
      print('エラーが発生しました: $e');
      if (mounted) {
        showAnimatedSnackBar(
          context,
          message: '趣味の取得に失敗しました',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '趣味・興味',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                _handlePressed();
              },
              child: const Text(
                '保存',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const SizedBox(height: 4.0),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _showHobbies()),
        ],
      ),
    );
  }

  Widget _showHobbies() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16.0),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              children: _hobbies.map((hobby) {
                final isSelected = _selectedHobbies
                    .any((selectedHobby) => selectedHobby['id'] == hobby['id']);
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      hobby['name'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.deepPurpleAccent,
                    backgroundColor: Colors.grey[300],
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedHobbies.add(hobby);
                        } else {
                          _selectedHobbies.removeWhere((selectedHobby) =>
                              selectedHobby['id'] == hobby['id']);
                        }
                      });
                    },
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePressed() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    print('data: ${_selectedHobbies}');
    final response = await http.patch(
      Uri.parse('${dotenv.get('API_URL')}/hobby'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'hobbies':
            _selectedHobbies.map((hobby) => {'id': hobby['id']}).toList(),
      }),
    );
    Navigator.pop(context, true);

    print("res: ${response.body}");
  }
}
