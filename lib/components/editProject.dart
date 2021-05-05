import 'package:new_bluebyte/components/inputItem.dart';
import 'package:new_bluebyte/components/purpleButton.dart';
import 'package:new_bluebyte/database/dbOps.dart';
import 'package:new_bluebyte/models/moduleModel.dart';

import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';

class EditProjectDialog extends StatefulWidget {
  EditProjectDialog({this.settings, this.module});
  final AppSettings settings;
  final Module module;

  @override
  _EditProjectDialogState createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  TextEditingController nameController;
  TextEditingController locationController;
  TextEditingController typeController;

  @override
  void initState() {
    super.initState();
    nameController = new TextEditingController(text: widget.module.name);
    locationController =
        new TextEditingController(text: widget.module.location);
    typeController = new TextEditingController(text: widget.module.moduleType);
  }

  @override
  void dispose() {
    nameController?.dispose();
    locationController?.dispose();
    typeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.settings.globalLanguage.getValue();
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      title: Text(
        Languages.editModule[lang == Config.fr ? Config.fr : Config.en],
        style: Styles.purpleTextLarge,
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Container(
            alignment: Alignment.center,
            width:
                size.width > size.height ? size.width * 0.8 : size.width * 0.65,
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
                size.width > size.height
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 60),
                                child: PurpleButton(
                                  label: lang == Config.fr
                                      ? Languages.edit[Config.fr] + "  "
                                      : Languages.edit[Config.en] + "  ",
                                  onPressed: () async {
                                    await editModule();
                                  },
                                ),
                              ))
                        ],
                      )
                    : PurpleButton(
                        label: lang == Config.fr
                            ? Languages.edit[Config.fr] + "  "
                            : Languages.edit[Config.en] + "  ",
                        onPressed: () async {
                          await editModule();
                        },
                      )
              ],
            )),
      ),
    );
  }

  Future<void> editModule() async {
    await DbOperations.editModule(widget.module.moduleId, {
      Config.moduleType: typeController.text,
      Config.name: nameController.text,
      Config.location: locationController.text
    });

    final modulesAnnex = await DbOperations.getAllModules();
    final modules = modulesAnnex.map<Module>((map) {
      return new Module.fromMap(map);
    }).toList();

    Navigator.of(context).pop(modules);
  }
}
