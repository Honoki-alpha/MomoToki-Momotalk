import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:path/path.dart';
import 'dart:convert';
class Files{
  static Files? _instance;
  factory Files() => _instance ?? Files._();
  Files._(){
      _instance = this;
  }

  File customSenseiAvatar = File('');

  dynamic jsonDecode(String content){
    if(content == "") content = "{}";
    return json.decode(content);
  }

  String getReleaseStudentPath(int id,int skinIndex){
    return join(AppLibrary.applicationPath,"Resources","Avatars","${id}_$skinIndex.png");
  }


  String joinAppPath(String path1,[String? path2,String? path3,String? path4,String? path5]){
    return join(AppLibrary.applicationPath,path1,path2,path3,path4,path5);
  }

}