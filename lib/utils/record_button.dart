import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

const _introAnimationEnd = 60 / 240;
const _lastStopIconAnimationEnd = 180 / 240;

class RecordButton extends StatefulWidget {
  const RecordButton({
    Key? key,
    required this.onStartRecording,
    required this.onStopRecording,
    this.size = 200,
    required this.record,
  }) : super(key: key);

  final bool record;
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;
  final double size;

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  bool isRecording = false;
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isRecording = !isRecording;
        });
        if (isRecording) {
          widget.onStartRecording?.call();
          _controller.animateTo(_lastStopIconAnimationEnd);
        } else {
          widget.onStopRecording?.call();
          _controller.animateTo(1);
        }
      },
      child: Lottie.network(
        "https://assets.codepen.io/35984/record_button.json",
        controller: _controller,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.fill,
        repeat: false,
        onLoaded: (composition) {
          _controller.duration = composition.duration;
          _controller.animateTo(_introAnimationEnd);
          _controller.addListener(() {
            if (_controller.value == 1) {
              _controller.value = _introAnimationEnd;
            }
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
