import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:motoki/AppData/AppConstant.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/AppData/InitWebApp.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:motoki/Managers/NotificationManager.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import 'package:motoki/Views/Home/AnimationPage.dart';
import 'package:get/get.dart' hide Response;
import 'package:workmanager/workmanager.dart';
import 'AppData/InitApplication.dart';


@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async{
    DateTime dt = DateTime.now();
    if(dt.hour < 7 || dt.hour > 8 || !GetPlatform.isAndroid) return Future.value(true);
    String month = dt.month.toString().padLeft(2,"0");
    String day = dt.day.toString().padLeft(2,"0");
    List birthdayStudent = [];
    if(AppConstant.birthday.containsKey(month) && AppConstant.birthday[month]!.containsKey(day)){
      birthdayStudent = AppConstant.birthday[month]![day]!;
      NotificationInstance.sendNotification("生日通知",
          "老师，今天是${birthdayStudent.join("和")}的生日哦，别忘了陪她度过");
    }
    String randomMonth = (Random().nextInt(12) + 1).toString().padLeft(2,"0");
    List randomList = AppLibrary.randGetFromList(AppConstant.birthday[randomMonth]!.values.toList());
    String randomStudent = AppLibrary.randGetFromList(randomList);
    NotificationInstance.sendNotification("来自：$randomStudent", "早上好，老师！${UserConfig.appFontSize}");
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );
  Workmanager().registerPeriodicTask(
      "motoki", "greet",frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      )
  );


  if(GetPlatform.isWeb){
    await initWebApp();
  }else{
    await initApplication();
  }


  runApp(ClipRRect(
    borderRadius: GetPlatform.isDesktop?BorderRadius.circular(12):BorderRadius.circular(0),
    clipBehavior: Clip.antiAlias,
    child: GetMaterialApp(
        darkTheme: ThemeManager.darkTheme,
        home:const AnimationPage(),
        debugShowCheckedModeBanner: false,
        title: "MomoTalk",
        builder: BotToastInit(),
        initialRoute: "/",
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
        theme: ThemeManager.getThemeData(UserConfig.themeIndex)),
  ));
}

