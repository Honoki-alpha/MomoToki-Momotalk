import 'dart:io';
import 'package:path/path.dart';
import '../AppData/AppLibrary.dart';

class JsonFileManager{
  //单例
  static JsonFileManager instance = JsonFileManager._();
  JsonFileManager._(); // 私有构造函数

  Future removeJsonFile(String dirName,String fileName)async{
    File file = File(join(AppLibrary.applicationPath,dirName,fileName));
    if(file.existsSync()){
      await file.delete();
    }
  }

  Future saveJsonFile(String dirName,String fileName,String contents)async{
    File file = File(join(AppLibrary.applicationPath,dirName,fileName));
    if(!file.existsSync()){
      file.create();
    }
    await file.writeAsString(contents);
  }

}