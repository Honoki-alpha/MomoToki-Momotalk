import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../AppData/AppLibrary.dart';
import '../Managers/StudentManager.dart';

class StudentEmojiDialog extends StatelessWidget{
  const StudentEmojiDialog({super.key, required this.studentID,this.height});
  final int studentID;
  final double? height;
  @override
  Widget build(BuildContext context) {
    List gallery = StudentManager.instance.getStudentById(studentID).gallery;
    return AlertDialog(
      content: SizedBox(
        height: 400,
        width: 400,
        child: ListView(
          children: gallery.map<Widget>((group){
            return groupItem(group);
          }).toList(),
        ),
      ),
    );
  }

  Widget groupItem(Map item){
    return Column(
      children: [
        Text(item["title"]),
        SizedBox(
          height: height ?? 170,
          width: 300,
          child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 10,
            crossAxisCount: AppLibrary.appLandscapeMode?5:4,
            childAspectRatio: 1.0, //显示区域宽高相等
          ),
          children: item["images"].map<Widget>((url){
            return GestureDetector(onTap: ()=>iconClick("https:$url"),child: Image.network(
              "https:$url",
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress){
                if(loadingProgress == null){
                  return child;
                }else{
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                }
              },
            ),);
          }).toList(),
        ))
      ],
    );
  }

  void iconClick(String url){
    Get.back(result: {"url":url});
  }

}