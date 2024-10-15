import 'dart:math';

import 'package:event_bus/event_bus.dart';

import '../Utils/EventBus.dart';


enum MessageType{
  nomal,sensei,aside,transaside,reply,story
}

class AppLibrary{
  ///软件运行信息
  static String applicationPath = "";//软件位置
  static String appVersion = "V0.5.20";//软件版本号
  static int requestTimes = 0;//请求次数
  static String appFontSource = "ResourceHanCN";
  static bool appLandscapeMode = true;//软件当前是否为横屏模式
  static List<MessageType> messageTypeIndex = [MessageType.nomal,MessageType.sensei,MessageType.aside,MessageType.transaside,MessageType.reply,MessageType.story];
  static EventBus globalEvent = EventBus();

  static int ellipsisTime = 1500; //省略号存在时间
  static int perMessageTime = 2000; //每条消息出现时长

  ///软件需求资源
  static List schoolList = [];

  static String generateUID(){
    var dt = DateTime.now();
    return "MOMOD${dt.day}H${String.fromCharCode(dt.hour+65)}M${dt.minute}S${dt.second}S${dt.millisecond}ML${dt.microsecond}";
  }

  //广播ReplyClick事件
  static void sendReplyEvent(String mes){
    globalEvent.fire(ReplyClick(mes));
  }

  static dynamic randGetFromList(List list){
    var num = Random().nextInt(list.length);
    return list[num];
  }
}