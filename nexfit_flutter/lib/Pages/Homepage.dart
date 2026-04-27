// // // // ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables
// // // ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nexfit_flutter/Pages/WeeklyDietPlan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/APIService.dart';
import 'MemberLoginPage.dart';

class HomePage extends StatefulWidget {
  final int? userId;
  final int? gymUserId;
  const HomePage({Key? key, this.userId, required this.gymUserId})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  List<dynamic>? dietPlans;
  List<dynamic>? workoutPlans;
  List<dynamic>? userPurchases;
  int? gymID;

  @override
  void initState() {
    _fetchUserData();
    super.initState();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    print('Homepage User ID = $userId');
    try {
      final userData = await _apiService.getUserData(userId!);
      final dietPlan = await _apiService.getTraineeDietPlans(userId);
      final workoutPlan =
          await _apiService.getTraineeWorkoutPlans(widget.gymUserId!);
      final userPurchasesResponse =
          await _apiService.getUserPurchases(widget.gymUserId!);
      print(userPurchasesResponse);

      setState(() {
        _userData = userData;
        dietPlans = dietPlan;
        userPurchases = userPurchasesResponse;
        workoutPlans = workoutPlan;
      });
    } catch (e) {
      print(e);
    }
  }

  String getCurrentDay() {
    int currentDayIndex = DateTime.now().weekday;
    switch (currentDayIndex) {
      case DateTime.monday:
        return 'day_1';
      case DateTime.tuesday:
        return 'day_2';
      case DateTime.wednesday:
        return 'day_3';
      case DateTime.thursday:
        return 'day_4';
      case DateTime.friday:
        return 'day_5';
      case DateTime.saturday:
        return 'day_6';
      case DateTime.sunday:
        return 'day_7';
      default:
        return 'day_1';
    }
  }

  Map<String, dynamic>? getCurrentDayDietPlan() {
    if (dietPlans == null) return null;
    String currentDay = getCurrentDay();
    for (var dietPlan in dietPlans!) {
      for (var day in dietPlan['days']) {
        if (day['day'] == currentDay) {
          return day;
        }
      }
    }
    return null;
  }

