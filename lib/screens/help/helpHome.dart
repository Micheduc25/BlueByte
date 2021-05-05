import 'package:new_bluebyte/components/purpleButton.dart';

import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/helpText.dart';

import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'projectStructure.dart';

class HelpHome extends StatelessWidget {
  HelpHome({this.settings, @required this.pageController});
  final AppSettings settings;
  final PageController pageController;
  @override
  Widget build(BuildContext context) {
    final bool isFrench = settings.globalLanguage.getValue() == Config.fr;
    final size = MediaQuery.of(context).size;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Image.asset(
              "assets/images/logo.png",
              width: 200,
              height: 300,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                HelpText.introMessage(isFrench),
                style: Styles.purpleTextNormal,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width < 700 ? 20 : size.width * 0.12),
              child: PurpleButton(
                label: HelpText.projectStructureTitle(isFrench),
                onPressed: () async {
                  await pageController.animateToPage(1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn);
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width < 700 ? 20 : size.width * 0.12),
              child: PurpleButton(
                label: HelpText.takingMeasurementsTitle(isFrench),
                onPressed: () async {
                  await pageController.animateToPage(2,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn);
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width < 700 ? 20 : size.width * 0.12),
              child: PurpleButton(
                label: HelpText.recordingAudiosTitle(isFrench),
                onPressed: () {},
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width < 700 ? 20 : size.width * 0.12),
              child: PurpleButton(
                label: HelpText.configureApplicationTitle(isFrench),
                onPressed: () {},
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width < 700 ? 20 : size.width * 0.12),
              child: PurpleButton(
                label: HelpText.manageProjectTitle(isFrench),
                onPressed: () {},
              ),
            ),
          ],
        ));
  }
}
