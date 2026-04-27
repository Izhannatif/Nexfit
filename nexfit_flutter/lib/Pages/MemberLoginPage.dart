// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nexfit_flutter/Pages/Homepage.dart';
import 'package:nexfit_flutter/Pages/UserDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController =
      TextEditingController(text: "izhan");
  final TextEditingController _passwordController =
      TextEditingController(text: "izhan123");
  String _errorMessage = '';
  bool isLoading = false;
  bool isLoggedIn = false;
  
  Future<void> _login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    print("Login Running");
    setState(() {
      isLoading = true;
    });
    final response = await http.post(
      Uri.parse('http://192.168.1.13:8001/api/login/'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      final String token = responseData['jwt'];
      final int gymUserId = responseData['gym_user_id'];
      final int userID = responseData['user_id'];
      final int trainerId = responseData['trainer_id'];
      final bool isTrainer = responseData['is_trainer'];
      final int trainerUserId = responseData['trainer_user_id'];

      // Store the token using shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setInt('user_id', userID);
      await prefs.setInt('gym_user_id', gymUserId);
      await prefs.setInt('trainer_id', trainerId);
      await prefs.setBool('isTrainer', isTrainer);
      await prefs.setInt('trainer_userId', trainerUserId);
      await prefs.setBool('isLoggedIn', true);

      // await prefs.setInt("trainer_id", 10 );
      print('Login successful!');
      print(response.body);
      setState(() {
        isLoading = false;
        isLoggedIn = true;
      });
      print(isLoading);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => UserDashboard(
                    userId: userID,
                    gymUserId: gymUserId,
                  )));
    } else {
      // Failed login, display error message
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        _errorMessage = responseData['detail'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(top: 0),
              padding: EdgeInsets.only(top: 50),
              decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50))),
              height: MediaQuery.of(context).size.height / 4,
              alignment: Alignment.center,
              child: Image.asset(
                'assets/nexfit-logo.png',
                height: 200,
              ),
            ),
            SizedBox(
              height: 80,
            ),
            isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.lime,))
                : Container(
                    padding: EdgeInsets.all(20),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(hintText: 'Username'),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(hintText: 'Password'),
                          obscureText: true,
                        ),
                      ),
                      SizedBox(height: 50.0),
                      GestureDetector(
                        onTap: _login,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.lime.shade400),
                          alignment: Alignment.center,
                          height: 40,
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                                color: Colors.grey.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1),
                          ),
                        ),
                      ),
                      // ElevatedButton(

                      //   style: ElevatedButton.styleFrom(backgroundColor: Colors.lime,padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                      //   onPressed: _login,
                      //   child: Text('Login', style: TextStyle(color: Colors.white),),
                      // ),
                      SizedBox(height: 20.0),
                      Text(
                        'Forgot Password ?',
                        style: TextStyle(
                            color: Colors.lime.shade600,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.lime.shade600),
                      ),
                      SizedBox(height: 8.0),
                      if (_errorMessage.isNotEmpty)
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                    ]),
                  ),
            SizedBox(
              height: 180,
            ),
            Center(
              child: Text(
                '\"the body achieves what the mind believes\"',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 18,
                    color: Colors.lime.shade600),
              ),
            )
          ],
        ),
      ),
    );
  }
}
