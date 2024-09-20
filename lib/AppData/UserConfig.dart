import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserConfig{
  static SharedPreferences? _sharedPreferences;
  //是否显示学生姓氏
  static bool applyStudentFamilyName = false;
  //是否显示为新UI风格
  static bool useMaterial3 = false;
  //是否开启横屏模式
  static bool applyLandscape = true;
  //是否开启夜间主题
  static bool applyDarkTheme = false;
  //AI对话KEY
  static String? aiChatKey;
  //聊天背景
  static Color chatBackGroundColor = Colors.white;
  //字体大小
  static int chatFontSize = 2;
  //学生名字语言
  static int studentNameLanguageIndex = 0;
  //头像尺寸
  static double avatarSize = 50;
  //自定义字体路径
  static String? customFont;
  //反转名字
  static bool applyNameReverse = false;

  Future<SharedPreferences> get sharedPreferences async {
    if (_sharedPreferences != null) return _sharedPreferences!;
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }

  Future initUserConfig()async{
    SharedPreferences sp = await sharedPreferences;
    applyNameReverse = sp.getBool("applyNameReverse") ?? false;
    customFont = sp.getString("customFont");
    avatarSize = sp.getDouble("avatarSize") ?? 50;
    studentNameLanguageIndex = sp.getInt("studentNameLanguageIndex") ?? 0;
    chatFontSize = sp.getInt("chatFontSize") ?? 2;
    applyStudentFamilyName = sp.getBool("applyStudentFamilyName") ?? false;
    useMaterial3 = sp.getBool("useMaterial3") ?? false;
    applyLandscape = sp.getBool("applyLandscape") ?? true;
    applyDarkTheme = sp.getBool("applyDarkTheme") ?? false;
    aiChatKey = sp.getString("aiChatKey");
  }

}