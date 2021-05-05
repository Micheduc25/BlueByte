import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  InfoDialog({Key key, @required this.title, @required this.fieldsAndInfo})
      : super(key: key);

  final String title;
  final Map<String, String> fieldsAndInfo;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(
        this.title,
        style: Styles.purpleTextLarge,
        textAlign: TextAlign.center,
      ),
      elevation: 8,
      children: generateInfo(),
    );
  }

  List<Widget> generateInfo() {
    List<Widget> infos = [];

    this.fieldsAndInfo.forEach((field, info) {
      infos.add(Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            field,
            style: TextStyle(
                color: AppColors.purpleDark,
                decoration: TextDecoration.underline,
                fontSize: 20),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            info,
            style: Styles.purpleTextNormal,
          ),
          SizedBox(
            height: 30,
          )
        ],
      ));
    });

    return infos;
  }
}
