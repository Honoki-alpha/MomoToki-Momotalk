import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:motoki/Views/Home/WindowHome.dart';
import 'package:path/path.dart';
import '../../AppData/AppLibrary.dart';
import '../../AppData/UserConfig.dart';
import '../../Components/MessageBox.dart';
import '../../Dialog/DIYEmojiDialog.dart';
import '../../Dialog/ScreenShotDialog.dart';
import '../../Dialog/StudentEmojiDialog.dart';
import '../../Entity/EMessageBox.dart';
import '../../Entity/EStudent.dart';
import '../../Managers/MessageManager.dart';
import '../../Managers/StudentManager.dart';
import '../../Managers/ThemeManager.dart';
import '../Secondary/SelectPage.dart';
import '../../Utils/CommonComponents.dart';
import '../../Utils/CommonFunctions.dart';
import 'MessageEditPage.dart';
import 'PlayPage.dart';
import 'ScreenShotPage.dart';

//点击消息列表中的一项后的页面
class MessagePage extends StatefulWidget{
  //上个窗口传入的参数，是哪个学生
  const MessagePage({super.key,required this.chatTileUID});
  final String chatTileUID;
  @override
  State<StatefulWidget> createState() =>_messagePageState();
}


class _messagePageState extends State<MessagePage>{
  //当前选择的学生
  EStudent currentStudent = StudentManager.instance.studentDirctory.entries.first.value;
  RxInt currentStudentSkinIndex = 0.obs;
  //插入的位置(后续更新了删除，现在为选择的消息盒子)
  RxInt currentSelectedIndex = RxInt(-1);
  ScrollController listController = ScrollController();
  TextEditingController input = TextEditingController();
  bool disableAddtionButton = false;
  RxBool toolBarVisible = false.obs;
  bool textFileldReadOnly = false;

  //载入的图片路径
  String loadImgPath = "";
  String loadImgMethod = "URL";

  final HotKey _attachKey = HotKey(KeyCode.enter,modifiers: [KeyModifier.control],scope: HotKeyScope.inapp);
  final HotKey _sendKey = HotKey(KeyCode.enter,scope:HotKeyScope.inapp);

  @override
  void initState() {
    super.initState();
    //初始化快捷键
    initHotKey();
    currentStudent = StudentManager.instance.getStudentById(MessageManager.instance.currentStudentId);
    scrollToBottom();
  }

  @override
  void deactivate() {
    super.deactivate();
    destoryHotKey();
  }

