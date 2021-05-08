import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_bluebyte/components/exitDialog.dart';
import 'package:new_bluebyte/screens/LoadProjectScreen/loadProjectScreen.dart';
import 'package:new_bluebyte/screens/NewProject/newProject.dart';
import 'package:new_bluebyte/screens/SettingsScreen/settings_image.dart';
import 'package:new_bluebyte/screens/help/help.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/specialFunctions.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamingSharedPreferences _prefs;
  String lang;
  AppSettings settings;
  StreamSubscription languageSubs;
  bool _isLoading = true;

  @override
  void initState() {
    StreamingSharedPreferences.instance.then((prefs) {
      setState(() {
        _prefs = prefs;
        // lang = _prefs
        //     .getString(Config.globalLanguage, defaultValue: Config.fr)
        //     .getValue();
        settings = new AppSettings(_prefs);

        languageSubs = settings.globalLanguage.listen((data) {
          setState(() {
            lang = data;
          });
        });
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    languageSubs.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFrench = lang == Config.fr;
    return WillPopScope(
      onWillPop: () {
        final result = showDialog<bool>(
            context: context,
            builder: (context) {
              return ExitDialog(isFrench: isFrench);
            });
        if (result != null) return result;
        return Future(() => false);
      },
      child: SafeArea(
        child: Scaffold(
          drawer: Drawer(
            child: Container(
              color: AppColors.purpleNormal,
              child: Column(
                children: <Widget>[
                  Container(
                      // margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      color: Colors.white,
                      child: Image.asset("assets/images/logo.png")),
                  Divider(
                    color: Colors.white,
                    height: 2,
                    thickness: 3,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      child: ListView(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 30,
                            ),
                            title: Text(
                              Languages
                                  .settings[isFrench ? Config.fr : Config.en],
                              style: Styles.whiteTextLarge,
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return ImageSettingsScreen(
                                  settings: settings,
                                );
                              }));
                            },
                          ),
                          Divider(
                            color: Colors.white,
                            thickness: 2,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.help_outline,
                              color: Colors.white,
                              size: 30,
                            ),
                            title: Text(
                              Languages.help[isFrench ? Config.fr : Config.en],
                              style: Styles.whiteTextLarge,
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return HelpController(
                                  settings: settings,
                                );
                              }));
                            },
                          ),
                          Divider(
                            color: Colors.white,
                            thickness: 2,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.exit_to_app,
                              color: Colors.white,
                              size: 30,
                            ),
                            title: Text(
                              isFrench
                                  ? "Quitter l'Application"
                                  : "Leave the App",
                              style: Styles.whiteTextLarge,
                            ),
                            onTap: () async {
                              final bool result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return ExitDialog(isFrench: isFrench);
                                  });
                              if (result != null && result) {
                                await SystemChannels.platform
                                    .invokeMethod('SystemNavigator.pop');
                              }
                            },
                          ),
                          Divider(
                            color: Colors.white,
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          appBar: AppBar(
            title: Text(lang == Config.fr
                ? Languages.homeScreenTitle[Config.fr]
                : Languages.homeScreenTitle[Config.en]),
            backgroundColor: AppColors.purpleNormal,
            centerTitle: true,
            actions: <Widget>[
              Tooltip(
                message:
                    Languages.loadSession[isFrench ? Config.fr : Config.en],
                child: InkWell(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.drive_folder_upload,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () async {
                    await SpecialFunctions.loadWork(() {
                      setState(() {
                        _isLoading = true;
                      });
                    }, () {
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) =>
                              LoadProjectScreen(settings: settings)));
                    }, (message) {
                      setState(() {
                        _isLoading = false;
                      });
                      Fluttertoast.showToast(msg: message);
                    });
                  },
                ),
              ),
              PopupMenuButton(
                icon: Icon(
                  Icons.language,
                  color: Colors.white,
                ),
                onSelected: (lan) async {
                  if (lan == Config.fr) {
                    await _prefs.setString(Config.globalLanguage, Config.fr);
                    setState(() {
                      lang = Config.fr;
                    });
                  } else {
                    await _prefs.setString(Config.globalLanguage, Config.en);
                    setState(() {
                      lang = Config.en;
                    });
                  }
                  settings = new AppSettings(_prefs);

                  print("language is $lang");
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                        value: Config.fr,
                        child: Text(
                          Config.fr,
                          style: TextStyle(color: AppColors.purpleNormal),
                        )),
                    PopupMenuItem(
                        value: Config.en,
                        child: Text(
                          Config.en,
                          style: TextStyle(color: AppColors.purpleNormal),
                        ))
                  ];
                },
              )
            ],
          ),
          body: Center(
            child: _isLoading == true
                ? CircularProgressIndicator(
                    backgroundColor: AppColors.purpleDark,
                  )
                : Container(
                    alignment: Alignment.center,
                    child: _prefs != null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                lang == Config.fr
                                    ? Languages.whatToDo[Config.fr]
                                    : Languages.whatToDo[Config.en],
                                style: TextStyle(
                                    color: AppColors.purpleNormal,
                                    fontSize: 20),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              RaisedButton(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                        lang == Config.fr
                                            ? Languages.createProject[Config.fr]
                                            : Languages
                                                .createProject[Config.en],
                                        style: Styles.whiteTextNormal),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                color: AppColors.purpleNormal,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          NewProjectScreen()));
                                },
                              ),
                              SizedBox(height: 20),
                              RaisedButton(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      Icons.rotate_right,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                        lang == Config.fr
                                            ? Languages.openProject[Config.fr]
                                            : Languages.openProject[Config.en],
                                        style: Styles.whiteTextNormal),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                color: AppColors.purpleNormal,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => LoadProjectScreen(
                                          settings: settings)));
                                },
                              )
                            ],
                          )
                        : CircularProgressIndicator(
                            backgroundColor: AppColors.purpleNormal,
                          )),
          ),
        ),
      ),
    );
  }
}
