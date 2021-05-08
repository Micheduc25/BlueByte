import 'package:new_bluebyte/screens/HomeScreen/selectLanguage.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedLetter extends StatefulWidget {
  AnimatedLetter(
      {@required this.letter, @required this.delay, this.last = false});
  final Duration delay;
  final String letter;
  final bool last;
  _AnimatedLetterState createState() => _AnimatedLetterState();
}

class _AnimatedLetterState extends State<AnimatedLetter>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation animation;

  @override
  void initState() {
    animationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.last ? 1000 : 500),
    );
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.last)
          Future.delayed(Duration.zero, () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SelectLanguage()));
          });
      }
    });

    animationController.addListener(() {
      setState(() {});
    });

    Future.delayed(widget.delay, () {
      animationController.forward();
    });

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
        child: Text(
      widget.letter,
      style: TextStyle(
          color: AppColors.purpleNormal.withOpacity(
            animation.value,
          ),
          fontSize: 35,
          fontWeight: FontWeight.bold,
          fontFamily: "crystal_cathedral"),
    ));
  }
}
