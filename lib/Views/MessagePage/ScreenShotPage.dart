import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path/path.dart';
import '../../AppData/AppLibrary.dart';
import '../../AppData/UserConfig.dart';
import '../../Components/MessageBox.dart';
import '../../Managers/MessageManager.dart';
import '../../Managers/ThemeManager.dart';

class ScreenShotPage extends StatefulWidget{
  const ScreenShotPage({super.key, required this.x,required this.delayTime,required this.command, this.start,this.length, });
  final int x;//一共截图X次
  final int delayTime;//每多少秒截取一次
  final String command;//怎么截图
  final int? start;//开始的截图点
  final int? length;//截图多长


  @override
  State<StatefulWidget> createState() => ScreenShotPageState();

}

// ignore: camel_case_types
class ScreenShotPageState extends State<ScreenShotPage>{
  List currentList = [];//当前展示的messages

  //消息列表
  double pixelRatio = 1.5;

  //截图组件Controller
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // showList = MessageManager.instance.messages.sublist(widget.startPointer,widget.endPointer);
    initCommand();
  }

  @override
  void deactivate(){
    super.deactivate();
    //
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top,SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("截图界面")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  color: ThemeManager.isDarkTheme || UserConfig.denpendTheme?ThemeManager.currentTheme.cardColor:UserConfig.chatBackGroundColor,
                  child: ListView.builder(
                    key: ValueKey(currentList),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: currentList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return MessageBox(index: index, isPlayMode: false,tempBox: currentList[index],);
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void initCommand()async{
    //如果命令为截图全部就直接截图
    int start = widget.start ?? 0;
    switch(widget.command){
      case "whole":
        shotOnce(MessageManager.instance.messages);
        break;
      case "after":
        shotOnce(MessageManager.instance.messages.sublist(start,min(start + widget.x, MessageManager.instance.messages.length)));
        break;
      default:
        int m = 0;//m是当前的起始点
        while(m < MessageManager.instance.messages.length){
          await shotOnce(MessageManager.instance.messages.sublist(m,min(m+widget.x, MessageManager.instance.messages.length)));
          m = m + widget.x;
        }
        BotToast.showText(text: "截图完成，可返回上一级界面");
        break;
    }
  }

  Future shotOnce(List target)async{
    if(!mounted){
      return;
    }
    setState(() {
      currentList = target;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    await shotSave();
  }


  Future shotSave()async{
    pixelRatio = PlatformDispatcher.instance.views.elementAt(0).devicePixelRatio;
    var result = await screenshotController.capture(pixelRatio: pixelRatio*2);
    if(result == null)return;
    if(Platform.isWindows){
      File file = File(join(AppLibrary.applicationPath,"MessageCature","Momo_${DateTime.now().millisecond}${DateTime.now().microsecond}.png"));
      var cancel = BotToast.showLoading();
      await file.writeAsBytes(result);
      cancel();
    }else{
      var cancel = BotToast.showLoading();
      await ImageGallerySaver.saveImage(result);
      cancel();
    }
  }
}