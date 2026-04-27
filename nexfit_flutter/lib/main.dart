// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nexfit_flutter/Pages/Homepage.dart';
import 'package:nexfit_flutter/Pages/LandingPage.dart';
import 'package:nexfit_flutter/Pages/MemberLoginPage.dart';
import 'package:nexfit_flutter/Pages/TrainerDashboard.dart';
import 'package:nexfit_flutter/Pages/UserDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  bool isLoggedIn = false;
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  int? userId = prefs.getInt('user_id');
  bool? isTrainer = prefs.getBool('isTrainer');
  isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  print("jwt - $token");
  print("user id - $userId");
  print("isTrainer - $isTrainer");
  print("isLoggedIn = $isLoggedIn");
  runApp(MyApp(token: token, userId: userId, isTrainer: isTrainer));
}

class MyApp extends StatelessWidget {
  final String? token;
  final int? userId;
  final bool? isTrainer;

  const MyApp({super.key, this.token, this.userId, this.isTrainer});

  @override
  Widget build(BuildContext context) {
    print("USER ID $userId");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          fontFamily:
              GoogleFonts.raleway(fontWeight: FontWeight.w600).fontFamily),
      darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          fontFamily:
              GoogleFonts.raleway(fontWeight: FontWeight.w600).fontFamily),
      navigatorKey: GlobalKey<NavigatorState>(),
      home: _getHomePage(),
    );
  }

  Widget _getHomePage() {
    if (token != null && userId != null) {
      if (isTrainer == true) {
        return TrainerDashboard(userId: userId!);
      } else {
        return UserDashboard(
          userId: userId!,
        );
      }
    } else {
      return LandingPage();
    }
  }
}
