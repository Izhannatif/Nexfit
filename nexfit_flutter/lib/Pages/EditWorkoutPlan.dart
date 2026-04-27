// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:nexfit_flutter/Services/APIService.dart';

class EditWorkoutPlan extends StatefulWidget {
  final int trainerId;
  final int planId;
  final int trainerUserID;

  const EditWorkoutPlan(
      {Key? key,
      required this.trainerId,
      required this.planId,
      required this.trainerUserID})
      : super(key: key);

  @override
  _EditWorkoutPlanState createState() => _EditWorkoutPlanState();
}

class _EditWorkoutPlanState extends State<EditWorkoutPlan> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  TextEditingController planName = TextEditingController();
  TextEditingController planDescription = TextEditingController();
  bool isLoading = false;

  String? _name;
  String? _description;
  List<Map<String, dynamic>> _days = [];
  List<dynamic>? _trainees;
  final List<int> _selectedTrainees = [];

  final Map<String, String> _dayNameMap = {
    'day_1': 'Monday',
    'day_2': 'Tuesday',
    'day_3': 'Wednesday',
    'day_4': 'Thursday',
    'day_5': 'Friday',
    'day_6': 'Saturday',
    'day_7': 'Sunday'
  };

  @override
  void initState() {
    super.initState();
    _fetchWorkoutPlanData();
    _fetchAllTrainees();
  }

  Future<void> _fetchWorkoutPlanData() async {
    try {
      final workoutPlanData =
          await _apiService.getWorkoutPlanDetails(widget.planId);
      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        isLoading = true;
        planName.text = workoutPlanData['name'];
        planDescription.text = workoutPlanData['description'];
        _days = List<Map<String, dynamic>>.from(
          workoutPlanData['Workout_plan_days'].map((day) => {
                'id': day['id'].toString(),
                'workout_name': day['workout_name'].toString(),
                'day': day['day'].toString(),
                'exercises':
                    List<dynamic>.from(day['exercises'].map((exercise) => {
                          'id': exercise['id'].toString(),
                          'name': exercise['name'].toString(),
                          'description': exercise['description'].toString(),
                          'image': exercise['image'].toString(),
                        })),
              }),
        );
        _selectedTrainees.addAll(
          List<int>.from(workoutPlanData['trainees'].map((t) => t['id'])),
        );
        isLoading = false;
      });
    } catch (e) {
      print(e);
      if (!mounted) return; // Check if the widget is still mounted
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error occurred')));
    }
  }

  Future<void> _fetchAllTrainees() async {
    try {
      final trainees = await _apiService.getTraineesList(widget.trainerUserID);
      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        _trainees = trainees;
      });
    } catch (e) {
      print(e);
      if (!mounted) return; // Check if the widget is still mounted
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error occurred')));
    }
  }

  Future<void> _updateWorkoutPlan() async {
    print('updating');
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      List<Map<String, dynamic>> processedWorkoutDays = _days.map((day) {
        List<dynamic> exercises = day['exercises'];
        List<int> exerciseIds = exercises
            .where((exercise) =>
                exercise.containsKey('id') && exercise['id'] != null)
            .map<int>((exercise) {
          final id = exercise['id'];
          if (id is int) {
            return id;
          } else if (id is String) {
            return int.tryParse(id) ?? 0; // Default to 0 if parsing fails
          } else {
            return 0; // Default to 0 for unexpected types
          }
        }).toList();

        return {
          'day': day['day'],
          'workout_name': day['workout_name'],
          'exercises': exerciseIds,
        };
      }).toList();

      final workoutPlanData = {
        'name': _name,
        'description': _description,
        'Workout_plan_days': processedWorkoutDays,
        'trainer_id': widget.trainerId,
        'trainees': _selectedTrainees,
      };

      try {
        final response = await _apiService.updateWorkoutPlan(
            widget.trainerId, widget.planId, workoutPlanData);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Workout Plan Updated Successfully')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update workout plan')));
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error occurred')));
      }
    }
  }

  void _removeDay(int index) async {
    if (_days[index]['id'] == null) {
      setState(() {
        _days.removeAt(index);
      });
    } else {
      final dayId = int.parse(_days[index]['id']);
      try {
        final response = await _apiService.deleteWorkoutPlanDay(dayId);
        if (response.statusCode == 200) {
          setState(() {
            _days.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Day removed successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove day')),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred')),
        );
      }
    }
  }

  void _addNewDay() {
    setState(() {
      _days.add({
        'workout_name': '',
        'day': _dayNameMap.keys.elementAt(_days.length % _dayNameMap.length),
        'exercises': [],
      });
    });
  }

  void _addNewTrainee(int traineeId) {
    setState(() {
      if (!_selectedTrainees.contains(traineeId)) {
        _selectedTrainees.add(traineeId);
      }
    });
  }

  String _getTraineeName(int id) {
    if (_trainees == null) {
      return 'Unknown';
    }

    final trainee = _trainees!
        .firstWhere((trainee) => trainee['id'] == id, orElse: () => null);
    return trainee != null ? trainee['first_name'] : 'Unknown';
  }

  void _addExercisesToDay(int dayIndex, List<dynamic> exercises) {
    setState(() {
      _days[dayIndex]['exercises'].addAll(exercises);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text('Edit Workout Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading || _trainees == null || _days.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: planName,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _name = value;
                          });
                        },
                        onSaved: (value) {
                          _name = value;
                        },
                      ),
                      TextFormField(
                        controller: planDescription,
                        decoration: InputDecoration(labelText: 'Description'),
                        onChanged: (value) {
                          setState(() {
                            _description = value;
                          });
                        },
                        onSaved: (value) {
                          _description = value;
                        },
                      ),
                      SizedBox(height: 16),
                      Text('Assigned Trainees:'),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _selectedTrainees.map((id) {
                          final traineeName = _getTraineeName(id);
                          return Chip(
                            label: Text(traineeName),
                            onDeleted: () {
                              setState(() {
                                _selectedTrainees.remove(id);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (_trainees != null)
                        DropdownButtonFormField<int>(
                          decoration: InputDecoration(labelText: 'Add Trainee'),
                          items:
                              _trainees!.map<DropdownMenuItem<int>>((trainee) {
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
                      SizedBox(height: 16),
                      Text('Workout Days:'),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _days.length,
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_dayNameMap[_days[index]['day']] ??
                                      'Unknown Day'),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle),
                                    onPressed: () => _removeDay(index),
                                  ),
                                ],
                              ),
                              TextFormField(
                                initialValue: _days[index]['workout_name'],
                                decoration:
                                    InputDecoration(labelText: 'Workout Name'),
                                onChanged: (value) {
                                  setState(() {
                                    _days[index]['workout_name'] = value;
                                  });
                                },
                                onSaved: (value) {
                                  _days[index]['workout_name'] = value!;
                                },
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _days[index]['exercises'].length,
                                itemBuilder: (context, exIndex) {
                                  return ListTile(
                                    title: Text(_days[index]['exercises']
                                        [exIndex]['name']),
                                    trailing: IconButton(
                                      icon: Icon(Icons.remove_circle),
                                      onPressed: () {
                                        setState(() {
                                          _days[index]['exercises']
                                              .removeAt(exIndex);
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Code to add new exercise
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return ExerciseSelectionDialog(
                                        onExercisesSelected: (exercises) {
                                          _addExercisesToDay(index, exercises);
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Text('Add Exercise'),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          elevation: 0,
                        ),
                        onPressed: _addNewDay,
                        child: Text(
                          'Add Another Day',
                          style: TextStyle(color: Colors.lime),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lime,
                          elevation: 0,
                        ),
                        onPressed: _updateWorkoutPlan,
                        child: Text(
                          'Update Workout Plan',
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class ExerciseSelectionDialog extends StatefulWidget {
  final Function(List<dynamic>) onExercisesSelected;

  ExerciseSelectionDialog({required this.onExercisesSelected});

  @override
  _ExerciseSelectionDialogState createState() =>
      _ExerciseSelectionDialogState();
}

class _ExerciseSelectionDialogState extends State<ExerciseSelectionDialog> {
  List<dynamic> _exercises = [];
  List<dynamic> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  void _fetchExercises() async {
    // Replace with your APIService call
    List<dynamic> exercises = await ApiService().getExercisesData();
    setState(() {
      _exercises = exercises;
    });
  }

  void _toggleSelection(Map<String, dynamic> exercise) {
    setState(() {
      if (_selectedExercises.contains(exercise)) {
        _selectedExercises.remove(exercise);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Exercises'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _exercises.length,
          itemBuilder: (context, index) {
            final exercise = _exercises[index];
            final isSelected = _selectedExercises.contains(exercise);
            return ListTile(
              title: Text(exercise['name']),
              trailing: isSelected
                  ? Icon(Icons.check_box)
                  : Icon(Icons.check_box_outline_blank),
              onTap: () => _toggleSelection(exercise),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onExercisesSelected(_selectedExercises);
            Navigator.of(context).pop();
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
