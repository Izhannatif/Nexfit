// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexfit_flutter/Pages/AttendanceTable.dart';
import 'package:nexfit_flutter/Pages/ExercisesPage.dart';
import 'package:nexfit_flutter/Pages/ProfilePage.dart';
import 'package:nexfit_flutter/Pages/TrainerChatList.dart';
import 'package:nexfit_flutter/Pages/TrainerHome.dart';
import 'package:nexfit_flutter/Services/APIService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainerDashboard extends StatefulWidget {
  final int? userId;
  const TrainerDashboard({super.key, this.userId});

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  List<dynamic>? dietPlans;
  List<Widget> _children = [];
  bool? isLoggedIn;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    int? trainerId = prefs.getInt('trainer_id');
    bool? isTrainer = prefs.getBool('isTrainer');
    try {
      final userData = await _apiService.getTrainerData(userId!);
      setState(() {
        isLoggedIn = prefs.getBool('isLoggedIn');
        _userData = userData;
        _initChildren(trainerId, isTrainer!);
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _initChildren(int? trainerId, bool isTrainer) {
    print('Dashboard User ID = ${widget.userId}');
    print('Dashboard Trainer ID $trainerId');
    _children = [
      TrainerHome(
        userID: widget.userId!,
        trainerID: trainerId!,
        isTrainer: isTrainer,
      ),
      // ChatPage(senderId: widget.userId ?? 0, receiverId: trainerId),
      TrainerChatList(
        userID: widget.userId,
        trainerID: trainerId,
        isTrainer: isTrainer,
      ),
      AttendanceTable(userID: widget.userId, isTrainer: isTrainer,),
      ExercisesPage(),
      ProfilePage(isTrainer: isTrainer,gymUserId: trainerId,userId: widget.userId!,),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_children.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.lime,
          ), // Show a loading indicator
        ),
      );
    }

    return Scaffold(
      appBar: isLoggedIn !=null ? AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        title: Text(
          'NEXFIT',
          style: TextStyle(
              fontSize: 45,
              letterSpacing: -3,
              color: Colors.lime.shade400,
              fontFamily: GoogleFonts.archivoBlack().fontFamily),
        ),
      ):null,
      bottomNavigationBar: isLoggedIn != null? BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          currentIndex: _currentIndex,
          elevation: 0,
          showUnselectedLabels: true,
          selectedIconTheme: IconThemeData(color: Colors.lime.shade500),
          selectedItemColor: Colors.lime.shade500,
          selectedFontSize: 12,
          selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.lime.shade500),
          unselectedIconTheme: IconThemeData(color: Colors.grey.shade600),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
          unselectedItemColor: Colors.grey.shade600,
          onTap: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined), label: 'Chat'),
            BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner_rounded), label: 'Attendance'),
            BottomNavigationBarItem(
                icon: Icon(Icons.sports_gymnastics), label: 'Exercises'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
          ]):null,

      body: _children[_currentIndex], // Safe to access _children here
      
    );
  }
}
