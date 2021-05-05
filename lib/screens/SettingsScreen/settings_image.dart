import 'dart:async';

import 'package:new_bluebyte/components/purpleButton.dart';
import 'package:new_bluebyte/components/settingsItem.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class ImageSettingsScreen extends StatefulWidget {
  ImageSettingsScreen({this.settings});
  final AppSettings settings;

  @override
  _ImageSettingsScreenState createState() => _ImageSettingsScreenState();
}

class _ImageSettingsScreenState extends State<ImageSettingsScreen> {
  StreamingSharedPreferences preferences;
  String language;
  String lineColor;
  String backgroundColor;
  String imageSource;
  String preferedUnit;
  double lineWidth;
  StreamSubscription<double> lineWidthSubs;
  StreamSubscription<String> langSubs;
  StreamSubscription<String> lineColorSubs;
  StreamSubscription<String> bgColorSubs;
  StreamSubscription<String> imgSourceSubs;
  StreamSubscription<String> preferedUnitSubs;

  // StreamSubscription<double> globalFontSubs;

  @override
  void initState() {
    StreamingSharedPreferences.instance.then((prefs) {
      setState(() {
        preferences = prefs;
      });
    });
    language = widget.settings.globalLanguage.getValue();

    langSubs = widget.settings.globalLanguage.listen((val) {
      if (mounted)
        setState(() {
          language = val;
        });
    });
    lineColorSubs = widget.settings.lineColor.listen((val) async {
      if (mounted && preferences != null) {
        setState(() {
          lineColor = val;
        });
        print("line color set to $val");
      }
    });
    lineWidthSubs = widget.settings.lineWidth.listen((val) async {
      if (mounted && preferences != null) {
        setState(() {
          lineWidth = val;
        });
        print("line width set to $val");
      }
    });

    bgColorSubs = widget.settings.backgroundColor.listen((val) async {
      if (mounted && preferences != null) {
        setState(() {
          backgroundColor = val;
        });
        print("bg color set to $val");
      }
    });

    imgSourceSubs = widget.settings.imageSource.listen((val) async {
      if (mounted) {
        setState(() {
          imageSource = val;
        });
        print("image Source set to $val");
      }
    });

    preferedUnit = widget.settings.preferedUnit.getValue();
    preferedUnitSubs = widget.settings.preferedUnit.listen((val) async {
      if (mounted && preferences != null) {
        setState(() {
          preferedUnit = val;
        });
        print("prefered unit set to $val");
      }
    });

    // globalFontSubs = widget.settings.globalFontSize.listen((val) async {
    //   if (mounted && preferences != null) {
    //     await preferences.setDouble(Config.globalFontSize, val);

    //     print("fontsize set to $val");
    //   }
    // });

    super.initState();
  }

