import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;
import 'src/app.dart';
import 'src/helpers/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initPlatformState();
  runApp(
      ChangeNotifierProvider(create: (context) => AuthState(), child: MyApp()));
}

Future<void> initPlatformState() async {
  await Purchases.setLogLevel(LogLevel.debug);

  if (Platform.isIOS) {
    await Purchases.configure(
        PurchasesConfiguration(dotenv.env['APPLE_API_KEY']!)
          ..appUserID = null // オプショナル：ユーザーIDを設定
        //  ..observerMode = false // 本番環境では true に設定
        );
    await Purchases.enableAdServicesAttributionTokenCollection();
  } else if (Platform.isAndroid) {
    /*
    await Purchases.configure(
      PurchasesConfiguration(dotenv.env['GOOGLE_API_KEY']!),
    );
    */
  }
}
