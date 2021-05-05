import 'package:new_bluebyte/screens/HomeScreen/homeScreen.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:flutter/material.dart';

import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class SelectLanguage extends StatefulWidget {
  @override
  _SelectLanguageState createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  StreamingSharedPreferences _prefs;
  String language;

  @override
  void initState() {
    StreamingSharedPreferences.instance.then((prefs) {
      setState(() {
        _prefs = prefs;
      });
    });
    language = "Francais";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> languages = ["Francais", "English"];
    return  Scaffold(
        body: SafeArea(
          child: Container(
              alignment: Alignment.center,
              child: _prefs != null
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset(
                            "assets/images/logo.png",
                            width: MediaQuery.of(context).size.width < 700
                                ? 300
                                : 500,
                          ),
                          SizedBox(height: 30),
                          Text("Choisissez une langue/Select a language"),
                          SizedBox(
                            height: 30,
                          ),
                          DropdownButton(
                            value: language,
                            underline: Container(
                              height: 2,
                              color: AppColors.purpleDark,
                            ),
                            focusColor: AppColors.purpleNormal,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.purpleNormal,
                            ),
                            iconSize: 27,
                            selectedItemBuilder: (context) {
                              return languages.map((lang) {
                                return Text(
                                  lang,
                                  style: TextStyle(
                                      color: AppColors.purpleNormal,
                                      fontSize: 20),
                                );
                              }).toList();
                            },
                            items: [
                              DropdownMenuItem(
                                  value: "Francais",
                                  child: Container(
                                    width: double.infinity,
                                    color: AppColors.purpleNormal,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      child: Text(
                                        "Francais",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  )),
                              DropdownMenuItem(
                                  value: "English",
                                  child: Container(
                                      width: double.infinity,
                                      color: AppColors.purpleNormal,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        child: Text(
                                          "English",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )))
                            ],
                            onChanged: (value) {
                              if (value == "Francais") {
                                setState(() {
                                  language = "Francais";
                                });
                              } else {
                                setState(() {
                                  language = "English";
                                });
                              }
                            },
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          RaisedButton(
                            child: Text(
                              "OK",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: AppColors.purpleNormal,
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 40),
                            onPressed: () async {
                              await _prefs.setString(
                                  Config.globalLanguage, language);
                              await _prefs.setBool(Config.firstRun, false);
                              print("first run set to false");

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => HomeScreen()));
                            },
                          )
                        ],
                      ),
                    )
                  : CircularProgressIndicator(
                      backgroundColor: AppColors.purpleNormal,
                    )),
        ),
      );
  }
}
