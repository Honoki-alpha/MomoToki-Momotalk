import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ThanksPage extends StatelessWidget {
  const ThanksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("感谢名单"),),
      backgroundColor:Color(0xFFE7F0F0) ,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(title: const Text("前往爱发电主页支持"),onTap: ()=>launchUrl(Uri.parse("https://afdian.com/a/honoki998"),mode:LaunchMode.platformDefault),),
            ListTile(title: const Text("前往B站主页充电支持"),onTap: ()=>launchUrl(Uri.parse("https://space.bilibili.com/328113450"),mode:LaunchMode.platformDefault),),
            Image.network("https://gitee.com/honoki/momotoki/raw/master/assets/images/thanks.webp",fit: BoxFit.fitWidth,)
          ],
        ),
      ),
    );
  }
}