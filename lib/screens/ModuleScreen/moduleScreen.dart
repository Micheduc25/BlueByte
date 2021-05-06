import 'dart:async';

import 'package:new_bluebyte/components/InfoDialog.dart';
import 'package:new_bluebyte/components/editProject.dart';
import 'package:new_bluebyte/components/inputItem.dart';
import 'package:new_bluebyte/components/purpleButton.dart';
import 'package:new_bluebyte/database/dbOps.dart';
import 'package:new_bluebyte/models/moduleModel.dart';
import 'package:new_bluebyte/models/objectModel.dart';
import 'package:new_bluebyte/provider/audiosProvider.dart';
import 'package:new_bluebyte/provider/modulesProvider.dart';

import 'package:new_bluebyte/screens/AudioRecordScreen/audioRecordScreen.dart';
import 'package:new_bluebyte/screens/ModuleScreen/audioView.dart';
import 'package:new_bluebyte/screens/ModuleScreen/exportScreen.dart';
import 'package:new_bluebyte/screens/ModuleScreen/objectsView.dart';
import 'package:new_bluebyte/screens/objectImagesScreen/objectImagesScreen.dart';
import 'package:new_bluebyte/utils/alertDialog.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModuleScreen extends StatefulWidget {
  ModuleScreen(
      {this.module,
      this.settings,
      this.initialTab = 0,
      @required this.isFrench});
  final Module module;
  final AppSettings settings;
  final int initialTab;
  final bool isFrench;
  @override
  _ModuleScreenState createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  bool showObjects;
  TextEditingController nameController;
  TextEditingController typeController;
  Map<String, dynamic> info;
  bool showInfoGetter;
  String language;
  StreamSubscription<String> langSubs;

  @override
  void initState() {
    language = widget.settings.globalLanguage.getValue();
    tabController = new TabController(
        length: 2, vsync: this, initialIndex: widget.initialTab);
    showObjects = true;
    nameController = new TextEditingController();
    typeController = new TextEditingController();
    showInfoGetter = false;

    langSubs = widget.settings.globalLanguage.listen((lang) {
      setState(() {
        language = lang;
        print("language is $language");
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    langSubs.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lang = language;
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColors.purpleNormal,
        centerTitle: true,
        title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text("Module: " + widget.module.name)),
        leading: InkWell(
          child: Icon(
            Icons.navigate_before,
            color: Colors.white,
            size: 25,
          ),
          onTap: () {
            if (tabController.index == 0 && showInfoGetter)
              setState(() {
                showInfoGetter = false;
              });
            else
              Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          InkWell(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Icon(Icons.import_export),
            ),
            onTap: () {
              //total module export here
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ExportScreen(
                      module: widget.module, settings: widget.settings)));
            },
          ),
          PopupMenuButton(
            tooltip: Languages.more[widget.isFrench ? Config.fr : Config.en],
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    value: "edit",
                    child: ListTile(
                      leading: Icon(
                        Icons.edit,
                        color: AppColors.purpleNormal,
                        size: 30,
                      ),
                      title: Text(
                        Languages.edit[widget.isFrench ? Config.fr : Config.en],
                        style: Styles.purpleTextNormal,
                      ),
                    )),
                PopupMenuItem(
                    value: "info",
                    child: ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: AppColors.purpleNormal,
                        size: 30,
                      ),
                      title: Text(
                        Languages.info[widget.isFrench ? Config.fr : Config.en],
                        style: Styles.purpleTextNormal,
                      ),
                    )),
                PopupMenuItem(
                    value: "delete",
                    child: ListTile(
                      leading: Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 30,
                      ),
                      title: Text(
                        Languages
                            .delete[widget.isFrench ? Config.fr : Config.en],
                        style: Styles.purpleTextNormal,
                      ),
                    ))
              ];
            },
            onSelected: (value) async {
              print(value);
              if (value == "edit") {
                final modules = await showDialog<List<Module>>(
                    context: context,
                    builder: (context) => EditProjectDialog(
                        settings: widget.settings, module: widget.module));

                Provider.of<ModulesProvider>(context, listen: false)
                    .setModules = modules;

                final newModule =
                    await DbOperations.getModule(widget.module.moduleId);
                // print("modules is $modules");

                if (modules != null) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => ModuleScreen(
                            isFrench: widget.isFrench,
                            settings: widget.settings,
                            module: newModule,
                          )));
                }
              } else if (value == "delete") {
                try {
                  await Provider.of<ModulesProvider>(context, listen: false)
                      .deleteModule(widget.module.moduleId);

                  print("module deleted successfully");
                } catch (e) {
                  print("could not delete module $e");
                }

                Navigator.of(context).pop();
              } else {
                await showDialog(
                    context: context,
                    builder: (context) {
                      return InfoDialog(
                          title: Languages.moduleInfoTitle[
                              widget.isFrench ? Config.fr : Config.en],
                          fieldsAndInfo: {
                            Languages.name[widget.isFrench
                                ? Config.fr
                                : Config.en]: widget.module.name,
                            Languages.location[widget.isFrench
                                ? Config.fr
                                : Config.en]: widget.module.location,
                            Languages.buildingType[widget.isFrench
                                ? Config.fr
                                : Config.en]: widget.module.moduleType,
                            Languages.createdOn[widget.isFrench
                                ? Config.fr
                                : Config.en]: widget.module.creationDate
                          });
                    });
              }
            },
          )
        ],
      ),
      floatingActionButton: !showInfoGetter
          ? FloatingActionButton(
              child: Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ),
              backgroundColor: AppColors.purpleNormal,
              onPressed: () {
                if (tabController.index == 0) {
                  print("show info getter true");
                  setState(() {
                    showInfoGetter = true;
                  });
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ChangeNotifierProvider<AudioProvider>(
                              create: (context) => AudioProvider(),
                              child: AudioRecordScreen(
                                settings: widget.settings,
                                moduleName: widget.module.name,
                              ))));
                }
              },
            )
          : Container(),
      body: Center(
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: <Widget>[
            !showInfoGetter
                ? Container(
                    child: Column(
                    children: <Widget>[
                      TabBar(
                        unselectedLabelColor: AppColors.purpleNormal,
                        controller: tabController,
                        tabs: [
                          Tab(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo),
                                  SizedBox(width: 5),
                                  Text(Languages.objects[lang == Config.fr
                                      ? Config.fr
                                      : Config.en])
                                ]),
                          ),
                          Tab(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                Icon(Icons.audiotrack),
                                SizedBox(width: 5),
                                Text("Audios"),
                              ])),
                        ],
                        indicatorColor: AppColors.purpleDark,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(color: AppColors.purpleNormal),
                        onTap: (tab) {
                          if (tab == 0) {
                            setState(() {
                              showObjects = true;
                            });
                            print("objects!");
                          } else {
                            setState(() {
                              showObjects = false;
                            });
                            print("audios!");
                          }
                        },
                      ),
                      Container(
                        height: 2,
                        color: AppColors.purpleDark,
                      ),
                      Expanded(
                        child: TabBarView(controller: tabController, children: [
                          ObjectsView(
                            module: widget.module,
                            settings: widget.settings,
                            isFrench: lang == Config.fr,
                          ),
                          AudiosView(
                            module: widget.module,
                            settings: widget.settings,
                            isFrench: lang == Config.fr,
                          )
                        ]),
                      ),
                    ],
                  ))
                : Container(),
            showInfoGetter ? infoGetter(context) : Container()
          ],
        ),
      ),
    );
  }

  Widget infoGetter(BuildContext context) {
    var lang = language;
    bool isFrench = lang == Config.fr;
    return SingleChildScrollView(
      child: Container(
        // alignment: Alignment.center,
        // color: Colors.white,

        padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: MediaQuery.of(context).size.width < 400
                ? 10
                : MediaQuery.of(context).size.width * 0.16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              Languages.objectInfoTitle[isFrench ? Config.fr : Config.en],
              style: Styles.purpleTextLarge,
            ),
            SizedBox(
              height: 20,
            ),
            InputItem(
              lang: lang,
              controller: nameController,
              size: MediaQuery.of(context).size,
              hint: Languages.name[isFrench ? Config.fr : Config.en],
              label: Languages.name[isFrench ? Config.fr : Config.en],
            ),
            SizedBox(
              height: 10,
            ),
            InputItem(
              lang: lang,
              controller: typeController,
              size: MediaQuery.of(context).size,
              hint: Languages.objectType[isFrench ? Config.fr : Config.en],
              label: Languages.objectType[isFrench ? Config.fr : Config.en],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.of(context).size.width < 500 ? 10 : 100),
              child: PurpleButton(
                paddingHori: 100,
                paddingVert: 20,
                label: Languages.create[isFrench ? Config.fr : Config.en],
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      typeController.text.isNotEmpty) {
                    info = {
                      Config.name: nameController.text,
                      Config.type: typeController.text
                    };

                    int moduleId =
                        await DbOperations.getModuleId(widget.module.name);
                    String date =
                        new DateTime.now().toIso8601String().split("T")[0];

                    Object newObject = new Object(
                        name: info[Config.name],
                        moduleId: moduleId,
                        creationDate: date,
                        objectType: info[Config.type]);
                    final id = await DbOperations.addObject(newObject);

                    showInfoGetter = false;

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ObjectImages(
                              settings: widget.settings,
                              object: null,
                              objectId: id,
                              moduleId: widget.module.moduleId,
                              moduleName: widget.module.name,
                              objectName: nameController.text,
                            )));
                  } else
                    NotificationDialog.showMyDialogue(
                        Languages
                            .emptyFormTitle[isFrench ? Config.fr : Config.en],
                        Languages
                            .emptyFormMessage[isFrench ? Config.fr : Config.en],
                        context,
                        positive: false);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
