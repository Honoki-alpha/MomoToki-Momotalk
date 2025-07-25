import 'dart:io';

import 'package:flutter/material.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:motoki/Entity/EStudent.dart';
import 'package:motoki/Managers/Files.dart';
import 'package:motoki/Managers/Students.dart';

import '../AppData/AppLibrary.dart';

class StudentCircleAvatar extends StatelessWidget{
  StudentCircleAvatar({super.key, required this.id,this.skinIndex,this.customWidth,this.student,this.selected});
  int id;
  int? skinIndex = 0;
  double? customWidth;
  EStudent? student;
  bool? selected;

  @override
  Widget build(BuildContext context) {
    id = id ??0;
    skinIndex = skinIndex ?? 0;
    student = student ?? Students().getStudentById(id);
    return Container(
        width:customWidth??50,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
        ),
        child: getAvatar(selected??false));
  }

  Widget getAvatar(bool selected){
    if(id == 1){
      return senseiAvatar(selected);
    }else if(UserConfig.applyOfflineMode || id > 10000){
      return localAvatar(selected);
    }else{
      return netAvatar(selected);
    }
  }

  Widget localAvatar(bool selected){
    File f = File(Files().getReleaseStudentPath(id, skinIndex!));
    if(student!.avatar.length >7 && student!.avatar.substring(0,7) == "NIY:://"){
      f = File(Files().joinAppPath("PictureCache","DIY",student!.avatar.substring(7)));
    }else if(f.existsSync() && UserConfig.applyOfflineMode){

    }else{
      f = File(student!.avatar);
    }
    if(!f.existsSync()){
      return Image.asset("assets/images/icon/IMAGELOST.png",fit: BoxFit.fitWidth, color: selected?Colors.redAccent:null,);
    }
    return Image.file(f,
        height: 50,
        color: selected?Colors.redAccent:null,
        fit: BoxFit.cover,
        errorBuilder: (b,o,t){return Image.asset("assets/images/icon/IMAGELOST.png",fit: BoxFit.fitWidth,);});
  }

  Widget netAvatar(bool selected){
    String url = "https:${student!.avatar}";
    if(skinIndex! < student!.skinList.length){
      url = "https:${student!.skinList[skinIndex!]["avatar"]}";
    }
    return Image.network(
      url,
      color: selected?Colors.redAccent:null,
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
        return Image.asset("assets/images/icon/IMAGELOST.png",fit: BoxFit.fitWidth,color: selected?Colors.redAccent:null,);
      },
    );
  }

  Widget senseiAvatar(bool selected){
    File? f = AppLibrary.customSenseiAvatar;
    if(!f.existsSync()&&UserConfig.applyOfflineMode)  f = File(Files().getReleaseStudentPath(id, skinIndex!));
    if(f.existsSync()){
      return Image.file(AppLibrary.customSenseiAvatar,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (b,o,t){return Image.asset("assets/images/icon/IMAGELOST.png",fit: BoxFit.fitWidth,);});
    }
    return Image.network(
      "https://gitee.com/honoki/mtkresouce/raw/master/assets/images/icon/sensei.jpg",
      filterQuality: FilterQuality.low,
      color: selected?Colors.redAccent:null,
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
        return Image.asset("assets/images/icon/IMAGELOST.png",fit: BoxFit.fitWidth, color: selected?Colors.redAccent:null,);
      },
    );
  }

}