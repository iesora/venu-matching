import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/helpers/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
      ChangeNotifierProvider(create: (context) => AuthState(), child: MyApp()));
}
