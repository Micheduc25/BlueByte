import 'package:new_bluebyte/screens/help/helpHome.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:flutter/material.dart';
import 'projectStructure.dart';
import 'prendreMesure.dart';

class HelpController extends StatefulWidget {
  HelpController({this.settings});
  final AppSettings settings;

  @override
  _HelpControllerState createState() => _HelpControllerState();
}

class _HelpControllerState extends State<HelpController>
    with SingleTickerProviderStateMixin {
  PageController pageController;
  @override
  void initState() {
    pageController = new PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFrench =
        widget.settings.globalLanguage.getValue() == Config.fr;
    // final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.purpleNormal,
          leading: InkWell(
            child: Icon(
              Icons.navigate_before,
              size: 30,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(Languages.help[isFrench ? Config.fr : Config.en]),
          actions: <Widget>[
            InkWell(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.home,
                  size: 30,
                ),
              ),
              onTap: () {
                pageController.jumpToPage(0);
              },
            )
          ],
        ),
        body: PageView(
          controller: pageController,
          children: <Widget>[
            HelpHome(
              settings: widget.settings,
              pageController: pageController,
            ),
            ProjectStructure(
              settings: widget.settings,
            ),
            PrendreMesure(settings: widget.settings)
          ],
        ));
  }
}
