// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:nexfit_flutter/Models/PersonalGoals.dart';
import 'package:nexfit_flutter/Pages/AddPersonalGoals.dart';
import 'package:nexfit_flutter/Pages/LandingPage.dart';
import 'package:nexfit_flutter/Pages/WeeklyProgessScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';

import '../Services/APIService.dart';

class ProfilePage extends StatefulWidget {
  final bool isTrainer;
  final int gymUserId;
  final int userId;
  const ProfilePage({super.key, required this.isTrainer, required this.gymUserId, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  @override
  void initState() {
    _fetchUserData();
    super.initState();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    try {
      final userData = widget.isTrainer == false
          ? await _apiService.getUserData(userId!)
          : await _apiService.getTrainerData(userId!);
      setState(() {
        _userData = userData;
      });
      print(_userData);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: _userData != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.lime.shade300,
                        radius: 40,
                        child:
                            Icon(Icons.person, color: Colors.white, size: 60),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_userData!['first_name']} ${_userData!['last_name']}'
                                .toTitleCase(),
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.isTrainer ? 'Trainer' : 'Member',
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // ListTile(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => AddGoalScreen(gymUserId: widget.gymUserId,)),
                  //     );
                  //   },
                  //   leading: Icon(
                  //     Icons.track_changes_rounded,
                  //     color: Colors.lime,
                  //   ),
                  //   title: Text(
                  //     'Set Your Personal Goals',
                  //     style: TextStyle(fontSize: 19),
                  //   ),
                  //   trailing: Icon(
                  //     Icons.arrow_forward_ios_rounded,
                  //     size: 20,
                  //   ),
                  // ),
                  // ListTile(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => ProgressScreen(goalId: 1, userId: widget.userId,gymUserId: widget.gymUserId,)),
                  //     );
                  //   },
                  //   leading: Icon(
                  //     Icons.track_changes,
                  //     color: Colors.lime,
                  //   ),
                  //   title: Text(
                  //     'Track Your Weekly Progress',
                  //     style: TextStyle(fontSize: 19),
                  //   ),
                  //   trailing: Icon(
                  //     Icons.arrow_forward_ios_rounded,
                  //     size: 20,
                  //   ),
                  // ),
                  // Center(
                  //   child: Container(
                  //     height: 100,
                  //     width: MediaQuery.of(context).size.width - 50,
                  //     decoration: BoxDecoration(
                  //         color: Colors.grey.shade900,
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.lime.shade500,
                  //             blurRadius: 4,
                  //             offset: Offset(0, 0),
                  //             spreadRadius: 1,
                  //             blurStyle: BlurStyle.outer,
                  //           )
                  //         ],
                  //         borderRadius: BorderRadius.circular(15)),
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(20.0),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text('Track Your Progress',
                  //               style: TextStyle(
                  //                 fontSize: 25,
                  //                 fontWeight: FontWeight.bold,
                  //               )),
                  //           SizedBox(
                  //             height: 10,
                  //           ),
                  //           LinearProgressBar(
                  //             minHeight: 10,
                  //             maxSteps: 6,
                  //             progressType: LinearProgressBar
                  //                 .progressTypeLinear, // Use Linear progress
                  //             currentStep: 5,
                  //             progressColor: Colors.lime.shade400,
                  //             backgroundColor: Colors.grey,
                  //           )
                  //           // LinearProgressBar()
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  ListTile(
                    leading: Icon(
                      Icons.person_outlined,
                      color: Colors.lime,
                    ),
                    title: Text('Username'),
                    subtitle: Text(
                      '${_userData!['username']}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.email,
                      color: Colors.lime,
                    ),
                    title: Text('Email'),
                    subtitle: Text(
                      '${_userData!['email']}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.phone_iphone_rounded,
                      color: Colors.lime,
                    ),
                    title: Text('Contact'),
                    subtitle: Text(
                      '${_userData!['contact']}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.home_work_rounded,
                      color: Colors.lime,
                    ),
                    title: Text('Gym'),
                    subtitle: Text(
                      '${_userData!['gym_name']}',
                      style: TextStyle(fontSize: 20),
                    ),
                    // trailing: Text('Request More', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline ),),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.money,
                      color: Colors.lime,
                    ),
                    title: Text(widget.isTrainer
                        ? 'Monthly Charges'
                        : 'Tokens Available'),
                    subtitle: Text(
                      widget.isTrainer
                          ? '${_userData!['monthly_charges']}'
                          : '${_userData!['number_of_tokens']}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.money,
                      color: Colors.lime,
                    ),
                    title:
                        Text(widget.isTrainer ? 'Certfication' : 'Trained By'),
                    subtitle: Text(
                      widget.isTrainer
                          ? '${_userData!['certification']}'
                          : '${_userData!['trainer_firstName']} ${_userData!['trainer_lastName']}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    onTap: () => _logout(context),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    tileColor: Colors.redAccent,
                    leading: Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(
                  color: Colors.lime,
                ),
              ),
      ),
    ));
  }

  Future<void> _logout(BuildContext context) async {
    // Clear user data from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Clear the navigator stack and navigate to the LandingPage
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LandingPage()),
      (Route<dynamic> route) => false,
    );
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
