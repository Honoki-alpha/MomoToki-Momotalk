
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import 'package:motoki/Views/Home/WindowHome.dart';
import 'package:motoki/Views/SettingPage/AboutAppPage.dart';
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
              top:AppLibrary.appLandscapeMode?deviceSize.height*0.4-30:deviceSize.height*0.3-30,
            child: const Text("   软件作者：BiliBili-星時Honoki")),
          Positioned(
            top:AppLibrary.appLandscapeMode?deviceSize.height*0.4:deviceSize.height*0.3,
            child: Container(
              width: AppLibrary.appLandscapeMode?(MediaQuery.of(context).size.width * 5 / 11):MediaQuery.of(context).size.width,
              height: 600,
              decoration: BoxDecoration(
                color: ThemeManager.currentTheme.cardColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(25),topRight: Radius.circular(25))
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ListTile(title: const Text("自定义学生"),leading: const Icon(Icons.assignment_ind_sharp),onTap:(){
                    if(AppLibrary.appLandscapeMode){
                      WindowHomeState.setLeftPage(const DIYStudentSetting());
                    }else{
                      Get.to(()=>const DIYStudentSetting(),transition: Transition.rightToLeftWithFade);
                    }
                  }),
                  const Divider(indent: 10,endIndent: 10,),
                  ListTile(title: const Text("加入群聊"),leading: const Icon(Icons.group),onTap: ()async{
                    final Uri url = Uri.parse("http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=3GuV5A0V_f3Eu97RWurn2zN_cn2nMK01&authKey=6FB%2Bbtk53oZASsA9pMMYXlsIRxRkMzlzHqCjnsckRZiYCV1%2FODT28GXx5FmK80yq&noverify=0&group_code=671122437");
                    if (!await launchUrl(url,mode:LaunchMode.platformDefault)) {
                      BotToast.showText(text:"打开失败");
                    }
                    Get.defaultDialog(title: "或通过二维码加入",content: Image.asset("assets/images/source/GroupQRcode.png",width: 300,fit: BoxFit.fitWidth));
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
            )
          ),
        ],
      )
    );
  }


}