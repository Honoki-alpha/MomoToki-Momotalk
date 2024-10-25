import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/Entity/EMessageBox.dart';
import 'package:motoki/Utils/EventBus.dart';

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
  late List messageList = [];//消息盒子全部
  List waitToPlayList = [];//正在播放的消息盒子
  ScrollController sc = ScrollController();
  StreamSubscription? stream;
  bool isHappend = false;
  ReplyClick lastReplyClick = ReplyClick("error");

  Completer completer = Completer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messageList.clear();

    //深拷贝一个数组
    String old = json.encode(MessageManager.instance.messages.sublist(widget.startPointer,widget.endPointer+1));
    messageList = jsonDecode(old);

    stream ??= AppLibrary.globalEvent.on<ReplyClick>().listen((item){
      replyButtonClick(item);
      });
    startPlay();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    waitToPlayList.clear();
    stream?.cancel();
  }

  @override
  void deactivate(){
    super.deactivate();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top,SystemUiOverlay.bottom]);
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
    await Future.delayed(Duration(milliseconds: AppLibrary.perMessageTime));
    for(var mesBox in messageList){
      if(!mounted) return;
      List mbList = List.from(mesBox["messageContentList"].toList());
      //如果是回复，则直接把整个都添加上
      if(mesBox["senderId"] == 4){
        if(mounted){
          setState(() {
            waitToPlayList.add(mesBox);
          });
        }
        //如果上一个已完成过，那么初始化一个新的，令其为未完成的状态
        if(completer.isCompleted){
          completer = Completer();
        }
        await completer.future;
        await Future.delayed(Duration(milliseconds: AppLibrary.perMessageTime));
        continue;
      }
      //不是回复就正常添加
      mesBox["messageContentList"] = mesBox["messageContentList"].sublist(0,1);
      if(mounted){
        setState(() {
          waitToPlayList.add(mesBox);
        });
      }
      int frequency = 0;
      await Future.delayed(Duration(milliseconds: AppLibrary.perMessageTime));
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
        await Future.delayed(Duration(milliseconds: AppLibrary.perMessageTime));
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

  void replyButtonClick(ReplyClick item)async{
    try{
      waitToPlayList.last["senderId"] = 1;
      waitToPlayList.last["senderSkinIndex"] = 0;
      waitToPlayList.last["messageContentList"] = [item.content];
      waitToPlayList.last["boxAlign"] = false;
      waitToPlayList.last["storageInfo"] = {};
    }catch(e){
      print("报错了");
      return;
    }
    if(!completer.isCompleted){
      if(mounted){setState(() {});}
      completer.complete();
    }
  }
}