import 'dart:convert';

import 'package:motoki/Managers/ChatGroups.dart';

import '../Entity/EMessageBox.dart';
import 'JsonFileManager.dart';

class MessageManager{
  //单例
  static MessageManager instance = MessageManager._();
  MessageManager._(); // 私有构造函数

  bool messageHasEdit = false;//判断消息是否被编辑过
  int currentStudentId = 0;
  String currentPage = "";
  List<dynamic> messages = [];
  List<dynamic> aiMessages = [];

  void addMessageBox(EMessageBox mb){
    messages.add(mb.toMap());
    messageHasEdit = true;
  }

  void addAIMessageBox(EMessageBox mb){
    aiMessages.add(mb.toMap());
    messageHasEdit = true;
  }

  void addMessage(String mes){
    messages.last["messageContentList"].add(mes);
    messageHasEdit = true;
  }

  void insertMessageBox(int index,EMessageBox mb){
    messages.insert(index, mb.toMap());
    messageHasEdit = true;
  }

  void insertMessage(int index,String mes){
    messages.last["messageContentList"].insert(index,mes);
    messageHasEdit = true;
  }

  void alterMessageBox(int index,EMessageBox emb){
    messages[index] = emb.toMap();
    messageHasEdit = true;
  }

  void deleteMessageBox(int index){
    messages.removeAt(index);
    messageHasEdit = true;
  }


  bool checkIsImg(String message){
    return message.length > 7 && (message.substring(0,7) == "IMG:://" || message.substring(0,7) == "URL:://" || message.substring(0,7) == "DOC:://");
  }

  Future saveMessages()async{
    messageHasEdit = messageHasEdit && messages.isNotEmpty;
    if(messageHasEdit){
      Map lastMessage = messages.last;
      String mes = lastMessage["messageContentList"].last;
      if(lastMessage["senderId"] == 1){
        mes = "老师：$mes";
      }else if(lastMessage["senderId"] < 100){
        bool img = MessageManager.instance.checkIsImg(mes);
        String content = img?"图片消息":mes;
        mes = "[聊天]$content";
      }else if(MessageManager.instance.checkIsImg(mes)){
        mes = "[图片]";
      }
      ChatGroups().alterChatTileSubtitle(mes);
      await JsonFileManager.instance.saveJsonFile("Messages", "$currentPage.json", json.encode(messages));
      messageHasEdit = false;
    }
  }

  Future saveAIMessages()async{
    messageHasEdit = messageHasEdit && aiMessages.isNotEmpty;
    if(messageHasEdit){
      await JsonFileManager.instance.saveJsonFile("AIChat", "$currentPage.json", json.encode(aiMessages));
      messageHasEdit = false;
    }
  }
  
}