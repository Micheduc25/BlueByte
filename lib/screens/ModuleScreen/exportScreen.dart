import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_bluebyte/components/pointMode.dart';
import 'package:new_bluebyte/components/snappableItem.dart';
import 'package:new_bluebyte/models/audioModel.dart';
import 'package:new_bluebyte/models/moduleModel.dart';
import 'package:new_bluebyte/models/newImageModel.dart';
import 'package:new_bluebyte/models/objectModel.dart';
import 'package:new_bluebyte/provider/audiosProvider.dart';
import 'package:new_bluebyte/provider/newImagesProvider.dart';
import 'package:new_bluebyte/provider/objectsProvider.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class ExportScreen extends StatefulWidget {
  final Module module;
  final AppSettings settings;

  ExportScreen({@required Module module, @required AppSettings settings})
      : module = module,
        settings = settings;
  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  GlobalKey paintKey = GlobalKey();
  List<Object> moduleObjects;
  List<Audio> moduleAudios;
  List<ObjectImage> objectImages = [];
  PointCollector pointController;
  List<PointCollector> pointControllers = [];

  // bool _isLoading = true;
  // ObjectImage _currentImage;
  // Object _currentObject;
  double progress = 0;
  int totalImages = 0;
  int totalAudios = 0;
  int imageCount = 0;
  int audioCount = 0;
  bool _isLoading = true;
  int currentIndex = 0;

  Map<int, File> imageFiles = {};
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    Future.delayed(Duration.zero, () async {
      // bool isFrench = widget.settings.globalLanguage.getValue() == Config.fr;
      setState(() {
        _isLoading = false;
      });

      //Exportation done here
      // final moduleProvider = Provider.of<ModulesProvider>(context);
      final imagesProvider =
          Provider.of<ImagesProvider>(context, listen: false);
      moduleObjects = await Provider.of<ObjectProvider>(context, listen: false)
          .getObjects(widget.module.moduleId);
      moduleAudios = await Provider.of<AudioProvider>(context, listen: false)
          .getAudios(widget.module.moduleId);

      for (int i = 0; i < moduleObjects.length; i++) {
        final objImages =
            await imagesProvider.getImages(moduleObjects[i].objectId);
        objectImages.addAll(objImages);

        totalImages += objImages.length;
      }

      //we create corresponding pointControllers for these images

      for (ObjectImage image in objectImages) {
        final pc = pointController = PointCollector(
            PointMode.Length, image.imageId, true, widget.settings,
            objectId: image.objectId,
            objectName: '',
            image: image,
            imagePath: image.path,
            moduleName: widget.module.name,
            editService: null,
            widgetState: null);
        await pc.loadPoints(context);
        pointControllers.add(pc);
      }

      totalAudios = moduleAudios.length;

      setState(() {});

      /////////////////////////////////////////////////////////////////////////////
      ////                                                                    ////
      ///                     Directory creation and snapshot   here          ///
      //////////////////////////////////////////////////////////////////////////

      //we create the directory in which the project will be exported
      final exportDir = Directory("storage/emulated/0/BlueByte/Exports");
      final moduleDirectory =
          Directory(path.join(exportDir.path, widget.module.name));
      Directory objectsDirectory =
          Directory(path.join(moduleDirectory.path, 'Objects'));
      Directory audiosDirectory =
          Directory(path.join(moduleDirectory.path, 'Audios'));

      final status = await Permission.storage.status;

      if (!status.isGranted) {
        await Permission.storage.request();
      }

      // if directories do not exist we create them
      if ((await moduleDirectory.exists())) {
        await moduleDirectory.delete(recursive: true);
      }
      // print('directory created at ${moduleDirectory.path}');

      await moduleDirectory.create(recursive: true);

      await objectsDirectory.create(recursive: false);

      await audiosDirectory.create(recursive: false);

      ////////////////////////////////////////////////////////////////////////
      ///
      await Future.delayed(Duration(milliseconds: 1500), () {});

      for (int i = 0; i < objectImages.length; i++) {
        ObjectImage im = objectImages[i];
        String objName =
            moduleObjects.firstWhere((obj) => obj.objectId == im.objectId).name;
        Directory imDir =
            await Directory(path.join(objectsDirectory.path, objName)).create();

        final finalPath = path.join(imDir.path, "${im.name}.png");
        await Future.delayed(Duration(milliseconds: 50), () {});

        RenderRepaintBoundary boundary =
            paintKey.currentContext.findRenderObject();
        var image = await boundary.toImage();
        var byteData = await image.toByteData(format: ImageByteFormat.png);
        var pngBytes = byteData.buffer.asUint8List();

        try {
          File imgFile = await File("$finalPath").create(recursive: true);
          await imgFile.writeAsBytes(pngBytes);

          setState(() {
            imageCount++;

            progress =
                (((imageCount + audioCount) / (totalImages + totalAudios)) *
                    100);
            if (currentIndex < objectImages.length - 1) {
              currentIndex++;
              print("index is $currentIndex");
            }
          });

          // setState(() {});
        } catch (err) {
          Fluttertoast.showToast(msg: 'error:$err');
        }
      }

      //after writing all images to export directory we now write all audios to export directory
      Audio currentAudio;
      for (int i = 0; i < moduleAudios.length; i++) {
        currentAudio = moduleAudios[i];
        File audioFile = File(currentAudio.path);
        if (await audioFile.exists()) {
          try {
            await audioFile.copy(path.join(
                audiosDirectory.path, '${currentAudio.filename}.m4a'));
            audioCount++;
            setState(() {
              progress =
                  (((imageCount + audioCount) / (totalImages + totalAudios)) *
                      100);
            });
          } catch (err) {
            print('could not copy ${currentAudio.filename}.m4a');
            await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      'Erreur!',
                      style: TextStyle(color: Colors.red),
                    ),
                    content: Text(
                      "Une érreure s'est produite lors de l'exportation. $err",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                });
            Future.delayed(Duration(seconds: 5), () {
              Navigator.of(context).pop();
            });
          }
        }
      }

      // //after exportation we zip the file
      final zipFile =
          File(path.join(exportDir.path, '${widget.module.name}.zip'));
      if (await zipFile.exists()) await zipFile.delete(recursive: true);
      await ZipFile.createFromDirectory(
        sourceDir: moduleDirectory,
        zipFile: zipFile,
      );
      if (mounted) {
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Succès'),
                  content: Text('Le module a été exporté avec succès!😁👌'),
                ));
      }
      Navigator.of(context).pop();
    });
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFrench = widget.settings.globalLanguage.getValue() == Config.fr;
    return Scaffold(
        body: objectImages != null && !_isLoading
            ? Stack(
                alignment: Alignment.center,
                children: [
                  RepaintBoundary(
                    key: paintKey,
                    child: Container(
                        color: Colors.black,
                        constraints: BoxConstraints.expand(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: List<SnappableItem>.generate(
                              objectImages.length, (index) {
                            final im = objectImages[index];
                            return SnappableItem(
                                isVisible: index == currentIndex,
                                imageFile: File(im.path),
                                objectImage: im,
                                isFrench: isFrench,
                                module: widget.module,
                                objectId: im.objectId,
                                pointController: pointControllers[index],
                                settings: widget.settings,
                                wstate: this);
                          }).reversed.toList(),
                        )),
                  ),
                  Container(
                    constraints: BoxConstraints.expand(),
                    color: Colors.black.withOpacity(.6),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          progress == 100
                              ? Container()
                              : CircularProgressIndicator(
                                  backgroundColor: AppColors.purpleDark,
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${progress.toStringAsFixed(2)}%',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(
                  backgroundColor: AppColors.purpleDark,
                ),
              ));
  }
}
