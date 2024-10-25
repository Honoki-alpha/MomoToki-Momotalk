import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:motoki/Utils/EventBus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path/path.dart';
import '../../AppData/AppLibrary.dart';
import '../../Components/MessageBox.dart';
import '../../Managers/MessageManager.dart';
import '../../Managers/ThemeManager.dart';

class ScreenShotPage extends StatefulWidget{
  const ScreenShotPage({super.key, required this.startPointer, required this.endPointer});
  final int startPointer;
  final int endPointer;

  @override
  State<StatefulWidget> createState() => ScreenShotPageState();

}

// ignore: camel_case_types
class ScreenShotPageState extends State<ScreenShotPage>{
  //消息列表
  late final List showList;
  late final Widget captureWidget;
  double pixelRatio = 1.5;

  //截图组件Controller
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //pagePixelRatio = PlatformDispatcher.instance.views.elementAt(0).devicePixelRatio;
    showList = MessageManager.instance.messages.sublist(widget.startPointer,widget.endPointer);
    if(!AppLibrary.appLandscapeMode) {
      loadingWidgets();
    }else{
      AppLibrary.globalEvent.on<ScreenShotEvent>().listen((screenShotEvent)=>loadingWidgets());
      loadingWidgets();
    }
  }

  @override
  void deactivate(){
    super.deactivate();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top,SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  color: ThemeManager.currentTheme.cardColor,
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: showList.asMap().entries.map<Widget>((item){
                      return MessageBox(index: widget.startPointer + item.key, isPlayMode: false);
                    }).toList(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }


  void loadingWidgets(){
    Timer(const Duration(milliseconds: 800), () {
      shotSave();
    });
  }

  void shotSave()async{
    var result = await screenshotController.capture(pixelRatio: 4.0);
    if(result == null)return;
    if(Platform.isWindows){
      File file = File(join(AppLibrary.applicationPath,"MessageCature","Momo_${DateTime.now().millisecond}${DateTime.now().microsecond}.png"));
      var cancel = BotToast.showLoading();
      await file.writeAsBytes(result);
      cancel();
    }else{
      var cancel = BotToast.showLoading();
      await ImageGallerySaver.saveImage(result,quality: 100);
      cancel();
    }
    if(!AppLibrary.appLandscapeMode) Get.back();
  }


}