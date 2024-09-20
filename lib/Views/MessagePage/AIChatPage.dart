import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/Components/MessageBox.dart';
import 'package:motoki/Managers/MessageManager.dart';
import 'package:motoki/Managers/StudentManager.dart';
import 'package:motoki/Utils/CommonComponents.dart';

class AIChatPage extends StatefulWidget{
  const AIChatPage({super.key});

  @override
  State<StatefulWidget> createState() => _AiChatPage();

}

class _AiChatPage extends State<AIChatPage>{
  ScrollController sc = ScrollController();
  TextEditingController input = TextEditingController();

  RxBool usualVisable = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:const Text("AI聊天")),
      body:getPageBody(),
    );
  }

  Widget getPageBody(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: Container(
          color: Colors.white,
          child: ListView.builder(
              shrinkWrap: true,
              controller: sc,
              itemCount: MessageManager.instance.aiMessages.length,
              itemBuilder: (context,index){
                return MessageBox(index:index, isPlayMode: true,tempBox: MessageManager.instance.aiMessages[index],);
              }),
        )),
        Row(
          children: [
            //expanded用于限制输入范围
            const SizedBox(width: 10,),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                    icon:GestureDetector(child: getCicleStudentAvatar(MessageManager.instance.currentStudentId),onTap: (){
                      usualVisable.value = !usualVisable.value;
                    },)
                ),
                controller: input,
                maxLines: null,
              ),
            ),
            //点击“发送”按钮效果
            ElevatedButton(onPressed: sendButtonClick, child:const Text("发送")),
          ],
        ),
        const SizedBox(height: 5,),
        Obx(()=>SizedBox(
          child: usualVisable.value?SizedBox(
              height: 120,
              child: GridView.builder(
                  itemCount: StudentManager.instance.usualStudents.length,
                  gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 5,
                    crossAxisCount: 8, //每行五列
                    childAspectRatio: 1.0, //显示区域宽高相等
                  ), itemBuilder: (context, index){
                return GestureDetector(
                  child: Container(),
                );
              })):const SizedBox()
        ))
      ],
    );
  }

  void sendButtonClick(){

  }
}