import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../loginState.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:mobile/src/widgets/custom_snackbar.dart';
import 'package:mobile/src/widgets/custom_dialog.dart';
import 'package:mobile/src/screens/blockList.dart';
import 'package:mobile/src/screens/venu/myVenu.dart'; // myVenu画面のインポート
import 'package:mobile/src/screens/auth/sign_in_screen.dart'; // sign_in_screenのインポート

class MyPageScreen extends HookWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  void _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
    await prefs.remove('userId');
    Provider.of<LoginState>(context, listen: false).logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
          icon: const Icon(Icons.delete, size: 40, color: Colors.red),
          title: '退会する',
          message: "一度退会するとこのアカウントを復元することはできません。\n退会しますか？",
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteAccountConfirmDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "退会する",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
          icon: const Icon(Icons.delete, size: 40, color: Colors.red),
          title: '退会する',
          message: "本当に退会しますか？",
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleDeleteAccount(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "退会する",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteAccount(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    final response = await http.delete(
      Uri.parse('${dotenv.get('API_URL')}/user'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      showAnimatedSnackBar(
        context,
        message: '退会しました',
        type: SnackBarType.success,
      );
      _handleLogout(context);
    } else {
      showAnimatedSnackBar(
        context,
        message: '退会に失敗しました',
        type: SnackBarType.error,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'マイページ',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.logout, color: Colors.grey[800]),
            title: const Text('ログアウト', style: TextStyle(color: Colors.black)),
            onTap: () {
              _handleLogout(context);
              showAnimatedSnackBar(
                context,
                message: 'ログアウトしました',
                type: SnackBarType.success,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: const Text('退会する', style: TextStyle(color: Colors.red)),
            onTap: () {
              _showDeleteAccountDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on, color: Colors.blue),
            title: const Text('マイ会場一覧', style: TextStyle(color: Colors.blue)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyVenuScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
