import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import '../Entity/EStudent.dart';
import '../Managers/StudentManager.dart';

Future initWebApp() async{
  try{
    await loadStudentInfoFromNet();//获取学生信息
  }catch(e){
    print("网络错误");
  }
  ThemeManager.initTheme();
  UserConfig().initUserConfig();
}
Future loadStudentInfoFromNet()async{
  Dio dio = Dio();
  dio.options.headers['Access-Control-Allow-Origin'] = '*';
  Response studentFronNet = await dio.request("https://gitee.com/honoki/mtkresouce/raw/master/public/students.json");
  for(var student in studentFronNet.data){
    StudentManager.instance.studentDirctory[student["id"]] = EStudent.fromMap(student);
  }
  String chatTools = await rootBundle.loadString("assets/datas/chatTools.json");
  for(var tool in jsonDecode(chatTools)){
    StudentManager.instance.toolStudentDirctory[tool["id"]] = EStudent.fromMap(tool);
  }
  StudentManager.instance.noneStudent.release = 0;

}