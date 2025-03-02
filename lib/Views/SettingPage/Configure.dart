
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/Components/SettingIcon.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import 'package:motoki/Views/Home/WindowHome.dart';
import 'package:motoki/Views/SettingPage/AboutAppPage.dart';
import 'package:motoki/Views/SettingPage/BackUpData.dart';
import 'package:motoki/Views/SettingPage/DIYStudentSetting.dart';
import 'package:motoki/Views/SettingPage/StudentSetting.dart';
import 'package:url_launcher/url_launcher.dart';
import 'AppSetting.dart';

class Configure extends StatefulWidget{
  const Configure({super.key});

  @override
  State<StatefulWidget> createState() => _configureState();

}

class _configureState extends State<Configure>{
  late Size deviceSize;
  @override
  Widget build(BuildContext context) {
    //获取屏幕分辨率
    deviceSize =  MediaQuery.of(context).size;

    return Container(
      alignment: Alignment.center,
      child:Stack(
        children: [
          Positioned(
            top: 0,
            child: SizedBox(
              width:AppLibrary.appLandscapeMode?(deviceSize.width * 0.46):deviceSize.width,
              child: Opacity(
                opacity:ThemeManager.isDarkTheme?0.5:1.0,
                child: Image.asset(
                  "assets/images/icon/banner.jpg",
                  fit: BoxFit.fitWidth,
                ),
              ),
            )),
          Positioned(
            top:100,
            child: SizedBox(
              width: deviceSize.width,
              child: ListTileTheme(
                data: ListTileThemeData(
                  minTileHeight: 60
                ),
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage("https://gitee.com/honoki/momotoki/raw/master/assets/images/avatar.jpg"),),
                  title: const Text("星時Honoki"),
                  subtitle:const Text("MomoToki软件作者"),
                  onTap: ()async{
                    final Uri url = Uri.parse("https://space.bilibili.com/328113450");
                    if (!await launchUrl(url,mode:LaunchMode.platformDefault)) {
                      BotToast.showText(text:"打开失败");
                    }
                  },
                  trailing:const Text("空间ᐅ"),
              )),)),
          Positioned(
            top:170,
            child: Container(
              width: AppLibrary.appLandscapeMode?(MediaQuery.of(context).size.width * 5 / 11):MediaQuery.of(context).size.width,
              height: 600,
              decoration: BoxDecoration(
                color: ThemeManager.currentTheme.cardColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(25),topRight: Radius.circular(25))
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(title: const Text("自定义学生/角色"),leading: const Icon(Icons.assignment_ind_sharp),onTap:(){
                      if(AppLibrary.appLandscapeMode){
                        WindowHomeState.setLeftPage(const DIYStudentSetting());
                      }else{
                        Get.to(()=>const DIYStudentSetting(),transition: Transition.rightToLeftWithFade);
                      }
                    }),
                    ListTile(title: const Text("消息管理(测试)"),leading: const Icon(Icons.chat_bubble),onTap: ()=>Get.to(()=>BackUpData()),),
                    const Divider(indent: 10,endIndent: 10,),
                    ListTile(title: const Text("软件教程"),leading: const Icon(Icons.book),onTap: ()async{
                      final Uri url = Uri.parse("https://www.yuque.com/unfriendly/cetwzc/ceaeblm4h7g9nmxk");
                      if (!await launchUrl(url,mode:LaunchMode.platformDefault)) {
                        BotToast.showText(text:"打开失败");
                      }
                      //Get.defaultDialog(title: "或通过二维码加入",content: Image.asset("assets/images/source/GroupQRcode.png",width: 300,fit: BoxFit.fitWidth));
                    }),
                    ListTile(title: const Text("关于软件"),leading:const Icon(Icons.apps),onTap: (){
                      if(AppLibrary.appLandscapeMode){
                        WindowHomeState.setLeftPage(const AboutAppPage());
                      }else{
                        Get.to(()=>const AboutAppPage(),transition: Transition.rightToLeftWithFade);
                      }
                    },),
                    ListTile(title: const Text("学生设置"),leading:const Icon(Icons.person_pin),onTap: (){
                      if(AppLibrary.appLandscapeMode){
                        WindowHomeState.setLeftPage(const StudentSetting());
                      }else{
                        Get.to(()=>const StudentSetting(),transition: Transition.rightToLeftWithFade);
                      }
                    }),
                    ListTile(title: const Text("软件设置"),leading:const Icon(Icons.settings),onTap: ()async{
                      if(AppLibrary.appLandscapeMode){
                        WindowHomeState.setLeftPage(const AppSetting());
                      }else{
                        await Get.to(()=>const AppSetting(),transition: Transition.rightToLeftWithFade);
                        setState(() {});
                      }
                    }),
                  ],
                ),
              ),
            )
          ),
        ],
      )
    );
  }

  Widget old(){
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ListTile(title: const Text("自定义学生/角色"),leading: const Icon(Icons.assignment_ind_sharp),onTap:(){
          if(AppLibrary.appLandscapeMode){
            WindowHomeState.setLeftPage(const DIYStudentSetting());
          }else{
            Get.to(()=>const DIYStudentSetting(),transition: Transition.rightToLeftWithFade);
          }
        }),
        const Divider(indent: 10,endIndent: 10,),
        ListTile(title: const Text("软件教程"),leading: const Icon(Icons.book),onTap: ()async{
          final Uri url = Uri.parse("https://www.yuque.com/unfriendly/cetwzc/ceaeblm4h7g9nmxk");
          if (!await launchUrl(url,mode:LaunchMode.platformDefault)) {
            BotToast.showText(text:"打开失败");
          }
          //Get.defaultDialog(title: "或通过二维码加入",content: Image.asset("assets/images/source/GroupQRcode.png",width: 300,fit: BoxFit.fitWidth));
        }),
        ListTile(title: const Text("关于软件"),leading:const Icon(Icons.apps),onTap: (){
          if(AppLibrary.appLandscapeMode){
            WindowHomeState.setLeftPage(const AboutAppPage());
          }else{
            Get.to(()=>const AboutAppPage(),transition: Transition.rightToLeftWithFade);
          }
        },),
        ListTile(title: const Text("学生设置"),leading:const Icon(Icons.person_pin),onTap: (){
          if(AppLibrary.appLandscapeMode){
            WindowHomeState.setLeftPage(const StudentSetting());
          }else{
            Get.to(()=>const StudentSetting(),transition: Transition.rightToLeftWithFade);
          }
        }),
        ListTile(title: const Text("软件设置"),leading:const Icon(Icons.settings),onTap: ()async{
          if(AppLibrary.appLandscapeMode){
            WindowHomeState.setLeftPage(const AppSetting());
          }else{
            await Get.to(()=>const AppSetting(),transition: Transition.rightToLeftWithFade);
            setState(() {});
          }
        }),
      ],
    );
  }

}