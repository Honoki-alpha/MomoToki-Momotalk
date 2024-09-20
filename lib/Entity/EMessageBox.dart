
class EMessageBox{
  int senderId;
  int senderSkinIndex;
  int messageType;
  String sendMessageName;
  List<String> messageContentList;
  bool boxAlign;
  Map storageInfo;

  EMessageBox(this.senderId,this.senderSkinIndex,this.messageType,this.sendMessageName,this.messageContentList,this.boxAlign,this.storageInfo);

  factory EMessageBox.fromMap(Map<dynamic, dynamic> map){
    List<String> maps = [];
    for(var mes in map["messageContentList"]){
      maps.add(mes);
    }
    return EMessageBox(
        map["senderId"],
        map["senderSkinIndex"],
        map["messageType"],
        map["sendMessageName"],
        maps,
        map["boxAlign"],
        map["storageInfo"] ?? {}
    );
  }

  Map toMap(){
    return {
      "senderId":senderId,
      "senderSkinIndex":senderSkinIndex,
      "messageType":messageType,
      "sendMessageName":sendMessageName,
      "messageContentList":messageContentList,
      "boxAlign":boxAlign,
      "storageInfo":storageInfo
    };
  }

  Map<String,dynamic> toJson(){
    return {
      "senderId":senderId,
      "senderSkinIndex":senderSkinIndex,
      "messageType":messageType,
      "sendMessageName":sendMessageName,
      "messageContentList":messageContentList,
      "boxAlign":boxAlign,
      "storageInfo":storageInfo
    };
  }
}