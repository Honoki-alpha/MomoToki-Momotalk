import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import 'package:motoki/Views/Home/AnimationPage.dart';
import 'package:get/get.dart' hide Response;
import 'AppData/InitApplication.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initApplication();

  runApp(ClipRRect(
    borderRadius: GetPlatform.isDesktop?BorderRadius.circular(12):BorderRadius.circular(0),
    clipBehavior: Clip.antiAlias,
    child: GetMaterialApp(
      darkTheme: ThemeManager.darkTheme,
      themeMode: ThemeMode.light,
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

