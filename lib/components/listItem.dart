import 'package:new_bluebyte/models/audioModel.dart';
import 'package:new_bluebyte/screens/AudioRecordScreen/audioPlayScreen.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';

class ListItem extends StatefulWidget {
  ListItem(
      {this.moduleAudios,
      this.filterKey,
      this.inEditMode,
      this.index,
      @required this.settings});
  final List<Audio> moduleAudios;
  final String filterKey;
  final bool inEditMode;
  final int index;
  final AppSettings settings;

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  bool selected;
  @override
  void initState() {
    selected = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          fit: StackFit.expand,
          children: <Widget>[
            InkWell(
              onLongPress: () {
                if (!selected) {
                  setState(() {
                    selected = true;
                  });
                } else {
                  setState(() {
                    selected = false;
                  });
                }
              },
              splashColor: AppColors.purpleLight.withOpacity(.5),
              child: ListTile(
                leading: Icon(
                  Icons.audiotrack,
                  color: AppColors.purpleNormal,
                  size: 25,
                ),
                title: Text(
                  widget.moduleAudios[widget.index].filename,
                  style: Styles.purpleTextNormal,
                ),
                trailing: Text(
                  widget.moduleAudios[widget.index].audioId.toString(),
                  style: TextStyle(color: AppColors.purpleLight, fontSize: 14),
                ),
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    //what is next
                    return AudioPlayScreen(
                      settings: widget.settings,
                      fileName: widget.moduleAudios[widget.index].filename,
                      filePath: widget.moduleAudios[widget.index].path,
                    );
                  }));
                },
              ),
            ),
            Container(
              color: selected
                  ? AppColors.purpleLight.withOpacity(.8)
                  : Colors.white,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Divider(
            height: 4,
            color: AppColors.purpleNormal,
            thickness: 1,
          ),
        )
      ],
    );
  }
}
