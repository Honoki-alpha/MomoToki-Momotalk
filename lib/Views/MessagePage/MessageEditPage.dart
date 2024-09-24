import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/Utils/CommonFunctions.dart';
import 'package:motoki/Entity/EMessageBox.dart';
import 'package:path/path.dart';

import '../../AppData/AppLibrary.dart';
import '../../Dialog/DIYEmojiDialog.dart';
import '../../Dialog/InquireDialog.dart';
import '../../Dialog/StudentEmojiDialog.dart';
import '../../Managers/MessageManager.dart';
import '../../Managers/StudentManager.dart';
import '../Secondary/SelectPage.dart';
import '../../Utils/CommonComponents.dart';

class MessageEditPage extends StatefulWidget{
  const MessageEditPage({super.key,required this.chatTileUID, required this.messageBox});
  final String chatTileUID;
  final EMessageBox messageBox;
  @override
  State<StatefulWidget> createState() => _messageEditPage();

}

// ignore: camel_case_types
class _messageEditPage extends State<MessageEditPage>{
  int selectedindex = 0;
  TextEditingController inputField = TextEditingController();
  String loadImgPath = "";
  String loadImgMethod = "URL";
  final List<String> typeMenu = ["老师","旁白","旁白（透明）","回复","羁绊"];
  bool disableInsert = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String head = widget.messageBox.messageContentList[selectedindex];
    editMessage(selectedindex, MessageManager.instance.checkIsImg(head));
  }

  @override
  Widget build(BuildContext context) {
    disableInsert = widget.messageBox.senderId < 100 && widget.messageBox.senderId != 4;
    return PopScope(
      canPop: false,
      onPopInvoked: saveRequest,
      child: Scaffold(
      appBar: getPlatformAppBar(const Text("消息编辑")),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(children: [
                const Text("发送者:"),
                const SizedBox(width: 20,),
                GestureDetector(
                  onTap: iconClick,
                  onDoubleTap: iconDoubleClick,
                  child: getCicleStudentAvatar(widget.messageBox.senderId,skinIndex: widget.messageBox.senderSkinIndex),),
                const SizedBox(width: 20,),
                const Text("位于右侧"),
                Switch(value: widget.messageBox.boxAlign, onChanged: (value){
                  setState(() {
                    widget.messageBox.boxAlign = value;
                  });
                }),
              ]),
              SizedBox(
                height: 280,
                child: ListView.builder(
                    itemCount: widget.messageBox.messageContentList.length,
                    itemBuilder: (build,index){
                      var element = widget.messageBox.messageContentList[index];
                      bool isImg = MessageManager.instance.checkIsImg(element);
                      return Row(
                        children: [
                          Expanded(child: Text(isImg?"【图片资源】":element)),
                          IconButton(icon: const Icon(Icons.edit),onPressed: ()=>editMessage(index,isImg),),
                          IconButton(icon: const Icon(Icons.remove),onPressed: ()=>deleteMessage(index),),
                          IconButton(icon: const Icon(Icons.add),onPressed: disableInsert?null:()=>insertMessage(index),),
                        ],
                      );
                    }),
              ),
              TextButton(onPressed: disableInsert?null:addMessage, child: const Text("末尾追加")),
              Row(
                children: [
                  Expanded(child: TextField(
                    controller: inputField,
                  )),
                  IconButton(onPressed: emojiButtonClick, icon: const Icon(Icons.emoji_emotions)),
                  IconButton(onPressed: imageButtonClick, icon: const Icon(Icons.image)),
                  TextButton(onPressed: applyEdit, child: const Text("应用"))
                ],
              ),
              ElevatedButton(onPressed: (){
                Get.back(result: {
                  "command":"delete",
                });
              }, child: const Text("删除整个消息盒子")),
              ElevatedButton(onPressed: typeChangeClick, child: const Text("转化为其他消息类型")),
              ElevatedButton(onPressed: (){
                Get.back(result: {
                  "command":"save",
                  "box":widget.messageBox
                });
              }, child: const Text("保存并返回"))
            ],
          ),
        ),
      ),
    )
    );
  }

  //保存并返回
  void saveRequest(bool didPop)async{
    if(didPop){
      return;
    }else{
      var result = await Get.dialog(const Inquiredialog(title: "保存",content: "老师，若您进行了修改，请点击下方的【保存并退出】，是否继续返回？",));
      if(result != true){
        return;
      }
      Get.back();
    }
  }

  //点击头像
  void iconClick()async{
    var student = await Get.to(()=>const SelectPage());
    if(student == null) return;
    setState(() {
      widget.messageBox.senderId = student.id;
    });
  }

  //双击头像
  void iconDoubleClick(){
    int skinIndex = StudentManager.instance.getStudentSkinIndex(widget.messageBox.senderId, widget.messageBox.senderSkinIndex+1);
    setState(() {
      widget.messageBox.senderSkinIndex = skinIndex;
    });
  }

  //末尾追加
  void addMessage(){
    setState(() {
      widget.messageBox.messageContentList.add("新消息");
    });
  }

  //编辑消息
  void editMessage(int index,bool isImg){
    selectedindex = index;
    inputField.text = isImg?"【图片资源】":widget.messageBox.messageContentList[index];
    print(widget.messageBox.messageContentList[index]);
  }

  //删除消息
  void deleteMessage(int index){
    if(widget.messageBox.messageContentList.length == 1){
      BotToast.showText(text: "最后一条不可删除，请删除整个消息盒子");
      return;
    }
    setState(() {
      widget.messageBox.messageContentList.removeAt(index);
    });
  }

  //插入消息
  void insertMessage(int index){
    setState(() {
      widget.messageBox.messageContentList.insert(index, "新消息");
    });
  }

  //应用编辑
  void applyEdit(){
    String content = inputField.text;
    if(loadImgPath != ""){
      content = "$loadImgMethod:://$loadImgPath";
      loadImgPath = "";
    }
    setState(() {
      widget.messageBox.messageContentList[selectedindex] = content;
    });
    inputField.text="";
  }

  //图片选择
  void imageButtonClick()async{
    BotToast.showText(text: "正在转存图片...");
    var cancel = BotToast.showLoading();
    String savePath = join(AppLibrary.applicationPath,"PictureCache","Messages",widget.chatTileUID);
    String fileName = await getPictureFromDevice(savePath);
    cancel();
    if(fileName == "error") return;
    inputField.text = "【图片资源】";
    loadImgPath = fileName;
    loadImgMethod = "IMG";
  }

  //改变类型
  void typeChangeClick()async{
    var result = await Get.dialog(const Inquiredialog(title: "警告",content: "转变类型将清空该盒子内的消息，是否继续？",));
    if(result != true) return;
    var typeId = await Get.dialog(typeMenuDialog());
    if(typeId == null) {
      return;
    }else{
      widget.messageBox.senderId = typeId + 1;
      widget.messageBox.senderSkinIndex = 0;
      widget.messageBox.messageContentList = ["请编辑该消息"];
    }
    setState(() {});
  }

  //改变类型的对话框
  Widget typeMenuDialog(){

    return SimpleDialog(
      children: typeMenu.map<Widget>((element){
        int elementIndex = typeMenu.indexOf(element);
        return SimpleDialogOption(
          child: Text(element),
          onPressed: (){
            Get.back(result: elementIndex);
          },
        );
      }).toList(),
    );
  }

  //表情差分按钮
  void emojiButtonClick()async{
    if(widget.messageBox.senderId < 10000){
      var result = await Get.dialog(StudentEmojiDialog(studentID: widget.messageBox.senderId));
      if(result == null) return;
      inputField.text = "【图片资源】";
      loadImgMethod = "URL";
      loadImgPath = result["url"];
    }else{
      Directory dir = Directory(join(AppLibrary.applicationPath,"DIYemotion",widget.messageBox.senderId.toString()));
      if(!dir.existsSync()){
        BotToast.showText(text: "未导入该自定义学生的差分");
        return;
      }
      var cancel = BotToast.showLoading();
      var files = dir.listSync();
      cancel();
      var result = await Get.dialog(DIYEmojiDialog(sendID: widget.messageBox.senderId, facePaths: files));
      if(result == null) return;
      inputField.text = "【图片资源】";
      loadImgMethod = "IMG";
      loadImgPath = result;
    }
  }
}