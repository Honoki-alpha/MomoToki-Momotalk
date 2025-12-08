import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:motoki/Components/MessageBox.dart';

class DIYMessageBox extends StatelessWidget {
  const DIYMessageBox({super.key});
  @override
  Widget build(BuildContext context) {

    var id = 115.obs;
    var edit = 1.obs;
    var radius = 6.0.obs;

    //当前颜色
    var currentRed = 76.0.obs;
    var currentGreen = 91.0.obs;
    var currentBlue = 112.0.obs;


    return PopScope(child: Scaffold(
      appBar: AppBar(title: Text("自定义对话框")),
      body: Container(
        padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  ElevatedButton(onPressed: (){
                    id.value = 115;
                  }, child: const Text("普通消息")),
                  ElevatedButton(onPressed: (){
                    id.value = 1;
                  }, child: const Text("老师消息"))
                ],
              ),
              Obx(()=>MessageBox(index: edit.value, isPlayMode: false,tempBox: {
                "senderId":id.value,
                "senderSkinIndex":0,
                "messageType":0,
                "sendMessageName":"演示",
                "messageContentList":["你好","这是一段消息演示"],
                "boxAlign":false
              })),
              const Text("圆角弧度"),
              Obx(()=>Slider(value: radius.value,max: 10,min: 0,onChanged: (double value){
                radius.value = value;
                UserConfig.boxRadius = value;
                edit.value = value.ceil();
              })),
              const Text("颜色编辑，松开以应用改变"),
              const Text("颜色编辑(R)"),
              Obx(()=>Slider(value: currentRed.value,min: 0,max: 255, onChanged: (value){
                currentRed.value = value;
              },onChangeEnd: (value){
                if(id.value == 1){
                  UserConfig.senseiBoxColor[0] = value.ceil();
                }else{
                  UserConfig.normalBoxColor[0] = value.ceil();
                }
                edit.value =value.ceil();
              })),
              const Text("颜色编辑(G)"),
              Obx(()=>Slider(value: currentGreen.value, min: 0,max: 255,onChanged: (value){
                currentGreen.value = value;
              },onChangeEnd: (value){
                if(id.value == 1){
                  UserConfig.senseiBoxColor[1] = value.ceil();
                }else{
                  UserConfig.normalBoxColor[1] = value.ceil();
                }
                edit.value =value.ceil();
              })),
              const Text("颜色编辑(B)"),
              Obx(()=>Slider(value: currentBlue.value, min: 0,max: 255,onChanged: (value){
                currentBlue.value = value;
              },onChangeEnd: (value){
                if(id.value == 1){
                  UserConfig.senseiBoxColor[2] = value.ceil();
                }else{
                  UserConfig.normalBoxColor[2] = value.ceil();
                }
                edit.value =value.ceil();
              })),
              ElevatedButton(onPressed: ()=>UserConfig().saveBoxDiy(), child: const Text("应用颜色和边距修改")),
              ElevatedButton(onPressed: (){
                UserConfig.normalBoxColor = [76,91,112];
                UserConfig.senseiBoxColor = [74,138,203];
                UserConfig.boxRadius = 6.0;
                edit.value = 0;
                UserConfig().saveBoxDiy();
              }, child: const Text("恢复默认数值"))
            ],
          ),
        ),
      ),
    ),onPopInvokedWithResult: (canpop,result){
      UserConfig.normalBoxColor = [76,91,112];
      UserConfig.senseiBoxColor = [74,138,203];
      UserConfig.boxRadius = 6.0;
    },);


  }
}