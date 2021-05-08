import 'package:new_bluebyte/components/animatedLetter.dart';
import 'package:new_bluebyte/components/logoAnimation.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:flutter/material.dart';

class AnimationScreen extends StatefulWidget {
  @override
  _AnimationScreenState createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LogoAnimation(),
              SizedBox(
                width: 10,
              ),
              AnimatedLetter(letter: "n", delay: Duration(milliseconds: 1000)),
              AnimatedLetter(letter: "a", delay: Duration(milliseconds: 1500)),
              AnimatedLetter(letter: "s", delay: Duration(milliseconds: 1800)),
              AnimatedLetter(letter: "h", delay: Duration(milliseconds: 2100)),
              AnimatedLetter(letter: "m", delay: Duration(milliseconds: 2400)),
              AnimatedLetter(letter: "a", delay: Duration(milliseconds: 2700)),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.only(left: 40),
            child: AnimatedLetter(
              last: true,
              letter: "presents...",
              delay: Duration(milliseconds: 3200),
            ),
          ),
        ],
      )),
    );
  }
}
