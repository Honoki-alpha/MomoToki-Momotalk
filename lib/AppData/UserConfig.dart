import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserConfig{
  static late SharedPreferences sp;
  //是否显示学生姓氏
  static bool applyStudentFamilyName = false;
  //是否开启横屏模式
  static bool applyLandscape = true;
  //是否开启夜间主题
  static int themeIndex = 0;
  //AI对话KEY
  static String? aiChatKey;
  //聊天背景
  static bool denpendTheme = true;
  static Color chatBackGroundColor = Colors.white;
  //自定义主题
  static Color customAppThemeColor = Colors.purpleAccent;
  //学生名字语言
  static String studentNameLanguage = "";
  //自定义字体路径
  static String customFont = "";
  //反转名字
  static bool applyNameReverse = false;
  //软件尺寸
  static double appDesktopSize = 1.0;
  //离线模式
  static bool applyOfflineMode = false;
  //字体大小
  static double appFontSize = 0.0;


  Future initUserConfig()async{
    sp = await SharedPreferences.getInstance();
    applyNameReverse = sp.getBool("applyNameReverse") ?? false;
    customFont = sp.getString("customFont")??"";
    studentNameLanguage = sp.getString("studentNameLanguage") ?? "cn";
    applyStudentFamilyName = sp.getBool("applyStudentFamilyName") ?? false;
    applyLandscape = sp.getBool("applyLandscape") ?? true;
    themeIndex = sp.getInt("themeIndex") ?? 0;
    aiChatKey = sp.getString("aiChatKey");
    denpendTheme = sp.getBool("denpendTheme")??true;
    applyOfflineMode = sp.getBool("applyOfflineMode")??false;
    appDesktopSize = sp.getDouble("appDesktopSize") ?? 1.0;
    appFontSize = sp.getDouble("appFontSize") ?? 0.0;
    List<String> colors = sp.getStringList("chatBackGroundColor") ?? ["255","255","255"];
    chatBackGroundColor = Color.fromRGBO(int.parse(colors[0]), int.parse(colors[1]), int.parse(colors[2]), 1);
    List<String> ccolors = sp.getStringList("customAppThemeColor") ?? ["255","255","255"];
    customAppThemeColor = Color.fromRGBO(int.parse(ccolors[0]), int.parse(ccolors[1]), int.parse(ccolors[2]), 1);
  }
}