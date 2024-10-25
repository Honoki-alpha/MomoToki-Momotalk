import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/Entity/EMessageBox.dart';
import 'package:motoki/Managers/StudentManager.dart';
import 'package:motoki/Managers/ThemeManager.dart';
import 'package:motoki/Utils/CommonComponents.dart';
import 'package:motoki/Views/Home/WindowHome.dart';

class Storypage extends StatelessWidget{
  const Storypage({super.key, required this.messageBox});
  final EMessageBox messageBox;


  @override
  Widget build(BuildContext context) {
    Map storage = messageBox.storageInfo;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(3),
        margin: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius:const BorderRadius.all(Radius.circular(8)),
          border: const Border(
            top:BorderSide(width: 1,color: Colors.black),
            bottom:BorderSide(width: 1,color: Colors.black),
            left:BorderSide(width: 1,color: Colors.black),
            right:BorderSide(width: 1,color: Colors.black)
          ),
          color: ThemeManager.currentTheme.cardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(leading: const Text("好感故事"),trailing: IconButton(icon:const Icon(Icons.close),onPressed: backToLastPage,)),
            const Divider(indent: 10,endIndent: 10,color: Colors.black54,),
            Stack(
              children: [
                getCicleStudentAvatar(
                  storage["id"] ?? 114,skinIndex:storage["skin"] ?? 0,customWidth: 100
                ),
                Positioned(right: 0,bottom: 0, height: 40,width: 40,
                    child: Container(
                      decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/source/heart.png"),

                      )
                  ),
                      alignment: Alignment.center,
                      child: Text(storage["level"] ?? "50"),
                ))
              ],
            ),
            Text(StudentManager.instance.getStudentName(storage["id"] ?? 114,showFullName: true)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D4563),
                    borderRadius: BorderRadius.all(Radius.circular(4))
                  ),
                  child: Text("章节 ${storage["ep"] ?? "03"}",style: const TextStyle(color: Colors.white),),
                ),
                Text(storage["title"] ?? "私たちの物語"),
              ],
            ),
            Image.asset("assets/images/source/reward.png",height: 30,),
            Stack(
              children: [
                Image.asset("assets/images/source/stone.png",fit:BoxFit.fitHeight,height: 60,),
                Positioned(right:10,bottom:5,child: Text("x${storage["stone"]??60}"))
              ],
            ),
            Image.asset("assets/images/source/enter.png",height: 60,)
          ],
        ),
      ),
    );
  }

  void backToLastPage(){
    if(AppLibrary.appLandscapeMode){
      WindowHomeState.setRightPage(WindowHomeState.tempWidget);
    }else{
      Get.back();
    }
  }

}