// // screens/add_goal_screen.dart
// import 'package:flutter/material.dart';
// import 'package:nexfit_flutter/Models/PersonalGoals.dart';
// import 'package:nexfit_flutter/Services/APIService.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class AddGoalScreen extends StatefulWidget {
//   final int gymUserId;
//   const AddGoalScreen({super.key, required this.gymUserId});

//   @override
//   _AddGoalScreenState createState() => _AddGoalScreenState();
// }

// class _AddGoalScreenState extends State<AddGoalScreen> {
//   final ApiService apiService = ApiService();
//   final _formKey = GlobalKey<FormState>();
//   String _goalType = 'weight_loss';
//   double _targetValue = 0;
//   String _startDate = '';
//   String _endDate = '';

//   void _submitGoal() async {
//   if (_formKey.currentState!.validate()) {
//     _formKey.currentState!.save();

//     // Replace with actual user_id
//     print(widget.gymUserId);
//     Map<String, dynamic> goalData = {
//       'gym_user': widget.gymUserId,
//       'goal_type': _goalType,
//       'target_value': _targetValue,
//       'start_date': _startDate,
//       'end_date': _endDate,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse('http://192.168.1.13:8001/api/personal-goals/'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(goalData),
//       );

//       if (response.statusCode == 201) {
//         Navigator.pop(context);
//       } else {
//         print('Failed to add goal: ${response.body}');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add goal: $e')),
//       );
//     }
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Goal')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               DropdownButtonFormField<String>(
//                 value: _goalType,
//                 onChanged: (value) => setState(() {
//                   _goalType = value!;
//                 }),
//                 items: [
//                   DropdownMenuItem(
//                     value: 'weight_gain',
//                     child: Text('Weight Gain'),
//                   ),
//                   DropdownMenuItem(
//                     value: 'weight_loss',
//                     child: Text('Weight Loss'),
//                   ),
//                   DropdownMenuItem(
//                     value: 'bmi',
//                     child: Text('BMI'),
//                   ),
//                 ],
//                 decoration: InputDecoration(labelText: 'Goal Type'),
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Target Value'),
//                 keyboardType: TextInputType.number,
//                 onSaved: (value) => _targetValue = double.parse(value!),
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
//                 onSaved: (value) => _startDate = value!,
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
//                 onSaved: (value) => _endDate = value!,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitGoal,
//                 child: Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// screens/add_goal_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddGoalScreen extends StatefulWidget {
  final int gymUserId;

  const AddGoalScreen({super.key, required this.gymUserId});

  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  String _goalType = 'weight_loss';
  double _targetValue = 0;
  String _startDate = '';
  String _endDate = '';

  void _submitGoal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Map<String, dynamic> goalData = {
        'gym_user': widget.gymUserId,
        'goal_type': _goalType,
        'target_value': _targetValue,
        'start_date': _startDate,
        'end_date': _endDate,
      };

      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.13:8001/api/personal-goals/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(goalData),
        );

        if (response.statusCode == 201) {
          Navigator.pop(context);
        } else {
          print('Failed to add goal: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add goal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _goalType,
                onChanged: (value) => setState(() {
                  _goalType = value!;
                }),
                items: [
                  DropdownMenuItem(
                    value: 'weight_gain',
                    child: Text('Weight Gain'),
                  ),
                  DropdownMenuItem(
                    value: 'weight_loss',
                    child: Text('Weight Loss'),
                  ),
                  DropdownMenuItem(
                    value: 'bmi',
                    child: Text('BMI'),
                  ),
                ],
                decoration: InputDecoration(labelText: 'Goal Type'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Target Value'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _targetValue = double.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
                onSaved: (value) => _startDate = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
                onSaved: (value) => _endDate = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitGoal,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
