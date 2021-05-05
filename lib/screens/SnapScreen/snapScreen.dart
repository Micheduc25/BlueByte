// import 'dart:async';
// import 'dart:io';

// import 'package:new_bluebyte/database/dbOps.dart';

// import 'package:new_bluebyte/models/newImageModel.dart';

// import 'package:new_bluebyte/screens/AudioRecordScreen/audioRecordScreen.dart';
// import 'package:new_bluebyte/screens/ImageScreen/imageScreen.dart';
// import 'package:new_bluebyte/utils/alertDialog.dart';
// import 'package:new_bluebyte/utils/colors&fonts.dart';
// import 'package:new_bluebyte/utils/config.dart';
// import 'package:new_bluebyte/utils/languages.dart';
// import 'package:new_bluebyte/utils/settings.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/services.dart';

// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:path/path.dart';

// List<CameraDescription> cameras;

// class SnapScreen extends StatefulWidget {
//   SnapScreen({this.settings, this.moduleName, this.objectInfo});
//   final AppSettings settings;
//   final String moduleName;
//   final Map objectInfo;
//   @override
//   _SnapScreenState createState() => _SnapScreenState();
// }

// class _SnapScreenState extends State<SnapScreen> with WidgetsBindingObserver {
//   CameraController controller;
//   List<CameraDescription> cameras;
//   bool cameraLoaded;
//   SharedPreferences _prefs;
//   String lang;
//   bool flashOn;
//   Map<PermissionGroup, PermissionStatus> permissions;

//   ///this method selects and loads the camera
//   Future<void> initCam() async {
//     try {
//       cameras = await availableCameras();
//     } catch (e) {
//       print("eroor while trying to get cameras: $e");
//     }
//     print(cameras);
//     controller = new CameraController(cameras[0], ResolutionPreset.ultraHigh);

//     try {
//       await controller.initialize();
//     } catch (e) {
//       print("error initializing camera ${e.toString()}");
//     }
//     //once the camera is selected and initialized with set the cameraLoaded
//     //boolean to true
//     setState(() {
//       cameraLoaded = true;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     flashOn = false;
//     cameraLoaded = false;
//     SharedPreferences.getInstance().then((prefs) {
//       setState(() {
//         _prefs = prefs;
//         lang = _prefs.getString(Config.globalLanguage);
//         if (widget.settings.firstSnap == null)
//           _prefs.setBool(Config.firstSnap, false);
//       });
//     });
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//     initCam();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (state == AppLifecycleState.resumed) {
//       await initCam();
//     }
//     super.didChangeAppLifecycleState(state);
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeRight,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);

//     // print("done setting orientations");

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;

//     if (widget.settings.firstSnap == null) {
//       final lang = widget.settings.globalLanguage;
//       NotificationDialog.showMyDialogue(
//           Languages.firstSnapTitle[
//               lang.getValue() == Config.fr ? Config.fr : Config.en],
//           Languages.firstSnapMessage[
//               lang.getValue() == Config.fr ? Config.fr : Config.en],
//           context);
//     }

//     return MaterialApp(
//       title: Config.appTitle,
//       home: Scaffold(
//         body: SafeArea(
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             child: cameraLoaded
//                 ? Stack(
//                     fit: StackFit.expand,
//                     children: <Widget>[
//                       AspectRatio(
//                           aspectRatio: size.width > size.height
//                               ? size.width / size.height
//                               : size.height / size.width,
//                           child: CameraPreview(controller)),
//                       Container(
//                         alignment: Alignment.bottomCenter,
//                         padding: EdgeInsets.only(bottom: 10),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: <Widget>[
//                             Row(
//                               children: <Widget>[
//                                 RaisedButton(
//                                   padding: EdgeInsets.symmetric(vertical: 10),
//                                   child: Icon(
//                                     Icons.audiotrack,
//                                     color: Colors.white,
//                                   ),
//                                   splashColor: Colors.white,
//                                   color:
//                                       AppColors.purpleNormal.withOpacity(.15),
//                                   onPressed: () {
//                                     //Navigate to the audio recording page

