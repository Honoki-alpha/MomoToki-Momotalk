import 'dart:io';

import 'package:flutter/material.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:motoki/Entity/EStudent.dart';
import 'package:motoki/Managers/Files.dart';
import 'package:motoki/Managers/Students.dart';

class StudentCircleAvatar extends StatefulWidget{
  StudentCircleAvatar({super.key, required this.id,this.skinIndex,this.customWidth,this.student,this.selected});

  @override
  State<StatefulWidget> createState() => _StudentCircleAvatarState();
  final int id;
  int? skinIndex;
  double? customWidth;
  EStudent? student;
  bool? selected;
}

class _StudentCircleAvatarState extends State<StudentCircleAvatar>{
  int id = 0;
  int skinIndex = 0;
  late EStudent student;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;
    skinIndex = widget.skinIndex??0;
    student = widget.student ?? Students().getStudentById(id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width:widget.customWidth??50,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
        ),
        child: getAvatar(widget.selected??false));
  }

  Widget getAvatar(bool selected){
    if(id==1){
      return senseiAvatar(selected);
    }else if(UserConfig.applyOfflineMode){
      return localAvatar(selected);
    }else{
      return netAvatar(selected);
    }
  }

  Widget localAvatar(bool selected){
    File? f = Files().safeFile(Files().getReleaseStudentPath(id, skinIndex));
    if(student.avatar.length >7 && student.avatar.substring(0,7) == "NIY:://"){
      f = Files().safeFile(Files().joinAppPath("PictureCache","DIY",student.avatar.substring(7)));
    }
    if(f ==null || !f.existsSync()){
      return Image.asset("assets/images/icon/IMAGELOST.png",fit: BoxFit.fitWidth, color: selected?Colors.redAccent:null,);
    }
    return Image.file(f,
        height: 50,
        color: selected?Colors.redAccent:null,
        fit: BoxFit.cover,
        errorBuilder: (b,o,t){return Image.asset("assets/images/icon/IMAGELOST.png",fit: BoxFit.fitWidth,);});
  }

  Widget netAvatar(bool selected){
    String url = "https:${student.avatar}";
    if(skinIndex < student.skinList.length){
      url = "https:${student.skinList[skinIndex]["avatar"]}";
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
    File f = Files().customSenseiAvatar;
    if(!f.existsSync()) f = Files().safeFile(Files().getReleaseStudentPath(id, skinIndex))!;
    if(f.existsSync() || UserConfig.applyOfflineMode){
      return Image.file(Files().customSenseiAvatar,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (b,o,t){return Image.asset("assets/images/icon/IMAGELOST.png",fit: BoxFit.fitWidth,);});
    }
    return Image.network(
      "https:://gitee.com/honoki/mtkresouce/raw/master/assets/images/icon/sensei.jpg",
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