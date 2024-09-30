import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/Managers/MessageManager.dart';
import 'package:motoki/Views/MessagePage/Chat.dart';
import 'package:motoki/Views/SettingPage/Configure.dart';
import 'package:window_manager/window_manager.dart';

import '../../Entity/EStudent.dart';
import '../../Managers/ChatGroupManager.dart';
import '../../Utils/CommonFunctions.dart';
import '../Secondary/SelectPage.dart';

class WindowHome extends StatefulWidget{
  const WindowHome({super.key});

  @override
  State<StatefulWidget> createState() =>WindowHomeState();

}

class WindowHomeState extends State<WindowHome>{

  int currentPageIndex = 0;

  static bool tabBarShow = false;
  static Rx<Widget> leftPage =( const Center(child: Text("请选择消息")) ).obs;
  static Rx<Widget> rightPage = ( const Center(child: Text("请选择学生")) ).obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setLeftPage(const Chat());
    tabBarShow = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    getLastVersion();
  }

  @override
  Widget build(BuildContext context) {
    AppLibrary.appLandscapeMode = true;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details){
        if(!GetPlatform.isDesktop) return;
        WindowManager.instance.startDragging();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: GetPlatform.isDesktop?75:null,
          title:const Text("MomoTalk",style: TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.bold,
              wordSpacing: 30
          ),),leading: Image.asset("assets/images/icon/momo.png",),
          actions: GetPlatform.isDesktop?[
            Padding(padding: const EdgeInsets.all(15),child: IconButton(onPressed: (){
              windowManager.minimize();
            }, icon: const Icon(Icons.remove)),),
            Padding(padding: const EdgeInsets.all(10),child: IconButton(onPressed: (){
              windowManager.close();
            }, icon: const Icon(Icons.close))),
          ]:[],),
        body: Row(
          children: [
            Expanded(flex:1,child: Container(color: const Color.fromRGBO(74,91,111, 1),child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    //设置选中颜色
                    color: currentPageIndex== 0?const Color.fromRGBO(255, 255, 255, 0.3):null,
                    child: IconButton(iconSize: 30,onPressed: (){
                      setState(() {
                        tabBarShow = true;
                        currentPageIndex = 0;
                      });
                      leftPage.value = const Center(child: Chat(),);
                    }, icon: Image.asset("assets/images/icon/home_person.png"),
                      color: Color.fromRGBO(255, 255, 255,currentPageIndex == 0?1.0:0.3),
                    )),
                Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    //设置选中颜色
                    color: currentPageIndex == 1?const Color.fromRGBO(255, 255, 255, 0.3):null,
                    child: IconButton(iconSize: 30,onPressed: (){
                      setState(() {
                        tabBarShow = false;
                        currentPageIndex = 1;
                      });
                      leftPage.value = const Center(child:Configure());
                    }, icon: Image.asset("assets/images/icon/home_mes.png"),
                      color: Color.fromRGBO(255, 255, 255,currentPageIndex == 1?1.0:0.3),))
              ],))),
            Expanded(flex:5,child: Column(
              children: [
                if(tabBarShow) Expanded(flex:1,child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(onTap: addChatStudent,child: Image.asset("assets/images/chattools/add_btn.png")),
                    InkWell(onTap: saveButtonClick,child: Image.asset("assets/images/chattools/save_btn.png")),
                    InkWell(onTap: addGroupDialog,child: Image.asset("assets/images/chattools/group_add_btn.png"))
                  ],
                )),
                Expanded(flex:12,child: Obx(()=>Container(child: leftPage.value,)))
              ],
            )),
            Expanded(flex:5,child: Obx(()=>SizedBox(child: rightPage.value))),
          ],
        ),
      ),
    );
  }


  static void setLeftPage(Widget page){
    tabBarShow = false;
    leftPage.value = Center(child: page);
  }

  static void setRightPage(Widget page){
    rightPage.value = Center(child: page);
  }

  void addChatStudent() async{
    if(ChatGroupManager.instance.selectedGroupIndex < 0){
      BotToast.showText(text: "未选择分组，请展开任意分组");
      return;
    }
    EStudent? student = await Get.to(()=>const SelectPage());
    if(student == null) return;
    setState(() {
      ChatGroupManager.instance.addChatTile(student);
    });
  }

  void addGroupDialog()async{
    Get.dialog(inputDialog());
  }

  void saveButtonClick()async{
    if(MessageManager.instance.messages.isNotEmpty || MessageManager.instance.aiMessages.isNotEmpty){
      var cancel = BotToast.showLoading();
      await MessageManager.instance.saveMessages();
      await MessageManager.instance.saveAIMessages();
      cancel();
    }
    BotToast.showText(text: "保存消息记录成功");
  }

  TextEditingController inputField = TextEditingController();
  //输入对话框
  Widget inputDialog(){
    return AlertDialog(
      title: const Text("请输入分组名"),
      content: TextField(
        controller: inputField,
      ),
      actions: [
        TextButton(onPressed: (){
          Get.back();
          addGroupButton();
        }, child: const Text("添加"))
      ],
    );
  }

  void addGroupButton(){
    if(inputField.text.isEmpty) return;
    ChatGroupManager.instance.addChatTileGroup(inputField.text);
    inputField.text = "";
  }

}