import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/src/widgets/default_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/src/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class SelectHobbyScreen extends StatefulWidget {
  const SelectHobbyScreen({super.key});

  @override
  State<SelectHobbyScreen> createState() => _SelectHobbyScreenState();
}

class _SelectHobbyScreenState extends State<SelectHobbyScreen> {
  List<Map<String, dynamic>> _hobbies = [];
  final List<Map<String, dynamic>> _selectedHobbies = [];

  @override
  void initState() {
    super.initState();
    _fetchHobbyList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[100]!,
              ],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                "趣味・興味の選択",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Text(
                "あなたの趣味・興味を3つ以上選択してください",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(child: _showHobbies()),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      child: DefaultButton(
                        backgroundColor: _selectedHobbies.length >= 3
                            ? Colors.deepOrangeAccent
                            : Colors.grey[300],
                        onPressed: _selectedHobbies.length >= 3
                            ? () {
                                _handlePressed();
                              }
                            : null,
                        child: Text(
                          '設定する',
                          style: TextStyle(
                            color: _selectedHobbies.length >= 3
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 2,
                      child: DefaultButton(
                        backgroundColor: Colors.white,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyStatefulWidget(),
                            ),
                          );
                        },
                        child: const Text(
                          'スキップ',
                          style: TextStyle(
                            color: Colors.deepOrangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyStatefulWidget(),
        ));
  }
}
