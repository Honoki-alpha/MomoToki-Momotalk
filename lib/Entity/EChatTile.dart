class EChatTile{
  int senderId;
  String chatTileUID;
  String chatTileName;
  String tileTitle;
  String tileSubtitle;
  int unreadNum;
  Map storageInfo;

  EChatTile(this.senderId,this.chatTileUID,this.chatTileName,this.tileTitle,this.tileSubtitle,this.unreadNum,this.storageInfo);

  factory EChatTile.fromMap(Map map){
    return EChatTile(map["senderId"],map["chatTileUID"],map["chatTileName"], map["tileTitle"], map["tileSubtitle"], map["unreadNum"], map["storageInfo"]);
  }

  Map toMap(){
    return {
      "senderId":senderId,
      "chatTileUID":chatTileUID,
      "chatTileName":chatTileName,
      "tileTitle":tileTitle,
      "tileSubtitle":tileSubtitle,
      "unreadNum":unreadNum,
      "storageInfo":storageInfo
    };
  }



}