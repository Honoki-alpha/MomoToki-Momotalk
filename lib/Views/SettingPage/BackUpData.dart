import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/Dialog/InquireDialog.dart';
import 'package:path/path.dart';

import '../../Entity/EChatTileGroup.dart';
import '../../Entity/EStudent.dart';
import '../../Managers/ChatGroupManager.dart';
import '../../Managers/StudentManager.dart';

class BackUpData extends StatefulWidget {
  const BackUpData({super.key});

  @override
  State<StatefulWidget> createState() => _BackUpDataState();
}

class _BackUpDataState extends State<BackUpData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("消息管理"),centerTitle: true,),
      body: ListView(
        children: [
          const Text("注意事项\n1.测试阶段可能存在BUG，请谨慎使用\n2.跨机型同步可能会造成图片信息丢失\n但其余消息将正常同步\n3.在同步前请确保软件获取存储权限",textAlign: TextAlign.center,),
          ListTile(title: const Text("消息导出"),trailing: const Icon(Icons.arrow_right),onTap: exportData,),
          ListTile(title: const Text("消息导入(覆盖)"),trailing: const Icon(Icons.arrow_right),onTap: importData,),
          ListTile(title: const Text("消息导入(不覆盖)"),trailing: const Icon(Icons.arrow_right),onTap: importDataAttend,),
        ],
      ),
    );
  }

  void exportData()async{
    String? result = await FilePicker.platform.getDirectoryPath(dialogTitle: "选择导出目录");
    if(result != null){
      Directory newDir = Directory(join(result,"Momotalk"));
      Directory oldDir = Directory(AppLibrary.applicationPath);
      var cancel = BotToast.showLoading();
      BotToast.showText(text: "开始导出消息...");
      await copyDirectory(oldDir,newDir);
      cancel();
    }
    BotToast.showText(text: "导出完成");

  }

  void importData()async{
    bool? sure = await Get.dialog(Inquiredialog(title: "警告", content: "导入消息会覆盖现有消息，是否继续？"));
    if(sure != true) return;
    String? result = await FilePicker.platform.getDirectoryPath(dialogTitle: "选择Momotalk文件夹所在目录");
    if(result == null) return;
    Directory oldDir = Directory(join(result,"Momotalk"));
    Directory newDir = Directory(AppLibrary.applicationPath);
    if(!oldDir.existsSync()){
      BotToast.showText(text: "所选目录下未有Momotalk文件夹，请重新选择");
      return;
    }
    BotToast.showText(text: "开始导入消息...");
    var cancel = BotToast.showLoading();
    await copyDirectory(oldDir, newDir);
    cancel();
    Get.dialog(Inquiredialog(title: "完成导入", content: "导入消息完成，聊天记录将于软件重启后生效"));
  }

  void importDataAttend()async{
    String? result = await FilePicker.platform.getDirectoryPath(dialogTitle: "选择Momotalk文件夹所在目录");
    if(result == null) return;
    var cancel = BotToast.showLoading();
    List<String> directCopyDirNames = ["AIChat","DIYemotion","Messages","PictureCache"];
    //Momotalk\ChatTiles\ChatTilesGroups.json和Momotalk\Users\DIY.json这两个文件需要合并
    for(String dirName in directCopyDirNames){
      Directory source = Directory(join(result,"Momotalk",dirName));
      Directory newDir = Directory(join(AppLibrary.applicationPath,dirName));
      await copyDirectory(source, newDir);
    }
    File chatTileGroupJson = File(join(result,"Momotalk","ChatTiles","ChatTilesGroups.json"));
    if(chatTileGroupJson.existsSync()){
      for(var chatGroup in json.decode(chatTileGroupJson.readAsStringSync())){
        ChatGroupManager.instance.chatTileGroups.add(EChatTileGroup.fromMap(chatGroup));
      }
    }
    await ChatGroupManager.instance.saveAsJson();
    File diyStudent = File(join(result,"Momotalk","Users","DIY.json"));
    for(var student in json.decode(diyStudent.readAsStringSync())){
      EStudent s = EStudent.fromMap(student);
      StudentManager.instance.diyStudentDirctory[s.id] = s;
    }
    await StudentManager.instance.saveDIYStudent();
    cancel();
  }

  Future<void> copyDirectory(Directory source, Directory destination)async{
    // 检查源目录是否存在
    if (!await source.exists()) {
      print("目录不存在：${source.path}");
      BotToast.showText(text: "源目录不存在！");
      return;
    }
    // 创建目标目录（如果不存在）
    await destination.create(recursive: true);
    // 获取源目录中的所有文件和子目录
    await for (var entity in source.list()) {
      if (entity is File) {
        // 如果是文件，复制到目标目录
        print(await entity.path);
        try{
          await entity.copy(join(destination.path,entity.uri.pathSegments.last));
        }catch(e){
          BotToast.showText(text: "文件同步失败:$e");
          return;
        }
      } else if (entity is Directory) {
        // 如果是目录，递归复制
        String lastPath = entity.uri.pathSegments[entity.uri.pathSegments.length-2];
        await copyDirectory(entity, Directory(join(destination.path,lastPath)));
      }
    }
  }
}