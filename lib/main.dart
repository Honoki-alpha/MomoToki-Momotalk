import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/views/Home/AndroidHome.dart';
import 'package:get/get.dart';
import 'AppData/InitApplication.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApplication();

  runApp(ClipRRect(
    borderRadius: GetPlatform.isDesktop?BorderRadius.circular(12):BorderRadius.circular(0),
    clipBehavior: Clip.antiAlias,
    child: GetMaterialApp(
        home:OrientationBuilder(builder: (context,orientation){
          // if((GetPlatform.isDesktop || orientation == Orientation.landscape)){
          //   AppLibrary.appLandscapeMode = true;
          //   //return const WindowsHome();
          // }else{
          //
          // }
          AppLibrary.appLandscapeMode = false;
          return AndroidHome();
        },),
        debugShowCheckedModeBanner: false,
        title: "MomoTalk",
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],
        theme: ThemeData(
          //颜色色调
            brightness: Brightness.light,
            fontFamily: "ResourceHanCN",
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFFF48FB1),
            appBarTheme: const AppBarTheme(color: const Color(0xFFF48FB1),titleTextStyle: const TextStyle(fontSize: 20,color: Colors.white,fontFamily:"ResourceHanCN"))
        )),
  ));
}

