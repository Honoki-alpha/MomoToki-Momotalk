import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/AppData/AppLibrary.dart';


// ignore: must_be_immutable
class ScreenShotDialog extends StatelessWidget{
  TextEditingController controller = TextEditingController();

  ScreenShotDialog({super.key});

  @override
  Widget build(BuildContext context) {
    if(controller.text.isEmpty)  controller.text=0.toString();
    return CupertinoAlertDialog(
      title: const Text("截图切割选项"),
      content: Material(
        child: TextField(
          keyboardType: TextInputType.number,
          controller: controller,
          decoration: const InputDecoration(
              hintText: "请输入X数值"
          ),
        ),
      ),
      actions: [
        CupertinoDialogAction(onPressed: (){Get.back(result: {"command":"every","x":int.parse(controller.text)});}, child:const Text("每X条一张图")),
        CupertinoDialogAction(onPressed: (){Get.back(result: {"command":"part","x":int.parse(controller.text)});}, child:const Text("共截X张图")),
        CupertinoDialogAction(onPressed: (){Get.back(result: {"command":"after","x":int.parse(controller.text)});}, child:const Text("从选中处向下截X条")),
        CupertinoDialogAction(onPressed: (){Get.back(result: {"command":"whole","x":0});}, child:const Text("整页截图"))
      ],
    );
  }


}
