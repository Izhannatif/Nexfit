// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:nexfit_flutter/Pages/AttendancePage.dart';
import 'package:nexfit_flutter/Services/APIService.dart';
import 'package:intl/intl.dart';

class AttendanceTable extends StatefulWidget {
  final int? userID;
  final bool isTrainer;
  const AttendanceTable({super.key, required this.userID, required this.isTrainer});

  @override
  State<AttendanceTable> createState() => _AttendanceTableState();
}

class _AttendanceTableState extends State<AttendanceTable> {
  final ApiService _apiService = ApiService();
  List<dynamic>? _attendanceData;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    _fetchUserAttendance();
    super.initState();
  }

  Future<void> _fetchUserAttendance() async {
    try {
      final List<dynamic> response =
          await _apiService.getUserAttendance(widget.userID!);
      setState(() {
        _attendanceData = response;
        _isLoading = false;
      });
      print(response);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load attendance data.';
        _isLoading = false;
      });
      print(e);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d').format(date);
  }

  List<DateTime> _getWeekDates(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  bool _isAttended(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _attendanceData!.any((attendance) => attendance['date'] == dateStr);
  }

  void _previousWeek() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: 7));
    });
  }

  bool get _isCurrentWeek {
    final now = DateTime.now();
    final startOfWeek = _getWeekDates(now).first;
    final endOfWeek = _getWeekDates(now).last;
    return _currentDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
        _currentDate.isBefore(endOfWeek.add(Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates(_currentDate);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text('Weekly Attendance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right:10.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => AttendancePage(
                      userID: widget.userID,
                      isTrainer: widget.isTrainer,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.qr_code_scanner_rounded,size: 40,),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.lime,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!),
                )
              : Column(
                  children: [
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: _previousWeek,
                        ),
                        Text(
                          'Week of ${_formatDate(weekDates.first)} - ${_formatDate(weekDates.last)}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        _isCurrentWeek
                          ? SizedBox(width: 48) // Placeholder to maintain alignment
                          : IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: _nextWeek,
                            ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: weekDates.length,
                        itemBuilder: (context, index) {
                          final date = weekDates[index];
                          final attended = _isAttended(date);
                          return ListTile(
                            leading: Icon(
                              attended ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: attended ? Colors.green : Colors.red,
                            ),
                            title: Text(
                              _formatDate(date),
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
