// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:nexfit_flutter/Pages/CreateDietPlan.dart';
import 'package:nexfit_flutter/Pages/CreateWorkoutPlan.dart';
import 'package:nexfit_flutter/Pages/ProfilePage.dart';
import 'package:nexfit_flutter/Pages/TrainerWorkoutPlans.dart';
import 'package:nexfit_flutter/Services/APIService.dart';
import 'package:nexfit_flutter/Pages/TrainerDietPlans.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TrainerHome extends StatefulWidget {
  final int userID;
  final int trainerID;
  final bool isTrainer;

  const TrainerHome(
      {super.key,
      required this.userID,
      required this.trainerID,
      required this.isTrainer});

  @override
  State<TrainerHome> createState() => _TrainerHomeState();
}

class _TrainerHomeState extends State<TrainerHome> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _trainerData;
  bool isLoading = false;
  List<dynamic>? traineesList;

  @override
  void initState() {
    super.initState();
    fetchTrainerData();
    _fetchTraineesList();
  }

  Future<void> fetchTrainerData() async {
    try {
      final trainerData = await _apiService.getTrainerData(widget.userID);
      print('Trainer Home Data : $trainerData');
      isLoading = true;
      setState(() {
        _trainerData = trainerData;
      });
      isLoading = false;
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchTraineesList() async {
    print('user ID ${widget.userID}');
    print('trainer ID ${widget.trainerID}');
    try {
      final List<dynamic> response =
          await _apiService.getTraineesList(widget.userID!);
      setState(() {
        isLoading = true;
        traineesList = response;
      });
      print(response);
    } catch (e) {
      print('Error fetching Trainer Chat List data: $e');
    }
  }

  String calculateExpectedIncome() {
    int expected_icome =
        _trainerData!['monthly_charges'] * traineesList!.length;
    return 'Rs ${expected_icome}/- '.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _trainerData == null || traineesList == null
            ? CircularProgressIndicator()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hello',
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          ', ${_trainerData!['first_name']} ${_trainerData!['last_name']} 👋',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2.3,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          margin:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                          decoration: BoxDecoration(
                              color: Colors.lime,
                              borderRadius: BorderRadius.circular(15)),
                          alignment: Alignment.topLeft,
                          height: 100,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trainer at',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Colors.grey.shade800),
                                ),
                                Text(
                                  '${_trainerData!['gym_name']}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22,
                                      color: Colors.grey.shade800),
                                  textAlign: TextAlign.start,
                                ),
                              ]),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2.3,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          margin: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                              color: Colors.lime,
                              borderRadius: BorderRadius.circular(15)),
                          alignment: Alignment.topLeft,
                          height: 100,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly Charges',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Colors.grey.shade800),
                                ),
                                Text(
                                  'Rs ${_trainerData!['monthly_charges']}/-'
                                      .toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: Colors.grey.shade800),
                                  textAlign: TextAlign.start,
                                ),
                              ]),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(15)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Trainees',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Wrap(
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.spaceEvenly,
                              children: traineesList!.map((trainee) {
                                return Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Chip(
                                    backgroundColor: Colors.transparent,
                                    label: Text(
                                      ' ${trainee['first_name']} ${trainee['last_name']}'
                                          .toTitleCase(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        // color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ]),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.sackDollar,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expected Monthly Income',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                calculateExpectedIncome(),
                                style: TextStyle(
                                    fontSize: 23, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TrainerDietPlans(
                                  trainerId: widget.trainerID,
                                  trainerUserID: widget.userID,
                                )));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.lime.shade600,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.kitchenSet,
                                  size: 50,
                                  color: Colors.grey.shade800,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Your Diet\nPlans'.toUpperCase(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.grey.shade800,
                              size: 30,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TrainerWorkoutPlans(
                                trainerId: widget.trainerID,
                                userId: widget.userID),
                          ),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.lime.shade600,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.dumbbell,
                                  size: 50,
                                  color: Colors.grey.shade800,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Your Workout\nPlans'.toUpperCase(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.grey.shade800,
                              size: 30,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
