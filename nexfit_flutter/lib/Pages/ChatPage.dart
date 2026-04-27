// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nexfit_flutter/Services/APIService.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final int senderId;
  final int receiverId;
  final bool isTrainer;
  const ChatPage(
      {Key? key,
      required this.senderId,
      required this.receiverId,
      required this.isTrainer})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class ChatMessage {
  final String message;
  final bool isSentByMe;

  ChatMessage({required this.message, required this.isSentByMe});
}

class _ChatPageState extends State<ChatPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _listViewController = ScrollController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> messages = []; // To store chat messages
  bool _isSending = false;
  @override
  void initState() {
    _fetchUserData();
    fetchChatHistory();
    initPusher();
    super.initState();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? trainerUserId = prefs.getInt('trainer_userId');
    // print('Trainer Chat Page User ID = $userId');
    bool? isTrainer = prefs.getBool('isTrainer');
    print('Trainer User ID on Chat Page : $trainerUserId');
    try {
      final userData = isTrainer == false
          ? await _apiService.getTrainerData(trainerUserId!)
          : await _apiService.getUserData(widget.receiverId);
      print('Chat Page User Data = $userData');
      setState(() {
        _userData = userData;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchChatHistory() async {
    var url = Uri.parse(
        'http://192.168.1.13:8001/api/chat-history/${widget.senderId}/${widget.receiverId}');
    print(
        'http://192.168.1.13:8001/api/chat-history/${widget.senderId}/${widget.receiverId}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> messageData = jsonDecode(response.body);
      setState(() {
        messages = messageData
            .map((msg) {
              bool isSentByMe =
                  msg['sender_id'].toString() == widget.senderId.toString();
              print(
                  "History Message: ${msg['message']}, Sender: ${msg['sender_id']}, isSentByMe: $isSentByMe"); // Debug print
              return ChatMessage(
                  message: msg['message'], isSentByMe: isSentByMe);
            })
            .toList()
            .cast<ChatMessage>(); // Ensure each item is cast to ChatMessage
      });
      // Call scrollToBottom after a delay to ensure UI has time to build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    } else {
      print("Failed to load chat history");
    }
  }

  void initPusher() async {
    try {
      await pusher.init(
        apiKey: "a199a1c31350a0a266a7",
        cluster: "ap2",
        onConnectionStateChange: onConnectionStateChange,
        onEvent: onEvent,
      );
      await pusher.subscribe(channelName: "chat_channel");
      await pusher.connect();
    } catch (e) {
      print("Error initializing Pusher: $e");
    }
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    print("Connection state changed: From $previousState to $currentState");
    if (currentState == 'CONNECTED') {
      print("Successfully connected to Pusher.");
    }
  }

  void onEvent(PusherEvent event) {
    print("Received event: ${event.data}");
    if (event.eventName == "new_message") {
      var data = jsonDecode(event.data);
      // Decode the JSON data
      bool isSentByMe =
          data['senderId'].toString() == widget.senderId.toString();
      print('Data = ${data['senderId']}');
      print('Is Sent By Me =  $isSentByMe');
      setState(() {
        messages
            .add(ChatMessage(message: data['message'], isSentByMe: isSentByMe));
      });
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    if (_listViewController.hasClients) {
      final position = _listViewController.position.maxScrollExtent;
      _listViewController.animateTo(
        position + 100,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty || _isSending) {
      print("No message to send or message is already being sent");
      return; // Prevent sending if empty or already sending
    }
    setState(() {
      _isSending = true; // Set sending state to true
    });

    var url = Uri.parse('http://192.168.1.13:8001/api/send_message/');
    var response = await http.post(url, body: {
      'sender-id': widget.senderId.toString(),
      'receiver-id': widget.receiverId.toString(),
      'message': message.trim(),
      'channel': 'conversation',
    });

    _messageController.clear();
    if (response.statusCode == 200) {
      print("Message sent successfully");
    } else {
      print("Failed to send message");
    }

    setState(() {
      _isSending =
          false; // Reset sending state regardless of success or failure
    });
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Align(
      alignment:
          message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: message.isSentByMe ? Colors.lime.shade300 : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.message,
            style: TextStyle(
                color: message.isSentByMe ? Colors.black : Colors.black)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _userData != null
          ? Scaffold(
              backgroundColor: Color.fromRGBO(26,26, 26,1),
              appBar: AppBar(
                leading: widget.isTrainer
                    ? IconButton(
                        icon: Icon(Icons.arrow_back_ios_new),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    : null,
                title: Text(
                  widget.isTrainer == true
                      ? '${_userData!['first_name']} ${_userData!['last_name']}'
                      : '${_userData!['first_name']} ${_userData!['last_name']}'
                          .toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                        controller: _listViewController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) =>
                            _buildMessageItem(messages[index])),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.lime,
                                  ),
                                  borderRadius: BorderRadius.circular(25)),
                              disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.lime,
                                  ),
                                  borderRadius: BorderRadius.circular(25)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.lime,
                                  ),
                                  borderRadius: BorderRadius.circular(25)),
                              labelText: "Type a message",
                              labelStyle:
                                  TextStyle(color: Colors.grey.shade600),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Colors.lime.shade500,
                          ),
                          onPressed: () => _messageController.text == ''
                              ? null
                              : sendMessage(_messageController.text),
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

  @override
  void dispose() {
    pusher.unsubscribe(channelName: "conversation");
    pusher.disconnect();
    super.dispose();
  }
}
