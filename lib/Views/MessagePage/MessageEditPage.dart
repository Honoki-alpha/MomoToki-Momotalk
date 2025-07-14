import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/Entity/EStudent.dart';
import 'package:motoki/Utils/CommonFunctions.dart';
import 'package:motoki/Entity/EMessageBox.dart';
import 'package:path/path.dart';

import '../../AppData/AppLibrary.dart';
import '../../AppData/UserConfig.dart';
import '../../Components/StudentCircleAvatar.dart';
import '../../Dialog/DIYEmojiDialog.dart';
import '../../Dialog/InquireDialog.dart';
import '../../Dialog/StudentEmojiDialog.dart';
import '../../Managers/MessageManager.dart';
import '../../Managers/Students.dart';
import '../../Utils/WidgetUtils.dart';
import '../Secondary/SelectPage.dart';

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
  //单条备注
  TextEditingController nick = TextEditingController();
  String loadImgPath = "";
  String loadImgMethod = "URL";

  final List<String> typeMenu = ["老师","旁白","旁白（透明）","回复","羁绊"];
  bool disableInsert = false;
  late EStudent currentStudent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String head = widget.messageBox.messageContentList[selectedindex];
    editMessage(selectedindex, MessageManager.instance.checkIsImg(head));
    currentStudent = Students().getStudentById(widget.messageBox.senderId);
    skinLength = currentStudent.skinList.length;
    nick.text = widget.messageBox.sendMessageName;
  }

  @override
  Widget build(BuildContext context) {
    disableInsert = widget.messageBox.senderId != 1 && widget.messageBox.senderId < 100 && widget.messageBox.senderId != 4;
    //获取当前学生
    currentStudent = Students().getStudentById(widget.messageBox.senderId);
    return PopScope(
      canPop: false,
      onPopInvoked: saveRequest,
      child: Scaffold(
      appBar: WidgetUtils().getPlatformAppBar(const Text("消息编辑")),
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
                  child: StudentCircleAvatar(id:widget.messageBox.senderId,skinIndex: widget.messageBox.senderSkinIndex),),
                const SizedBox(width: 20,),
                const Text("位于右侧"),
                Switch(value: widget.messageBox.boxAlign, onChanged: (value){
                  setState(() {
                    widget.messageBox.boxAlign = value;
                  });
                }),
              ]),
              SizedBox(width: 300,child: TextField(controller: nick,decoration: const InputDecoration(
                labelText: "单条消息备注"
              ),onChanged: (value){
                widget.messageBox.sendMessageName = value;
              },)),
              SizedBox(
                height: 280,
                child: ReorderableListView.builder(
                    itemCount: widget.messageBox.messageContentList.length,
                    itemBuilder: (build,index){
                      var element = widget.messageBox.messageContentList[index];
                      bool isImg = MessageManager.instance.checkIsImg(element);
                      return Row(
                        key: ObjectKey(index),
                        children: [
                          Expanded(child: Text(isImg?"【图片资源】":element)),
                          IconButton(icon: const Icon(Icons.edit), onPressed: ()=>editMessage(index,isImg)),
                          IconButton(
                            icon: const Icon(Icons.remove),onPressed: ()=>deleteMessage(index)),
                          IconButton(icon: const Icon(Icons.add),onPressed: disableInsert?null:()=>insertMessage(index),),
                        ],
                      );
                    }, onReorder: (int oldIndex, int newIndex) {
                      var item = widget.messageBox.messageContentList.removeAt(oldIndex);
                      if(newIndex < oldIndex){
                        widget.messageBox.messageContentList.insert(newIndex, item);
                      }else{
                        widget.messageBox.messageContentList.insert(newIndex-1, item);
                      }
                      setState(() {});
                      //print("oldIndex:$oldIndex;newIndex:$newIndex");
                },),
              ),
              if(widget.messageBox.senderId != 5) TextButton(onPressed: disableInsert?null:addMessage, child: const Text("末尾追加")),
              if(widget.messageBox.senderId == 5) TextButton(onPressed: editStoryButton, child: const Text("羁绊编辑")),
              Row(
                children: [
                  Expanded(child: TextField(
                    maxLines: null,
                    controller: inputField,
                  )),
                  IconButton(onPressed: emojiButtonClick, icon: const Icon(Icons.emoji_emotions)),
                  IconButton(onPressed: imageButtonClick, icon: const Icon(Icons.image)),
                  TextButton(onPressed: applyEdit, child: const Text("应用"))
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: ()async{
                    var result = await Get.dialog(Inquiredialog(title: "警告", content: "是否确认清除该消息？"));
                    if(result != true) return;
                    Get.back(result: {
                      "command":"delete",
                    });
                  }, child: const Text("清除")),
                  ElevatedButton(onPressed: typeChangeClick, child: const Text("转为...")),
                  ElevatedButton(onPressed: (){
                    Get.back(result: {
                      "command":"save",
                      "box":widget.messageBox
                    });
                  }, child: const Text("保存"))
                ],
              )
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
      var result = await Get.dialog(const Inquiredialog(title: "保存",content: "老师，您点击了退出按钮，在退出之前，是否保存此次修改呢？",));
      if(result != true){
        Get.back();
        return;
      }
      Get.back(result: {
        "command":"save",
        "box":widget.messageBox
      });
    }
  }

  //点击头像
  void iconClick()async{
    var student = await Get.to(()=>const SelectPage(multiple: false,));
    if(student == null) return;
    setState(() {
      widget.messageBox.senderId = student.id;
    });
  }

  //双击头像
  void iconDoubleClick(){
    int skinIndex = Students().getStudentSkinIndex(widget.messageBox.senderId, widget.messageBox.senderSkinIndex+1);
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
    var result = await Get.dialog(const Inquiredialog(title: "警告",content: "转变类型将删除盒子内的部分消息，是否继续？",));
    if(result != true) return;
    var typeId = await Get.dialog(typeMenuDialog());
    if(typeId == null) {
      return;
    }else{
      widget.messageBox.senderId = typeId + 1;
      widget.messageBox.senderSkinIndex = 0;
      if(typeId != 0 && typeId != 3){
        String beforeMessage = widget.messageBox.messageContentList[0];
        widget.messageBox.messageContentList = [beforeMessage];
      }

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
    if(widget.messageBox.senderId < 100) return;
    if(currentStudent.release != 2 && !UserConfig.applyOfflineMode){
      var result = await Get.dialog(StudentEmojiDialog(studentID: widget.messageBox.senderId));
      if(result == null) return;
      inputField.text = "【图片资源】";
      loadImgMethod = "URL";
      loadImgPath = result["url"];
    }else{
      //载入自定义文件夹
      Directory dir = Directory(join(AppLibrary.applicationPath,"DIYemotion",widget.messageBox.senderId.toString()));
      //如果不是自定义学生
      if(currentStudent.release != 2){
        dir = Directory(join(AppLibrary.faceBasePath,"Resources","Emotions","${widget.messageBox.senderId}"));
      }
      //如果文件不存在
      if(!dir.existsSync()){
        BotToast.showText(text: "未找到该学生差分");
        return;
      }
      var cancel = BotToast.showLoading();
      var files = dir.listSync();
      cancel();
      var result = await Get.dialog(DIYEmojiDialog(sendID: widget.messageBox.senderId, facePaths: files));
      if(result == null) return;
      inputField.text = "【图片资源】";
      loadImgMethod = "IMG";
      loadImgPath = result.path;
    }
  }

  void editStoryButton()async{
    Get.dialog(storyEditDialog());
  }

  RxInt storyMainStudent = 100.obs;
  int skinLength = 1;
  RxInt storyMainSkin = 0.obs;
  TextEditingController storyLevel = TextEditingController();
  TextEditingController stoneNum = TextEditingController();
  TextEditingController chapter = TextEditingController();
  TextEditingController title = TextEditingController();
  Widget storyEditDialog(){
    storyMainStudent.value = widget.messageBox.storageInfo["id"] ?? 100;
    storyMainSkin.value = widget.messageBox.storageInfo["skin"] ?? 0;
    storyLevel.text = widget.messageBox.storageInfo["level"] ?? "50";
    stoneNum.text = widget.messageBox.storageInfo["stone"] ?? "60";
    chapter.text = widget.messageBox.storageInfo["ep"] ?? "03";
    title.text = widget.messageBox.storageInfo["title"] ?? "私たちの物語";
    return AlertDialog(
      title: const Text("羁绊故事编辑"),
      content: SizedBox(
        height: 300,
        width: 300,
        child: Column(
          children: [
            Obx(() => GestureDetector(
              child: StudentCircleAvatar(id:storyMainStudent.value,skinIndex: storyMainSkin.value),
              onTap: ()async{
                EStudent? student = await Get.to(()=>const SelectPage(multiple: false,));
                if(student == null) return;
                storyMainStudent.value = student.id;
                skinLength = student.skinList.length;
              },
              onDoubleTap: (){
                if(storyMainSkin.value + 1 == skinLength){
                  storyMainSkin.value = 0;
                }else{
                  storyMainSkin.value++;
                }
              },
            )),
            Expanded(child: TextField(
              controller: storyLevel,
              decoration: const InputDecoration(
                  helperText: "好感等级"
              ),
            )),
            Expanded(child: TextField(
              controller: chapter,
              decoration: const InputDecoration(
                  helperText: "输入第几章，格式:03"
              ),
            )),
            Expanded(child: TextField(
              controller: title,
              decoration: const InputDecoration(
                  helperText: "章节标题"
              ),
            )),
            Expanded(child: TextField(
              controller: stoneNum,
              decoration: const InputDecoration(
                  helperText: "青辉石数量"
              ),
            )),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: (){
          widget.messageBox.storageInfo = {
            "id":storyMainStudent.value,
            "skin":storyMainSkin.value,
            "level":storyLevel.text,
            "ep":chapter.text,
            "title":title.text,
            "stone":stoneNum.text
          };
          Get.back();
        }, child: const Text("确认")),
      ],
    );
  }

}