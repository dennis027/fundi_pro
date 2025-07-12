import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fundi_pro/pages/components/home.dart';
import 'package:fundi_pro/pages/loading.dart';
import 'package:fundi_pro/pages/authenication/login.dart';
import 'package:fundi_pro/pages/authenication/register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Loading(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/home': (context) => HomePage(),
      },
    ),
  );
}
