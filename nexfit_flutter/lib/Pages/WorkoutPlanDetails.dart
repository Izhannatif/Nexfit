// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nexfit_flutter/Pages/EditWorkoutPlan.dart';
import 'package:nexfit_flutter/Services/APIService.dart';

class WorkoutPlanDetails extends StatefulWidget {
  final int planId;
  final int trainerId;
  final int userId;
  const WorkoutPlanDetails(
      {super.key,
      required this.planId,
      required this.trainerId,
      required this.userId});

  @override
  State<WorkoutPlanDetails> createState() => _WorkoutPlanDetailsState();
}

class _WorkoutPlanDetailsState extends State<WorkoutPlanDetails> {
  Map<String, dynamic>? workoutPlan;
  bool isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchWorkoutPlanDetails();
  }

  void _fetchWorkoutPlanDetails() async {
    final response = await _apiService.getWorkoutPlanDetails(widget.planId);
    setState(() {
      workoutPlan = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workoutPlan != null ? workoutPlan!['name'] : 'Loading...'),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditWorkoutPlan(
                    trainerId: widget.trainerId,
                    planId: widget.planId,
                    trainerUserID: widget.userId,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.lime, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Text(
                    'Edit Plan',
                    style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w900),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.edit,
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : workoutPlan != null
              ? _buildWorkoutPlanDetails()
              : Center(child: Text('Failed to load workout plan details.')),
    );
  }

  Widget _buildWorkoutPlanDetails() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workoutPlan!['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              workoutPlan!['description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Divider(),
            _buildTraineesSection(),
            _buildWorkoutDays(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutDays() {
    List<dynamic> workoutDays = workoutPlan!['Workout_plan_days'];
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: workoutDays.length,
      itemBuilder: (context, index) {
        var day = workoutDays[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            title: Text('${day['workout_name']} - ${day['day']}'),
            children: _buildExercises(day['exercises']),
          ),
        );
      },
    );
  }

  List<Widget> _buildExercises(List<dynamic> exercises) {
    return exercises.map((exercise) {
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            'http://192.168.1.13:8001/api${exercise!['image']}',
            height: 150,
          ),
        ),
        title: Text(exercise['name']),
        subtitle: Text(exercise['exercise_type']),
      );
    }).toList();
  }

  Widget _buildTraineesSection() {
    List<dynamic> assignedTrainees = workoutPlan!['trainees'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Trainees',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: assignedTrainees.map<Widget>((trainee) {
            return Chip(
              label: Text(trainee['first_name']),
            );
          }).toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
