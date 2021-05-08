import 'package:new_bluebyte/provider/audiosProvider.dart';

import 'package:new_bluebyte/provider/modulesProvider.dart';
import 'package:new_bluebyte/provider/newImagesProvider.dart';
import 'package:new_bluebyte/provider/objectsProvider.dart';
import 'package:new_bluebyte/screens/HomeScreen/loadingScreen.dart';
import 'package:new_bluebyte/screens/LoadProjectScreen/loadProjectScreen.dart';

import 'package:new_bluebyte/screens/welcomeAnimationScreen.dart';

import 'package:new_bluebyte/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:provider/provider.dart';

import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamingSharedPreferences prefs;
  @override
  void initState() {
    //we load our shared preferences
    StreamingSharedPreferences.instance.then((pref) {
      setState(() {
        prefs = pref;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioProvider>(
          create: (context) => AudioProvider(),
        ),
        ChangeNotifierProvider(create: (context) => ObjectProvider()),
        ChangeNotifierProvider(create: (context) => ModulesProvider()),
        ChangeNotifierProvider(create: (context) => ImagesProvider())
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Config.appTitle,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          //we check if it is the first time that the app is opened
          //if yes we go directly to the homescreen
          //if no we go to the language selection screen

          home: prefs == null
              ? LoadingScreen()

              //if its the first run we show the animation screen
              : prefs.getBool(Config.firstRun, defaultValue: true).getValue() ==
                      true
                  ? AnimationScreen()
                  : LoadProjectScreen(
                      settings: AppSettings(this.prefs),
                    )
          // HomeScreen()

          ),
    );
  }
}
