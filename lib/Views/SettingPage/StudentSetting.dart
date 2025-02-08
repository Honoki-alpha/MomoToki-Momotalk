import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:flutter/material.dart';
import 'package:motoki/Dialog/InquireDialog.dart';
import 'package:motoki/Entity/EStudent.dart';
import 'package:motoki/Managers/StudentManager.dart';
import 'package:motoki/Utils/CommonComponents.dart';
import 'package:motoki/Views/Home/WindowHome.dart';
import 'package:motoki/Views/Secondary/SelectPage.dart';
import 'package:motoki/Views/SettingPage/StudentNickNameSetting.dart';
import 'package:path/path.dart';

import '../../Utils/CommonFunctions.dart';

class StudentSetting extends StatefulWidget{
  const StudentSetting({super.key});

  @override
  State<StatefulWidget> createState() => _seitoSet();

}

class _seitoSet extends State<StudentSetting>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getPlatformAppBar(const Text("学生设置")),
        body:ListView(
          children: [
            getSettingBorderBox([
              ListTile(
                title:const Text("显示学生姓氏"),
                trailing: Switch(
                  value: UserConfig.applyStudentFamilyName,
                  onChanged: (value){
                    UserConfig.sp.setBool("applyStudentFamilyName", value);
                    setState(() {
                      UserConfig.applyStudentFamilyName = value;
                    });
                  },
                ),
              ),
              ListTile(
                enabled: UserConfig.applyStudentFamilyName,
                title:const Text("姓名反转"),
                trailing: Switch(
                  value: UserConfig.applyNameReverse,
                  onChanged: (value){
                    if(!UserConfig.applyStudentFamilyName){
                      return;
                    }
                    UserConfig.sp.setBool("applyNameReverse", value);
                    setState(() {
                      UserConfig.applyNameReverse = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("学生名字语言"),
                trailing: DropdownButton(
                  value: UserConfig.studentNameLanguage,
                  items: const [
                    DropdownMenuItem(value:"cn",child: Text("中文")),
                    DropdownMenuItem(value:"kr",child: Text("한국어")),
                    DropdownMenuItem(value:"jp",child: Text("日本語")),
                    DropdownMenuItem(value:"en",child: Text("English")),
                    DropdownMenuItem(value:"tw",child: Text("繁體")),
                  ],
                  onChanged: (v) {
                    UserConfig.sp.setString("studentNameLanguage", v as String);
                    setState(() {
                      UserConfig.studentNameLanguage = v;
                    });
                  },

                ),
              ),
            ]),
            getSettingBorderBox([
              ListTile(
                title: const Text("学生备注"),
                trailing: const Icon(Icons.arrow_forward_ios_sharp),
                onTap: (){
                  if(AppLibrary.appLandscapeMode){
                    WindowHomeState.setLeftPage(const StudentNickNameSetting());
                  }else{
                    Get.to(()=>const StudentNickNameSetting(),transition: Transition.rightToLeftWithFade);
                  }
                },
              ),
              ListTile(title: const Text("设置老师头像"),onTap: setSenseiAvatar,),
              ListTile(title: const Text("自定义学生"),onTap: setCustomGreetStudent,),
              ListTile(title: const Text("自定义问候语"),onTap: setCustomGreetContent,),
            ]),
            getSettingBorderBox([
              ListTile(
                title: const Text("下载配置表(离线必须！)"),
                trailing: const Icon(Icons.arrow_forward_ios_sharp),
                onTap: downloadJson,
              ),
              ListTile(
                title: const Text("头像资源下载"),
                trailing: const Icon(Icons.arrow_forward_ios_sharp),
                onTap: downloadAvatar,
              ),
              ListTile(
                title: const Text("配置学生差分下载路径"),
                trailing: Text(UserConfig.faceSaveDirectory == ""?"未配置":"已配置",style: TextStyle(color: UserConfig.faceSaveDirectory == ""?Colors.red:Colors.blueAccent),),
                subtitle: const Text("配置路径后将会在相册显示"),
                onTap:selectFaceSaveDirectory
              ),
              ListTile(
                title: const Text("下载学生差分"),
                trailing: const Icon(Icons.arrow_forward_ios_sharp),
                onTap: downloadSingle,
              ),
              // ListTile(
              //   title: const Text("下载全部差分"),
              //   trailing: const Icon(Icons.arrow_forward_ios_sharp),
              //   onTap: downloadEmotion,
              // ),
            ])
          ],
        )
    );
  }

  void setCustomGreetStudent()async{
    EStudent? result = await Get.to(()=>const SelectPage());
    if(result == null) return;
    UserConfig.sp.setInt("customGreetStudent", result.id);
    UserConfig.customGreetStudent = result.id;
    BotToast.showText(text: "已成功将问候学生设置为${StudentManager.instance.getStudentName(result.id)}");
  }

  void setCustomGreetContent()async{
    print(UserConfig.customGreetContent);
    String? result = await Get.dialog(inputDialog());
    if(result == null) return;
    UserConfig.sp.setString("customGreetContent", result);
    UserConfig.customGreetContent = result;
    BotToast.showText(text: "已成功自定义问候语");
  }

  TextEditingController sc = TextEditingController();
  Widget inputDialog(){
    sc.text = UserConfig.customGreetContent??"";
    return AlertDialog(
      title: const Text("请输入自定义问候语"),
      content: TextField(
        controller: sc,
      ),
      actions: [
        TextButton(onPressed: (){
          Get.back(result:sc.text);
        }, child: const Text("保存")),
      ],
    );
  }

  void setSenseiAvatar()async{
    if(!AppLibrary.customSenseiAvatar.existsSync()){
      XFile? file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if(file == null){
        BotToast.showText(text: "设置头像失败");
        return;
      }
      String path = join(AppLibrary.applicationPath,"Users","Sensei.png");
      await file.saveTo(path);
      BotToast.showText(text: "设置头像成功");
    }else{
      var result = await Get.dialog(const Inquiredialog(title: "文件已存在", content: "自定义老师头像已存在，是否删除？"));
      if(result ?? false){
        await AppLibrary.customSenseiAvatar.delete();
        BotToast.showText(text: "删除成功");
      }
    }
  }

  void downloadJson()async{
    var dio = Dio();
    var cancel = BotToast.showLoading();
    await dio.download(
        "https://gitee.com/honoki/mtkresouce/raw/master/public/students.json",
        join(AppLibrary.applicationPath,"Resources","students.json"));
    await dio.download(
        "https://gitee.com/honoki/mtkresouce/raw/master/public/appDatas.json",
        join(AppLibrary.applicationPath,"Resources","appDatas.json"));
    cancel();
    BotToast.showText(text: "下载配置表完成");
  }

  void downloadAvatar()async{
    var request = await Get.dialog(const Inquiredialog(title: "警告", content: "下载本地会使软件占用空间增大，是否继续？"));
    if(request != true) return;
    var cencel = BotToast.showCustomLoading(toastBuilder: (b)=>defaultDialog());
    var dio = Dio();
    int i = 0;
    int length = StudentManager.instance.studentDirctory.length;
    //下载工具
    for(var item in StudentManager.instance.toolStudentDirctory.entries){
      EStudent student = item.value;
      await dio.download("https:${student.avatar}", join(AppLibrary.applicationPath,"Resources","Avatars","${student.id}_0.png"));
    }
    await dio.download("https://gitee.com/honoki/mtkresouce/raw/master/assets/images/icon/unkown.webp", join(AppLibrary.applicationPath,"Resources","Avatars","99_0.png"));
    //下载学生
    for(var item in StudentManager.instance.studentDirctory.entries){
      EStudent student = item.value;
      var skinIndex = 0;
      for(var skin in student.skinList){
        if(!mounted) return;
        File f = File(join(AppLibrary.applicationPath,"Resources","Avatars","${student.id}_$skinIndex.png"));
        if(f.existsSync()) continue;
        await dio.download("https:${skin["avatar"]}", f.path);
        skinIndex++;
        await Future.delayed(const Duration(milliseconds: 200));
      }
      progroessValue.value = i.toDouble()/length;
      i++;
    }
    cencel();
    progroessValue.value = 0.0;
    BotToast.showText(text: "下载完成");
  }

  void downloadSingle()async{
    if(AppLibrary.requestTimes > 12){
      BotToast.showText(text: "请求过于频繁，请等待30分钟后重启软件后再次下载");
      return;
    }
    EStudent? student = await Get.to(()=>const SelectPage(),transition: Transition.rightToLeftWithFade);
    if(student == null) return;
    var cancel = BotToast.showLoading();
    await downloadSingleEmotion(student);
    cancel();
    AppLibrary.requestTimes++;
    BotToast.showText(text: "下载完成");
  }

  Future downloadSingleEmotion(EStudent student)async{
    var dio = Dio();
    int fileIndex = 0;
    for(var gal in student.gallery){
      if(!mounted) return;
      for(var img in gal["images"]){
        await dio.download("https:$img", join(AppLibrary.faceBasePath,"Resources","Emotions","${student.id}","$fileIndex.png"));
        fileIndex++;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

  }

  void downloadEmotion()async{
    var request = await Get.dialog(const Inquiredialog(title: "警告", content: "下载本地会使软件占用空间增大，是否继续？"));
    if(request != true) return;
    var cencel = BotToast.showCustomLoading(toastBuilder: (b)=>defaultDialog());
    BotToast.showText(text: "若出现进度条卡顿，请使用单个学生下载");
    int i = 0;
    int length = StudentManager.instance.studentDirctory.length;
    for(var item in StudentManager.instance.studentDirctory.entries){
      EStudent student = item.value;
      await downloadSingleEmotion(student);
      progroessValue.value = i.toDouble()/length;
      i++;
    }
    cencel();
    progroessValue.value = 0.0;
    BotToast.showText(text: "下载完成");
  }

  RxDouble progroessValue = 0.0.obs;
  Widget defaultDialog(){
    return Container(
      height: 200,
      width: 240,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height:150,child: Image.asset("assets/images/source/loading.png",fit: BoxFit.fitHeight,),),
          SizedBox(
            width: 180,
            height: 5,
            child: Obx(()=>LinearProgressIndicator(
              //strokeWidth:8,
              value: progroessValue.value,
            )),
          ),
          const Text("\n正在下载资源，请勿退出该界面...")
        ],
      ),
    );
  }

  void selectFaceSaveDirectory()async{
    if(UserConfig.faceSaveDirectory != ""){
      bool? result = await Get.dialog(const Inquiredialog(title: "您已设置路径", content: "您已设置差分下载路径，是否清除后重新配置"));
      if(result == true){
        setState(() {
          UserConfig.faceSaveDirectory = "";
          UserConfig.sp.setString("faceSaveDirectory", "");
          AppLibrary.faceBasePath = AppLibrary.applicationPath;
        });
      }
      return;
    }
    var result = await FilePicker.platform.getDirectoryPath();
    if(result == null) return;
    setState(() {
      UserConfig.faceSaveDirectory = result;
      UserConfig.sp.setString("faceSaveDirectory", result);
      AppLibrary.faceBasePath = result;
    });
  }

}