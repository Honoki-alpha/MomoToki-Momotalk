import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Entity/EStudent.dart';
import '../Managers/StudentManager.dart';
class DIYEmojiDialog extends StatefulWidget{
  const DIYEmojiDialog({super.key, required this.sendID,required this.facePaths});
  final int sendID;
  final List<FileSystemEntity> facePaths;
  @override
  State<StatefulWidget> createState()=>_faceImgState();

}

class _faceImgState extends State<DIYEmojiDialog>{
  late final EStudent student;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    student = StudentManager.instance.getStudentById(widget.sendID);
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("表情列表"),
      content: SizedBox(
        height: 300,
        width: Get.width-200,
        child: GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(6),
            itemCount: widget.facePaths.length,
            gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 5,
              crossAxisCount: (Get.width/100).floor(), //每行3列
              childAspectRatio: 1.0, //显示区域宽高相等
            ), itemBuilder: (context, index){
          return GestureDetector(child:CircleAvatar(
              backgroundImage: FileImage(widget.facePaths[index] as File),backgroundColor: Colors.white,
          ),onTap: ()=>Get.back(result:widget.facePaths[index]),
            //如果是网络图片直接返回链接，否则返回路径
          );
        }),
      ),
    );
  }

}