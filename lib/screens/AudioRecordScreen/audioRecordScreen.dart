import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:new_bluebyte/components/purpleButton.dart';
import 'package:new_bluebyte/database/dbOps.dart';
import 'package:new_bluebyte/models/audioModel.dart';

import 'package:new_bluebyte/provider/audiosProvider.dart';

import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class AudioRecordScreen extends StatefulWidget {
  AudioRecordScreen({this.settings, this.moduleName});
  final AppSettings settings;
  final String moduleName;
  @override
  _AudioRecordScreenState createState() => _AudioRecordScreenState();
}

class _AudioRecordScreenState extends State<AudioRecordScreen>
    with SingleTickerProviderStateMixin {
  bool loading;
  bool isRecording;
  bool paused;
  bool stoped;
  bool playing;
  AnimationController animationController;
  FlutterAudioRecorder recorder;
  String fileName;
  double scaleFactor;
  bool animate;
  bool recorderInitialized;
  bool playPaused;
  AudioPlayer audioPlayer;
  String minutes;
  String seconds;
  String hours;

  String filePath;
  Timer timerRef;
  bool exitResult;
  Duration audioDuration;

  @override
  void initState() {
    super.initState();
    loading = false;
    isRecording = false;
    playing = false;
    playPaused = false;
    paused = false;
    stoped = false;
    minutes = '00';
    hours = '00';
    seconds = '00';
    recorderInitialized = false;
    scaleFactor = 1;
    audioPlayer = new AudioPlayer();

    audioPlayer.onAudioPositionChanged.listen((position) {
      if (mounted) {
        print(position);
        int totalSeconds = position.inSeconds;
        int temphours = (totalSeconds / 3600).floor();
        int tempminutes = ((totalSeconds % 3600) / 60).floor();
        int tempseconds = ((totalSeconds % 3600) % 60).floor();
        setState(() {
          hours = temphours < 10 ? '0$temphours' : '$temphours';
          minutes = tempminutes < 10 ? '0$tempminutes' : '$tempminutes';
          seconds = tempseconds < 10 ? '0$tempseconds' : '$tempseconds';
        });
      }
    });

    audioPlayer.onPlayerCompletion.listen((data) {
      setState(() {
        playing = false;
        paused = false;
      });

      print("Playing stopped");
    });

    audioPlayer.onPlayerError.listen((err) {
      print("An error occurred: $err");
    });

    audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        audioDuration = duration;
      });
    });

    animationController = new AnimationController(
        upperBound: 0.3, vsync: this, duration: Duration(milliseconds: 500));

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });

    Future.delayed(Duration.zero, () async {
      bool hasPermission = await FlutterAudioRecorder.hasPermissions;
      // print("permission is $hasPermission");
      if (!hasPermission) {
        hasPermission = await Permission.microphone.request().isGranted;
        // print("permission requested again $status");
        if (!hasPermission) {
          Navigator.of(context).pop();
        }
      }
      if (hasPermission) {
        final result = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              var controller = TextEditingController();
              bool isFrench =
                  widget.settings.globalLanguage.getValue() == Config.fr;
              return SingleChildScrollView(
                child: Center(
                  child: Dialog(
                    backgroundColor: Colors.white,
                    child: Container(
                      padding: EdgeInsets.all(7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(Languages
                              .fileName[isFrench ? Config.fr : Config.en]),
                          SizedBox(height: 30),
                          TextField(
                            autofocus: true,
                            controller: controller,
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (text) async {
                              if (text.isNotEmpty) {
                                Directory appDir =
                                    await getExternalStorageDirectory();

                                Directory audioDir =
                                    await new Directory(Path.join(
                                  appDir.path,
                                  widget.moduleName,
                                  "audios",
                                )).create(recursive: true);
                                setState(() {
                                  fileName = text;
                                  recorder = new FlutterAudioRecorder(
                                      Path.join(audioDir.path, text),
                                      audioFormat: AudioFormat.AAC);

                                  print("recorder created $recorder");

                                  filePath =
                                      Path.join(audioDir.path, text + ".m4a");
                                });
                                await recorder.initialized;
                                setState(() {
                                  recorderInitialized = true;
                                });
                                Navigator.of(context).pop(true);
                              }
                            },
                            cursorColor: AppColors.purpleNormal,
                            decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.purpleNormal,
                                        width: 2)),
                                hintText: Languages
                                    .fileName[isFrench ? Config.fr : Config.en],
                                hintStyle: TextStyle(
                                    color: AppColors.purpleLight,
                                    fontSize: 15)),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              PurpleButton(
                                label: "OK",
                                onPressed: () async {
                                  if (controller.text.isNotEmpty) {
                                    Directory appDir =
                                        await getExternalStorageDirectory();
                                    Directory audioDir =
                                        await new Directory(Path.join(
                                      appDir.path,
                                      widget.moduleName,
                                      "audios",
                                    )).create(recursive: true);
                                    setState(() {
                                      fileName = controller.text;
                                      recorder = new FlutterAudioRecorder(
                                          Path.join(
                                              audioDir.path, controller.text),
                                          audioFormat: AudioFormat.AAC);

                                      filePath = Path.join(audioDir.path,
                                          controller.text + ".m4a");
                                      print(filePath);
                                    });
                                    await recorder.initialized;
                                    setState(() {
                                      recorderInitialized = true;
                                    });

                                    Navigator.of(context).pop(true);
                                  }
                                },
                              ),
                              SizedBox(width: 15),
                              PurpleButton(
                                  label: Languages
                                      .cancel[isFrench ? Config.fr : Config.en],
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  }),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });

        if (!result || result == null) {
          Navigator.of(context).pop();
        }
      }
    });

    timerRef = Timer.periodic(Duration(milliseconds: 50), (timer) async {
      if (recorder != null && recorderInitialized) {
        var recording = await recorder.current(channel: 0);

        int totalSeconds = recording.duration.inSeconds;
        int temphours = (totalSeconds / 3600).floor();
        int tempminutes = ((totalSeconds % 3600) / 60).floor();
        int tempseconds = ((totalSeconds % 3600) % 60).floor();

        if (mounted)
          setState(() {
            hours = temphours < 10 ? '0$temphours' : '$temphours';
            minutes = tempminutes < 10 ? '0$tempminutes' : '$tempminutes';
            seconds = tempseconds < 10 ? '0$tempseconds' : '$tempseconds';
          });
      }
    });
  }

  @override
  void dispose() async {
    animationController?.dispose();

    audioPlayer?.dispose();
    timerRef.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String lang = widget.settings.globalLanguage.getValue();
    bool isFrench = lang == Config.fr;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.purpleNormal,
        title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child:
                Text(Languages.recordAudio[isFrench ? Config.fr : Config.en])),
        leading: InkWell(
          child: Icon(
            Icons.navigate_before,
            size: 30,
          ),
          onTap: () async {
            if (exitResult == null && stoped) {
              int moduleId = await DbOperations.getModuleId(widget.moduleName);
              await showAskDialog(context);

              if (exitResult) {
                //if user decides to save the audio
                //we add it to database
                await DbOperations.addAudio(new Audio(
                    moduleId: moduleId,
                    filename: fileName,
                    description: "",
                    path: filePath));

                final audios =
                    await Provider.of<AudioProvider>(context, listen: false)
                        .getAudios(moduleId);
                Provider.of<AudioProvider>(context, listen: false).setAudios =
                    audios;
              } else {
                //else we delete the file
                try {
                  await Directory(filePath).delete(recursive: true);
                } catch (e) {
                  print("could not delete audio $e");
                }
              }
            }

            Navigator.of(context).pop();
          },
        ),
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
              if (filePath != null) {
                await Share.shareFiles([filePath],
                    subject:
                        Languages.shareAudio[isFrench ? Config.fr : Config.en],
                    text: "bluebyte audio: $fileName");
              }
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Transform.scale(
                    scale: scaleFactor + animationController.value,
                    child: Container(
                      // padding: EdgeInsets.all(40),
                      child: Text(
                        "$hours:$minutes:$seconds",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.purpleNormal,
                            fontSize: 35,
                            fontWeight: FontWeight.bold),
                      ),
                      padding: EdgeInsets.all(70),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.purpleNormal, width: 3)),
                    ),
                  ),
                ),
                SizedBox(height: 60),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "a",
                      onPressed: () async {
                        final recording = await recorder.current(channel: 0);
                        if (recording.status == RecordingStatus.Paused ||
                            recording.status == RecordingStatus.Recording) {
                          try {
                            await recorder.stop();
                            animationController.value = 0;
                            animationController.stop();
                            setState(() {
                              stoped = true;
                              timerRef.cancel();
                              isRecording = false;
                              paused = false;
                            });
                          } catch (e) {
                            print("could not stop recording" + e.toString());
                          }
                        } else if (stoped) {
                          await audioPlayer.stop();

                          int totalSeconds = audioDuration.inSeconds;
                          int temphours = (totalSeconds / 3600).floor();
                          int tempminutes =
                              ((totalSeconds % 3600) / 60).floor();
                          int tempseconds =
                              ((totalSeconds % 3600) % 60).floor();

                          setState(() {
                            hours =
                                temphours < 10 ? '0$temphours' : '$temphours';
                            minutes = tempminutes < 10
                                ? '0$tempminutes'
                                : '$tempminutes';
                            seconds = tempseconds < 10
                                ? '0$tempseconds'
                                : '$tempseconds';

                            playing = false;
                            paused = false;
                          });
                        }
                      },
                      child: Icon(
                        Icons.stop,
                        color: Colors.white,
                        size: 30,
                      ),
                      backgroundColor: AppColors.purpleNormal,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: FloatingActionButton(
                        heroTag: "b",
                        onPressed: () async {
                          //here we record
                          final recording = await recorder.current(channel: 0);
                          final status = recording.status;

                          if (status == RecordingStatus.Initialized) {
                            setState(() {
                              isRecording = true;
                              paused = false;
                              animate = true;
                            });

                            try {
                              animationController.forward();
                              await recorder.start();
                            } catch (e) {
                              print("unable to record" + e.toString());
                            }
                          } else if (status == RecordingStatus.Recording) {
                            try {
                              setState(() {
                                isRecording = false;
                                paused = true;
                              });
                              animationController.value = 0;
                              animationController.stop();
                              await recorder.pause();
                            } catch (e) {
                              print("unable to pause" + e.toString());
                            }
                          } else if (status == RecordingStatus.Paused) {
                            try {
                              setState(() {
                                isRecording = true;
                                paused = false;
                              });
                              animationController.forward();
                              await recorder.resume();
                            } catch (e) {
                              print("unable to resume" + e.toString());
                            }
                          } else if (stoped) {
                            if (!playing) {
                              try {
                                //recorded audio should be played here
                                setState(() {
                                  playing = true;
                                  playPaused = false;
                                });

                                await audioPlayer.play(filePath,
                                    isLocal: true, stayAwake: true);
                              } catch (e) {
                                print("unable to play audio" + e.toString());
                              }
                            } else if (audioPlayer.state ==
                                AudioPlayerState.PAUSED) {
                              setState(() {
                                playing = true;
                                playPaused = false;
                              });
                              try {
                                await audioPlayer.resume();
                              } catch (e) {
                                print("unable to resume audio" + e.toString());
                              }
                            } else if (audioPlayer.state ==
                                AudioPlayerState.PLAYING) {
                              setState(() {
                                playing = false;
                                playPaused = true;
                              });
                              try {
                                await audioPlayer.pause();
                              } catch (e) {
                                print("unable to pause audio" + e.toString());
                              }
                            }
                          }
                        },
                        child: Icon(
                          paused
                              ? Icons.mic
                              : isRecording
                                  ? Icons.pause
                                  : playing
                                      ? Icons.pause
                                      : playPaused
                                          ? Icons.play_arrow
                                          : stoped
                                              ? Icons.play_arrow
                                              : Icons.mic,
                          color: Colors.white,
                          size: 30,
                        ),
                        backgroundColor: AppColors.purpleNormal,
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: "c",
                      onPressed: () async {
                        if (audioPlayer.state == AudioPlayerState.STOPPED ||
                            audioPlayer.state == AudioPlayerState.COMPLETED ||
                            audioPlayer.state == null) {
                          print(audioPlayer.state);
                          if (exitResult == null && stoped) {
                            int moduleId = await DbOperations.getModuleId(
                                widget.moduleName);
                            await showAskDialog(context);

                            if (exitResult) {
                              //if user decides to save the audio
                              //we add it to database
                              await DbOperations.addAudio(new Audio(
                                  moduleId: moduleId,
                                  filename: fileName,
                                  description: "",
                                  path: filePath));

                              final audios = await Provider.of<AudioProvider>(
                                      context,
                                      listen: false)
                                  .getAudios(moduleId);
                              Provider.of<AudioProvider>(context, listen: false)
                                  .setAudios = audios;
                            } else {
                              //else we delete the file
                              try {
                                await Directory(filePath)
                                    .delete(recursive: true);
                              } catch (e) {
                                print("could not delete audio $e");
                              }
                            }
                          }
                          Navigator.of(context).pop();
                        }
                      },
                      child: Icon(
                        Icons.library_music,
                        color: Colors.white,
                        size: 30,
                      ),
                      backgroundColor: AppColors.purpleNormal,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showAskDialog(BuildContext context) async {
    bool isFrench = widget.settings.globalLanguage.getValue() == Config.fr;
    // bool result;

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text(
                Languages.save[isFrench ? Config.fr : Config.en],
                style: Styles.purpleTextNormal,
              ),
              content:
                  Text(Languages.saveMessage[isFrench ? Config.fr : Config.en]),
              actions: <Widget>[
                PurpleButton(
                    label: Languages.yes[isFrench ? Config.fr : Config.en],
                    onPressed: () {
                      setState(() {
                        exitResult = true;
                      });
                      Navigator.of(context).pop(true);
                    }),
                PurpleButton(
                    label: Languages.no[isFrench ? Config.fr : Config.en],
                    onPressed: () {
                      setState(() {
                        exitResult = false;
                      });
                      Navigator.of(context).pop(false);
                    })
              ],
            ));
  }
}
