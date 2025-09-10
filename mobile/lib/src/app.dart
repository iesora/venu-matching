import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home.dart';
import 'screens/ranking.dart';
import 'screens/search.dart';
import 'screens/request/requestList.dart';
import 'screens/myPage.dart';
import 'screens/match/matchingList.dart'; // 追加
import 'loginState.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/sign_in_screen.dart';
import 'helpers/auth_state.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widgets/custom_dialog.dart';
import 'widgets/custom_snackbar.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => LoginState(),
        child: MaterialApp(
          title: 'Flutter Demo',
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          navigatorObservers: [CustomNavigatorObserver(context)],
          home: const MyStatefulWidget(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ja', ''),
          ],
          debugShowCheckedModeBanner: false, // Debugの帯を非表示
        ));
  }
}

class MyStatefulWidget extends StatefulWidget {
  final int initialIndex;

  const MyStatefulWidget({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  List<Widget> _screens = [];
  Map<String, dynamic>? _userData;
  late int _selectedIndex;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _initializeApp();
  }

  void _showLoginBonusDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // モーダルをタップで閉じられないようにする
      builder: (BuildContext context) {
        return CustomDialog(
          icon: const Icon(Icons.card_giftcard,
              size: 40, color: Colors.orangeAccent),
          title: 'ログインボーナス',
          message: "${now.month}月${now.day}日のログインボーナスです！100Pt獲得しました！",
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "OK",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeApp() async {
    // アプリ起動時の初期化処理
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('${dotenv.get('API_URL')}/auth/authenticate'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          Provider.of<AuthState>(context, listen: false).login(data);
          _userData = data;
          _setupScreens();
          _loginBonus();
        } else {
          throw Exception('認証に失敗しました');
        }
      } catch (e) {
        showAnimatedSnackBar(
          context,
          message: 'ネットワークエラーが発生しました',
          type: SnackBarType.error,
        );
      }
    }

    if (_userData != null) {
      if (_userData!["isFirstLoginToday"]) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showLoginBonusDialog();
        });
      }
    }
  }

  void _setupScreens() {
    if (_userData != null && _userData!['mode'] == 'normal') {
      _screens = [
        HomeScreen(),
        RankingScreen(),
        MyPageScreen(),
      ];
    } else {
      _screens = [
        HomeScreen(),
        SearchScreen(), // ダミー（検索タブ用）
        RequestListScreen(),
        MatchingListScreen(), // 追加
        MyPageScreen(),
      ];
    }
  }

  Future<void> _loginBonus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/user/login-bonus'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["isFirstLoginToday"]) {
          _showLoginBonusDialog();
        }
        print('ログインボーナスの処理に成功しました');
      } else {
        print('ログインボーナスの処理に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('ログインボーナスの処理に失敗しました: $e');
    }
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    await _loginBonus();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Provider.of<LoginState>(context).isLoggedIn;
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
        body: authState.isLoggedIn ? _screens[_selectedIndex] : SignInScreen(),
        bottomNavigationBar: authState.isLoggedIn
            ? Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1.0,
                    ),
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  items: _userData != null && _userData!['mode'] == 'normal'
                      ? const <BottomNavigationBarItem>[
                          BottomNavigationBarItem(
                              icon: Icon(Icons.home_outlined),
                              label: 'ホーム',
                              backgroundColor: Colors.black87),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.emoji_events),
                              label: 'ランキング',
                              backgroundColor: Colors.white),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.person_outline),
                              label: 'マイページ',
                              backgroundColor: Colors.white),
                        ]
                      : const <BottomNavigationBarItem>[
                          BottomNavigationBarItem(
                              icon: Icon(Icons.home_outlined),
                              label: 'ホーム',
                              backgroundColor: Colors.black87),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.emoji_events),
                              label: 'ランキング',
                              backgroundColor: Colors.white),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.search),
                              label: '検索',
                              backgroundColor: Colors.white),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.list),
                              label: 'リクエスト',
                              backgroundColor: Colors.white),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.person_outline),
                              label: 'マイページ',
                              backgroundColor: Colors.white),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.list_alt),
                              label: 'マッチング',
                              backgroundColor: Colors.white), // 追加
                        ],
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: Colors.deepOrangeAccent,
                  unselectedItemColor: Colors.grey[400],
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  elevation: 8,
                  showUnselectedLabels: true,
                ),
              )
            : const SizedBox.shrink());
  }
}

class CustomNavigatorObserver extends NavigatorObserver {
  final BuildContext context;

  CustomNavigatorObserver(this.context);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    print('Pushed route: ${route.settings.name}');
    // 遷移時に発火させたいコードをここに記述
    _checkToken(); // Tokenの有無を判定

    // 画面遷移後にログインボーナスの処理を呼び出す
    /*
    if (route is MaterialPageRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loginBonus();
      });
    }
    */
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    print('Popped route: ${route.settings.name}');
    // 戻る操作時に発火させたいコードをここに記述
  }

  /*
  Future<void> _loginBonus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/user/login-bonus'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("isFirstLoginToday: ${data["isFirstLoginToday"]}");
        print("sex: ${data["sex"]}");
        if (data["isFirstLoginToday"] && data["sex"] == Sex.MALE.value) {
          print("loginBonus");
          _showLoginBonusDialog();
        }
        print('ログインボーナスの処理に成功しました');
      } else {
        print('ログインボーナスの処理に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('ログインボーナスの処理に失敗しました: $e');
    }
  }

  void _showLoginBonusDialog() {
    DateTime now = DateTime.now();
    print("dialog");
    showDialog(
      context: context,
      barrierDismissible: false, // モーダルをタップで閉じられないようにする
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ログインボーナス"),
          content: Text("${now.month}月${now.day}日のログインボーナスです！100Pt獲得しました！"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // モーダルを閉じる
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
  */
  void _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
    Provider.of<AuthState>(context, listen: false).logout();
    Navigator.pop(context);
  }

  Future<void> _checkToken() async {
    print("checkToken");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    if (token == null) {
      print("token: null");
      _handleLogout(context);
    }
  }
}
