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

class RankingScreen extends HookWidget {
  const RankingScreen({Key? key}) : super(key: key);

  void _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
    Provider.of<LoginState>(context, listen: false).logout();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'ランキング',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Noto Sans JP',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
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
            onTap: () {},
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
