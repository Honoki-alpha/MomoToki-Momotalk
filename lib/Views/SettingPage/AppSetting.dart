import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:motoki/Dialog/InquireDialog.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import 'package:motoki/Utils/CommonComponents.dart';
import 'package:path/path.dart';

import '../../AppData/AppLibrary.dart';

class AppSetting extends StatefulWidget{
  const AppSetting({super.key});

  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<AppSetting>{
  var pickerColor = const Color(0xff443a49).obs;
  RxDouble size = 0.5.obs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(!UserConfig.denpendTheme) pickerColor.value=UserConfig.chatBackGroundColor;
    size.value = UserConfig.appDesktopSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getPlatformAppBar(const Text("软件设置")),
        body: Column(
          children: [
            Expanded(child:
              ListView(
                children: [
                  getSettingBorderBox([
                    ListTile(
                    title: const Text("主题模式"),
                    trailing: DropdownButton(
                      value: UserConfig.themeIndex,
                      items: const [
                        DropdownMenuItem(value:0,child: Text("MomoTalk")),
                        DropdownMenuItem(value:1,child: Text("夜间主题")),
                        DropdownMenuItem(value:2,child: Text("BlueArchive")),
                      ],
                      onChanged:dayOrNightChange,
                    ),
                  ),
                    if(GetPlatform.isMobile) ListTile(
                      title:const Text("什亭之匣"),
                      trailing: Switch(
                        value: UserConfig.applyLandscape,
                        onChanged: (value){
                          UserConfig.sp.setBool("applyLandscape", value);
                          setState(() {
                            UserConfig.applyLandscape = value;
                          });
                        },
                      ),
                    ),]),
                  getSettingBorderBox([
                    ListTile(title: const Text("背景跟随主题"),trailing:Switch(
                      value: UserConfig.denpendTheme,
                      onChanged: (value){
                        UserConfig.sp.setBool("denpendTheme", value);
                        setState(() {
                          UserConfig.denpendTheme = value;
                        });
                      },
                    ),),
                    ListTile(
                      enabled: !UserConfig.denpendTheme,
                      title: const Text("聊天背景颜色"),
                      onTap: setPageBackGroundColor,
                      trailing: !UserConfig.denpendTheme?Container(color:pickerColor.value,height: 10,width: 10,):null,
                    ),
                    ListTile(title: const Text("软件字体"),onTap: setCustomFont,trailing: Text(UserConfig.customFont == ""?"未配置":"已配置"),),
                    ListTile(
                      title: const Text("AI聊天KEY", style: TextStyle(color: Colors.blue),),
                        trailing: Text(UserConfig.aiChatKey==null?"未配置":"已配置", style: TextStyle(color:UserConfig.aiChatKey==null?Colors.red:Colors.blue)),
                        onTap: setAIChatKey),]),
                ],
              )
            )
          ],
        )
    );
  }

  void dayOrNightChange(int? value){
    if(value == null) return;
    UserConfig.sp.setInt("themeIndex", value);
    ThemeData tD = ThemeManager.getThemeData(value);
    Get.changeTheme(tD);
    ThemeManager.isDarkTheme = value == 1;
    ThemeManager.currentTheme = tD;
    setState(() {
      UserConfig.themeIndex = value;
    });
  }

  void setCustomFont()async{
    if(UserConfig.customFont == ""){
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['ttf']
      );
      if(result == null) return;
      File file = File(join(AppLibrary.applicationPath,"Users","CustomFont.ttf"));
      var cancel = BotToast.showLoading();
      await file.writeAsBytes(result.files.single.bytes as List<int>);
      cancel();
      UserConfig.customFont = file.path;
      UserConfig.sp.setString("customFont", file.path);
      BotToast.showText(text: "设置成功，重启后生效");
    }else{
      bool result = await Get.dialog(const Inquiredialog(title: "已设置字体",content: "老师您已设置字体，是否清除当前设置"));
      UserConfig.customFont = "";
      if(result) UserConfig.sp.setString("customFont", "");
    }
    setState(() {});
  }


  void setPageBackGroundColor()async{
    await Get.defaultDialog(content: Obx(()=>ColorPicker(pickerColor: pickerColor.value, onColorChanged: (Color value) {
      setState(() {
        pickerColor.value=value;
      });
    },)));
    UserConfig.chatBackGroundColor = pickerColor.value;
  }

  void setAIChatKey()async{
    var result = await Get.dialog(inputDialog());
    if(result == null) return;
    UserConfig.sp.setString("aiChatKey", result);
    setState(() {
      UserConfig.aiChatKey = result;
    });
  }

  TextEditingController sc = TextEditingController();
  Widget inputDialog(){
    sc.text = UserConfig.aiChatKey??"";
    return AlertDialog(
      title: const Text("请输入API Key"),
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



}
