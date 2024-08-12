import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:just_waveform/just_waveform.dart';

class WaveformPlayer extends HookWidget {
  final String audioUrl =
      'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3';

  @override
  Widget build(BuildContext context) {
    final audioPlayer = useMemoized(() => AudioPlayer(), []);
    final progressStream = useState<WaveformProgress?>(null);
    final waveform = useState<Waveform?>(null);
    final isPlaying = useState<bool>(false);
    final playbackPosition = useState<Duration>(Duration.zero);

    useEffect(() {
      _generateWaveform(audioUrl, progressStream, waveform);
      return () => audioPlayer.dispose();
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text('Waveform Player'),
      ),
      body: Column(
        children: [
          if (waveform.value != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: WaveformWidget(
                  waveform: waveform.value!,
                  playbackPosition: playbackPosition.value,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(isPlaying.value ? Icons.pause : Icons.play_arrow),
                onPressed: () async {
                  if (isPlaying.value) {
                    await audioPlayer.pause();
                    isPlaying.value = false;
                  } else {
                    await audioPlayer.setUrl(audioUrl);
                    isPlaying.value = true;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateWaveform(
      String url,
      ValueNotifier<WaveformProgress?> progressStream,
      ValueNotifier<Waveform?> waveform) async {
    final client = http.Client();
    try {
      // Download and save the audio file temporarily
      final response = await client.send(http.Request('GET', Uri.parse(url)));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final audioFile = File(p.join(tempDir.path, 'waveform.mp3'));
        final sink = audioFile.openWrite();
        await response.stream.pipe(sink);
        await sink.close();

        // Generate waveform
        final waveFile = File(p.join(tempDir.path, 'waveform.wave'));
        final extractionProgress = JustWaveform.extract(
          audioInFile: audioFile,
          waveOutFile: waveFile,
        );

        extractionProgress.listen((progress) {
          progressStream.value = progress;
          if (progress.waveform != null) {
            waveform.value = progress.waveform;
          }
        }, onError: (e) {
          // Handle error
          print("Waveform extraction error: $e");
        });
      }
    } catch (e) {
      // Handle download error
      print("Error downloading audio: $e");
    } finally {
      client.close();
    }
  }
}

class WaveformWidget extends StatelessWidget {
  final Waveform waveform;
  final Duration playbackPosition;

  const WaveformWidget({
    required this.waveform,
    required this.playbackPosition,
    WaveformProgress? progress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveformPainter(waveform, playbackPosition),
      size: Size.infinite,
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Waveform waveform;
  final Duration playbackPosition;

  WaveformPainter(this.waveform, this.playbackPosition);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final waveformHeight = size.height / 2;
    final waveformWidth = size.width;

    final List<int> samples = waveform.data;
    final int sampleCount = samples.length;
    final double sampleWidth = waveformWidth / sampleCount;

    for (int i = 0; i < sampleCount; i++) {
      final double x = i * sampleWidth;
      final double y = waveformHeight * (1 - samples[i]);
      canvas.drawLine(Offset(x, waveformHeight), Offset(x, y), paint);
    }

    // Draw the current playback position
    if (playbackPosition != Duration.zero) {
      final positionWidth = waveformWidth *
          (playbackPosition.inMilliseconds / waveform.duration.inMilliseconds);
      paint.color = Colors.red;
      canvas.drawLine(
        Offset(positionWidth, 0),
        Offset(positionWidth, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.waveform != waveform ||
        oldDelegate.playbackPosition != playbackPosition;
  }
}
