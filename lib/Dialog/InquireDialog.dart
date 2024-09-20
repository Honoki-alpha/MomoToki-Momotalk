import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class Inquiredialog extends StatefulWidget{
  const Inquiredialog({super.key, required this.title, required this.content});
  final String title;
  final String content;
  @override
  State<StatefulWidget> createState()=> _boolDialog();

}

class _boolDialog extends State<Inquiredialog>{
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.title),
      content: Text(widget.content),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text("取消"),
          onPressed: () => Get.back(result:false), // 关闭对话框
        ),
        CupertinoDialogAction(
          child:const Text("确认"),
          onPressed: () => Get.back(result:true),
        ),
      ],
    );
  }

}