import 'dart:io';

import 'package:flutter/material.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import '../AppData/AppResource.dart';
import '../AppData/UserConfig.dart';
import '../Entity/EStudent.dart';
import '../Managers/StudentManager.dart';


PreferredSizeWidget? getPlatformAppBar(Widget title,{List<Widget>? actions,bool? centerTitle,PreferredSizeWidget? bottom}){
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

//获取矩形头像
Widget getRectangleStudentAvatar(int id,{int? skinIndex}){
  int index = skinIndex??0;
  EStudent student = StudentManager.instance.getStudentById(id);
  return Container(
      decoration: const BoxDecoration(
          shape: BoxShape.rectangle
      ),
      child: getAvatarFromResource(student.id,index));
}

//获取圆形头像
Widget getCicleStudentAvatar(int id, {int? skinIndex,double? customWidth}){
  double w = customWidth ?? 50;
  int index = skinIndex??0;
  EStudent student = StudentManager.instance.getStudentById(id);
  return Container(
      width:w,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
          shape: BoxShape.circle
      ),
      child: getAvatarFromResource(student.id,index));
}

//根据DIY还是软件内置学生返回本地/网络头像
Widget getAvatarFromResource(int id,int skinIndex){
  EStudent student = StudentManager.instance.getStudentById(id);
  File? f = AppResource.getStudentAvatarFile(id, skinIndex, student.release);
  if(id == 1 && AppLibrary.customSenseiAvatar.existsSync()){
    return Image.file(AppLibrary.customSenseiAvatar,height: 50, fit: BoxFit.cover);
  }
  if( f != null && f.existsSync() ){
    if(UserConfig.applyOfflineMode || student.release == 2 || id == 1){
      return Image.file(f,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (b,o,t){return Image.asset("assets/images/icon/IMAGELOST.png",fit: BoxFit.fitWidth,);});
    }
  }
  String url = "https:${student.avatar}";
  if(skinIndex < student.skinList.length){
    url = "https:${student.skinList[skinIndex]["avatar"]}";
  }
  return Image.network(
    url,
    scale: 30,
    filterQuality: FilterQuality.low,
    fit: BoxFit.cover,
    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress){
      if(loadingProgress == null){
        return child;
      }else{
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      }
    },
    errorBuilder: (context,obj,stack){
      return Image.asset("assets/images/icon/IMAGELOST.png",fit: BoxFit.fitWidth,);
    },
  );
}



//获取设置列表
Widget getSettingBorderBox(List<Widget> children){
  return Container(
    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.07),
        borderRadius: BorderRadius.circular(10)
    ),
    child: Column(
      children: children,
    ),
  );
}