  Map<String, dynamic>? getCurrentDayWorkoutPlan() {
    if (workoutPlans == null) return null;
    String currentDay = getCurrentDay();
    for (var workoutPlan in workoutPlans!) {
      for (var day in workoutPlan['Workout_plan_days']) {
        if (day['day'] == currentDay) {
          return day;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentDayDietPlan = getCurrentDayDietPlan();
    final currentDayWorkoutPlan = getCurrentDayWorkoutPlan();
    print(currentDayWorkoutPlan);
    return Scaffold(
      body: _userData != null
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 15),
                    child: Row(
                      children: [
                        Text(
                          'Hello',
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          ', ${_userData!['first_name']} ${_userData!['last_name']} 👋',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.lime,
                            borderRadius: BorderRadius.circular(15)),
                        alignment: Alignment.topLeft,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Member at',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.grey.shade800),
                              ),
                              Text(
                                '${_userData!['gym_name']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: Colors.grey.shade800),
                                textAlign: TextAlign.start,
                              ),
                            ]),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.lime,
                            borderRadius: BorderRadius.circular(15)),
                        alignment: Alignment.topLeft,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tokens Available',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.grey.shade800),
                              ),
                              Text(
                                '${_userData!['number_of_tokens']}',
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
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.lime,
                        borderRadius: BorderRadius.circular(15)),
                    alignment: Alignment.topLeft,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trained By',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.grey.shade800),
                          ),
                          Row(
                            children: [
                              Text(
                                '${_userData!['trainer_firstName']} ${_userData!['trainer_lastName']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                    color: Colors.grey.shade800),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ]),
                  ),

                  // Diet Plan Section
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.lime,
                        borderRadius: BorderRadius.circular(15)),
                    child: currentDayDietPlan != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Diet Plan for Today',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.grey.shade800),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => WeeklyDietPlan(
                                            dietPlans: dietPlans!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View Full Week',
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              Colors.grey.shade800),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Table(
                                border: TableBorder.all(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(15),
                                    width: 0.5),
                                children: [
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Breakfast',
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          currentDayDietPlan['breakfast'],
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Dinner',
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          currentDayDietPlan['dinner'],
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Lunch',
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        currentDayDietPlan['lunch'],
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Snacks',
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        currentDayDietPlan['snacks'],
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ])
                                ],
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Diet Plan for Today',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => WeeklyDietPlan(
                                            dietPlans: dietPlans!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View Full Week',
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              Colors.grey.shade800),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Cheat Day!',
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                  ),
                  // Workout Plan Section
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(15)),
                    child: currentDayWorkoutPlan != null
                        ? Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Workout Plan for Today',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    // color: Colors.grey.shade800,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '${currentDayWorkoutPlan['workout_name']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    // color: Colors.grey.shade800,
                                  ),
                                ),
                                SizedBox(height: 10),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      currentDayWorkoutPlan!['exercises'].length,
                                  itemBuilder: (context, index) {
                                    var exercise =
                                        currentDayWorkoutPlan!['exercises']
                                            [index];
                                    print(
                                        'http://192.168.1.13:8001/api${exercise!['image']}');
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        // color: Colors.lime,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                exercise['name'] ?? 'N/A',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  // color: Colors.grey.shade800,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                exercise['exercise_type'] ??
                                                    'Exercise_type',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                  // color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: Image.network(
                                                'http://192.168.1.13:8001/api${exercise!['image']}',
                                                height: 50,
                                              ))
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        )
                        : Center(
                            child: Text(
                              'No Workout Plan for Today',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.grey.shade800),
                            ),
                          ),
                  ),

                  // Purchases Section
                  if (userPurchases != null && userPurchases!.isNotEmpty)
                    Container(
                      width: MediaQuery.of(context).size.width - 50,
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          color: Colors.lime,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Purchase History',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Purchases: ${userPurchases!.length}',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                Text(
                                  'Total Tokens: ${userPurchases!.map((purchase) => purchase['number_of_tokens']).reduce((a, b) => a + b)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ]),
                    ),

                  // Example graph section
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.lime,
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Graph',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey.shade800),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey,
                                    strokeWidth: 1,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: SideTitles(showTitles: false),
                                topTitles: SideTitles(showTitles: false),
                                bottomTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  getTextStyles: (context, value) =>
                                      const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                  getTitles: (value) {
                                    switch (value.toInt()) {
                                      case 1:
                                        return 'M';
                                      case 2:
                                        return 'T';
                                      case 3:
                                        return 'W';
                                      case 4:
                                        return 'T';
                                      case 5:
                                        return 'F';
                                      case 6:
                                        return 'S';
                                      case 7:
                                        return 'S';
                                    }
                                    return '';
                                  },
                                  margin: 8,
                                ),
                                leftTitles: SideTitles(
                                  showTitles: true,
                                  getTextStyles: (context, value) =>
                                      const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                  getTitles: (value) {
                                    switch (value.toInt()) {
                                      case 1:
                                        return '1K';
                                      case 3:
                                        return '3K';
                                      case 5:
                                        return '5K';
                                    }
                                    return '';
                                  },
                                  reservedSize: 28,
                                  margin: 12,
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              minX: 0,
                              maxX: 7,
                              minY: 0,
                              maxY: 6,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 3),
                                    FlSpot(1, 1),
                                    FlSpot(2, 4),
                                    FlSpot(3, 2),
                                    FlSpot(4, 5),
                                    FlSpot(5, 2),
                                    FlSpot(6, 4),
                                  ],
                                  isCurved: true,
                                  colors: [Colors.red, Colors.green],
                                  barWidth: 5,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(show: true),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
