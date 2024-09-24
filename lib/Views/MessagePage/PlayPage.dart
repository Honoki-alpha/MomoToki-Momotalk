import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../Components/MessageBox.dart';
import '../../Managers/MessageManager.dart';
import '../../Managers/ThemeManager.dart';

class PlayPage extends StatefulWidget{
  const PlayPage({super.key, required this.startPointer, required this.endPointer});
  final int startPointer;
  final int endPointer;

  @override
  State<StatefulWidget> createState() => _playPageState();

}

class _playPageState extends State<PlayPage>{
  List messageList = [];//消息盒子全部
  List waitToPlayList = [];//正在播放的消息盒子
  ScrollController sc = ScrollController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messageList = List.of(MessageManager.instance.messages.sublist(widget.startPointer,widget.endPointer+1));
    startPlay();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Container(
            color: ThemeManager.currentTheme.cardColor,
            alignment: Alignment.topCenter,
            child: ListView.builder(
              //reverse: true,
              controller: sc,
              shrinkWrap: true,
              itemCount: waitToPlayList.length,
              itemBuilder: (BuildContext context,int index){
                return MessageBox(index: index, isPlayMode: true,tempBox: waitToPlayList[index]);
              },
            ),)),
          const SizedBox(height: 40)
        ],
      ),
    );
  }

  void startPlay()async{
    for(var mesBox in messageList){
      List mbList = List.from(mesBox["messageContentList"].toList());
      mesBox["messageContentList"] = mesBox["messageContentList"].sublist(0,1);
      if(mounted){
        setState(() {
          waitToPlayList.add(mesBox);
        });
      }
      int frequency = 0;
      await Future.delayed(const Duration(milliseconds: 2000));
      for(var mes in mbList){
        if(frequency == 0) {
          frequency++;
          continue;
        }
        if(mounted){
          setState(() {
            waitToPlayList.last["messageContentList"].add(mes);
          });
        }
        toBottom();
        await Future.delayed(const Duration(milliseconds: 2000));
      }
      toBottom();
    }
  }

  void toBottom(){
    Timer.periodic(const Duration(milliseconds: 100), (t){
      if(mounted){
        sc.jumpTo(sc.position.maxScrollExtent);
      }
    });
  }
}