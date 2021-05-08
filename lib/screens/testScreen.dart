// import 'package:new_bluebyte/utils/colors&fonts.dart';
// import 'package:flutter/material.dart';
// import 'dart:ui' as ui;

// class TestScreen extends StatefulWidget {
//   @override
//   _TestScreenState createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen>
//     with SingleTickerProviderStateMixin {
//   AnimationController controller;
//   FinalPainter thePainter;
//   @override
//   void initState() {
//     thePainter = new FinalPainter();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Material App',
//       home: Scaffold(
//         body: Center(
//           child: Home(),
//         ),
//       ),
//     );
//   }
// }

// class Home extends StatefulWidget {
//   const Home({
//     Key key,
//   }) : super(key: key);

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   List<Widget> objectStack = [];
//   int count = 0;
//   Offset p1;
//   Offset p2;
//   double added = 10;
//   FinalPainter thePainter;

//   @override
//   initState() {
//     super.initState();
//     thePainter = new FinalPainter(added: added);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//         onTapDown: (details) {
//           thePainter.paint(
//               Canvas(ui.PictureRecorder()), MediaQuery.of(context).size,
//               added: added);
//           added += 10;
//           count++;

//           if (count == 1) {
//             p1 = details.globalPosition;
//             print(p1);
//           } else if (count == 2) {
//             p2 = details.globalPosition;
//             print(p2);
//             setState(() {});
//             count = 0;
//           }
//         },
//         onDoubleTap: () {
//           if (objectStack.isNotEmpty) {
//             setState(() {
//               objectStack.removeLast();
//             });
//           }
//         },
//         child: Container(
//             color: Colors.greenAccent,
//             child: CustomPaint(
//               size: MediaQuery.of(context).size,
//               painter: thePainter,
//             )));
//   }
// }

// class FinalPainter extends CustomPainter {
//   FinalPainter({this.added = 0});
//   double added;

//   @override
//   void paint(Canvas canvas, Size size, {double added = 0}) {
//     final paint = new Paint()
//       ..color = AppColors.purpleNormal
//       ..strokeWidth = 3
//       ..style = PaintingStyle.stroke;

//     print("painted another circle");
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
