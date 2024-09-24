import 'package:flutter/material.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/AppData/UserConfig.dart';

class ThemeManager{

  static late ThemeData currentTheme;

  static late ThemeData momoTheme;
  static late ThemeData darkTheme;
  static late ThemeData blueTheme;
  static bool isDarkTheme = true;


  static initTheme(){
    momoTheme = ThemeData(
      brightness: Brightness.light,
      fontFamily: AppLibrary.appFontSource,
      useMaterial3: true,
      cardColor:Colors.white,
      canvasColor: Colors.white,
      colorSchemeSeed: const Color(0xFFF48FB1),
      highlightColor: const Color(0xFFFFBBFF),
      appBarTheme: const AppBarTheme(
        color: Color(0xFFff89a1),
        titleTextStyle: TextStyle(fontSize: 20,color: Colors.white,fontFamily:"ResourceHanCN")
      )
    );
    darkTheme = ThemeData(
        brightness: Brightness.dark,
        fontFamily: AppLibrary.appFontSource,
        useMaterial3: true,
        cardColor: Colors.black12,
        colorSchemeSeed: Colors.black12,
        highlightColor: Colors.white38,
        canvasColor: Colors.grey,
        appBarTheme: const AppBarTheme(
            color: Colors.black45,
            titleTextStyle: TextStyle(fontSize: 20,color: Colors.grey,fontFamily:"ResourceHanCN")
        )
    );
    blueTheme = ThemeData(
        brightness: Brightness.light,
        fontFamily: AppLibrary.appFontSource,
        useMaterial3: true,
        cardColor:Colors.white,
        colorSchemeSeed: const Color(0xFF87CEFA),
        canvasColor: Colors.white,
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(

          )
        ),
        highlightColor: Colors.blue,
        appBarTheme: const AppBarTheme(
            color: Color(0xFF00BFFF),
            titleTextStyle: TextStyle(fontSize: 20,color: Colors.white,fontFamily:"ResourceHanCN")
        )
    );

    currentTheme = getThemeData(UserConfig.themeIndex);
    isDarkTheme = UserConfig.themeIndex == 1;
  }

  static ThemeData getThemeData(int index){
    switch(index){
      case 0: return momoTheme;
      case 1: return darkTheme;
      case 2: return blueTheme;
      default: return momoTheme;
    }
  }
}