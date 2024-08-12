import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PromptApi extends StatefulWidget {
  const PromptApi({super.key});

  @override
  State<PromptApi> createState() => _PromptApiState();
}

class _PromptApiState extends State<PromptApi> {
  @override
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendData() async {
    final url = Uri.parse('http://192.168.1.9:5000/prompt');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"string_data": _controller.text}),
    );

    if (response.statusCode == 200) {
      print('Data sent successfully');
    } else {
      print('Failed to send data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter to Flask'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Type something',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendData,
              child: Text('Send Data'),
            ),
          ],
        ),
      ),
    );
  }
}
