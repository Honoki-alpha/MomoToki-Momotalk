import 'dart:io';

import 'package:flutter/material.dart';
import '../Entity/EStudent.dart';
import '../Managers/StudentManager.dart';


Widget getRectangleStudentAvatar(int id,{int? skinIndex}){
  int index = skinIndex??0;
  EStudent student = StudentManager.instance.getStudentById(id);
  String url = "";
  if(index > student.skinList.length - 1){
    url = "https:${student.avatar}";
  }else{
    url = "https:${student.skinList[index]["avatar"]}";
  }
  //自定义学生
  if(student.release == 2){
    url = student.avatar;
  }
  return Container(
      decoration: const BoxDecoration(
          shape: BoxShape.rectangle
      ),
      child: getAvatarByReleases(student.release, url));
}

Widget getCicleStudentAvatar(int id, {int? skinIndex,double? customWidth}){
  double w = customWidth ?? 50;
  int index = skinIndex??0;
  EStudent student = StudentManager.instance.getStudentById(id);
  String url = "";
  if(index > student.skinList.length - 1){
    url = "https:${student.avatar}";
  }else{
    url = "https:${student.skinList[index]["avatar"]}";
  }
  //自定义学生
  if(student.release == 2){
    url = student.avatar;
  }
  return Container(
      width:w,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
          shape: BoxShape.circle
      ),
      child: getAvatarByReleases(student.release, url));
}

Widget getSettingBorderBox(List<Widget> children){
  return Container(
    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    decoration: BoxDecoration(
        color: const Color.fromARGB(150, 255,230,240),
        borderRadius: BorderRadius.circular(10)
    ),
    child: Column(
      children: children,
    ),
  );
}

//根据DIY还是软件内置学生返回本地/网络头像
Widget getAvatarByReleases(int releases,String path){
  if(releases == 2){
    return Image.file(File(path),errorBuilder: (b,o,t){
      return Image.asset("assets/images/icon/IMAGELOST.png");
    },);
  }
  return Image.network(
    path,
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
  );
}