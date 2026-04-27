// // screens/progress_screen.dart
// import 'package:flutter/material.dart';
// import 'package:nexfit_flutter/Models/PersonalGoals.dart';
// import 'package:nexfit_flutter/Services/APIService.dart';

// class ProgressScreen extends StatefulWidget {
//   final int goalId;

//   ProgressScreen({required this.goalId});

//   @override
//   _ProgressScreenState createState() => _ProgressScreenState();
// }

// class _ProgressScreenState extends State<ProgressScreen> {
//   final ApiService apiService = ApiService();
//   final _formKey = GlobalKey<FormState>();
//   double _currentValue = 0;

//   Future<List<WeeklyProgress>>? _progressList;

//   @override
//   void initState() {
//     super.initState();
//     _progressList = apiService.getWeeklyProgress(widget.goalId);
//   }

//   _submitProgress() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       WeeklyProgress progress = WeeklyProgress(
//         personalGoalId: widget.goalId,
//         date: DateTime.now().toIso8601String().substring(0, 10),
//         currentValue: _currentValue,
//       );

//       try {
//         await apiService.addWeeklyProgress(progress);
//         setState(() {
//           _progressList = apiService.getWeeklyProgress(widget.goalId);
//         });
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add progress: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Progress')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Form(
//               key: _formKey,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(labelText: 'Current Value'),
//                       keyboardType: TextInputType.number,
//                       onSaved: (value) => _currentValue = double.parse(value!),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   ElevatedButton(
//                     onPressed: _submitProgress,
//                     child: Text('Add'),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             FutureBuilder<List<WeeklyProgress>>(
//               future: _progressList,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Text('No progress found');
//                 } else {
//                   final progressList = snapshot.data!;
//                   return Expanded(
//                     child: ListView.builder(
//                       itemCount: progressList.length,
//                       itemBuilder: (context, index) {
//                         final progress = progressList[index];
//                         return ListTile(
//                           title: Text(
//                               'Value: ${progress.currentValue}, Date: ${progress.date}'),
//                           // subtitle: Text(
//                           //     'Progress: ${progress.progressPercentage()}%'),
//                         );
//                       },
//                     ),
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nexfit_flutter/Models/PersonalGoals.dart';
import 'package:nexfit_flutter/Services/APIService.dart';

class ProgressScreen extends StatefulWidget {
  final int goalId;
  final int gymUserId;
  final int userId;
  ProgressScreen({required this.goalId, required this.gymUserId, required this.userId});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  double _currentValue = 0;

  Future<List<WeeklyProgress>>? _progressList;

  @override
  void initState() {
    super.initState();
    // _progressList = apiService.getWeeklyProgress(widget.userId,widget.goalId);
    print(_progressList);
  }

  _submitProgress() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      WeeklyProgress progress = WeeklyProgress(
        personalGoalId: widget.goalId,
        date: DateTime.now().toIso8601String().substring(0, 10),
        currentValue: _currentValue,
      );

      try {
        await apiService.addWeeklyProgress(progress);
        setState(() {
          // _progressList = apiService.getWeeklyProgress(widget.userId,widget.goalId);
        });
        print(_progressList);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add progress: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Progress')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Current Value'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _currentValue = double.parse(value!),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submitProgress,
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder<List<WeeklyProgress>>(
              future: _progressList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No progress found');
                } else {
                  final progressList = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: progressList.length,
                      itemBuilder: (context, index) {
                        final progress = progressList[index];
                        return ListTile(
                          title: Text(
                              'Value: ${progress.currentValue}, Date: ${progress.date}'),
                          // subtitle: Text(
                          //     'Progress: ${progress.progressPercentage()}%'),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
