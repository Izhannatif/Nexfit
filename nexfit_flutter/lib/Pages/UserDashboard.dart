// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexfit_flutter/Pages/AttendancePage.dart';
import 'package:nexfit_flutter/Pages/AttendanceTable.dart';
import 'package:nexfit_flutter/Pages/ChatPage.dart';
import 'package:nexfit_flutter/Pages/ExercisesPage.dart';
import 'package:nexfit_flutter/Pages/Homepage.dart';
import 'package:nexfit_flutter/Pages/LandingPage.dart';
import 'package:nexfit_flutter/Pages/MemberLoginPage.dart';
import 'package:nexfit_flutter/Pages/ProfilePage.dart';
import 'package:nexfit_flutter/Pages/TrainerDashboard.dart';
import 'package:nexfit_flutter/Services/APIService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboard extends StatefulWidget {
  final int? userId;
  final int? gymUserId;
  const UserDashboard({Key? key, this.userId, this.gymUserId})
      : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  List<Widget> _children = [];
  int? userId;
  int? gymUserId;
  int? trainerId;
  bool? isTrainer;
  bool isLoggedIn = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
    print('isLoggedIn = $isLoggedIn');
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');
    gymUserId = prefs.getInt('gym_user_id');
    trainerId = prefs.getInt('trainer_id');
    isTrainer = prefs.getBool('isTrainer');
    // bool? isMe = prefs.getBool('is_trainer');

    try {
      final userData = await _apiService.getUserData(userId!);
      print('Trainer ID $trainerId');
      print('Trainer $isTrainer');
      setState(() {
        _userData = userData;
        _initChildren(trainerId!, isTrainer!, gymUserId!);
      });
      print('Userid = ${userId}');
      print('Trainerid = ${trainerId}');
      print('isTrainer = ${isTrainer}');
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _initChildren(int? trainerId, bool isTrainer, int gymUserId) {
    // Ensure trainerId is non-null, or use a default/fallback value
    trainerId = trainerId ?? 0; // Default/fallback value if trainerId is null
    print(trainerId);
    _children = [
      HomePage(
        gymUserId: gymUserId,
      ),
      ChatPage(
        senderId: widget.userId ?? 0,
        receiverId: trainerId,
        isTrainer: isTrainer,
      ),
      AttendanceTable(userID: widget.userId, isTrainer: isTrainer,),
      ExercisesPage(),
      ProfilePage(isTrainer: isTrainer,gymUserId: gymUserId,userId: userId!,),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn!) {
      return LandingPage(); // Redirect to the login page
    }
    // Ensure _children is not empty before attempting to access its elements
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
      appBar: isLoggedIn
          ? AppBar(
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
            )
          : null,
      bottomNavigationBar: isLoggedIn
          ? Theme(
              data: Theme.of(context).copyWith(splashColor: Colors.transparent),
              child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentIndex,
                  elevation: 0,
                  showUnselectedLabels: true,
                  selectedIconTheme: IconThemeData(color: Colors.lime.shade500),
                  selectedItemColor: Colors.lime.shade500,
                  selectedFontSize: 12,
                  selectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.lime.shade500),
                  unselectedIconTheme:
                      IconThemeData(color: Colors.grey.shade600),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                  unselectedItemColor: Colors.grey.shade600,
                  onTap: (value) {
                    setState(() {
                      _currentIndex = value;
                      navigatorKey.currentState
                          ?.pushReplacementNamed('/'); // Reset navigator stack
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.message_outlined),
                      label: 'Chat',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.qr_code_scanner_rounded),
                      label: 'Attendance',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.sports_gymnastics),
                      label: 'Exercises',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ]),
            )
          : null,

      body: _children[_currentIndex], // Safe to access _children here
      // body: isLoggedIn ? Navigator(
      //   key: navigatorKey, // Create a separate Navigator for the body
      //   onGenerateRoute: (RouteSettings settings) {
      //     WidgetBuilder builder;
      //     switch (_currentIndex) {
      //       case 0:
      //         builder = (BuildContext context) => HomePage(
      //               gymUserId: gymUserId,
      //             );
      //         break;
      //       case 1:
      //         builder = (BuildContext context) => ChatPage(
      //               senderId: widget.userId ?? 0,
      //               receiverId: trainerId!,
      //               isTrainer: isTrainer!,
      //             );
      //         break;
      //       case 2:
      //         builder = (BuildContext context) =>
      //             AttendanceTable(userID: widget.userId);
      //         break;
      //       case 3:
      //         builder = (BuildContext context) => ExercisesPage();
      //         break;
      //       case 4:
      //         builder = (BuildContext context) => ProfilePage();
      //         break;
      //       default:
      //         builder = (BuildContext context) => HomePage(
      //               gymUserId: gymUserId,
      //             );
      //         break;
      //     }
      //     return MaterialPageRoute(builder: builder, settings: settings);
      //   },
      // ):null,
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
