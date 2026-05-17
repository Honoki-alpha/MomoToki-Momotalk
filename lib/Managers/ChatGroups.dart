import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:path/path.dart';
import '../AppData/AppLibrary.dart';
import '../Entity/EChatTile.dart';
import '../Entity/EChatTileGroup.dart';
import '../Entity/EStudent.dart';
import '../Utils/EventBus.dart';
import 'JsonFileManager.dart';

class ChatGroups{

  //单例
  static ChatGroups _instance = ChatGroups._();
  ChatGroups._(); // 私有构造函数
  factory ChatGroups() => _instance;

  int selectedGroupIndex = -1; //当前选中的分组
  int selectedTileIndex = 0;
  List<EChatTileGroup> chatTileGroups = [];//消息分组

  Future addChatTile(EStudent student)async{
    //生成唯一UID
    String uid = AppLibrary.generateUID();
    //新建消息列表块
    EChatTile chatTile = EChatTile(student.id,uid, student.givenName["nm"], student.givenName["nm"], "老师好", 1, {});
    chatTileGroups[selectedGroupIndex].chatTiles.add(chatTile);
    AppLibrary.globalEvent.fire(PageRefresh());
    //新建聊天文件
    File(join(AppLibrary.applicationPath,"Messages","$uid.json")).writeAsString("[]");
    File(join(AppLibrary.applicationPath,"AIChat","$uid.json")).writeAsString("[]");
    //开启线程保存json
    saveAsJson();
  }

  void addChatTileGroup(String groupName){
    for(var group in chatTileGroups){
      if(group.groupName == groupName){
        BotToast.showText(text: "该组名已存在");
        return;
      }
    }
    //添加组
    chatTileGroups.add(EChatTileGroup(groupName, false, []));
    AppLibrary.globalEvent.fire(PageRefresh());
    //开启线程保存json
    saveAsJson();
  }

  void alterChatTileGroup(int groupIndex,String name){
    chatTileGroups[groupIndex].groupName = name;
    saveAsJson();
  }

  void alterChatTile(EChatTile tile,String title,int unreadNum){
    tile.unreadNum = unreadNum;
    tile.tileTitle = title;
    saveAsJson();
  }

  void alterChatTileSubtitle(String subtitle){
    chatTileGroups[selectedGroupIndex].chatTiles[selectedTileIndex].tileSubtitle = subtitle;
    saveAsJson();
  }

  Future removeChatTileGroup(int groupIndex)async {
    for(int i=0;i<chatTileGroups[groupIndex].chatTiles.length;i++){
      await removeChatTile(chatTileGroups[groupIndex],i,false);
    }
    chatTileGroups.removeAt(groupIndex);
    saveAsJson();
  }

  Future removeChatTile(EChatTileGroup group,int index,bool saved)async{
    String uid = group.chatTiles[index].chatTileUID;
    group.chatTiles.removeAt(index);
    await JsonFileManager.instance.removeJsonFile("Messages", "$uid.json");
    await JsonFileManager.instance.removeJsonFile("AIChat", "$uid.json");
    if(saved) saveAsJson();
  }

  Future moveChatTile(EChatTileGroup oldGroup,int tileIndex,int newGroupIndex,)async{
    EChatTile tile = oldGroup.chatTiles.removeAt(tileIndex);
    chatTileGroups[newGroupIndex].chatTiles.add(tile);
    saveAsJson();
  }

  Future saveAsJson()async{
    List<Map> maps = [];
    for(var group in chatTileGroups){
      maps.add(group.toMap());
    }
    if(maps.isEmpty) return;
    JsonFileManager.instance.saveJsonFile("ChatTiles", "ChatTilesGroups.json", json.encode(maps));
  }
}