// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/APIService.dart';

class CreateDietPlan extends StatefulWidget {
  final int userID;
  final int trainerID;
  const CreateDietPlan(
      {super.key, required this.trainerID, required this.userID});
  @override
  State<CreateDietPlan> createState() => _CreateDietPlanState();
}

class _CreateDietPlanState extends State<CreateDietPlan> {
 final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String? _name;
  String? _description;
  List<Map<String, String>> _days = [];
  List<dynamic>? _trainees;
  final List<int> _selectedTrainees = [];

  final List<String> _dietDays = ['day_1', 'day_2', 'day_3', 'day_4', 'day_5', 'day_6', 'day_7'];

  @override
  void initState() {
    super.initState();
    _fetchTrainees();
    _addNewDay();
  }

  Future<void> _fetchTrainees() async {
    try {
      final trainees = await _apiService.getTraineesList(widget.userID);
      setState(() {
        _trainees = trainees;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _createDietPlan() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final dietPlanData = {
        'name': _name,
        'description': _description,
        'days': _days,
        'trainer_id':widget.trainerID,
        'trainees': _selectedTrainees,
      };

      try {
        final response = await _apiService.createDietPlan(dietPlanData, widget.trainerID);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Diet Plan Created Successfully')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create diet plan')));
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error occurred')));
      }
    }
  }

  void _addNewDay() {
    setState(() {
      _days.add({});
    });
  }

  void _removeDay(int index) {
    setState(() {
      _days.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Diet Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onSaved: (value) {
                    _description = value;
                  },
                ),
                _trainees != null
                    ? DropdownButtonFormField(
                        decoration: InputDecoration(labelText: 'Select Trainees'),
                        items: _trainees!.map((trainee) {
                          return DropdownMenuItem(
                            value: trainee['id'],
                            child: Text(trainee['first_name'] + ' ' + trainee['last_name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null && !_selectedTrainees.contains(value)) {
                            setState(() {
                              _selectedTrainees.add(value as int);
                            });
                          }
                        },
                      )
                    : Center(child: CircularProgressIndicator()),
                ..._days.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Day ${index + 1}'),
                          IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () => _removeDay(index),
                          ),
                        ],
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Day'),
                        items: _dietDays.map((String day) {
                          return DropdownMenuItem<String>(
                            value: day,
                            child: Text(day),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _days[index]['day'] = value!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Breakfast'),
                        onSaved: (value) {
                          _days[index]['breakfast'] = value!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Lunch'),
                        onSaved: (value) {
                          _days[index]['lunch'] = value!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Dinner'),
                        onSaved: (value) {
                          _days[index]['dinner'] = value!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Snacks'),
                        onSaved: (value) {
                          _days[index]['snacks'] = value!;
                        },
                      ),
                    ],
                  );
                }).toList(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addNewDay,
                  child: Text('Add Another Day'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createDietPlan,
                  child: Text('Create Diet Plan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}
