
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:motoki/Components/SettingIcon.dart';
import 'package:motoki/Managers/ChatGroups.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import 'package:motoki/Views/Home/WindowHome.dart';
import 'package:motoki/Views/Secondary/ThanksPage.dart';
import 'package:motoki/Views/SettingPage/AboutAppPage.dart';
import 'package:motoki/Views/SettingPage/AdView.dart';
import 'package:motoki/Views/SettingPage/BackUpData.dart';
import 'package:motoki/Views/SettingPage/DIYStudentSetting.dart';
import 'package:motoki/Views/SettingPage/StudentSetting.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';
import 'AppSetting.dart';

class Configure extends StatefulWidget{
  const Configure({super.key});

  @override
  State<StatefulWidget> createState() => _configureState();

}

class _configureState extends State<Configure>{
  late Size deviceSize;
  double configWidth = 0.0;
  RxDouble windowWidth = 1228.0.obs;
  RxDouble windowHeight = 648.0.obs;
  double containerHeight = 420;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(GetPlatform.isDesktop) getWindowsSize();
  }

  @override
  Widget build(BuildContext context) {
    //获取屏幕分辨率
    deviceSize =  MediaQuery.of(context).size;
    configWidth = AppLibrary.appLandscapeMode?(deviceSize.width * 0.42):deviceSize.width;
    return Container(
      alignment: Alignment.center,
      child:Stack(
        children: [
          Positioned(
            top: 0,
            child: SizedBox(
              width:configWidth,
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
              width: configWidth,
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
          Positioned.fill(
            top:170,
            child: Container(
              width: configWidth,
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
                    ListTile(title: const Text("感谢名单"),onTap: ()=>Get.to(()=>ThanksPage()),leading: const Icon(Icons.list),),
                    ListTile(title: Text(AppLibrary.adTitle),onTap:()=>Get.to(()=>AdView()),leading: const Icon(Icons.star),),
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
                    if(GetPlatform.isDesktop) const Text("PC端尺寸调整（高 * 宽）"),
                    if(GetPlatform.isDesktop) Row(
                      children: [
                        Expanded(
                          child: Obx(()=>Slider(
                            min: 486.0,
                            max: 810.0,
                            value: windowHeight.value.ceilToDouble(),
                            onChangeEnd: (value){
                              windowManager.setSize(Size(windowWidth.value, value),animate: true);
                            },
                            onChanged: (double value) {
                              windowHeight.value = value;
                              UserConfig.sp.setDouble("customWindowHeight",value);
                              containerHeight = value - 256;
                            },))),
                        Expanded(child: Obx(()=>Slider(
                          min: 921,
                          max: 1535,
                          value: windowWidth.value.ceilToDouble(),
                          onChanged: (value){
                            windowWidth.value = value;
                          },onChangeEnd: (value){
                          windowManager.setSize(Size(value,windowHeight.value),animate: true);
                          UserConfig.sp.setDouble("customWindowWidth",value);
                        },)))
                      ],
                    )
                  ],
                ),
              ),
            )
          ),
        ],
      )
    );
  }

  void getWindowsSize()async{
    Size s = await windowManager.getSize();
    windowWidth.value = min(max(s.width, 921 ), 1535);
    windowHeight.value = min(max(s.height,486), 810);
    setState(() {
      containerHeight = s.height - 256;
    });
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