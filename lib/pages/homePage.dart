import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fm_proj/audio_out/prompt_api.dart';
import 'package:fm_proj/pages/wave.dart';
import 'package:fm_proj/utils/constants.dart';
import 'package:fm_proj/utils/record_button.dart';
import 'package:fm_proj/pages/sample_cont.dart';
import 'package:fm_proj/utils/mesh_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import '../audio_out/audio_stream_api.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  bool down = false;

  double _confLevel = 0;

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  bool _rec = false;
  bool _audioPlay = false;

  bool _songPlaying = true;

  String encoded = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    print('ON start listening');
    _speechToText.listen(onResult: _onSpeechResult, partialResults: true);

    setState(() {
      _rec = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    print("on stop listening");
    setState(() {
      _rec = false;
      _audioPlay = true;
    });
  }

  void _onSpeechResult(result) {
    // print('RESULT: ' + result.toString());
    setState(() {
      print('INit Init');
      _lastWords = result.recognizedWords;
      _confLevel = result.confident;
    });
  }

  Future<void> _sendData() async {
    final url = Uri.parse(Usage.flutterToPy);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"string_data": _lastWords}),
    );

    if (response.statusCode == 200) {
      print('Data sent successfully');
    } else {
      print('Failed to send data');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _lastWords = '';
    _speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        title: Text(
          "Blend",
          style: GoogleFonts.raleway(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xff1A1A1A),
        leading: Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: GestureDetector(
            onTap: () {
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => Mesh()));
              setState(() {
                _audioPlay = !_audioPlay;
                down = !down;
              });
            },
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  "images/user.svg",
                  semanticsLabel: 'user',
                  color: Usage.appBarIcon,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 700),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: _audioPlay
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        //color: Colors.grey,
                        key: ValueKey(1),
                        decoration: BoxDecoration(boxShadow: [
                          // BoxShadow(
                          //     blurRadius: 10,
                          //     spreadRadius: 2,
                          //     color: Colors.white24)
                        ]),
                        height: screenHeight * 0.30,
                        child: Mesh(
                          encode: encoded,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          //color: Colors.grey,
                          key: ValueKey(2),
                          height: screenHeight * 0.21,
                          width: screenHeight * 0.21,
                          child: RecordButton(
                            onStartRecording: () {
                              setState(() {
                                down = !down;
                                print(down);
                                print('isListening? : ' +
                                    _speechToText.isListening.toString());
                                _speechToText.isListening
                                    ? _stopListening()
                                    : _startListening();
                              });
                            },
                            onStopRecording: () {
                              _stopListening();
                              print(
                                  "${_lastWords}kkkkkkkkkkkkkkkkkkkkkkkkkkkkk");

                              setState(() {
                                encoded = json.encode(_lastWords);
                              });
                            },
                            record: _rec,
                            // onStartRecording:
                            // record: _rec,
                            // onStopRecording: () {
                            //   setState(() {
                            //     down = !down;
                            //     print(down);
                            //     if (_rec == true) {}
                            //     // _sendData();
                            //   });
                            // },
                          ),
                        ),
                        _audioPlay
                            ? Container()
                            : Container(
                                //color: Colors.pink,
                                height: screenHeight * 0.05,
                                width: screenWidth,
                                child: Center(
                                  child: Text(
                                      _speechToText.isListening
                                          ? 'Listening..'
                                          : _speechEnabled
                                              ? 'Tap to Speak'
                                              : 'Access Denied',
                                      style: GoogleFonts.ubuntu(
                                          fontSize: 15,
                                          color: Colors.grey.shade600)),
                                  // child: GradientText(
                                  //   _speechToText.isListening
                                  //       ? 'Listening..'
                                  //       : _speechEnabled
                                  //           ? 'Tap to Speak'
                                  //           : 'Access Denied',
                                  //   style: GoogleFonts.ubuntu(fontSize: 15),
                                  //   colors: [
                                  //     Color(0xff4D4D4D),
                                  //     Color(0xffD8D8D8),
                                  //     Color(0xffd2d2d2),
                                  //     Color(0xffD8D8D8),
                                  //     Color(0xff4D4D4D),
                                  //   ],
                                  // ),
                                ),
                              ),
                      ],
                    ),
                  ),
          ),
          _audioPlay
              ? Container(
                  height: screenHeight * 0.10,
                  width: screenWidth,
                  child: Text(""))
              : Container(
                  height: screenHeight * 0.10,
                  width: screenWidth,
                  //color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15),
                        child: GradientText(
                          _lastWords,
                          style: GoogleFonts.dmMono(fontSize: 13),
                          colors: [
                            Color(0xff4D4D4D),
                            Color(0xffD8D8D8),
                            Color(0xffd2d2d2),
                            Color(0xffD8D8D8),
                            Color(0xff4D4D4D),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          _audioPlay
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        height: screenHeight * 0.3,
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                _audioPlay = !_audioPlay;
                              });
                            },
                            icon: Icon(
                              Icons.mic,
                              color: Colors.white24,
                            )))
                  ],
                )
              : Container(
                  //color: Colors.blueAccent,
                  height: screenHeight * 0.3,
                  child: Content(
                      //rec: down,
                      ),
                ),
        ],
      ),
    );
  }
}
