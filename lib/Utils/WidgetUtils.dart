import 'package:flutter/material.dart';

import '../AppData/AppLibrary.dart';

class WidgetUtils{
  PreferredSizeWidget? getPlatformAppBar(
      Widget title,{List<Widget>? actions,bool? centerTitle,PreferredSizeWidget? bottom}){
    if(AppLibrary.appLandscapeMode){
      return null;
    }
    return AppBar(
      title: title,
      actions: actions,
      centerTitle: centerTitle,
      bottom: bottom,
    );
  }
}