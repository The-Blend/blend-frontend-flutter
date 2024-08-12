import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fm_proj/utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class Content extends StatefulWidget {
  //bool rec;
  Content({
    super.key,
  });

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        AnimatedPositioned(
          width: screenWidth,
          height: selected ? 300 : 300.0,
          top: selected ? 200 : 20.0,
          duration: const Duration(seconds: 2),
          curve: Curves.easeOut,
          child: GestureDetector(
            onTap: () {
              setState(() {
                selected = !selected;
                // widget.rec = !widget.rec;
              });
            },
            child: Column(
              children: [
                Center(
                    child: Icon(
                  selected
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down_outlined,
                  color: Colors.white,
                  size: 35,
                )),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(Usage.flutterToPy);
                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: json.encode({"string_data": Usage.egPrompt1}),
                    );

                    if (response.statusCode == 200) {
                      print('Data sent successfully');
                    } else {
                      print('Failed to send data');
                    }
                  },
                  child: Container(
                    height: 60,
                    width: screenWidth,
                    color: Colors.grey.shade800.withOpacity(0.2),
                    child: Center(
                        child: Text(
                      Usage.egPrompt1,
                      style: GoogleFonts.roboto(
                          color: Usage.promptTxt.withOpacity(0.5)),
                    )),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(Usage.flutterToPy);
                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: json.encode({"string_data": Usage.egPrompt2}),
                    );

                    if (response.statusCode == 200) {
                      print('Data sent successfully');
                    } else {
                      print('Failed to send data');
                    }
                  },
                  child: Container(
                    height: 60,
                    width: screenWidth,
                    color: Colors.grey.shade700.withOpacity(0.2),
                    child: Center(
                        child: Text(
                      Usage.egPrompt2,
                      style: GoogleFonts.roboto(
                          color: Colors.white.withOpacity(0.6)),
                    )),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(Usage.flutterToPy);
                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: json.encode({"string_data": Usage.egPrompt3}),
                    );

                    if (response.statusCode == 200) {
                      print('Data sent successfully');
                    } else {
                      print('Failed to send data');
                    }
                  },
                  child: Container(
                    height: 60,
                    width: screenWidth,
                    color: Colors.grey.shade600.withOpacity(0.2),
                    child: Center(
                        child: Text(
                      Usage.egPrompt3,
                      style: GoogleFonts.roboto(
                          color: Colors.white.withOpacity(0.7)),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
