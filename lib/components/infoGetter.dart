import 'dart:async';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_bluebyte/components/inputItem.dart';
import 'package:new_bluebyte/components/purpleButton.dart';
import 'package:new_bluebyte/database/dbOps.dart';
import 'package:new_bluebyte/models/newImageModel.dart';
import 'package:new_bluebyte/provider/newImagesProvider.dart';
import 'package:new_bluebyte/screens/ImageScreen/imageScreen.dart';
import 'package:new_bluebyte/utils/alertDialog.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart' as picker;

class InfoGetter extends StatefulWidget {
  final String moduleName;

  const InfoGetter(
      {Key key,
      @required this.context,
      this.moduleName,
      @required this.isFrench,
      @required this.lang,
      @required this.nameController,
      @required this.widgetSettings,
      this.fromImageScreen = false,
      this.objectName,
      this.objectId})
      : super(key: key);

  final BuildContext context;
  final bool fromImageScreen;
  final int objectId;
  final String objectName;
  final bool isFrench;
  final String lang;
  final TextEditingController nameController;
  final AppSettings widgetSettings;

  @override
  _InfoGetterState createState() => _InfoGetterState();
}

class _InfoGetterState extends State<InfoGetter> {
  StreamSubscription imgSourceSubs;

  String imageSource;

  @override
  void initState() {
    imageSource = widget.widgetSettings.imageSource.getValue();
    imgSourceSubs = widget.widgetSettings.imageSource.listen((val) async {
      if (mounted) {
        setState(() {
          imageSource = val;
        });
        // print("image Source set to $val");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    imgSourceSubs.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        color: Colors.white,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              Languages.imageName[widget.isFrench ? Config.fr : Config.en],
              style: Styles.purpleTextLarge,
            ),
            SizedBox(
              height: 20,
            ),
            InputItem(
              lang: widget.lang,
              controller: widget.nameController,
              size: MediaQuery.of(context).size,
              hint: Languages.name[widget.isFrench ? Config.fr : Config.en],
              label: Languages.name[widget.isFrench ? Config.fr : Config.en],
            ),
            SizedBox(
              height: 10,
            ),
            PurpleButton(
              label: "OK",
              onPressed: () async {
                if (widget.nameController.text.isNotEmpty &&
                    widget.nameController.text != "") {
                  FocusScope.of(context).unfocus();

                  String name = widget.nameController.text;
                  File imageFile;

                  // print("image source is $imageSource");

                  final _picker = new picker.ImagePicker();

                  final pickedFile = await _picker.getImage(
                      source: imageSource == Config.camera
                          ? picker.ImageSource.camera
                          : picker.ImageSource.gallery);

                  if (pickedFile != null) {
                    imageFile = File(pickedFile.path);

                    // imageFile = await picker.ImagePicker.pickImage(
                    //     source: imageSource == Config.camera
                    //         ? picker.ImageSource.camera
                    //         : picker.ImageSource.gallery);

                    Directory appDir = await getExternalStorageDirectory();
                    final imageDir = await Directory(join(appDir.path,
                            widget.moduleName, widget.objectName, "images"))
                        .create(recursive: true);

                    //we now define the path of the image
                    final finalPath = join(imageDir.path, "$name.jpg");

                    try {
                      final newIm = await imageFile.copy(finalPath);
                      // print(newIm.path);
                      await imageFile.delete(recursive: true);
                    } catch (e) {
                      print("could not copy the image $e");
                    }

                    ObjectImage newImage = new ObjectImage(
                        objectId: widget.objectId, path: finalPath, name: name);

                    final id = await DbOperations.addImage(newImage);
                    newImage.imageId = id;
                    // print("image $name.jpg added to db");
                    widget.nameController.clear();

                    await Provider.of<ImagesProvider>(context, listen: false)
                        .getImages(widget.objectId);

                    if (widget.fromImageScreen) {
                      int count = 3;
                      await Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => ImageScreen(
                                      objectName: widget.objectName,
                                      moduleName: widget.moduleName,
                                      settings: widget.widgetSettings,
                                      imagePath: finalPath,
                                      image: newImage)), (route) {
                        count--;

                        return count == 0 ? true : false;
                      });
                    } else {
                      await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => ImageScreen(
                                  objectName: widget.objectName,
                                  moduleName: widget.moduleName,
                                  settings: widget.widgetSettings,
                                  imagePath: finalPath,
                                  image: newImage)));
                    }
                  } else {
                    Fluttertoast.showToast(msg: 'no image selected');
                    Navigator.of(context).pop();
                  }
                } else
                  NotificationDialog.showMyDialogue(
                      Languages.emptyFormTitle[
                          widget.isFrench ? Config.fr : Config.en],
                      Languages.emptyFormMessage[
                          widget.isFrench ? Config.fr : Config.en],
                      context,
                      positive: false);
              },
            )
          ],
        ),
      ),
    );
  }
}

class ImageItem extends StatelessWidget {
  ImageItem(
      {this.file,
      this.id,
      this.caption,
      @required this.onTap,
      @required this.onLongPress,
      @required this.foregroundColor,
      @required this.name});
  final String file;
  final int id;
  final Function onLongPress;
  final String caption;
  final Color foregroundColor;
  final String name;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: Colors.black,
        foregroundDecoration: BoxDecoration(color: foregroundColor),
        child: Stack(
          // fit: StackFit.expand,
          alignment: Alignment.center,
          children: <Widget>[
            Hero(
                tag: name + id.toString(),
                child: Image.file(
                  new File(this.file),
                )),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                // width: double.infinity,
                child: Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: Styles.whiteTextNormal,
                ),
                padding: EdgeInsets.all(5),
                color: AppColors.purpleNormal.withOpacity(.6),
              ),
            )
          ],
        ),
      ),
    );
  }
}
