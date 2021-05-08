import 'package:new_bluebyte/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

enum ImageSource {
  ///get the image from the source
  File,

  ///get the image from the camera
  Camera
}

class AppSettings {
  AppSettings(StreamingSharedPreferences preferences)
      : globalLanguage = preferences.getString(Config.globalLanguage,
            defaultValue: Config.fr),
        firstSnap = preferences.getBool(Config.firstSnap, defaultValue: true),
        imageSource = preferences.getString(Config.imageSource,
            defaultValue: Config.camera),
        globalFontSize =
            preferences.getDouble(Config.globalFontSize, defaultValue: 18),
        lineColor = preferences.getString(Config.lineColor,
            defaultValue: Colors.yellowAccent.toString()),
        lineWidth = preferences.getDouble(Config.lineWidth, defaultValue: 3),
        preferedUnit = preferences.getString(Config.unit, defaultValue: "m"),
        backgroundColor = preferences.getString(Config.backgroundColor,
            defaultValue: Colors.greenAccent.toString());

  Preference<String> globalLanguage;

  Preference<bool> firstSnap;
  Preference<String> lineColor;
  Preference<String> backgroundColor;
  Preference<String> preferedUnit;
  Preference<double> lineWidth;

  Preference<String> imageSource;
  Preference<double> globalFontSize;
}
