import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import 'package:motoki/Views/Home/AnimationPage.dart';
import 'package:get/get.dart' hide Response;
import 'AppData/InitApplication.dart';

///
/// 程序的主入口
///
/// initApplication 为初始化软件的数据
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initApplication();
  runApp(const MomoToki());
}

class MomoToki extends StatefulWidget{
  const MomoToki({super.key});

  @override
  State<StatefulWidget> createState() => _MomoTokiState();

}

class _MomoTokiState extends State<MomoToki>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build;
    return ClipRRect(
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
    );
  }

}