  void scrollToBottom(){
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      listController.animateTo(
        listController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuart,
      );
    });
  }

  void initHotKey()async{
    // await hotKeyManager.register(_sendKey,keyDownHandler: (hotkey)=>sendButtonClick());
    // await hotKeyManager.register(_attachKey,keyDownHandler: (hotkey)=>attachButtonClick());
  }

  void destoryHotKey(){
    hotKeyManager.unregister(_sendKey);
    hotKeyManager.unregister(_attachKey);
  }

  @override
  Widget build(BuildContext context) {
    //currentStudent = StudentManager.instance.getStudentById(MessageManager.instance.currentStudentId);
    disableAddtionButton = checkAddtionButtonUse();
    return PopScope(
        canPop: false,
        onPopInvoked: onPopInvoked,
        child: Scaffold(
          appBar: getPlatformAppBar(Obx(()=>Text(StudentManager.instance.getStudentName(
              currentStudent.id,skinIndex: currentStudentSkinIndex.value
          ))),actions: [
            IconButton(onPressed: saveButtonClick, icon: const Icon(Icons.save_as_rounded)),
          ]),
          body: Column(
            children: [
              //渲染消息列表
              Expanded(
                  child: Container(
                      color: ThemeManager.isDarkTheme || UserConfig.denpendTheme?ThemeManager.currentTheme.cardColor:UserConfig.chatBackGroundColor,
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: listController,
                        itemCount: MessageManager.instance.messages.length,
                        itemBuilder: (BuildContext context,int index){
                          //根据加载项渲染messageBox
                          return GestureDetector(
                            child:Padding(
                                padding:const EdgeInsets.symmetric(vertical: 1.0),
                                child: Obx(()=>Container(
                                    color: Color.fromRGBO(0, 0, 0,currentSelectedIndex.value==index?0.25:0),
                                    child: MessageBox(index: index, isPlayMode: false)
                                ))),
                            onLongPress: ()=>messageBoxHoldTap(index),
                            onDoubleTap: ()=>onMessageBoxDoubleTap(index),
                          );
                        },
                      ))
              ),
              //底部输入框和按钮
              Row(
                children: [
                  const SizedBox(width: 7,),
                  //expanded用于限制输入范围
                  Expanded(
                      child:TextField(
                        controller: input,
                        onTap: (){
                          if(toolBarVisible.value){
                            setState(() {
                              toolBarVisible.value = false;
                            });
                          }
                        },
                        decoration: InputDecoration(
                            icon:GestureDetector(
                              child: Obx(()=>SizedBox(
                                  width: 40,
                                  child: getCicleStudentAvatar(
                                      currentStudent.id,
                                      skinIndex: currentStudentSkinIndex.value))),
                              onTap: (){
                                setState(() {
                                  toolBarVisible.value = !toolBarVisible.value;
                                });
                              },
                              onDoubleTap: (){
                                currentStudentSkinIndex.value++;
                                if(currentStudentSkinIndex.value > currentStudent.skinList.length-1){
                                  currentStudentSkinIndex.value = 0;
                                }
                              },
                            )
                        ),
                        style: const TextStyle(
                            fontSize: 13
                        ),
                        maxLines: null,
                      )
                  ),
                  //点击“追加”按钮效果
                  ElevatedButton(
                      onPressed: disableAddtionButton?null:addtionButtonClick,
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.purple)
                      ),
                      child:const Text("追加",style:TextStyle(color: Colors.white))),
                  //点击“发送”按钮效果
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child:ElevatedButton(
                          onPressed:sendButtonClick,
                          child:Obx(()=>Text(currentSelectedIndex.value>-1?"插入":"发送")))),
                ],
              ),
              Obx(()=>Container(
                child: toolBarVisible.value?Column(
                  children: [
                    SizedBox(height:50,child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          IconButton(onPressed: emojiButtonClick, icon: const Icon(Icons.emoji_emotions)),
                          IconButton(onPressed: imagePickerClick, icon: const Icon(Icons.image)),
                          IconButton(onPressed: addUsualStudent, icon: const Icon(Icons.person_add)),
                          IconButton(onPressed: (){}, icon: const Icon(Icons.shield)),
                          IconButton(onPressed: playButtonClick, icon: const Icon(Icons.play_circle)),
                          IconButton(onPressed: screenShotButton, icon: const Icon(Icons.screenshot_sharp)),
                        ])),
                    SizedBox(
                        height: 120,
                        child: GridView.builder(
                            itemCount: StudentManager.instance.toolStudentDirctory.length+StudentManager.instance.usualStudents.length,
                            gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisSpacing: 5,
                                crossAxisCount: AppLibrary.appLandscapeMode?12:7,
                                childAspectRatio: 1.0),//显示区域宽高相等
                            itemBuilder: (context, index){
                              int iconId = 0;
                              int iconSkin = 0;
                              int length = StudentManager.instance.toolStudentDirctory.length;
                              if(index<length){
                                iconId = index + 1;
                              }else{
                                List studentAndSkin = StudentManager.instance.usualStudents[index-length].split("||");
                                iconId = int.parse(studentAndSkin[0]);
                                iconSkin = int.parse(studentAndSkin[1]);
                              }
                              return GestureDetector(
                                child:getCicleStudentAvatar(iconId,skinIndex: iconSkin),
                                onTap: (){
                                  currentStudentSkinIndex.value = iconSkin;
                                  currentStudent = StudentManager.instance.getStudentById(iconId);

                                  setState(() {});
                                },
                                onLongPress: ()=>deleteUsualStudent(index),
                              );
                            })),
                  ],
                ):const Row(),
              ))
            ],
          ),
        )
    );
  }


  void onPopInvoked(bool onpop)async{
    if(onpop){
      return;
    }else{
      var cancel = BotToast.showLoading();
      await MessageManager.instance.saveMessages();
      cancel();
      BotToast.showText(text: "消息记录保存成功(๑•ω•๑)");
      Get.back();
    }
  }

  bool checkAddtionButtonUse(){
    //为空或者最后为不可追加列表
    return MessageManager.instance.messages.isEmpty ||
        [2,3,5].contains(MessageManager.instance.messages.last["senderId"]) ||
        (loadImgPath != "" && MessageManager.instance.messages.last["senderId"] == 4);
  }


  //双击编辑消息框
  void onMessageBoxDoubleTap(int index)async{
    EMessageBox emb = EMessageBox.fromMap(MessageManager.instance.messages[index]);
    var result = await Get.to(()=>MessageEditPage(chatTileUID: widget.chatTileUID,messageBox: emb));
    if(result == null) return;
    if(result["command"] == "save"){
      setState(() {
        MessageManager.instance.alterMessageBox(index,result["box"]);
      });
    }else if(result["command"] == "delete"){
      setState(() {
        MessageManager.instance.deleteMessageBox(index);
      });
    }
  }

  //点击发送按钮时
  void sendButtonClick(){
    if(input.text.isEmpty) return;
    String message = input.text;
    if(loadImgPath != ""){
      message = "$loadImgMethod:://$loadImgPath";
      loadImgPath = "";
    }
    EMessageBox em = EMessageBox(
        currentStudent.id,
        currentStudentSkinIndex.value,
        0,
        currentStudent.givenName["cn"],
        [message],
        false,
        {});
    if(currentSelectedIndex.value>-1){
      MessageManager.instance.insertMessageBox(currentSelectedIndex.value,em);
    }else{
      MessageManager.instance.addMessageBox(em);
    }
    setState(() {
      input.text = "";
    });
    if(currentSelectedIndex.value==-1) {
      scrollToBottom();
    }else{
      currentSelectedIndex.value = -1;
    }
  }

  //点击追加按钮时
  void addtionButtonClick(){
    if(input.text.isEmpty) return;
    String message = input.text;
    if(loadImgPath != ""){
      message = "URL:://$loadImgPath";
      loadImgPath = "";
    }
    MessageManager.instance.addMessage(message);
    setState(() {
      input.text = "";
    });
    scrollToBottom();
  }

  //保存消息按钮
  Future saveButtonClick()async{
    var cancel = BotToast.showLoading();
    await MessageManager.instance.saveMessages();
    BotToast.showText(text: "消息记录保存成功(๑•ω•๑)");
    cancel();
  }

  //长按MessageBox效果
  void messageBoxHoldTap(int index){
    if(currentSelectedIndex.value == index) {
      currentSelectedIndex.value = -1;
    } else {
      currentSelectedIndex.value = index;
    }
  }

  //表情差分按钮
  void emojiButtonClick()async{
    if(currentStudent.release < 2){
      var result = await Get.dialog(StudentEmojiDialog(studentID: currentStudent.id));
      if(result == null) return;
      input.text = "[图片已加载]";
      loadImgMethod = "URL";
      loadImgPath = result["url"];
    }else{
      Directory dir = Directory(join(AppLibrary.applicationPath,"DIYemotion",currentStudent.id.toString()));
      if(!dir.existsSync()){
        BotToast.showText(text: "未导入该自定义学生的差分");
        return;
      }
      var cancel = BotToast.showLoading();
      var files = dir.listSync();
      cancel();
      var result = await Get.dialog(DIYEmojiDialog(sendID: currentStudent.id, facePaths: files));
      if(result == null) return;
      input.text = "[图片已加载]";
      loadImgMethod = "IMG";
      loadImgPath = result;
    }
  }

  //图片按钮
 void imagePickerClick()async{
    BotToast.showText(text: "正在转存图片...");
    var cancel = BotToast.showLoading();
    String savePath = join(AppLibrary.applicationPath,"PictureCache","Messages",widget.chatTileUID);
    String fileName = await getPictureFromDevice(savePath);
    cancel();
    if(fileName == "error") return;
    input.text = "[图片已加载]";
    loadImgPath = fileName;
    loadImgMethod = "IMG";
 }

 //添加常用学生
 void addUsualStudent()async{
    EStudent? student = await Get.to(()=>const SelectPage());
    if(student == null) return;
    int skinIndex = 0;
    if(student.skinList.length > 1){
      skinIndex = ( await Get.dialog(skinIndexSelectDialog(student.skinList)) )?? 0;
    }
    setState(() {
      StudentManager.instance.addUsualStudent(student.id,skinIndex);
    });
 }

 //删除常用学生
  void deleteUsualStudent(int index)async{
    StudentManager.instance.deleteUsualStudent(index);
  }

  void screenShotButton()async{
    var result = await Get.dialog(ScreenShotDialog());
    if(result == null) return;
    await saveButtonClick();
    int x = 0;
    if(result["command"] == "every"){
      x = result["x"];
    }else if(result["command"] == "part"){
      x = (MessageManager.instance.messages.length / result["x"]).ceil();
    }else if(result["command"] == "after"){
      if(currentSelectedIndex.value < 0){
        BotToast.showText(text: "还未选中消息盒子");
        return;
      }
      int sP = currentSelectedIndex.value;
      int eP = sP + result["x"] as int;
      if(eP>MessageManager.instance.messages.length-1){
        eP = MessageManager.instance.messages.length-1;
      }
      if(AppLibrary.appLandscapeMode){
        WindowHomeState.setRightPage(ScreenShotPage(startPointer: sP, endPointer: eP));
      }else{
        await Get.to(()=>ScreenShotPage(startPointer: sP, endPointer: eP));
      }
      return;
    }else if(result["command"] == "whole"){
      if(AppLibrary.appLandscapeMode){
        WindowHomeState.setRightPage(ScreenShotPage(startPointer: 0, endPointer: MessageManager.instance.messages.length));
      }else{
        await Get.to(()=>ScreenShotPage(startPointer: 0, endPointer: MessageManager.instance.messages.length));
      }
      return;
    }
    if(GetPlatform.isMobile){
      for(var i = 0;i<MessageManager.instance.messages.length;i=i+x){
        var endPointer = i+x;
        if(endPointer >= MessageManager.instance.messages.length){
          endPointer = MessageManager.instance.messages.length;
        }
        if(AppLibrary.appLandscapeMode){
          WindowHomeState.setRightPage(ScreenShotPage(startPointer: i, endPointer: endPointer));
        }else{
          await Get.to(()=>ScreenShotPage(startPointer: i, endPointer: endPointer));
        }
      }
    }
  }

  void playButtonClick()async{
    await saveButtonClick();
    if(AppLibrary.appLandscapeMode){
      WindowHomeState.setRightPage(PlayPage(startPointer: 0, endPointer: MessageManager.instance.messages.length-1));
    }else{
      await Get.to(()=>PlayPage(startPointer: 0, endPointer: MessageManager.instance.messages.length-1));
    }

  }

 //选择常用学生的皮肤
 Widget skinIndexSelectDialog(List skinList){
    return AlertDialog(
      content: SizedBox(
        height: 200,
        child: SingleChildScrollView(
          child: Column(
            children: skinList.map<Widget>((element){
              return ListTile(
                title: Text(element["skin"]==""?"普通":element["skin"]),
                onTap: ()=>Get.back(result:skinList.indexOf(element)),
              );
            }).toList(),
          ),
        ),
      ),
    );
 }

}
