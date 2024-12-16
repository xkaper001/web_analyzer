import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late WebSocketChannel channel;
  late StreamController<String> _streamController;
  List<String> notifications = [];


  @override
  void initState() {
    super.initState();
    _streamController = StreamController<String>();
    channel = WebSocketChannel.connect(
      Uri.parse('ws://172.25.213.113:8000/ws'),
    );

    channel.stream.listen((message) {
      log('Message received: $message');
      _streamController.add(message);
    }, onError: (error) {
      log('WebSocket error: $error');
    }, onDone: () {
      log('WebSocket connection closed');
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Web App Anaylzer Group 51"),
      ),
      body: StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No notifications yet.'));
          }

          // Parse the WebSocket message
          final data = jsonDecode(snapshot.data as String);
          if (data['type'] == 'failed-login') {
            final loginData = data['data'];
            final email = loginData['email'];
            final ipAddress = loginData['ip_address'];
            final browser = loginData['browser'];
            final timestamp = loginData['timestamp'];

            return ListView(
              children: [
                ListTile(
                  title: const Text('Failed login attempt'),
                  subtitle: Text(
                    'Email: $email\n'
                    'IP Address: $ipAddress\n'
                    'Browser: $browser\n'
                    'Time: $timestamp',
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Unknown notification type.'));
        },
      ),
    );
  }
}
