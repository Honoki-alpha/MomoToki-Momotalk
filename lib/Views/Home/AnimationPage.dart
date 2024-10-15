import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:universal_html/html.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import 'package:motoki/Views/Home/AndroidHome.dart';
import 'package:motoki/Views/Home/WindowHome.dart';

class AnimationPage extends StatefulWidget{
  const AnimationPage({super.key});

  @override
  State<StatefulWidget> createState() => _AnimationPageState();

}

class _AnimationPageState extends State<AnimationPage> with TickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
    if(Get.mediaQuery.platformBrightness == Brightness.dark) {
      UserConfig.themeIndex = 1;
      ThemeManager.isDarkTheme = true;
      ThemeManager.currentTheme = ThemeManager.darkTheme;
    }
    Timer(const Duration(milliseconds: 300), enterHomePage);

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        color: ThemeManager.currentTheme.appBarTheme.backgroundColor,
        alignment: Alignment.center,
        child:SizedBox(
          height: 300,
          width: 300,
          child: Image.asset("assets/images/icon/start_logo.png"),),
      ),
    );
  }


  void enterHomePage(){
    BotToast.showText(text: (UserConfig.sp.getInt("BackTaskTest") ?? 0).toString());
    Get.off(
        ()=>getHome(),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 600),
        curve: Curves.ease
    );
  }

  Widget getHome(){
    return OrientationBuilder(builder: (context,orientation){
      bool isWebPC = GetPlatform.isWeb && window.navigator.platform.toString().contains("Win");
      if( ( ( orientation == Orientation.landscape || GetPlatform.isDesktop ) &&
        UserConfig.applyLandscape ) || isWebPC){
        AppLibrary.appLandscapeMode = true;
        return const WindowHome();
      }else{
        AppLibrary.appLandscapeMode = false;
        return const AndroidHome();
      }
    });
  }

}