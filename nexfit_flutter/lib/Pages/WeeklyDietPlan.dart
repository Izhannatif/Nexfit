// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class WeeklyDietPlan extends StatelessWidget {
  final List<dynamic> dietPlans;

  WeeklyDietPlan({Key? key, required this.dietPlans}) : super(key: key);
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Diet Plan'),
        scrolledUnderElevation: 0,
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          
          itemCount: dietPlans.length,
          itemBuilder: (context, index) {
            final dietPlan = dietPlans[index];
            return Card(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.symmetric(vertical: 10),
              elevation: 5,

              child: ExpansionTile(
                backgroundColor: Colors.transparent,
                
                shape: RoundedRectangleBorder(side: BorderSide.none,borderRadius: BorderRadius.circular(15)),
                title: Text(
                  dietPlan['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.lime,
                  ),
                ),
                subtitle: Text(
                  dietPlan['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                children: dietPlan['days']
                    .map<Widget>((day) => _buildDayCard(day))
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getDayName(day['day']),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.lime,
                ),
              ),
              SizedBox(height: 10),
              _buildMealRow('Breakfast', day['breakfast']),
              _buildMealRow('Lunch', day['lunch']),
              _buildMealRow('Dinner', day['dinner']),
              _buildMealRow('Snacks', day['snacks']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealRow(String mealType, String meal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$mealType: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          Expanded(
            child: Text(
              meal,
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(String dayCode) {
    switch (dayCode) {
      case 'day_1':
        return 'Monday';
      case 'day_2':
        return 'Tuesday';
      case 'day_3':
        return 'Wednesday';
      case 'day_4':
        return 'Thursday';
      case 'day_5':
        return 'Friday';
      case 'day_6':
        return 'Saturday';
      case 'day_7':
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}
