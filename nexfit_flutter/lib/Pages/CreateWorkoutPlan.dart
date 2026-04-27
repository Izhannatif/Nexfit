// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:nexfit_flutter/Services/APIService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateWorkoutPlan extends StatefulWidget {
  final int? userID;
  final int? trainerID;
  const CreateWorkoutPlan({super.key, this.userID, this.trainerID});

  @override
  State<CreateWorkoutPlan> createState() => _CreateWorkoutPlanState();
}

class _CreateWorkoutPlanState extends State<CreateWorkoutPlan> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  String _planName = '';
  String _description = '';
  List<Map<String, dynamic>> _workoutDays = [];
  List<dynamic> _exercises = [];
  final List<int> _selectedTrainees = [];
  List<dynamic>? _trainees;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchExercises();
    _fetchAllTrainees();
  }

  Future<void> _fetchExercises() async {
    try {
      final exercises = await _apiService.getExercisesData();
      setState(() {
        _exercises = exercises;
      });
    } catch (e) {
      print('Failed to load exercises: $e');
    }
  }

  Future<void> _fetchAllTrainees() async {
    try {
      final trainees = await _apiService.getTraineesList(widget.userID!);
      setState(() {
        _trainees = trainees;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error occurred')));
    }
  }

  void _addWorkoutDay() {
    setState(() {
      _workoutDays.add({'day': '', 'workout_name': '', 'exercises': []});
    });
    print(_workoutDays);
  }

  void _removeWorkoutDay(int index) {
    setState(() {
      _workoutDays.removeAt(index);
    });
    print(_workoutDays);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Collect form data and make API call
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('trainer_id')!;

      List<Map<String, dynamic>> processedWorkoutDays = _workoutDays.map((day) {
        return {
          'day': day['day'],
          'workout_name': day['workout_name'],
          'exercises': (day['exercises'] as List)
              .map<int>((exercise) => exercise['id'] as int)
              .toList(),
        };
      }).toList();
      Map<String, dynamic> workoutPlanData = {
        'name': nameController.text,
        'description': _description,
        'trainer': userId,
        'trainees': _selectedTrainees,
        'days': processedWorkoutDays,
      };
      try {
        final response = await _apiService.createWorkoutPlan(workoutPlanData);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Workou Plan Created Successfully')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create Workout Plan')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error occurred : $e')));
      }
    }
  }

  void _addNewTrainee(int traineeId) {
    setState(() {
      if (!_selectedTrainees.contains(traineeId)) {
        _selectedTrainees.add(traineeId);
      }
    });
    print(_selectedTrainees);
  }

  String _getTraineeName(int id) {
    final trainee = _trainees?.firstWhere((trainee) => trainee['id'] == id);
    return trainee != null ? trainee['first_name'] : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Workout Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Plan Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a plan name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _planName = value!;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(
                height: 10,
              ),
              Text('Assigned Trainees:'),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _selectedTrainees
                    .map((id) => Chip(
                          label: Text(_getTraineeName(id)),
                          onDeleted: () {
                            setState(() {
                              _selectedTrainees.remove(id);
                            });
                          },
                        ))
                    .toList(),
              ),
              if (_trainees != null)
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Add Trainee'),
                  items: _trainees!.map<DropdownMenuItem<int>>((trainee) {
                    return DropdownMenuItem<int>(
                      value: trainee['id'],
                      child: Text(trainee['first_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _addNewTrainee(value);
                    }
                  },
                ),
              const SizedBox(height: 20),
              Text('Workout Days',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ..._workoutDays.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> day = entry.value;
                return _buildWorkoutDayTile(index, day);
              }).toList(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addWorkoutDay,
                child: Text('Add Workout Day'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Create Workout Plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildWorkoutDayTile(int index, Map<String, dynamic> day) {
  //   // Dropdown items
  //   List<String> dropdownItems = [
  //     'day_1_$index',
  //     'day_2_$index',
  //     'day_3_$index',
  //     'day_4_$index',
  //     'day_5_$index',
  //     'day_6_$index',
  //     'day_7_$index',
  //   ];

  //   // Initial value for the dropdown
  //   String initialValue = dropdownItems.first;

  //   // Check if the current day value exists in the dropdown items
  //   if (dropdownItems.contains(day['day'])) {
  //     initialValue = day['day'];
  //   }

  //   return Card(
  //     margin: EdgeInsets.symmetric(vertical: 8.0),
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           DropdownButtonFormField(
  //             key: Key((index).toString()), // Unique key for each dropdown
  //             decoration: InputDecoration(labelText: 'Day'),
  //             items: dropdownItems.map((value) {
  //               return DropdownMenuItem(child: Text(value), value: value);
  //             }).toList(),
  //             value: initialValue,
  //             onChanged: (value) {
  //               setState(() {
  //                 _workoutDays[index]['day'] = value!;
  //               });
  //             },
  //             validator: (value) {
  //               if (value == null) {
  //                 return 'Please select a day';
  //               }
  //               return null;
  //             },
  //           ),
  //           TextFormField(
  //             decoration: InputDecoration(labelText: 'Workout Name'),
  //             initialValue: day['workout_name'],
  //             onChanged: (value) {
  //               setState(() {
  //                 _workoutDays[index]['workout_name'] = value;
  //               });
  //             },
  //           ),
  //           const SizedBox(height: 10),
  //           Text('Exercises', style: TextStyle(fontWeight: FontWeight.bold)),
  //           const SizedBox(height: 5),
  //           ...day['exercises'].map<Widget>((exercise) {
  //             return ListTile(
  //               title: Text(exercise['name']),
  //               trailing: IconButton(
  //                 icon: Icon(Icons.delete),
  //                 onPressed: () {
  //                   setState(() {
  //                     _workoutDays[index]['exercises'].remove(exercise);
  //                   });
  //                 },
  //               ),
  //             );
  //           }).toList(),
  //           const SizedBox(height: 10),
  //           ElevatedButton(
  //             onPressed: () async {
  //               final selectedExercise = await _showExerciseDialog();
  //               if (selectedExercise != null) {
  //                 setState(() {
  //                   _workoutDays[index]['exercises'].add(selectedExercise);
  //                 });
  //               }
  //             },
  //             child: Text('Add Exercise'),
  //           ),
  //           const SizedBox(height: 10),
  //           ElevatedButton(
  //             onPressed: () => _removeWorkoutDay(index),
  //             child: Text('Remove Day'),
  //             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildWorkoutDayTile(int index, Map<String, dynamic> day) {
    List<String> dropdownItems = [
      'day_1',
      'day_2',
      'day_3',
      'day_4',
      'day_5',
      'day_6',
      'day_7',
    ];

    String initialValue =
        dropdownItems.contains(day['day']) ? day['day'] : 'day_1';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField(
              key: Key((index).toString()),
              decoration: InputDecoration(labelText: 'Day'),
              items: dropdownItems.map((value) {
                return DropdownMenuItem(child: Text(value), value: value);
              }).toList(),
              value: initialValue,
              onChanged: (value) {
                setState(() {
                  _workoutDays[index]['day'] = value!;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a day';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Workout Name'),
              initialValue: day['workout_name'],
              onChanged: (value) {
                setState(() {
                  _workoutDays[index]['workout_name'] = value;
                });
              },
            ),
            const SizedBox(height: 10),
            Text('Exercises', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            ...day['exercises'].map<Widget>((exercise) {
              return ListTile(
                title: Text(exercise['name']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _workoutDays[index]['exercises'].remove(exercise);
                    });
                  },
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final selectedExercise = await _showExerciseDialog();
                if (selectedExercise != null) {
                  setState(() {
                    _workoutDays[index]['exercises'].add(selectedExercise);
                  });
                }
              },
              child: Text('Add Exercise'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _removeWorkoutDay(index),
              child: Text('Remove Day'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  // Future<Map<String, dynamic>?> _showExerciseDialog() async {
  //   return await showDialog<Map<String, dynamic>>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Select Exercise'),
  //         content: Container(
  //           width: double.maxFinite,
  //           child: ListView.builder(
  //             shrinkWrap: true,
  //             itemCount: _exercises.length,
  //             itemBuilder: (context, index) {
  //               return ListTile(
  //                 title: Text(_exercises[index]['name']),
  //                 onTap: () {
  //                   Navigator.pop(context, _exercises[index]);
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<Map<String, dynamic>?> _showExerciseDialog() async {
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Exercise'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_exercises[index]['name']),
                  onTap: () {
                    Navigator.pop(context, {
                      'id': _exercises[index]['id'],
                      'name': _exercises[index]['name'],
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
