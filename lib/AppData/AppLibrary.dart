import 'dart:math';

import 'package:event_bus/event_bus.dart';


enum MessageType{
  nomal,sensei,aside,transaside,reply,story
}

class AppLibrary{
  ///软件运行信息
  static String applicationPath = "";//软件位置
  static String appVersion = "V0.5.01";//软件版本号
  static String appFontSource = "ResourceHanCN";
  static bool appLandscapeMode = true;//软件当前是否为横屏模式
  static List<MessageType> messageTypeIndex = [MessageType.nomal,MessageType.sensei,MessageType.aside,MessageType.transaside,MessageType.reply,MessageType.story];
  static EventBus globalEvent = EventBus();

  ///软件需求资源
  static Function refreshChatPage=(){};

  static String generateUID(){
    var dt = DateTime.now();
    return "MOMOD${dt.day}H${String.fromCharCode(dt.hour+40)}M${dt.minute}S${dt.second}S${dt.millisecond}ML${dt.microsecond}";
  }

  static dynamic randGetFromList(List list){
    var num = Random().nextInt(list.length);
    return list[num];
  }
}