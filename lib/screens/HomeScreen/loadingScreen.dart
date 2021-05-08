import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
        lowerBound: 18,
        upperBound: 30);

    controller.addListener(() {
      setState(() {});
    });

    // controller.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     controller.forward();
    //   }
    // });
    controller.repeat();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Image.asset("assets/images/logo.png"),
                ),
                Text(
                  "Loading...",
                  style: TextStyle(
                      color: AppColors.purpleNormal,
                      fontWeight: FontWeight.bold,
                      fontSize: controller.value),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
