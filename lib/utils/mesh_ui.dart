import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:just_audio/just_audio.dart';

class Mesh extends StatefulWidget {
  final String encode;
  const Mesh({
    super.key,
    required this.encode,
  });

  @override
  State<Mesh> createState() => _MeshState();
}

class _MeshState extends State<Mesh> with TickerProviderStateMixin {
  late final MeshGradientController _controller;
  bool _isAnimating = false;
  late Timer _timer;
  late final AudioPlayer _audioPlayer;
  double pitch = 0;

  final player = AudioPlayer();
  Duration pos = Duration.zero;
  Duration duration = Duration.zero;
  bool isAudioPlaying = false;

  @override
  void initState() {
    super.initState();

    _controller = MeshGradientController(
      points: [
        MeshGradientPoint(
          position: const Offset(
            -1,
            0.2,
          ),
          color: const Color(0xffF574E0),
        ),
        MeshGradientPoint(
          position: const Offset(
            2,
            0.6,
          ),
          color: const Color(0xffE414EE),
        ),
        MeshGradientPoint(
          position: const Offset(
            0.7,
            0.3,
          ),
          color: const Color(0xff3614CA),
        ),
        MeshGradientPoint(
          position: const Offset(
            0.4,
            0.8,
          ),
          color: const Color(0xff0F0830),
        ),
      ],
      vsync: this,
    );

    setState(() {
      _audioPlayer = AudioPlayer();
      _audioPlayer.setUrl(
          'https://gemini-radio-backend.onrender.com/stream/${widget.encode}');

      if (isAudioPlaying) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play();
        setState(() {
          pitch = _audioPlayer.pitch;
          print("Pitch ==========================${pitch}");
        });
      }

      if (_audioPlayer.playing) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    });

    // player.setAsset("assets/nv.wav");
    // player.positionStream.listen((p) {
    //   setState(() => pos = p);
    // });
    // player.durationStream.listen((d) {
    //   setState(() => duration = d ?? Duration.zero);
    // });
  }

  void _startAnimation() {
    _isAnimating = true;
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (_audioPlayer.playing) {
        if (_isAnimating) {
          _animateMeshGradient();
        } else {
          timer.cancel();
        }
      }
    });
  }

  void _stopAnimation() {
    if (!_audioPlayer.playing) {
      _isAnimating = false;
    }
  }

  Future<void> _animateMeshGradient() async {
    await _controller.animateSequence(
      duration: const Duration(seconds: 2),
      sequences: [
        AnimationSequence(
          pointIndex: 0,
          newPoint: MeshGradientPoint(
            position: Offset(
              Random().nextDouble() * 2 - 0.5,
              Random().nextDouble() * 2 - 0.5,
            ),
            color: _controller.points.value[0].color,
          ),
          interval: const Interval(
            0,
            0.5,
            curve: Curves.easeInOut,
          ),
        ),
        AnimationSequence(
          pointIndex: 1,
          newPoint: MeshGradientPoint(
            position: Offset(
              Random().nextDouble() * 2 - 0.5,
              Random().nextDouble() * 2 - 0.5,
            ),
            color: _controller.points.value[1].color,
          ),
          interval: const Interval(
            0.25,
            0.75,
            curve: Curves.easeInOut,
          ),
        ),
        AnimationSequence(
          pointIndex: 2,
          newPoint: MeshGradientPoint(
            position: Offset(
              Random().nextDouble() * 2 - 0.5,
              Random().nextDouble() * 2 - 0.5,
            ),
            color: _controller.points.value[2].color,
          ),
          interval: const Interval(
            0.5,
            1,
            curve: Curves.easeInOut,
          ),
        ),
        AnimationSequence(
          pointIndex: 3,
          newPoint: MeshGradientPoint(
            position: Offset(
              Random().nextDouble() * 2 - 0.5,
              Random().nextDouble() * 2 - 0.5,
            ),
            color: _controller.points.value[3].color,
          ),
          interval: const Interval(
            0.75,
            1,
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x7373735B),
              blurRadius: 50,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink.withOpacity(0.9),
              ),
              child: SizedBox(
                height: 200,
                width: 200,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: MeshGradient(
                        controller: _controller,
                        options: MeshGradientOptions(
                          blend: 3.5,
                          noiseIntensity: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // super.dispose();
    _isAnimating = false;
    // player.dispose();
  }
}
