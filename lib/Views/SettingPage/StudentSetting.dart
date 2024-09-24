import 'package:get/get.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:flutter/material.dart';
import 'package:motoki/Utils/CommonComponents.dart';
import 'package:motoki/Views/Home/WindowHome.dart';
import 'package:motoki/Views/SettingPage/StudentNickNameSetting.dart';

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
            ])
          ],
        )
    );
  }
}