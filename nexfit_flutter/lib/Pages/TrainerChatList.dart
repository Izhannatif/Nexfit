// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:nexfit_flutter/Pages/ChatPage.dart';
import 'package:nexfit_flutter/Pages/ProfilePage.dart';
import 'package:nexfit_flutter/Services/APIService.dart';

class TrainerChatList extends StatefulWidget {
  final int? userID;
  final int? trainerID;
  final bool isTrainer;
  const TrainerChatList(
      {super.key,
      required this.userID,
      required this.trainerID,
      required this.isTrainer});

  @override
  State<TrainerChatList> createState() => _TrainerChatListState();
}

class _TrainerChatListState extends State<TrainerChatList> {
  final ApiService _apiService = ApiService();
  List<dynamic>? traineesList;
  bool isLoading = false;
  @override
  void initState() {
    _fetchTraineesList();
    super.initState();
  }

  Future<void> _fetchTraineesList() async {
    print('user ID ${widget.userID}');
    print('trainer ID ${widget.trainerID}');
    try {
      final List<dynamic> response =
          await _apiService.getTraineesList(widget.userID!);
      setState(() {
        isLoading = true;
        traineesList = response;
      });
      print(response);
    } catch (e) {
      print('Error fetching Trainer Chat List data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: traineesList == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.lime,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    'Trainees',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: traineesList!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 8),
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            contentPadding: EdgeInsets.all(8),
                            tileColor: Colors.black12,
                            leading: CircleAvatar(
                              child: Icon(
                                Icons.message,
                                size: 20,
                                color: Colors.lime.shade500,
                              ),
                              backgroundColor: Colors.grey.shade900,
                            ),
                            onTap: (() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ChatPage(
                                              isTrainer: widget.isTrainer,
                                              senderId: widget.trainerID!,
                                              receiverId: traineesList![index]
                                                  ['user'])));
                            }),
                            title: Text(
                              '${traineesList![index]['first_name']} ${traineesList![index]['last_name']} '
                                  .toCapitalized(),
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w500),
                            ),
                            // subtitle: Text('Last Message Here //Needs to be done.', style: TextStyle(fontSize: 12, color: Colors.grey),),
                          ),
                        );
                      }),
                ),
              ],
            ),
    );
  }
}
