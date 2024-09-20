import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path/path.dart';

import '../../AppData/AppLibrary.dart';
import '../../Components/MessageBox.dart';
import '../../Managers/MessageManager.dart';

class ScreenShotPage extends StatefulWidget{
  const ScreenShotPage({super.key, required this.startPointer, required this.endPointer});
  final int startPointer;
  final int endPointer;

  @override
  State<StatefulWidget> createState() => _screenShotPageState();

}

// ignore: camel_case_types
class _screenShotPageState extends State<ScreenShotPage>{
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
    loadingWidgets();
  }

  @override
  Widget build(BuildContext context) {
    pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  color: Colors.white,
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
    Timer(const Duration(milliseconds: 600), () {
      shotSave();
    });
  }

  void shotSave()async{
    var result = await screenshotController.capture();
    if(result == null)return;
    if(Platform.isWindows){
      File file = File(join(AppLibrary.applicationPath,"MessageCature","Momo_${DateTime.now().millisecond}${DateTime.now().microsecond}.png"));
      await file.writeAsBytes(result);
    }else{
      await ImageGallerySaver.saveImage(result,quality: 100);
    }
    Get.back();
  }


}