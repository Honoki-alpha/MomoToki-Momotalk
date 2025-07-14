import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:motoki/Utils/EventBus.dart';
import 'package:motoki/Views/Home/WindowHome.dart';
import 'package:path/path.dart';
import '../../AppData/AppLibrary.dart';
import '../../AppData/UserConfig.dart';
import '../../Components/MessageBox.dart';
import '../../Components/StudentCircleAvatar.dart';
import '../../Dialog/DIYEmojiDialog.dart';
import '../../Dialog/ScreenShotDialog.dart';
import '../../Dialog/StudentEmojiDialog.dart';
import '../../Entity/EMessageBox.dart';
import '../../Entity/EStudent.dart';
import '../../Managers/MessageManager.dart';
import '../../Managers/Students.dart';
import '../../Managers/ThemeManager.dart';
import '../../Utils/WidgetUtils.dart';
import '../Secondary/SelectPage.dart';
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
  EStudent currentStudent = Students().studentMap.entries.first.value;
  RxInt currentStudentSkinIndex = 0.obs;
  //插入的位置(后续更新了删除，现在为选择的消息盒子)
  RxInt currentSelectedIndex = RxInt(-1);
  //聊天滑块
  ScrollController listController = ScrollController();
  //输入框
  TextEditingController input = TextEditingController();
  //是否禁用追加按钮
  bool disableAddtionButton = false;
  //功能栏是否可见
  RxBool toolBarVisible = false.obs;
  //是否直接发送到右侧
  RxBool isRightMessage = false.obs;
  //消息内容是否只读
  bool textFileldReadOnly = false;
  //当前进度条
  RxDouble nowProgress = 1.0.obs;

  //载入的图片路径
  String loadImgPath = "";
  String loadImgMethod = "URL";

  //快捷键
  final HotKey _attachKey = HotKey(KeyCode.enter,modifiers: [KeyModifier.control],scope: HotKeyScope.inapp);
  final HotKey _sendKey = HotKey(KeyCode.enter,scope:HotKeyScope.inapp);
  final HotKey _emojiKey = HotKey(KeyCode.keyQ,modifiers: [KeyModifier.control],scope:HotKeyScope.inapp);
  final HotKey _imgKey = HotKey(KeyCode.keyW,modifiers: [KeyModifier.control],scope:HotKeyScope.inapp);
  final HotKey _addUsuKey = HotKey(KeyCode.keyE,modifiers: [KeyModifier.control],scope:HotKeyScope.inapp);
  final HotKey _circleKey = HotKey(KeyCode.keyA,modifiers: [KeyModifier.control],scope:HotKeyScope.inapp);
  final HotKey _playKey = HotKey(KeyCode.keyD,modifiers: [KeyModifier.control],scope:HotKeyScope.inapp);
  final HotKey _captureKey = HotKey(KeyCode.keyF,modifiers: [KeyModifier.control],scope:HotKeyScope.inapp);
  final HotKey _saveKey = HotKey(KeyCode.keyS,modifiers: [KeyModifier.control],scope:HotKeyScope.inapp);

  @override
  void initState() {
    super.initState();
    //初始化快捷键
    if(GetPlatform.isDesktop) initHotKey();
    currentStudent = Students().getStudentById(MessageManager.instance.currentStudentId);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top,SystemUiOverlay.bottom]);
    scrollToBottom();
    //添加列表滚动监听
    listController.addListener((){
      nowProgress.value = listController.position.pixels/listController.position.maxScrollExtent;
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    if(GetPlatform.isDesktop) destoryHotKey();
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
    await hotKeyManager.register(_sendKey,keyDownHandler: (hotkey)=>sendButtonClick());
    await hotKeyManager.register(_attachKey,keyDownHandler: (hotkey)=>addtionButtonClick());
    await hotKeyManager.register(_emojiKey,keyDownHandler: (hotkey)=>emojiButtonClick());
    await hotKeyManager.register(_imgKey,keyDownHandler: (hotkey)=>imagePickerClick());
    await hotKeyManager.register(_addUsuKey,keyDownHandler: (hotkey)=>addUsualStudent());
    await hotKeyManager.register(_circleKey,keyDownHandler: (hotkey)=>circleEmojiButtonClick());
    await hotKeyManager.register(_playKey,keyDownHandler: (hotkey)=>playButtonClick());
    await hotKeyManager.register(_captureKey,keyDownHandler: (hotkey)=>screenShotButton());
    await hotKeyManager.register(_saveKey,keyDownHandler: (hotkey)=>saveButtonClick());
  }

  void destoryHotKey(){
    hotKeyManager.unregister(_sendKey);
    hotKeyManager.unregister(_attachKey);
    hotKeyManager.unregister(_emojiKey);
    hotKeyManager.unregister(_imgKey);
    hotKeyManager.unregister(_captureKey);
    hotKeyManager.unregister(_addUsuKey);
    hotKeyManager.unregister(_circleKey);
    hotKeyManager.unregister(_playKey);
    hotKeyManager.unregister(_saveKey);
  }

  @override
  Widget build(BuildContext context) {
    //currentStudent = Students().getStudentById(MessageManager.instance.currentStudentId);
    disableAddtionButton = checkAddtionButtonUse();
    return PopScope(
        canPop: false,
        onPopInvoked: onPopInvoked,
        child: Scaffold(
          appBar: WidgetUtils().getPlatformAppBar(
              Obx(()=> Text(Students().getStudentName(currentStudent.id, skinIndex: currentStudentSkinIndex.value))),
            actions: [
              IconButton(onPressed: saveButtonClick, icon: const Icon(Icons.save_as_rounded)),
              //IconButton(onPressed: notificationButtonClick, icon: const Icon(Icons.notifications))
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
                                    color: Color.fromRGBO(70, 70, 70,currentSelectedIndex.value==index?0.5:0),
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
                                  child: StudentCircleAvatar(id:
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
                            ),
                            hintText: "当前共${MessageManager.instance.messages.length}条消息...",
                            border: InputBorder.none
                        ),
                        style: const TextStyle(
                            fontSize: 13
                        ),
                        maxLines: null,
                      )
                  ),

                  const SizedBox(width: 7,),


                ],
              ),
              Row(children: [
                Expanded(flex: 4, child: SizedBox(height: 45,child:ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      IconButton(onPressed: emojiButtonClick, icon: const Icon(Icons.emoji_emotions)),
                      IconButton(onPressed: imagePickerClick, icon: const Icon(Icons.image)),
                      IconButton(onPressed: addUsualStudent, icon: const Icon(Icons.person_add)),
                      IconButton(onPressed: circleEmojiButtonClick, icon: const Icon(Icons.shield)),
                      IconButton(onPressed: screenShotButton, icon: const Icon(Icons.crop)),
                      IconButton(onPressed: playButtonClick, icon: const Icon(Icons.play_circle)),

                    ]))),
                //点击“追加”按钮效果
                Expanded(flex: 1,child: MaterialButton(
                    onPressed: disableAddtionButton?null:addtionButtonClick,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    // style: ButtonStyle(
                    //     backgroundColor: WidgetStateProperty.all(Colors.purple)
                    // ),
                    color: Colors.purple,
                    disabledColor: Colors.grey,
                    child:const Text("追加",style:TextStyle(color: Colors.white,fontSize: 12))),),
                //点击“发送”按钮效果
                Expanded(flex: 1,child: Obx(()=>MaterialButton(
                    onLongPress: (){
                      isRightMessage.value = !isRightMessage.value;
                    },
                    onPressed:sendButtonClick,
                    color: isRightMessage.value?const Color(0xFF97E7EC):const Color(0xFFE595B5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    // style: ButtonStyle(
                    //     backgroundColor: WidgetStateProperty.all(
                    //         isRightMessage.value?const Color(0xFF97E7EC):const Color(0xFFE595B5)
                    //     )
                    // ),
                    child:Text(currentSelectedIndex.value>-1?"插入":"发送",style:TextStyle(fontSize: 12)))),),
              ]),
              Obx(()=>Container(
                child: toolBarVisible.value?Column(
                  children: [
                    SizedBox(
                        width: 500,
                        height: 30,
                        child: Obx(()=>Slider(
                          divisions: 20,
                          label: "${(nowProgress.value *100).floor()}%",
                          value: nowProgress.value, onChanged: (double value) {
                            nowProgress.value = value; },
                          onChangeEnd: (double value){
                            listController.jumpTo(nowProgress.value*listController.position.maxScrollExtent);
                          },
                        ))),
                    SizedBox(
                        height: 120,
                        child: GridView.builder(
                            itemCount: Students().toolStudentMap.length+Students().usualStudents.length,
                            gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisSpacing: 5,
                                crossAxisCount: AppLibrary.appLandscapeMode?9:7,
                                childAspectRatio: 1.0),//显示区域宽高相等
                            itemBuilder: (context, index){
                              int iconId = 0;
                              int iconSkin = 0;
                              int length = Students().toolStudentMap.length;
                              if(index<length){
                                iconId = index + 1;
                              }else{
                                List studentAndSkin = Students().usualStudents[index-length].split("||");
                                iconId = int.parse(studentAndSkin[0]);
                                iconSkin = int.parse(studentAndSkin[1]);
                              }
                              return GestureDetector(
                                child:StudentCircleAvatar(id:iconId,skinIndex: iconSkin),
                                onTap: (){
                                  currentStudentSkinIndex.value = iconSkin;
                                  currentStudent = Students().getStudentById(iconId);

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
        [2,3,5,6].contains(MessageManager.instance.messages.last["senderId"]) ||
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
        "",
        [message],
        isRightMessage.value,
        {});
    if(currentSelectedIndex.value>-1){
      MessageManager.instance.insertMessageBox(currentSelectedIndex.value,em);
    }else{
      MessageManager.instance.addMessageBox(em);
    }
    if(UserConfig.autoSaveMessage) saveButtonClick();
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
      message = "$loadImgMethod:://$loadImgPath";
      loadImgPath = "";
    }
    MessageManager.instance.addMessage(message);
    setState(() {
      input.text = "";
    });
    scrollToBottom();
  }

  //保存消息按钮
  Future saveButtonClick({bool? noneDialog})async{
    var cancel = BotToast.showLoading();
    await MessageManager.instance.saveMessages();
    String tipText = "消息记录保存成功";
    int totalLength = MessageManager.instance.messages.length;
    if(totalLength > 1000 && totalLength<2000){
      tipText = "已保存，但当前消息较长";
    }else if(totalLength > 2000){
      tipText = "已保存，当前消息记录过长，建议新建";
    }
    if(noneDialog != true) BotToast.showText(text: tipText);
    cancel();
  }


  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  Widget notificationDialog(){
    return AlertDialog(
      content: SizedBox(
        width: 300,
        height: 120,
        child: Column(
          children: [
            Expanded(child: TextField(controller: title,decoration: const InputDecoration(helperText: "通知标题"))),
            Expanded(child: TextField(controller: content,decoration: const InputDecoration(helperText: "通知内容")))
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: (){Get.back(result:true);}, child: const Text("发送"))
      ],
    );
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
    if(currentStudent.id < 100) return;
    if(currentStudent.release != 2 && !UserConfig.applyOfflineMode){
      var result = await Get.dialog(StudentEmojiDialog(studentID: currentStudent.id));
      if(result == null) return;
      input.text = "[图片已加载]";
      loadImgMethod = "URL";
      loadImgPath = result["url"];
    }
    else{
      //获取自定义途径
      Directory dir = Directory(join(AppLibrary.applicationPath,"DIYemotion",currentStudent.id.toString()));
      if(currentStudent.release != 2){
        dir = Directory(join(AppLibrary.faceBasePath,"Resources","Emotions","${currentStudent.id}"));
      }
      if(!dir.existsSync()){
        BotToast.showText(text: "未找到该学生差分！");
        return;
      }
      var cancel = BotToast.showLoading();
      var files = dir.listSync();
      cancel();
      var result = await Get.dialog(DIYEmojiDialog(sendID: currentStudent.id, facePaths: files));
      if(result == null) return;
      input.text = "[图片已加载]";
      loadImgMethod = "IMG";
      loadImgPath = result.path;
    }
  }

  void circleEmojiButtonClick()async{
    if(UserConfig.applyOfflineMode){
      //获取自定义途径
      Directory dir = Directory(join(AppLibrary.faceBasePath,"Resources","Emotions","7"));
      if(!dir.existsSync()){
        BotToast.showText(text: "未找到该学生差分！");
        return;
      }
      var cancel = BotToast.showLoading();
      var files = dir.listSync();
      cancel();
      var result = await Get.dialog(DIYEmojiDialog(sendID: 7, facePaths: files));
      if(result == null) return;
      input.text = "[图片已加载]";
      loadImgMethod = "IMG";
      loadImgPath = result.path;
    }
    var result = await Get.dialog(const StudentEmojiDialog(studentID: 7,height: 370));
    if(result == null) return;
    input.text = "[图片已加载]";
    loadImgMethod = "URL";
    loadImgPath = result["url"];
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
    List<EStudent>? students = await Get.to(()=>const SelectPage(multiple: true,));
    if(students == null) return;
    setState(() {
      for(var student in students){
        Students().addUsualStudent(student.id,0);
      }
    });
 }

 //删除常用学生
  void deleteUsualStudent(int index)async{
    if(index < Students().toolStudentMap.length) return;
    int newIndex = index - Students().toolStudentMap.length;
    setState(() {
      Students().deleteUsualStudent(newIndex);
    });
    BotToast.showText(text: "删除成功！");
  }

  void screenShotButton()async{
    var result = await Get.dialog(ScreenShotDialog());
    if(result == null) return;
    int x = 0;
    //检测输入是否为0
    if(result["x"]==0 && result["command"] != "whole") {
      BotToast.showText(text: "输入的值需大于0");
      return;
    }
    //检测是否有消息
    if(MessageManager.instance.messages.isEmpty){
      BotToast.showText(text: "空消息无法截图");
      return;
    }
    await saveButtonClick();
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
      if(eP>=MessageManager.instance.messages.length){
        eP = MessageManager.instance.messages.length;
      }
      await gotoRightPageByPf(ScreenShotPage(startPointer: sP, endPointer: eP));
      WindowHomeState.setRightPage(this.widget);
      return;
    }else if(result["command"] == "whole"){
      await gotoRightPageByPf(ScreenShotPage(startPointer: 0, endPointer: MessageManager.instance.messages.length));
      WindowHomeState.setRightPage(this.widget);
      return;
    }
    for(var i = 0;i<MessageManager.instance.messages.length;i=i+x){
      var endPointer = i+x;
      if(endPointer >= MessageManager.instance.messages.length){
        endPointer = MessageManager.instance.messages.length;
      }
      await gotoRightPageByPf(ScreenShotPage(startPointer: i, endPointer: endPointer));
    }
    WindowHomeState.setRightPage(this.widget);
  }

  Future gotoRightPageByPf(Widget page)async{
    if(AppLibrary.appLandscapeMode){
      WindowHomeState.setRightPage(page);
      AppLibrary.globalEvent.fire(ScreenShotEvent());
      await Future.delayed(const Duration(seconds: 4));
    }else{
      await Get.to(()=>page);
    }
  }

  void playButtonClick()async{
    var result = await Get.dialog(playInfoDialog());
    if(result != true) return;
    await saveButtonClick(noneDialog: true);
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
        height: 140,
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

 TextEditingController ellipsis = TextEditingController();
 TextEditingController perMessage = TextEditingController();
 Widget playInfoDialog(){
   ellipsis.text = AppLibrary.ellipsisTime.toString();
   perMessage.text = AppLibrary.perMessageTime.toString();
   return AlertDialog(
      title: const Text("播放设置"),
      content: SizedBox(
        height: 150,
        child: Column(
          children: [
            Expanded(child: TextField(
              keyboardType: TextInputType.number,
              controller: ellipsis,
              decoration: const InputDecoration(
                helperText: "等待动画持续时长(ms)"
              ),
            )),
            Expanded(child: TextField(
              keyboardType: TextInputType.number,
              controller: perMessage,
              decoration: const InputDecoration(
                helperText: "每条消息间隔时长(ms)"
              ),
            )),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: (){
          AppLibrary.ellipsisTime = max(int.parse(ellipsis.text), 500);
          AppLibrary.perMessageTime = max(int.parse(perMessage.text), 500);
          Get.back(result: true);
        }, child: const Text("确认"))
      ],
    );
 }

}
