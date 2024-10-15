import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:motoki/Dialog/InquireDialog.dart';
import 'package:motoki/Utils/CommonComponents.dart';
import 'package:motoki/Entity/EChatTileGroup.dart';
import 'package:motoki/Views/Home/WindowHome.dart';
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
  State<StatefulWidget> createState() => _ChatState();
}

class _ChatState extends State<Chat>{

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
        if(ChatGroupManager.instance.selectedGroupIndex==groupIndex){
          ChatGroupManager.instance.selectedGroupIndex = -1;
        }else{
          ChatGroupManager.instance.selectedGroupIndex = groupIndex;
        }
        setState(() {
          group.display = !group.display;
        });
      },
      children: [ExpansionPanel(
          canTapOnHeader: true,
          isExpanded: ChatGroupManager.instance.selectedGroupIndex==groupIndex,
          headerBuilder: (context,open){
            return ListTile(
              leading: IconButton(
                icon: const Icon(Icons.menu_outlined),
                onPressed: ()=>groupEditClick(groupIndex),
              ),
              title: Text(group.groupName),
            );
          },
          body: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.chatTiles.length,
              itemBuilder: (builder,index){
                return chatTile(group,index);
              })
      )],
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
  Widget groupEditDialog(int index){
    groupName.text = ChatGroupManager.instance.chatTileGroups[index].groupName;
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

  //对话框
  TextEditingController unreadC = TextEditingController();
  TextEditingController asnameC = TextEditingController();
  Widget tileEidtDialog(EChatTileGroup group,int tileIndex){
    unreadC.text = group.chatTiles[tileIndex].unreadNum.toString();
    asnameC.text = group.chatTiles[tileIndex].tileTitle;
    return AlertDialog(
      title: const Text("编辑/删除"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            keyboardType: TextInputType.number,
            decoration:const InputDecoration(
              hintText: "未读消息数",
            ),
            controller: unreadC,),
          TextField(
            decoration:const InputDecoration(
              hintText: "故事名",
            ),
            controller: asnameC,),
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

  void visitChatTile(EChatTileGroup group,int index)async{
    //加一个读取等待对话框
    var cancel = BotToast.showLoading();
    if(AppLibrary.appLandscapeMode && MessageManager.instance.messages.isNotEmpty){
      await MessageManager.instance.saveMessages();
      MessageManager.instance.messages = [];
    }
    if(AppLibrary.appLandscapeMode && MessageManager.instance.aiMessages.isNotEmpty){
      await MessageManager.instance.saveAIMessages();
      MessageManager.instance.aiMessages = [];
    }
    EChatTile tile = group.chatTiles[index];
    List message = [];
    try{
      File file = File(join(AppLibrary.applicationPath,"Messages","${tile.chatTileUID}.json"));
      String fileStr = await file.readAsString();
      message = json.decode(fileStr);
    }catch(e){
      Clipboard.setData(ClipboardData(text: e.toString()));
      BotToast.showText(text: "文件丢失，请重新创建该聊天！");
      return;
    }
    //Tile信息
    ChatGroupManager.instance.selectedTileIndex = index;

    //Message信息
    MessageManager.instance.currentStudentId = tile.senderId;
    MessageManager.instance.currentPage = tile.chatTileUID;
    MessageManager.instance.messages = message;
    MessageManager.instance.messageHasEdit = false;
    cancel();
    BotToast.showText(text: "成功获取消息记录(*^_^*)");
    if(!AppLibrary.appLandscapeMode){
      Get.to(()=>MessagePage(chatTileUID: tile.chatTileUID),transition: Transition.rightToLeftWithFade);
    }else{
      WindowHomeState.setRightPage(MessagePage(chatTileUID: tile.chatTileUID));
    }
    setState(() {
      tile.unreadNum = 0;
    });
    ChatGroupManager.instance.saveAsJson();
  }

  void groupEditClick(int groupIndex)async{
    var result = await Get.dialog(groupEditDialog(groupIndex));
    if(result == null) return;
    if(result["command"] == "edit"){
      ChatGroupManager.instance.alterChatTileGroup(groupIndex, groupName.text);
    }else{

      ChatGroupManager.instance.removeChatTileGroup(groupIndex);
    }
    setState(() {});
  }

  void holdTilePress(EChatTileGroup group,int index)async{
    Map? result = await Get.dialog(tileEidtDialog(group,index));
    if(result == null) return;
    if(result["command"] == "delete"){
      bool? result = await Get.dialog(const Inquiredialog(title: "警告！", content: "老师点击了删除按钮，是否要删除该聊天呢？"));
      if(result != true) return;
      await deleteChatTile(group, index);
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
      if(UserConfig.aiChatKey == null){
        BotToast.showText(text: "未配置AI API KEY,可前往关于软件中查看教程");
        return;
      }
      visitAIPage(group,index);
    }
    ChatGroupManager.instance.saveAsJson();
  }

  Future deleteChatTile(EChatTileGroup group,int index)async{
    var cancel = BotToast.showLoading();
    String uid = group.chatTiles[index].chatTileUID;
    await ChatGroupManager.instance.removeChatTile(group, index, true);
    String path = join(AppLibrary.applicationPath,"PictureCache","Messages",uid);
    Directory directory = Directory(path);
    if(directory.existsSync()){
      BotToast.showText(text: "正在删除该聊天记录下的所有图片");
      for(var file in directory.listSync()){
        await file.delete(recursive: true);
      }
    }
    cancel();
    setState(() {

    });
  }

  void visitAIPage(EChatTileGroup group,int index)async{
    if(MessageManager.instance.aiMessages.isNotEmpty && MessageManager.instance.messageHasEdit){
      MessageManager.instance.saveAIMessages();
    }
    //加一个读取等待对话框
    var cancel = BotToast.showLoading();
    EChatTile tile = group.chatTiles[index];
    List mes = [];
    try{
      File file = File(join(
          AppLibrary.applicationPath, "AIChat", "${tile.chatTileUID}.json"));
      String fileStr = await file.readAsString();
      mes = json.decode(fileStr);
    }catch(e){
      Clipboard.setData(ClipboardData(text: e.toString()));
      BotToast.showText(text: "发生错误，错误信息已粘贴，请发送给作者");
      return;
    }

    MessageManager.instance.currentStudentId = tile.senderId;
    MessageManager.instance.currentPage = tile.chatTileUID;
    MessageManager.instance.aiMessages = mes;
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