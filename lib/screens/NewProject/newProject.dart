import 'package:new_bluebyte/components/inputItem.dart';
import 'package:new_bluebyte/components/purpleButton.dart';
import 'package:new_bluebyte/models/moduleModel.dart';
import 'package:new_bluebyte/screens/HomeScreen/loadingScreen.dart';
import 'package:new_bluebyte/screens/ModuleScreen/moduleScreen.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:new_bluebyte/database/dbOps.dart';

import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class NewProjectScreen extends StatefulWidget {
  @override
  _NewProjectScreenState createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  StreamingSharedPreferences _prefs;
  String lang;
  TextEditingController nameController;
  TextEditingController locationController;
  TextEditingController typeController;
  bool loading;

  @override
  void initState() {
    StreamingSharedPreferences.instance.then((prefs) {
      setState(() {
        _prefs = prefs;
        lang = _prefs
            .getString(Config.globalLanguage, defaultValue: Config.fr)
            .getValue();
      });
    });
    loading = false;
    nameController = new TextEditingController();
    locationController = new TextEditingController();
    typeController = new TextEditingController();
    super.initState();
  }

  @override
  dispose() {
    nameController.dispose();
    locationController.dispose();
    typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return _prefs != null && !loading
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.purpleNormal,
              leading: InkWell(
                child: Icon(
                  Icons.navigate_before,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              centerTitle: true,
              title: Text(
                  lang == Config.fr
                      ? Languages.newProject[Config.fr]
                      : Languages.newProject[Config.en],
                  style: Styles.whiteTextNormal),
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                    alignment: Alignment.center,
                    width: size.width > size.height
                        ? size.width * 0.8
                        : size.width * 0.65,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        InputItem(
                          size: size,
                          lang: lang,
                          controller: nameController,
                          label: lang == Config.fr
                              ? Languages.name[Config.fr] + "  "
                              : Languages.name[Config.en] + "  ",
                          hint: lang == Config.fr
                              ? Languages.nameOfProject[Config.fr] + "  "
                              : Languages.nameOfProject[Config.en] + "  ",
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InputItem(
                          size: size,
                          lang: lang,
                          controller: locationController,
                          label: lang == Config.fr
                              ? Languages.location[Config.fr] + "  "
                              : Languages.location[Config.en] + "  ",
                          hint: lang == Config.fr
                              ? Languages.locationOfBuilding[Config.fr] + "  "
                              : Languages.locationOfBuilding[Config.en] + "  ",
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InputItem(
                          size: size,
                          lang: lang,
                          controller: typeController,
                          label: lang == Config.fr
                              ? Languages.buildingType[Config.fr] + "  "
                              : Languages.buildingType[Config.en] + "  ",
                          hint: lang == Config.fr
                              ? Languages.buildingType[Config.fr] + "  "
                              : Languages.buildingType[Config.en] + "  ",
                        ),
                        SizedBox(height: 20),
                        PurpleButton(
                          label: lang == Config.fr
                              ? Languages.create[Config.fr] + "  "
                              : Languages.create[Config.en] + "  ",
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                            //we create a new module object that will contain the collected info
                            Module newModule = new Module(
                                name: nameController.text,
                                location: locationController.text,
                                moduleType: typeController.text,
                                creationDate: new DateTime.now()
                                    .toIso8601String()
                                    .split("T")[0]);

                            //we add module to db(id generated automatically)
                            await DbOperations.addModule(newModule);

                            //we get the generated Id
                            final moduleId =
                                await DbOperations.getModuleId(newModule.name);

                            //we set the obtainedId as module Id
                            newModule.id = moduleId;

                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => ModuleScreen(
                                        isFrench: lang == Config.fr,
                                        module: newModule,
                                        settings: AppSettings(_prefs))));
                          },
                        )
                      ],
                    )),
              ),
            ),
          )
        : LoadingScreen();
  }
}
