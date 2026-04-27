// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../Services/APIService.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final ApiService _apiService = ApiService();
  List<dynamic>? _exerciseData;

  @override
  void initState() {
    _fetchExercisesData();
    super.initState();
  }

  Future<void> _fetchExercisesData() async {
    try {
      final List<dynamic> response = await _apiService.getExercisesData();
      print(response);
      setState(() {
        _exerciseData = response;
      });
    } catch (e) {
      print('Error fetching Exercise data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Exercises',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            )),
        body: _exerciseData == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _exerciseData!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 5),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      tileColor: Colors.grey.shade900,
                      leading: _exerciseData![index]['image'] != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                                'http://192.168.1.13:8001/api${_exerciseData![index]['image']}', 
                                fit: BoxFit.cover,
                                scale: 1.5,
                              ),
                          )
                          : CircleAvatar(),
                      title: Text(
                        _exerciseData![index]['name'],
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_exerciseData![index]['exercise_type'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              )),
                        ],
                      ),
                    ),
                  );
                }));
  }
}
