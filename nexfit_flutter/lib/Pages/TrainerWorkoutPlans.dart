// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nexfit_flutter/Pages/CreateWorkoutPlan.dart';
import 'package:nexfit_flutter/Pages/ProfilePage.dart';
import 'package:nexfit_flutter/Pages/WorkoutPlanDetails.dart';
import 'package:nexfit_flutter/Services/APIService.dart';

class TrainerWorkoutPlans extends StatefulWidget {
  final int trainerId;
  final int userId;

  const TrainerWorkoutPlans(
      {super.key, required this.trainerId, required this.userId});

  @override
  State<TrainerWorkoutPlans> createState() => _TrainerWorkoutPlansState();
}

class _TrainerWorkoutPlansState extends State<TrainerWorkoutPlans> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _workoutPlans;

  @override
  void initState() {
    super.initState();
    _workoutPlans = _apiService.getWorkoutPlans(widget.trainerId);
    print(_workoutPlans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Workout Plans'.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 25,
          ),
        ),
        actions: [
          
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CreateWorkoutPlan(
                        trainerID: widget.trainerId,
                        userID: widget.userId,
                      )));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.lime, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Text(
                    'Add New',
                    style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w900),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.grey.shade800,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _workoutPlans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('No diet plans available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var dietPlan = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WorkoutPlanDetails(
                        planId: dietPlan['id'],
                        trainerId: widget.trainerId,
                        userId: widget.userId,
                      ),
                    ));
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.lime.withOpacity(1)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${dietPlan['name']}'.toCapitalized(),
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.grey.shade800,
                              fontSize: 21),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${dietPlan['description']}'.toCapitalized(),
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        SizedBox(height: 8),
                        Text(
                          'Assigned To:',
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (dietPlan['trainees'] as List<dynamic>)
                              .map((trainee) {
                            print(trainee);
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                '- ${trainee['first_name']} ${trainee['last_name']}',
                                style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