  @override
  void dispose() {
    langSubs.cancel();
    lineColorSubs.cancel();
    bgColorSubs.cancel();
    imgSourceSubs.cancel();
    preferedUnitSubs.cancel();
    lineWidthSubs.cancel();
    // globalFontSubs.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFrench = language == Config.fr;
    return Scaffold(
      appBar: AppBar(
        title: Text(Languages.settings[isFrench ? Config.fr : Config.en]),
        backgroundColor: AppColors.purpleNormal,
        leading: InkWell(
          child: Icon(
            Icons.navigate_before,
            color: Colors.white,
            size: 30,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
      ),
      body: Center(
          child: preferences != null
              ? Container(
                  child: ListView(
                    children: <Widget>[
                      //laguage
                      SettingsItem(
                        icon: Icons.language,
                        label: Languages
                            .language[isFrench ? Config.fr : Config.en],
                        currentValue: Text(
                          language,
                          style: TextStyle(
                              color: AppColors.purpleNormal.withOpacity(.7),
                              fontSize: 12),
                        ),
                        action: () async {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text(
                                      Languages.language[
                                          isFrench ? Config.fr : Config.en],
                                      style: Styles.purpleTextNormal,
                                      // textAlign: TextAlign.center,
                                    ),
                                    content: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SettingsItem(
                                            icon: isFrench ? Icons.check : null,
                                            label: "Français",
                                            action: () async {
                                              await preferences.setString(
                                                  Config.globalLanguage,
                                                  Config.fr);
                                              // setState(() {
                                              //   isFrench = true;
                                              // });
                                              Navigator.of(context).pop();
                                            },
                                            showTrailing: false,
                                          ),
                                          SettingsItem(
                                            icon:
                                                !isFrench ? Icons.check : null,
                                            label: "English",
                                            action: () async {
                                              await preferences.setString(
                                                  Config.globalLanguage,
                                                  Config.en);
                                              // setState(() {
                                              //   isFrench = false;
                                              // });
                                              Navigator.of(context).pop();
                                            },
                                            showTrailing: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ));
                        },
                      ),
                      //lineWidth
                      SettingsItem(
                        icon: Icons.linear_scale,
                        label: Languages
                            .lineSize[isFrench ? Config.fr : Config.en],
                        currentValue: Container(
                            height: lineWidth,
                            width: 15,
                            color: AppColors.purpleDark),
                        action: () async {
                          final widthController =
                              TextEditingController(text: lineWidth.toString());

                          final newLineWidth = await showDialog<double>(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text(
                                      Languages.lineSize[
                                          isFrench ? Config.fr : Config.en],
                                      style: Styles.purpleTextNormal,
                                      // textAlign: TextAlign.center,
                                    ),
                                    content: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          TextFormField(
                                            controller: widthController,
                                            keyboardType: TextInputType.number,
                                            onFieldSubmitted: (val) {
                                              try {
                                                final doubleValue =
                                                    double.parse(
                                                        widthController.text);
                                                Navigator.of(context)
                                                    .pop(doubleValue);
                                              } catch (err) {
                                                Navigator.of(context).pop(null);
                                              }
                                            },
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors
                                                            .purpleLight))),
                                          ),
                                          SizedBox(height: 10),
                                          PurpleButton(
                                            label: "OK",
                                            onPressed: () {
                                              try {
                                                final doubleValue =
                                                    double.parse(
                                                        widthController.text);
                                                Navigator.of(context)
                                                    .pop(doubleValue);
                                              } catch (err) {
                                                Navigator.of(context).pop(null);
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ));

                          print(newLineWidth);

                          if (newLineWidth != null &&
                              newLineWidth != lineWidth) {
                            preferences.setDouble(
                                Config.lineWidth, newLineWidth);
                          }
                        },
                      ),
                      //line color
                      SettingsItem(
                        icon: Icons.border_color,
                        label: Languages
                            .lineColor[isFrench ? Config.fr : Config.en],
                        currentValue: Container(
                          width: 30,
                          height: 10,
                          color: AppColors.colorFromHexString(lineColor),
                        ),
                        action: () async {
                          Color color;

                          await showDialog<Color>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(Languages.lineColor[
                                      isFrench ? Config.fr : Config.en]),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                        // paletteType: PaletteType.rgb,
                                        pickerColor:
                                            AppColors.colorFromHexString(
                                                    lineColor) ??
                                                AppColors.purpleNormal,
                                        pickerAreaHeightPercent: 0.8,
                                        pickerAreaBorderRadius:
                                            BorderRadius.circular(5),
                                        onColorChanged: (col) {
                                          color = col;
                                        }),
                                  ),
                                  actions: <Widget>[
                                    PurpleButton(
                                      label: "OK",
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });

                          if (color != null)
                            await preferences.setString(
                                Config.lineColor, color.toString());

                          print("color was set to $color");
                        },
                      ),

                      //background color settings
                      SettingsItem(
                        icon: Icons.color_lens,
                        label: Languages
                            .backgroundColor[isFrench ? Config.fr : Config.en],
                        currentValue: Container(
                          width: 30,
                          height: 10,
                          color: AppColors.colorFromHexString(backgroundColor),
                        ),
                        action: () async {
                          Color color;

                          await showDialog<Color>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(Languages.backgroundColor[
                                      isFrench ? Config.fr : Config.en]),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                        // paletteType: PaletteType.rgb,
                                        pickerColor:
                                            AppColors.colorFromHexString(
                                                    backgroundColor) ??
                                                AppColors.purpleNormal,
                                        pickerAreaHeightPercent: 0.8,
                                        pickerAreaBorderRadius:
                                            BorderRadius.circular(5),
                                        onColorChanged: (col) {
                                          color = col;
                                        }),
                                  ),
                                  actions: <Widget>[
                                    PurpleButton(
                                      label: "OK",
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });

                          if (color != null)
                            await preferences.setString(
                                Config.backgroundColor, color.toString());

                          print("color was set to $color");
                        },
                      ),

                      //imageSource
                      SettingsItem(
                        icon: Icons.image,
                        label: Languages
                            .imageSource[isFrench ? Config.fr : Config.en],
                        currentValue: Text(
                          imageSource == Config.camera
                              ? Languages
                                  .camera[isFrench ? Config.fr : Config.en]
                              : Languages
                                  .gallery[isFrench ? Config.fr : Config.en],
                          style: TextStyle(
                              color: AppColors.purpleNormal.withOpacity(.7),
                              fontSize: 12),
                        ),
                        action: () async {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text(
                                      Languages.imageSource[
                                          isFrench ? Config.fr : Config.en],
                                      style: Styles.purpleTextNormal,
                                      // textAlign: TextAlign.center,
                                    ),
                                    content: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SettingsItem(
                                            icon: imageSource == Config.camera
                                                ? Icons.check
                                                : null,
                                            label: Languages.camera[isFrench
                                                ? Config.fr
                                                : Config.en],
                                            action: () async {
                                              await preferences.setString(
                                                  Config.imageSource,
                                                  Config.camera);

                                              Navigator.of(context).pop();
                                            },
                                            showTrailing: false,
                                          ),
                                          SettingsItem(
                                            icon: imageSource != Config.camera
                                                ? Icons.check
                                                : null,
                                            label: Languages.gallery[isFrench
                                                ? Config.fr
                                                : Config.en],
                                            action: () async {
                                              await preferences.setString(
                                                  Config.imageSource,
                                                  Config.gallery);

                                              Navigator.of(context).pop();
                                            },
                                            showTrailing: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ));
                        },
                      ),

                      //prefered length unit

                      SettingsItem(
                        icon: Icons.linear_scale,
                        label: Languages
                            .preferedUnit[isFrench ? Config.fr : Config.en],
                        currentValue: Text(
                          preferedUnit == "m"
                              ? Languages
                                  .mettre[isFrench ? Config.fr : Config.en]
                              : Languages
                                  .centimeter[isFrench ? Config.fr : Config.en],
                          style: TextStyle(
                              color: AppColors.purpleNormal.withOpacity(.7),
                              fontSize: 12),
                        ),
                        action: () async {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text(
                                      Languages.preferedUnit[
                                          isFrench ? Config.fr : Config.en],
                                      style: Styles.purpleTextNormal,
                                      // textAlign: TextAlign.center,
                                    ),
                                    content: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SettingsItem(
                                            icon: preferedUnit == "m"
                                                ? Icons.check
                                                : null,
                                            label: Languages.mettre[isFrench
                                                ? Config.fr
                                                : Config.en],
                                            action: () async {
                                              await preferences.setString(
                                                  Config.unit, "m");

                                              Navigator.of(context).pop();
                                            },
                                            showTrailing: false,
                                          ),
                                          SettingsItem(
                                            icon: preferedUnit != "m"
                                                ? Icons.check
                                                : null,
                                            label: Languages.centimeter[isFrench
                                                ? Config.fr
                                                : Config.en],
                                            action: () async {
                                              await preferences.setString(
                                                  Config.unit, "cm");

                                              Navigator.of(context).pop();
                                            },
                                            showTrailing: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ));
                        },
                      )
                    ],
                  ),
                )
              : CircularProgressIndicator(
                  backgroundColor: AppColors.purpleNormal,
                )),
    );
  }
}
