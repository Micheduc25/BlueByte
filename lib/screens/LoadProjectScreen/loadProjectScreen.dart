import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:new_bluebyte/components/exitDialog.dart';
import 'package:new_bluebyte/models/moduleModel.dart';
import 'package:new_bluebyte/provider/modulesProvider.dart';
import 'package:new_bluebyte/screens/ModuleScreen/exportScreen.dart';
import 'package:new_bluebyte/screens/ModuleScreen/moduleScreen.dart';
import 'package:new_bluebyte/screens/NewProject/newProject.dart';
import 'package:new_bluebyte/screens/SettingsScreen/settings_image.dart';
import 'package:new_bluebyte/screens/help/help.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadProjectScreen extends StatefulWidget {
  LoadProjectScreen({this.settings});
  final AppSettings settings;
  @override
  _LoadProjectScreenState createState() => _LoadProjectScreenState();
}

class _LoadProjectScreenState extends State<LoadProjectScreen> {
  TextEditingController searchController;
  // List<Map<String, dynamic>> allModulesMaps;
  List<Module> allModules;
  // List<Module> allModulesAnnex;

  StreamSubscription languageSubs;
  String language;
  String filterKey;

  @override
  void initState() {
    searchController = new TextEditingController();
    filterKey = "";
    allModules = [];
    languageSubs = widget.settings.globalLanguage.listen((val) {
      if (mounted)
        setState(() {
          language = val;
          print(language);
        });
    });

    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    languageSubs.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFrench = language == Config.fr;
    print(widget.settings.globalLanguage);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.purpleNormal,
        title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child:
                Text(Languages.loadProject[isFrench ? Config.fr : Config.en])),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => NewProjectScreen()));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
        backgroundColor: AppColors.purpleNormal,
        tooltip: Languages.createProject[isFrench ? Config.fr : Config.en],
      ),
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
                          Languages.settings[isFrench ? Config.fr : Config.en],
                          style: Styles.whiteTextLarge,
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ImageSettingsScreen(
                              settings: widget.settings,
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
                              settings: widget.settings,
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
                          isFrench ? "Quitter l'Application" : "Leave the App",
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
      body: Center(
        child: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: TextField(
                  controller: searchController,
                  cursorColor: AppColors.purpleNormal,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.purpleNormal,
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 3, color: AppColors.purpleDark)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: AppColors.purpleDark)),
                      hintText: Languages
                          .searchModule[isFrench ? Config.fr : Config.en],
                      hintStyle: TextStyle(
                        color: AppColors.purpleLight,
                        fontSize: 18,
                      )),
                  onChanged: (text) {
                    setState(() {
                      filterKey = text;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: Provider.of<ModulesProvider>(context)
                    .getModules(filterKey: filterKey),
                builder: (context, AsyncSnapshot<List<Module>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    allModules = snapshot.data;

                    if (allModules.isEmpty)
                      return Center(
                        child: Text(
                          Languages.noModules[isFrench ? Config.fr : Config.en],
                          style: Styles.purpleTextLarge,
                          textAlign: TextAlign.center,
                        ),
                      );
                    return ListView.builder(
                        itemCount: allModules.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              Slidable(
                                child: ListTile(
                                  leading: Icon(
                                    Icons.folder,
                                    color: AppColors.purpleNormal,
                                    size: 25,
                                  ),
                                  title: Text(
                                    allModules[index].name,
                                    style: Styles.purpleTextNormal,
                                  ),
                                  trailing: Text(
                                    allModules[index].creationDate,
                                    style: TextStyle(
                                        color: AppColors.purpleLight,
                                        fontSize: 14),
                                  ),
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => ModuleScreen(
                                                  isFrench: isFrench,
                                                  module: allModules[index],
                                                  settings: widget.settings,
                                                )));
                                  },
                                ),
                                actionPane: SlidableScrollActionPane(),
                                actionExtentRatio: 1 / 2,
                                actions: [
                                  IconSlideAction(
                                    icon: Icons.import_export,
                                    caption: Languages.export[
                                        isFrench ? Config.fr : Config.en],
                                    color: AppColors.purpleDark,
                                    foregroundColor: Colors.white,
                                    closeOnTap: false,
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ExportScreen(
                                                      module: allModules[index],
                                                      settings:
                                                          widget.settings)));
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Divider(
                                  height: 4,
                                  color: AppColors.purpleNormal,
                                  thickness: 1,
                                ),
                              )
                            ],
                          );
                        });
                  } else {
                    return Container();
                  }
                },
              ),
            )
          ],
        )),
      ),
    );
  }
}
