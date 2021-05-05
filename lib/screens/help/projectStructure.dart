import 'package:flutter/material.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/helpText.dart';
import 'package:new_bluebyte/utils/settings.dart';

class ProjectStructure extends StatelessWidget {
  ProjectStructure({@required this.settings});
  AppSettings settings;

  @override
  Widget build(BuildContext context) {
    bool isFrench = settings.globalLanguage.getValue() == Config.fr;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 10),
                Text(
                  HelpText.projectStructureTitle(isFrench),
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(height: 10),
                Image.asset('assets/images/projectStructure.png'),
                SizedBox(height: 20),
                Text(
                  HelpText.projectStructureBody1(isFrench),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
