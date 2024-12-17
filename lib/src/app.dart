import 'package:appproject/src/page/Login/LoginPage.dart';
import 'package:appproject/src/page/Profile/ProfilePage.dart';
import 'package:appproject/src/page/routes.dart';
import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "App",
      routes: AppRoute.all,
      home: const LoginPage(),
    );
  }
}

