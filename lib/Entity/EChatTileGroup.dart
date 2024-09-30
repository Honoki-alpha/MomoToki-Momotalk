

import 'EChatTile.dart';

class EChatTileGroup{
  String groupName;
  bool display;
  List<EChatTile> chatTiles;

  EChatTileGroup(this.groupName,this.display,this.chatTiles);

  factory EChatTileGroup.fromMap(Map map){
    //从本地读取消息块
    List<EChatTile> tempList = [];
    for(var tile in map["chatTiles"]){
      tempList.add(EChatTile.fromMap(tile));
    }
    return EChatTileGroup(map["groupName"],false,tempList);
  }

  Map toMap(){
    List<Map> maps = [];
    for(var chat in chatTiles){
      maps.add(chat.toMap());
    }
    return {
      "groupName":groupName,
      "chatTiles":maps
    };
  }
}