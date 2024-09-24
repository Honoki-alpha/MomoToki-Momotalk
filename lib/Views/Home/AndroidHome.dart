import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/Entity/EStudent.dart';
import 'package:motoki/Managers/ChatGroupManager.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import '../../AppData/AppConstant.dart';
import '../Secondary/SelectPage.dart';
import '../MessagePage/Chat.dart';
import '../SettingPage/Configure.dart';

class AndroidHome extends StatefulWidget{
  const AndroidHome({super.key});

  @override
  State<StatefulWidget> createState() => _homeState();
}

class _homeState extends State<AndroidHome>{
  int popTimes = 0;
  bool floatingButtonVisable = true;
  RxBool isMessagePage = true.obs;
  //测试页面跳转
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppLibrary.appLandscapeMode = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top,SystemUiOverlay.bottom]);
    kawaiNotification();
  }

  //弹出两个小可爱的问候
  void kawaiNotification(){
    var chara = AppLibrary.randGetFromList(AppConstant.kawaiName);
    BotToast.showCustomNotification(toastBuilder: (b){
      return Material(color: Colors.transparent,child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1,horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5)
        ),
        child: ListTile(
          title: Text("From $chara"),
          subtitle: Text("${AppLibrary.randGetFromList(AppConstant.greeting)}"),
          leading: Image.asset("assets/images/expression/$chara.png"),
        ),
      ),);
    },duration:const Duration(seconds: 3) );
  }

  //导航栏布局
  List navigationPageList = [const Chat(),const Configure()];
  //悬浮添加按钮在其他页面不显示
  int navigationCurrentPage = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: onWillPopHappend,
        child: Scaffold(
          appBar:navigationCurrentPage==0?AppBar(title: const Text("MomoTalk"),leading: Image.asset("assets/images/icon/momo.png")):null,
          body:navigationPageList[navigationCurrentPage],
          bottomNavigationBar: BottomAppBar(
            height: 60,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: IconButton(
                      onPressed: (){
                  setState(() {
                    navigationCurrentPage = 0;
                  });
                },
                      icon: const Icon(Icons.message),
                      color: navigationCurrentPage==0?ThemeManager.currentTheme.highlightColor:Colors.black45,)
                ),
                Expanded(
                    child: IconButton(
                      tooltip: "Hello",
                      onPressed: (){
                        setState(() {
                          navigationCurrentPage = 1;
                        });
                      },
                      icon: const Icon(Icons.more_horiz),
                      color: navigationCurrentPage==1?ThemeManager.currentTheme.highlightColor:Colors.black45,)
                ),
              ],
            ),
            ),
          floatingActionButton: SpeedDial(
            overlayColor: Colors.black45,
            direction: SpeedDialDirection.up,
            children: [
              SpeedDialChild(child: const Icon(Icons.add),onTap: addChatStudent,label: "添加学生"),
              SpeedDialChild(child: const Icon(Icons.add_road),onTap: addGroupDialog,label: "添加分组"),
            ],
            icon: Icons.add,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ));
  }

  Future<bool> onWillPopHappend(bool didPop)async{
    popTimes++;
    if(popTimes == 2){
      return true;
    }else{
      Timer(const Duration(seconds: 1), () {
        popTimes = 0;
      });
      return false;
    }
  }


  void addChatStudent() async{
    EStudent? student = await Get.to(()=>const SelectPage());
    if(student == null) return;
    setState(() {
      ChatGroupManager.instance.addChatTile(student);
    });
  }

  void addGroupDialog()async{
    Get.dialog(inputDialog());
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