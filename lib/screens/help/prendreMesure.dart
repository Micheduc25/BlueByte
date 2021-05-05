import 'package:flutter/material.dart';
import 'package:new_bluebyte/screens/help/movingHand.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/helpText.dart';
import 'package:new_bluebyte/utils/settings.dart';

class PrendreMesure extends StatefulWidget {
  PrendreMesure({@required this.settings});
  final AppSettings settings;

  @override
  _PrendreMesureState createState() => _PrendreMesureState();
}

class _PrendreMesureState extends State<PrendreMesure> {
  GlobalKey _imKey = GlobalKey();
  Offset initPosition;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      RenderBox imRenderBox = _imKey.currentContext.findRenderObject();
      final position = imRenderBox.localToGlobal(Offset.zero);
      setState(() {
        initPosition = position;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isFrench = widget.settings.globalLanguage.getValue() == Config.fr;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            child: Stack(
              children: [
                ListView(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      HelpText.takingMeasurementsTitle(isFrench),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    SizedBox(height: 10),
                    Text(
                      HelpText.takingMeasurementsBody1(isFrench),
                    ),
                    SizedBox(height: 20),
                    Image.asset(
                      'assets/images/measurements.png',
                      key: _imKey,
                      height: 400,
                    ),
                  ],
                ),
                MovingHand(
                    initialPosition: initPosition ?? Offset(10, 15),
                    finalPosition: initPosition == null
                        ? Offset(40, 40)
                        : Offset(initPosition.dx + 100, initPosition.dy + 30))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
