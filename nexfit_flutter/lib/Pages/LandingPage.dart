// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexfit_flutter/Pages/MemberLoginPage.dart';
import 'package:nexfit_flutter/Pages/TrainerLoginPage.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/landing-page-bg.jpg',
                  ),
                  fit: BoxFit.cover,
                  opacity: 0.3)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height /8,
              ),
              Padding(
                padding: const EdgeInsets.only(left:20.0),
                child: Image.asset('assets/nexfit-logo.png', height: 70,),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Get \nStarted.'.toUpperCase(),
                  style: TextStyle(
                      fontSize: 70,
                      color: Colors.white,
                      fontFamily: GoogleFonts.archivoBlack().fontFamily),
                ),
              ),
              SizedBox(height: 200,),
              Center(
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage() ));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.lime,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    height: 50,
                    width: MediaQuery.of(context).size.width / 1.8,
                    child: Center(
                        child: Text(
                      'Member',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
                    )),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Center(
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TrainerLoginPage() )); 
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    height: 50,
                    width: MediaQuery.of(context).size.width / 1.8,
                    child: Center(
                        child: Text(
                      'Trainer',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
                    )),
                  ),
                ),
              ),
              SizedBox(
                height: 100,
              )
            ],
          ),
        ),
      ),
    );
  }
}
