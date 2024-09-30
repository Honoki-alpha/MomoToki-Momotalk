import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:window_manager/window_manager.dart';
import '../Entity/EChatTileGroup.dart';
import '../Entity/EStudent.dart';
import '../Managers/ChatGroupManager.dart';
import '../Managers/StudentManager.dart';
import 'AppLibrary.dart';
import 'package:path_provider/path_provider.dart';

import 'AppResource.dart';
import 'UserConfig.dart';


Future initApplication()async{
  await requestAppPermission();//申请软件权限
  await initWindowsConfig();//初始化桌面端尺寸
  await setDefaultApplicationPath();//设置软件路径
  await createNecessaryDirctory();//创建必要文件
  await loadStudentInfoFromNet();//获取学生信息
  await loadJsonFiles();//获取本地聊天记录
  await loadDIYJson();//获取DIY学生
  await loadStudentNickName();//获取学生备注
  await UserConfig().initUserConfig();//初始化用户配置
  await loadUsualJson();//添加常用学生
  await loadCustomFont();//初始化字体
  ThemeManager.initTheme();//初始化主题
  loadStudentAvatar();//初始化学生资源
}

//设置软件路径
Future setDefaultApplicationPath()async{
  if(GetPlatform.isWindows){
    AppLibrary.applicationPath = join(Directory.current.path,"Momotalk");
  }else{
    AppLibrary.applicationPath = join((await getApplicationDocumentsDirectory()).path,"Momotalk");
  }
}

//创建必要文件夹
Future createNecessaryDirctory()async{
  /*
  ChatTileGroups：聊天项分组
  ChatTiles：聊天列表的项
  Message：所有消息记录
  User：用于存储DIY.json和Usually.json
  * */
  List dirs = ["ChatTiles","Messages","Users","AIChat","PictureCache","DIYemotion","MessageCature","Resouces"];
  for (var dir in dirs) {
    Directory d = Directory(join(AppLibrary.applicationPath,dir));
    if(!d.existsSync()){
      await d.create(recursive: true);
      if(dir == "ChatTiles"){
        //创建默认
        File defaultjson = File(join(d.path,"ChatTilesGroups.json"));
        defaultjson.create();
        defaultjson.writeAsString("[{\"groupName\":\"默认分组\",\"chatTiles\":[]}]");
      }else if(dir == "Users"){
        File diyjson = File(join(d.path,"DIY.json"));
        diyjson.create();
        diyjson.writeAsString("[]");
        File usualJson = File(join(d.path,"Usually.json"));
        usualJson.create();
        usualJson.writeAsString("[]");
      }else if(dir=="Resouces"){
        Directory(join(dir,"Avatars")).create(recursive: true);
        Directory(join(dir,"Emotions")).create(recursive: true);
      }
    }
  }
}

//从网络获取学生信息
Future loadStudentInfoFromNet()async{
  Dio dio = Dio();
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

//这个会用到的
Future loadStudentAvatar()async{
  StudentManager.instance.studentDirctory.forEach((id,student){
    loadStudentAvatarResource(student);
  });
  StudentManager.instance.toolStudentDirctory.forEach((id,student){
    loadStudentAvatarResource(student);
  });
  StudentManager.instance.diyStudentDirctory.forEach((id,student){
    loadStudentAvatarResource(student);
  });
  loadStudentAvatarResource(StudentManager.instance.noneStudent);
}
void loadStudentAvatarResource(EStudent student){
  int id = student.id;
  if(student.release == 2){
    AppResource.addDIYAvatar(id, student.avatar);
  }else{
    int length = student.skinList.length;
    if(length <= 0){
      AppResource.addReleaseAvatar(id, 0);
    }else{
      for(var i = 0;i<length;i++){
        AppResource.addReleaseAvatar(id, i);
      }
    }

  }
}


//读取本地json聊天块列表记录
Future loadJsonFiles()async{
  File chatTileGroupJson = File(join(AppLibrary.applicationPath,"ChatTiles","ChatTilesGroups.json"));
  for(var chatGroup in json.decode(chatTileGroupJson.readAsStringSync())){
    ChatGroupManager.instance.chatTileGroups.add(EChatTileGroup.fromMap(chatGroup));
  }
}

//读取本地DIY学生列表
Future loadDIYJson()async{
  File diyStudent = File(join(AppLibrary.applicationPath,"Users","DIY.json"));
  for(var student in json.decode(diyStudent.readAsStringSync())){
    EStudent s = EStudent.fromMap(student);
    StudentManager.instance.diyStudentDirctory[s.id] = s;
  }
}

Future loadUsualJson()async{
  File usualStudent = File(join(AppLibrary.applicationPath,"Users","Usually.json"));
  for(var usual in json.decode(usualStudent.readAsStringSync())){
    StudentManager.instance.usualStudents.add(usual);
  }
}

//初始化windows端的窗口信息
Future initWindowsConfig()async{
  if(!GetPlatform.isWindows) return;
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(921, 486),//设置窗口的最小尺寸
    maximumSize: Size(1535, 810),//设置窗口的最大尺寸
    //window 设置窗口的初始尺寸
    size: Size(1228, 648),
    //窗口是否居中
    center: true,
    //true 表示在状态栏不显示程序：就是windows最底部的状态
    skipTaskbar: false,
    //true 表示设置Window一直位于最顶层：置顶
    alwaysOnTop: false,
    //hidden 表示隐藏标题栏 normal 窗体标题栏
    titleBarStyle: TitleBarStyle.hidden,
    title: "MomoToki - Momotalk Creator",
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.focus();
    await windowManager.setAsFrameless();
    await windowManager.setResizable(true);
    await windowManager.show();
  });


  //注册windows端快捷键
  await hotKeyManager.unregisterAll();
  await hotKeyManager.register(
    HotKey(KeyCode.escape,scope: HotKeyScope.inapp),
    keyDownHandler: (hotKey)=>Get.back(),
  );
}

Future loadCustomFont()async{
  if(UserConfig.customFont == "") return;
  if(!File(UserConfig.customFont).existsSync()){
    UserConfig.sp.setString("customFont", "");
    UserConfig.customFont = "";
    return;
  }
  FontLoader fontLoader = FontLoader('CustomFont');
  fontLoader.addFont(readFont());
  AppLibrary.appFontSource = "CustomFont";
  await fontLoader.load();
}
Future<ByteData> readFont() async {
  ByteData fontData = (await File(UserConfig.customFont).readAsBytes()).buffer.asByteData();
  return fontData;
}
Future loadStudentNickName()async{
  File studentNickName = File(join(AppLibrary.applicationPath,"Users","NickName.json"));
  if(!studentNickName.existsSync()) {
   await studentNickName.create();
  }
  try{
    StudentManager.instance.studentNickName = json.decode(studentNickName.readAsStringSync());
  }catch(e){
    StudentManager.instance.studentNickName = {};
  }
}

//权限申请
Future requestAppPermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.photos,
    Permission.manageExternalStorage,
  ].request();
}