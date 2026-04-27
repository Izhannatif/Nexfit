// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:nexfit_flutter/Services/APIService.dart';

class EditDietPlan extends StatefulWidget {
  final int trainerId;
  final int planId;
  final int trainerUserID;

  const EditDietPlan(
      {Key? key,
      required this.trainerId,
      required this.planId,
      required this.trainerUserID})
      : super(key: key);

  @override
  _EditDietPlanState createState() => _EditDietPlanState();
}

class _EditDietPlanState extends State<EditDietPlan> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  TextEditingController planName = TextEditingController();
  TextEditingController planDescription = TextEditingController();
  TextEditingController traineeController = TextEditingController();
  bool isLoading = false;

  String? _name;
  String? _description;
  List<Map<String, String>> _days = [];
  List<dynamic>? _trainees;
  final List<int> _selectedTrainees = [];
  final List<String> _dietDays = [
    'day_1',
    'day_2',
    'day_3',
    'day_4',
    'day_5',
    'day_6',
    'day_7'
  ];

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
    _fetchDietPlanData();
    _fetchAllTrainees();
  }

  Future<void> _fetchDietPlanData() async {
    try {
      final dietPlanData = await _apiService.getDietPlan(widget.planId);
      setState(() {
        isLoading = true;
        planName.text = dietPlanData['name'];
        planDescription.text = dietPlanData['description'];
        _days = List<Map<String, String>>.from(
          dietPlanData['days'].map((day) => {
                'id': day['id'].toString(),
                'day': day['day'].toString(),
                'breakfast': day['breakfast'].toString(),
                'lunch': day['lunch'].toString(),
                'dinner': day['dinner'].toString(),
                'snacks': day['snacks'].toString(),
              }),
        );
        _selectedTrainees.addAll(
            List<int>.from(dietPlanData['trainees'].map((t) => t['id'])));
        isLoading = false;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error occurred')));
    }
  }

  Future<void> _fetchAllTrainees() async {
    try {
      final trainees = await _apiService.getTraineesList(widget.trainerUserID);
      setState(() {
        _trainees = trainees;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error occurred')));
    }
  }

  Future<void> _updateDietPlan() async {
    print('updating');
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print(_formKey.currentState);
      print(_selectedTrainees);
      final dietPlanData = {
        'name': _name,
        'description': _description,
        'days': _days,
        'trainer_id': widget.trainerId,
        'trainees': _selectedTrainees,
      };

      try {
        final response = await _apiService.updateDietPlan(
            widget.trainerId, widget.planId, dietPlanData);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Diet Plan Updated Successfully')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update diet plan')));
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error occurred')));
      }
    }
  }

  late final int dayId;
  void _removeDay(int index) async {
    if (_days[index]['id'] == null) {
      setState(() {
        _days.removeAt(index);
      });
    } else {
      dayId = int.parse(_days[index]['id']!);

      try {
        final response = await _apiService.deleteDietPlanDay(dayId);
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
    print('Adding New Day');
    setState(() {
      _days.add({
        'day': _dietDays[_days.length % _dietDays.length],
        'breakfast': '',
        'lunch': '',
        'dinner': '',
        'snacks': ''
      });
      print('Updated Days: $_days');
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
    final trainee = _trainees?.firstWhere((trainee) => trainee['id'] == id);
    return trainee != null ? trainee['first_name'] : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    print('Building UI');
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Diet Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
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
                      Text('Days Details:'),
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
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(labelText: 'Day'),
                                value: _days[index]['day'],
                                items: _dietDays.map((String day) {
                                  return DropdownMenuItem<String>(
                                    value: day,
                                    child: Text(_dayNameMap[day]!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _days[index]['day'] = value!;
                                  });
                                },
                              ),
                              TextFormField(
                                initialValue: _days[index]['breakfast'],
                                decoration:
                                    InputDecoration(labelText: 'Breakfast'),
                                onChanged: (value) {
                                  setState(() {
                                    _days[index]['breakfast'] = value;
                                  });
                                },
                                onSaved: (value) {
                                  _days[index]['breakfast'] = value!;
                                },
                              ),
                              TextFormField(
                                initialValue: _days[index]['lunch'],
                                decoration: InputDecoration(labelText: 'Lunch'),
                                onChanged: (value) {
                                  setState(() {
                                    _days[index]['lunch'] = value;
                                  });
                                },
                                onSaved: (value) {
                                  _days[index]['lunch'] = value!;
                                },
                              ),
                              TextFormField(
                                initialValue: _days[index]['dinner'],
                                decoration:
                                    InputDecoration(labelText: 'Dinner'),
                                onChanged: (value) {
                                  setState(() {
                                    _days[index]['dinner'] = value;
                                  });
                                },
                                onSaved: (value) {
                                  _days[index]['dinner'] = value!;
                                },
                              ),
                              TextFormField(
                                initialValue: _days[index]['snacks'],
                                decoration:
                                    InputDecoration(labelText: 'Snacks'),
                                onChanged: (value) {
                                  setState(() {
                                    _days[index]['snacks'] = value;
                                  });
                                },
                                onSaved: (value) {
                                  _days[index]['snacks'] = value!;
                                },
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
                        onPressed: _updateDietPlan,
                        child: Text(
                          'Update Diet Plan',
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
