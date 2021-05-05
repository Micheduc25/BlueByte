import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  SearchBar(
      {this.searchController, this.onChange, this.isFrench, this.searchFor});
  final String searchFor;
  final TextEditingController searchController;
  final Function(String text) onChange;
  final bool isFrench;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: searchController,
        cursorColor: AppColors.purpleNormal,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.purpleNormal,
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 3, color: AppColors.purpleDark)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: AppColors.purpleDark)),
            hintText: Languages.searchFor[isFrench ? Config.fr : Config.en] +
                " " +
                searchFor,
            hintStyle: TextStyle(
              color: AppColors.purpleLight,
              fontSize: 18,
            )),
        onChanged: (text) {
          onChange(text);
        },
      ),
    );
  }
}
