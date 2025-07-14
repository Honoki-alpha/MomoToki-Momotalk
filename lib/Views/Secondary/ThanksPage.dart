import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Apis/Requests.dart';

class ThanksPage extends StatefulWidget {
  const ThanksPage({super.key});

  @override
  State<StatefulWidget> createState() => ThanksPageState();

}

class ThanksPageState extends State<ThanksPage>{
  List biliList = [];
  List afdList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  void initData()async{
    dynamic result = await Requests().request("https://gitee.com/honoki/momotoki/raw/master/public/thanks.json");
    biliList = result["bili"];
    afdList = result["afd"];
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("感谢名单"),),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(title: const Text("前往爱发电主页支持"),onTap: ()=>launchUrl(Uri.parse("https://afdian.com/a/honoki998"),mode:LaunchMode.platformDefault),),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: afdList.length,
              itemBuilder: (BuildContext context, int index) {
                return thanksItem(afdList[index]);
              },),
            ListTile(title: const Text("前往B站主页充电支持"),onTap: ()=>launchUrl(Uri.parse("https://space.bilibili.com/328113450"),mode:LaunchMode.platformDefault),),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: biliList.length,
              itemBuilder: (BuildContext context, int index) {
                return thanksItem(biliList[index]);
              },),
          ],
        ),
      ),
    );
  }

  Widget thanksItem(dynamic item){
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(item["avatar"]),),
      title: Text(item["name"]),
      onTap: item["link"]!=""?()async{
        final Uri url = Uri.parse("https://space.bilibili.com/328113450");
        if (!await launchUrl(url,mode:LaunchMode.platformDefault)) {
          BotToast.showText(text:"打开失败");
        }
      }:null,
    );
  }

}