//                                     Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                                 AudioRecordScreen(
//                                                   settings: widget.settings,
//                                                   moduleName: widget.moduleName,
//                                                 )));
//                                   },
//                                 ),
//                                 RaisedButton(
//                                   padding: EdgeInsets.symmetric(vertical: 10),
//                                   child: Icon(
//                                     Icons.close,
//                                     color: Colors.white,
//                                   ),
//                                   splashColor: Colors.white,
//                                   color:
//                                       AppColors.purpleNormal.withOpacity(.15),
//                                   onPressed: () {
//                                     //Navigate to the audio recording page

//                                     Navigator.of(context).pop();
//                                   },
//                                 )
//                               ],
//                             ),
//                             FloatingActionButton(
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.padded,
//                               onPressed: () async {
//                                 permissions = await PermissionHandler()
//                                     .requestPermissions(
//                                         [PermissionGroup.storage]);
//                                 if (permissions[PermissionGroup.storage] ==
//                                     PermissionStatus.granted) {
//                                   print("permission granted");
//                                   final appDir =
//                                       await getExternalStorageDirectory();

//                                   //we create the folder where the image will be stored
//                                   final imageDir = await Directory(join(
//                                           appDir.path,
//                                           widget.moduleName,
//                                           "images"))
//                                       .create(recursive: true);

//                                   //we now define the path of the image
//                                   final finalPath = join(imageDir.path,
//                                       widget.objectInfo[Config.name] + ".jpg");

//                                   //we take the picture
//                                   try {
//                                     await controller.takePicture(finalPath);
//                                     print("picture taken!");
//                                   } catch (e) {
//                                     print("Could not take picture:" +
//                                         e.toString());
//                                   }

//                                   try {
//                                     //here we create a new object and pass it to the imageSCreen constructor
//                                     // int moduleId =
//                                     //     await DbOperations.getModuleId(
//                                     //         widget.moduleName);
//                                     // String date = new DateTime.now()
//                                     //     .toIso8601String()
//                                     //     .split("T")[0];

//                                     // Object newObject = new Object(
//                                     //     name: widget.objectInfo[Config.name],
//                                     //     moduleId: moduleId,
//                                     //     creationDate: date,
//                                     //     objectType:
//                                     //         widget.objectInfo[Config.type]);
//                                     // await DbOperations.addObject(newObject);

//                                     ObjectImage newImage = new ObjectImage(
//                                         name: widget.objectInfo[Config.name],
//                                         path: finalPath,
//                                         objectId:
//                                             widget.objectInfo[Config.objectId]);

//                                     await DbOperations.addImage(newImage);

//                                     SystemChrome.setPreferredOrientations([
//                                       DeviceOrientation.landscapeRight,
//                                       DeviceOrientation.landscapeLeft,
//                                       DeviceOrientation.portraitUp,
//                                       DeviceOrientation.portraitDown,
//                                     ]);
//                                     Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                             builder: (context) => ImageScreen(
//                                                 objectName: widget
//                                                     .objectInfo[Config.name],
//                                                 moduleName: widget.moduleName,
//                                                 settings: widget.settings,
//                                                 imagePath: finalPath,
//                                                 image: newImage)));
//                                   } catch (e) {
//                                     print("could not add object: " +
//                                         e.toString());
//                                   }
//                                 } else {
//                                   Navigator.of(context).pop();
//                                 }
//                               },
//                               backgroundColor:
//                                   AppColors.purpleNormal.withOpacity(.4),
//                               splashColor: Colors.white,
//                               child: Icon(
//                                 Icons.camera,
//                                 size: 50,
//                                 color: AppColors.purpleDark,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   )
//                 : Container(
//                     alignment: Alignment.center,
//                     child: CircularProgressIndicator(
//                       backgroundColor: AppColors.purpleNormal,
//                     ),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }
