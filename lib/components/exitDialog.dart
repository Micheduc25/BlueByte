import 'package:flutter/material.dart';
import 'package:new_bluebyte/components/purpleButton.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/styles.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({
    Key key,
    @required this.isFrench,
  }) : super(key: key);

  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            "assets/images/logo.png",
            width: 50,
            height: 50,
          ),
          SizedBox(
            width: 15,
          ),
          Text(
            Languages.appExitTitle[isFrench ? Config.fr : Config.en],
            style: Styles.purpleTextLarge,
          ),
        ],
      ),
      content: Text(
        Languages.appExitMessage[isFrench ? Config.fr : Config.en],
        style: Styles.purpleTextNormal,
      ),
      actions: <Widget>[
        PurpleButton(
          label: Languages.no[isFrench ? Config.fr : Config.en],
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        PurpleButton(
          label: Languages.yes[isFrench ? Config.fr : Config.en],
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        )
      ],
    );
  }
}