import 'dart:io';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:path/path.dart';

class AppResource{
  static Map<String,File> studentAvatars = {};
  static Map<int,File> diyStudentAvatars = {};

  static void addDIYAvatar(int id,String path){
    diyStudentAvatars[id] = File(path);
  }

  static void addReleaseAvatar(int id,int skinIndex){
    studentAvatars["$id-$skinIndex"] = File(getReleaseStudentPath(id,skinIndex));
  }

  static File? getStudentAvatarFile(int id,int skinIndex,int release){
    if(release == 2){
      return diyStudentAvatars[id];
    }
    return studentAvatars["$id-$skinIndex"];
  }

  static String getReleaseStudentPath(int id,int skinIndex){
    return join(AppLibrary.applicationPath,"Resouces","Avatars","${id}_$skinIndex.png");
  }

}