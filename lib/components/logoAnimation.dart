import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class LogoAnimation extends StatefulWidget {
  _LogoAnimationState createState() => _LogoAnimationState();
}

class _LogoAnimationState extends State<LogoAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation animation;

  @override
  void initState() {
    animationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    // animationController.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     animationController.reverse();
    //   } else if (status == AnimationStatus.dismissed) {
    //     animationController.forward();
    //   }
    // });

    animationController.addListener(() {
      setState(() {});
    });

    animationController.forward();

    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Transform.rotate(
          angle: 2 * (math.pi) * animation.value,
          child: Image.asset("assets/images/nashma.png")),
    );
  }
}
