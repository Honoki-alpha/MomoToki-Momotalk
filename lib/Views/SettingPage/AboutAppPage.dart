import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/AppData/InitApplication.dart';
import 'package:motoki/Utils/CommonComponents.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Utils/CommonFunctions.dart';

class AboutAppPage extends StatelessWidget{
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:getPlatformAppBar(const Text("关于软件")),
      body: ListView(
        children: [
          getSettingBorderBox([
            ListTile(title: const Text("软件教程"),trailing: const Icon(Icons.help),onTap: ()async{
              final Uri url = Uri.parse("https://www.yuque.com/unfriendly/cetwzc/ceaeblm4h7g9nmxk");
              if (!await launchUrl(url,mode:LaunchMode.platformDefault)) {
                BotToast.showText(text:"打开失败");
              }
            },),
            ListTile(title: const Text("当前版本"),trailing: Text(AppLibrary.appVersion),),
            const ListTile(title: Text("检查更新"),trailing: Icon(Icons.arrow_forward_ios),onTap: getLastVersion),
            ListTile(title: const Text("重载资源文件"),trailing: const Icon(Icons.arrow_forward_ios),onTap: ()async{
              await loadStudentInfoFromNet();
            }),
          ])
        ],
      ),
    );
  }

}
