import 'package:new_bluebyte/components/inputItem.dart';
import 'package:new_bluebyte/components/purpleButton.dart';
import 'package:new_bluebyte/provider/objectsProvider.dart';
import 'package:new_bluebyte/utils/alertDialog.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget editObjectinfoGetter(BuildContext context,
    {@required int objectId,
    @required String lang,
    @required String initialName,
    @required String initialType}) {
  final nameController = new TextEditingController(text: initialName);
  final typeController = new TextEditingController(text: initialType);
  bool isFrench = lang == Config.fr;
  return SingleChildScrollView(
    child: Container(
      alignment: Alignment.center,
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
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
          Row(
            children: <Widget>[
              // Expanded(flex: 1, child: Container()),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PurpleButton(
                    label: Languages.edit[isFrench ? Config.fr : Config.en],
                    onPressed: () async {
                      if (nameController.text.isNotEmpty &&
                          typeController.text.isNotEmpty) {
                        if (nameController.text != initialName ||
                            typeController.text != initialType)
                          Provider.of<ObjectProvider>(context, listen: false)
                              .editObject(objectId, {
                            Config.name: nameController.text,
                            Config.objectType: nameController.text
                          });

                        Navigator.of(context).pop(nameController.text);
                      } else
                        NotificationDialog.showMyDialogue(
                            Languages.emptyFormTitle[
                                isFrench ? Config.fr : Config.en],
                            Languages.emptyFormMessage[
                                isFrench ? Config.fr : Config.en],
                            context,
                            positive: false);
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}
