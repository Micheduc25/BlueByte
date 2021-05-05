import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class AudioPlayScreen extends StatefulWidget {
  AudioPlayScreen({this.fileName, this.filePath, @required this.settings});

  final String filePath;
  final String fileName;
  final AppSettings settings;
  @override
  _AudioPlayScreenState createState() => _AudioPlayScreenState();
}

class _AudioPlayScreenState extends State<AudioPlayScreen> {
  AudioPlayer audioPlayer;
  bool playing;
  bool paused;
  bool stopped;
  String minutes;
  String seconds;
  String hours;
  Duration audioDuration;
  Duration position;
  StreamSubscription positionSubscription;

  StreamSubscription sub1;
  StreamSubscription sub2;
  StreamSubscription sub3;
  bool isFrench;
  StreamSubscription languageSubscription;
  // StreamSubscription sub4;

  @override
  void initState() {
    audioPlayer = new AudioPlayer();
    isFrench = widget.settings.globalLanguage.getValue() == Config.fr;
    audioPlayer.setUrl(widget.filePath, isLocal: true).then((val) async {
      // final result = await audioPlayer.getDuration();
      // print("result is $result");

      setState(() {});
    });

    positionSubscription = audioPlayer.onAudioPositionChanged.listen((pos) {
      if (mounted) {
        int totalSeconds = pos.inSeconds;
        int temphours = (totalSeconds / 3600).floor();
        int tempminutes = ((totalSeconds % 3600) / 60).floor();
        int tempseconds = ((totalSeconds % 3600) % 60).floor();
        setState(() {
          position = pos;
          print(position);
          hours = temphours < 10 ? '0$temphours' : '$temphours';
          minutes = tempminutes < 10 ? '0$tempminutes' : '$tempminutes';
          seconds = tempseconds < 10 ? '0$tempseconds' : '$tempseconds';
        });
      }
    });

    sub1 = audioPlayer.onPlayerCompletion.listen((data) {
      setState(() {
        position = Duration.zero;
      });

      print("Playing stopped");
    });

    sub2 = audioPlayer.onPlayerError.listen((err) {
      print("An error occurred with the audio player: $err");
    });

    sub3 = audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        audioDuration = duration;
        print("duration is $audioDuration");
      });
    });

    languageSubscription = widget.settings.globalLanguage.listen((newValue) {
      setState(() {
        isFrench = newValue == Config.fr;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    positionSubscription.cancel();
    sub1.cancel();
    sub2.cancel();
    sub3.cancel();
    languageSubscription.cancel();
    // audioPlayer?.release();

    audioPlayer?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(
            Icons.navigate_before,
            size: 30,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        title: SingleChildScrollView(
            scrollDirection: Axis.horizontal, child: Text(widget.fileName)),
        centerTitle: true,
        backgroundColor: AppColors.purpleNormal,
        actions: <Widget>[
          InkWell(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.share,
                color: Colors.white,
                size: 30,
              ),
            ),
            onTap: () async {
              if (widget.filePath != null) {
                await Share.shareFiles([widget.filePath],
                    subject:
                        Languages.shareAudio[isFrench ? Config.fr : Config.en],
                    text: "bluebyte audio: ${widget.fileName}");
              }
            },
          )
        ],
      ),
      body: Center(
        child: Container(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.fileName + ".m4a",
              style: Styles.purpleTextLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width > size.height ? 100 : 40),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                          disabledThumbColor: Colors.black,
                          trackHeight: 7,
                          activeTrackColor: AppColors.purpleNormal,
                          thumbColor: Colors.black,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 20),
                          inactiveTrackColor: AppColors.purpleLight),
                      child: Slider(
                        //slider position is by default between 0 and 1

                        onChanged: (v) {
                          if (audioDuration != null) {
                            final pos = v * audioDuration.inMicroseconds;
                            audioPlayer
                                .seek(Duration(microseconds: pos.round()));
                          }
                        },
                        value: (position != null &&
                                audioDuration != null &&
                                position.inMilliseconds > 0 &&
                                position.inMilliseconds <
                                    audioDuration.inMilliseconds)
                            ? position.inMicroseconds /
                                audioDuration
                                    .inMicroseconds //which is between 0 and 1
                            : 0.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    audioPlayer.state == AudioPlayerState.PLAYING ||
                            audioPlayer.state == AudioPlayerState.PAUSED
                        ? position.toString().split(".")[0]
                        // "${hours ?? '00'}:${minutes ?? '00'}:${seconds ?? '00'}"
                        : audioDuration.toString().split(".")[0],
                    style: Styles.purpleTextNormal,
                  )
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InkWell(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.purpleNormal),
                    child: Icon(
                      Icons.stop,
                      color: Colors.red,
                      size: 60,
                    ),
                  ),
                  onTap: () async {
                    if (audioPlayer.state == AudioPlayerState.PAUSED ||
                        audioPlayer.state == AudioPlayerState.PLAYING) {
                      await audioPlayer.stop();
                      setState(() {
                        position = Duration.zero;
                      });
                    }
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                InkWell(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.purpleNormal),
                    child: Icon(
                      audioPlayer.state == AudioPlayerState.PLAYING
                          ? Icons.pause
                          : audioPlayer.state == AudioPlayerState.PAUSED
                              ? Icons.play_arrow
                              : Icons.play_arrow,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  onTap: () async {
                    print("player state: ${audioPlayer.state}");
                    if (audioPlayer.state == AudioPlayerState.STOPPED ||
                        audioPlayer.state == AudioPlayerState.COMPLETED ||
                        audioPlayer.state == null) {
                      print("playings");
                      await audioPlayer.play(widget.filePath,
                          isLocal: true,
                          stayAwake: true,
                          position: Duration.zero);
                    } else if (audioPlayer.state == AudioPlayerState.PAUSED) {
                      await audioPlayer.resume();
                    } else if (audioPlayer.state == AudioPlayerState.PLAYING) {
                      await audioPlayer.pause();
                      setState(() {});
                    }
                  },
                ),
                SizedBox(width: 20),
                InkWell(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.purpleNormal),
                    child: Icon(
                      Icons.library_music,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ],
        )),
      ),
    );
  }

  List<String> getDurationTime() {
    int totalSeconds = audioDuration.inSeconds;
    int temphours = (totalSeconds / 3600).floor();
    int tempminutes = ((totalSeconds % 3600) / 60).floor();
    int tempseconds = ((totalSeconds % 3600) % 60).floor();

    String fhours = temphours < 10 ? '0$temphours' : '$temphours';
    String fminutes = tempminutes < 10 ? '0$tempminutes' : '$tempminutes';
    String fseconds = tempseconds < 10 ? '0$tempseconds' : '$tempseconds';

    return [fhours, fminutes, fseconds];
  }
}
