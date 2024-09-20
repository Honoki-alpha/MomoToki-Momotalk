import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/Views/SettingPage/DIYStudentSetting.dart';

class Configure extends StatefulWidget{
  const Configure({super.key});

  @override
  State<StatefulWidget> createState() => _configureState();

}

class _configureState extends State<Configure>{

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Expanded(child: ListView(
            children: [
              const ListTile(
                  leading:CircleAvatar(
                      backgroundImage: NetworkImage("https://gitee.com/honoki/mtkresouce/raw/master/assets/images/avatar.jpg")),
                    title: Text("软件作者"),
                    subtitle: Text("哔哩哔哩@星時Honoki")),

              //生日学生

              const SizedBox(height: 20,),
              ListTile(title: const Text("自定义学生"),leading: const Icon(Icons.edit),onTap:(){
                Get.to(()=>const DIYStudentSetting(),transition: Transition.rightToLeftWithFade);
              }),
              const SizedBox(height: 20,),
              ListTile(title: const Text("关于软件"),leading:const Icon(Icons.apps),onTap: (){},),
              ListTile(title: const Text("学生设置"),leading:const Icon(Icons.assignment_ind),onTap: (){}),
              ListTile(title: const Text("软件设置"),leading:const Icon(Icons.settings),onTap: (){}),
            ],
          )),
        ],
      )
    );
  }

}