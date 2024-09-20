import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/Utils/CommonComponents.dart';
import 'package:motoki/Entity/EChatTileGroup.dart';
import 'package:path/path.dart';
import '../../Entity/EChatTile.dart';
import '../../Managers/ChatGroupManager.dart';
import '../../Managers/MessageManager.dart';
import '../../Utils/EventBus.dart';
import 'AIChatPage.dart';
import 'MessagePage.dart';

//消息页面，既进入程序后的主界面
class Chat extends StatefulWidget{
  const Chat({super.key});
  @override
  State<StatefulWidget> createState() => _chatState();
}

class _chatState extends State<Chat>{
  //对话框
  TextEditingController unreadC = TextEditingController();
  TextEditingController asnameC = TextEditingController();
  int host = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppLibrary.globalEvent.on<PageRefresh>().listen((event) {
      if(mounted){
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: ChatGroupManager.instance.chatTileGroups.length,
      itemBuilder: (BuildContext context, int index) {
        return chatTileGroup(ChatGroupManager.instance.chatTileGroups[index],index);
      },
    );
  }

  Widget chatTileGroup(EChatTileGroup group,int groupIndex){
    return ExpansionPanelList(
      expansionCallback: (index,isOpen){
        ChatGroupManager.instance.selectedGroupIndex = groupIndex;
        setState(() {
          group.display = !group.display;
        });
      },
      children: [ExpansionPanel(
          canTapOnHeader: true,
          isExpanded: group.display,
          headerBuilder: (context,open){
            return ListTile(
              title: Text(group.groupName),
              onLongPress: ()=>groupholdPress(groupIndex),
            );
          },
          body: SizedBox(
            height: 500,
            child: ListView.builder(
                itemCount: group.chatTiles.length,
                itemBuilder: (builder,index){
                  return chatTile(group,index);
                }),))],
    );
  }

  Widget chatTile(EChatTileGroup group,int index){
    var tile = group.chatTiles[index];
    return ListTile(
      title: Text(tile.tileTitle),
      leading: getCicleStudentAvatar(tile.senderId),
      trailing: tile.unreadNum == 0?null:Container(
          //因为消息数位数不同宽度不同，会导致背景色宽度也不同，所以此处固定宽高
          width: 30,
          height: 30,
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Text(
            tile.unreadNum>99?"...":tile.unreadNum.toString(),
            style: const TextStyle(color: Colors.white),),),
      subtitle: Text(tile.tileSubtitle),
      onTap: ()=>visitChatTile(group,index),
      onLongPress: ()=>holdTilePress(group,index),
    );
  }

  TextEditingController groupName = TextEditingController();
  Widget groupEditDialog(){
    return AlertDialog(
      title: const Text("编辑/删除"),
      content: TextField(
        decoration:const InputDecoration(
          hintText: "分组名",
        ),
        controller: groupName,),
      actions: [
        TextButton(onPressed: (){
          Get.back(result: {"command":"delete"});
        }, child: const Text("删除")),
        TextButton(onPressed: (){
          Get.back(result: {"command":"edit"});
        }, child: const Text("修改")),
      ],
    );
  }

  Widget tileEidtDialog(){
    return AlertDialog(
      title: const Text("编辑/删除"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration:const InputDecoration(
              hintText: "未读消息数",
            ),
            controller: unreadC,),
          TextField(
            decoration:const InputDecoration(
              hintText: "故事名",
            ),
            controller: asnameC,),
          ListTile(title: const Text("AI代理"),trailing: Text("${host==3?"(国外)":"(国内)"}Host $host"),onTap: (){
            if(host == 3){
              host = 1;
            }else{
              host++;
            }
            setState(() {

            });
          },)
        ],
      ),
      actions: [
        TextButton(onPressed: (){
          Get.back(result: {"command":"AI","host":host});
        }, child: const Text("AI")),
        TextButton(onPressed: (){
          Get.back(result: {"command":"delete"});
        }, child: const Text("删除")),
        TextButton(onPressed: (){
          Get.back(result: {"command":"edit","unreadNum":unreadC.text,"tileTitle":asnameC.text});
        }, child: const Text("确认")),
      ],
    );
  }

  void deleteChatTile(EChatTileGroup group,int index){

  }

  void visitChatTile(EChatTileGroup group,int index)async{
    //加一个读取等待对话框
    var cancel = BotToast.showLoading();
    EChatTile tile = group.chatTiles[index];
    File file = File(join(AppLibrary.applicationPath,"Messages","${tile.chatTileUID}.json"));
    String fileStr = await file.readAsString();

    //Tile信息
    ChatGroupManager.instance.selectedTileIndex = index;

    //Message信息
    MessageManager.instance.currentStudentId = tile.senderId;
    MessageManager.instance.currentPage = tile.chatTileUID;
    MessageManager.instance.messages = json.decode(fileStr);
    MessageManager.instance.messageHasEdit = false;


    cancel();
    BotToast.showText(text: "成功获取消息记录(*^_^*)");
    if(GetPlatform.isMobile){
      Get.to(()=>MessagePage(chatTileUID: tile.chatTileUID),transition: Transition.rightToLeftWithFade);
    }
    setState(() {
      tile.unreadNum = 0;
    });
    ChatGroupManager.instance.saveAsJson();
  }

  void groupholdPress(int groupIndex)async{
    var result = await Get.dialog(groupEditDialog());
    if(result == null) return;
    if(result["command"] == "edit"){
      ChatGroupManager.instance.alterChatTileGroup(groupIndex, groupName.text);
    }else{
      ChatGroupManager.instance.removeChatTileGroup(groupIndex);
    }
    setState(() {});
  }

  void holdTilePress(EChatTileGroup group,int index)async{
    Map? result = await Get.dialog(tileEidtDialog());
    if(result == null) return;
    if(result["command"] == "delete"){
      var cancel = BotToast.showLoading();
      await ChatGroupManager.instance.removeChatTile(group, index, true);
      cancel();
      setState(() {
      });
    }
    else if(result["command"] == "edit"){
      setState(() {
        ChatGroupManager.instance.alterChatTile(
            group.chatTiles[index],
            result["tileTitle"] ?? "未输入标题",
            int.parse(result["unreadNum"] ?? "0"));
      });
    }
    else if(result["command"] == "AI"){
      visitAIPage(group,index);
    }
    ChatGroupManager.instance.saveAsJson();
  }

  void visitAIPage(EChatTileGroup group,int index)async{
    if(MessageManager.instance.aiMessages.isNotEmpty && MessageManager.instance.messageHasEdit){
      MessageManager.instance.saveAIMessages();
    }
    //加一个读取等待对话框
    var cancel = BotToast.showLoading();
    EChatTile tile = group.chatTiles[index];
    File file = File(join(AppLibrary.applicationPath,"AIChat","${tile.chatTileUID}.json"));
    String fileStr = await file.readAsString();

    MessageManager.instance.currentStudentId = tile.senderId;
    MessageManager.instance.currentPage = tile.chatTileUID;
    MessageManager.instance.aiMessages = json.decode(fileStr);
    MessageManager.instance.messageHasEdit = false;

    cancel();
    BotToast.showText(text: "成功获取消息记录(*^_^*)");
    if(GetPlatform.isMobile){
      Get.to(()=>const AIChatPage(),transition: Transition.rightToLeftWithFade);
    }
    setState(() {
      tile.unreadNum = 0;
    });
    ChatGroupManager.instance.saveAsJson();
  }

}