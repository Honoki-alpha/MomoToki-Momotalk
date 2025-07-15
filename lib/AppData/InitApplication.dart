import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:window_manager/window_manager.dart';
import 'AppLibrary.dart';
import 'package:path_provider/path_provider.dart';

import 'UserConfig.dart';


Future initApplication()async{
  await initWindowsConfig();
  await requestAppPermission();//申请软件权限
  await setDefaultApplicationPath();//设置软件路径
  await createNecessaryDirctory();//创建必要文件
  await UserConfig().initUserConfig();
  await loadCustomFont();//初始化字体
  ThemeManager.initTheme();//初始化主题
}

//设置软件路径
Future setDefaultApplicationPath()async{
  if(GetPlatform.isWindows){
    AppLibrary.applicationPath = join(Directory.current.path,"Momotalk");
  }
  // else if(GetPlatform.isAndroid){
  //   AppLibrary.applicationPath = join((await getExternalStorageDirectory())!.path,"Momotalk");
  // }
  else {
    AppLibrary.applicationPath = join((await getApplicationDocumentsDirectory()).path,"Momotalk");
  }
}

//创建必要文件夹
Future createNecessaryDirctory()async{
  /*
  ChatTiles：聊天列表的项
  Message：所有消息记录
  User：用于存储DIY.json和Usually.json
  AICHAT:ai聊天
  PictureCache：图片储存地址
  DIYemotion：自定义差分存储
  MessageCature：PC截图保存
  Resouces:资源存储
  * */
  List dirs = ["ChatTiles","Messages","Users","AIChat","PictureCache","DIYemotion","MessageCature","Resources"];
  AppLibrary.customSenseiAvatar = File(join(AppLibrary.applicationPath,"Users","Sensei.png"));
  print(AppLibrary.customSenseiAvatar.existsSync());
  for (var dir in dirs) {
    Directory d = Directory(join(AppLibrary.applicationPath,dir));
    if(!d.existsSync()){
      await d.create(recursive: true);
      if(dir == "ChatTiles"){
        //创建默认
        File defaultjson = File(join(d.path,"ChatTilesGroups.json"));
        defaultjson.create();
        defaultjson.writeAsString("[{\"groupName\":\"默认分组\",\"chatTiles\":[]}]");
      }
      else if(dir == "Users"){
        File diyjson = File(join(d.path,"DIY.json"));
        diyjson.create();
        diyjson.writeAsString("[]");
        File usualJson = File(join(d.path,"Usually.json"));
        usualJson.create();
        usualJson.writeAsString("[]");
      }
      else if(dir=="Resources"){
        Directory(join(d.path,"Avatars")).create(recursive: true);
        Directory(join(d.path,"Emotions")).create(recursive: true);
      }
    }
  }
}


//初始化windows端的窗口信息
Future initWindowsConfig()async{
  if(!GetPlatform.isWindows) return;
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    minimumSize: Size(921, 486),//设置窗口的最小尺寸
    maximumSize: Size(1535, 810),//设置窗口的最大尺寸

    //window 设置窗口的初始尺寸
    size: Size(UserConfig.customWindowWidth, UserConfig.customWindowHeight),
    //窗口是否居中
    center: true,
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

//权限申请
Future requestAppPermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.notification,
    Permission.accessNotificationPolicy,
    Permission.scheduleExactAlarm,
    Permission.storage,
    Permission.photos,
    Permission.manageExternalStorage,
  ].request();
}


