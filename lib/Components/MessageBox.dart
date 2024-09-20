import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import '../Entity/EMessageBox.dart';
import '../Managers/MessageManager.dart';
import '../Managers/StudentManager.dart';
import '../Utils/CommonComponents.dart';


class MessageBox extends StatefulWidget{
  const MessageBox({super.key,required this.index, required this.isPlayMode,this.tempBox});
  final int index;
  final bool isPlayMode;
  final Map? tempBox;
  @override
  State<StatefulWidget> createState() =>_messageBoxState();
}

class _messageBoxState extends State<MessageBox>{
  late EMessageBox messageBox;
  int playedIndex = 0;//播放过消息的条数
  //bool isPlayed = false;//是否是播放过的
  @override
  void initState() {
    super.initState();
    messageBox =  EMessageBox.fromMap(widget.tempBox ?? MessageManager.instance.messages[widget.index]);
    //如果不是播放模式或者全都播放过了
    Timer timer = Timer.periodic(const Duration(milliseconds: 1500), (t) {
      if(!mounted) return;
      setState(() {
        playedIndex++;
      });
    });
    if(widget.isPlayMode && playedIndex < messageBox.messageContentList.length){

    }else{
      timer.cancel();
    }

  }


  @override
  Widget build(BuildContext context) {
    messageBox =  EMessageBox.fromMap(MessageManager.instance.messages[widget.index]);
    switch(messageBox.senderId){
      case 1:return senseiBox();
      case 2:return asideBox();
      case 3:return asidetransBox();
      case 4:return replyBox();
      case 5:return storyBox();
      default:return nomalBox();
    }
  }

  //学生的消息盒子
  Widget nomalBox(){
    int rightIndex = messageBox.boxAlign?0:1;
    //头像
    Widget avatar = getCicleStudentAvatar(messageBox.senderId,skinIndex: messageBox.senderSkinIndex);
    return ListTile(
      titleAlignment: ListTileTitleAlignment.top,
      //判断对齐，显示头像位置
      leading:[null,avatar][rightIndex],
      trailing:[avatar,null][rightIndex],
      //获取学生姓名并进行左右对齐
      title:Text(
        StudentManager.instance.getStudentName(messageBox.senderId,skinIndex:messageBox.senderSkinIndex),
        style: const TextStyle(fontSize: 15),textAlign: [TextAlign.right,null][rightIndex],),
      //设置消息列表
      subtitle:Container(
        //往左偏移8,方便对话气泡箭头的添加
        transform: [Matrix4.translationValues(8, 0.0, 0.0),Matrix4.translationValues(0-8, 0.0, 0.0)][rightIndex],
        child:ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: messageBox.messageContentList.length,
            itemBuilder: (BuildContext context, int index) {
              //获取消息
              var message = messageBox.messageContentList[index];
              //判断是否是IMG消息类型.........
              bool isImg = MessageManager.instance.checkIsImg(message);
              return messageBoxSignle(message,index,rightIndex==0,isImg);
            }),
      ),
    );
  }
  Widget messageBoxSignle(String mes,int index,bool isRight,bool isImg){
    String arrow = "left";
    if(isRight){
      arrow = "right";
    }
    //根据是否为播放页面从而实现播放效果
    Widget child = getBoxItemContent(mes,isImg);
    if(widget.isPlayMode && playedIndex <= index){
      child = Image.asset("assets/images/chatres/load_student.gif",fit: BoxFit.fitHeight,height: 16,);
    }else{

    }
    return Row(
      textDirection: isRight?TextDirection.rtl:TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //添加左侧箭头
        index==0&&!isImg?Image.asset("assets/images/chatres/arrow_$arrow.webp",scale: 20,alignment: Alignment.bottomRight):const SizedBox(width: 6,),
        Expanded(
            child: Align(
                alignment: isRight?Alignment.centerRight:Alignment.centerLeft,
                child: Container(
                  //限制图片最大宽度
                    constraints: isImg?const BoxConstraints(maxWidth: 180):null,
                    //设置边距
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      //根据是不是图片出现描边和底色背景
                      border: isImg?Border.all(width: 0.3):null,
                      color: isImg?Colors.white:const Color(0xFF4C5B70),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    child: child)
            ))
      ],
    );
  }
  //返回本地/网络图片或者文本类型
  Widget getBoxItemContent(String mes,bool isImg){
    final double fz = 15;//double.parse("${(LocalConfig.fontSize-2)*2+15}");
    Widget origin;
    origin = Text(mes,style: TextStyle(color: Colors.white,fontSize: fz,height: 1.1,wordSpacing: -0.6,letterSpacing: -0.6));
    if(mes.length > 7 && mes.substring(3,7) == ":://"){
      if(mes.substring(0,7) == "IMG:://"){
        File f = File(mes.substring(7));
        origin = Image.file(f,
            errorBuilder: (b,o,s){
              return Image.asset("assets/images/icon/IMAGELOST.png");
            },);
      }else{
        origin = Image.network(mes.substring(7)
          ,errorBuilder: (b,o,s){
            return Image.asset("assets/images/icon/IMAGELOST.png");
          },
        );
      }
    }
    return origin;
  }

  //老师的消息盒子
  Widget senseiBox(){
    return Column(children: [
      ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(15, 1, 15, 1),
          itemCount: messageBox.messageContentList.length,
          itemBuilder: (c,i){
            var message = messageBox.messageContentList[i];
            //判断是否是IMG消息类型.........
            bool isImg = MessageManager.instance.checkIsImg(message);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //套一个Expanded是为了使Text自动换行
                Expanded(child:
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      constraints: isImg?const BoxConstraints(maxWidth: 180):null,//限制宽度
                      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        //根据图片是否白色底色+描边
                        border: isImg?Border.all(width: 0.3):null,
                        color: isImg?Colors.white:const Color(0xFF4A8ACB),
                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                      ),
                      child: GestureDetector(child: getBoxItemContent(message,isImg))
                  ),)),
                (isImg||i>0)?const SizedBox(width: 6,):Image.asset("assets/images/chatres/arrow_teacher.webp",scale: 20)
              ],
            );
          })],);
  }

  //旁白
  Widget asideBox(){
    return Container(
      height: 25,
      alignment: Alignment.center,
      margin:const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(220,230,230, 1),
        borderRadius: BorderRadius.circular(8)
      ),
      child:Text(messageBox.messageContentList[0]),
    );
  }

  Widget asidetransBox(){
    return Container(
      height: 25,
      alignment: Alignment.center,
      margin:const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8)
      ),
      child:Text(messageBox.messageContentList[0]),
    );
  }

  Widget replyBox(){
    return Align(
        alignment: Alignment.centerRight,
        child:Container(
          padding: const EdgeInsets.fromLTRB(0, 3, 20, 3),
          child: Column(
            children: [
              const Image(image: AssetImage("assets/images/chattools/reply_head.png"),width: 280,),
              SizedBox(
                width:280,
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: messageBox.messageContentList.length,
                    itemBuilder: (context,index){
                      return replyItem(messageBox.messageContentList[index],);
                    }),),//单个回复项目
              const Image(image: AssetImage("assets/images/chattools/reply_tail.png"),width: 280,),
            ],
          ),
        ));
  }

  Widget replyItem(String mes){
    return Container(
      width: 280,
      constraints:const BoxConstraints(
        minHeight: 54,
      ),
      decoration: const BoxDecoration(
          border:  Border(left:BorderSide(width:0.1,color:Colors.black),right:BorderSide(width:0.1,color:Colors.black) ),
          color: Color.fromRGBO(226,237,239, 1)
      ),
      child:Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          margin: const EdgeInsets.only(right:15, top: 4,left: 15,bottom: 4),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.5),		// 阴影的颜色
              offset: const Offset(0.5, 0.5),						// 阴影与容器的距离
              blurRadius: 2.0,							// 高斯的标准偏差与盒子的形状卷积。
              spreadRadius: 0.0,							// 在应用模糊之前，框应该膨胀的量。
            )],
            border: Border.all(color: Colors.grey, width: 0.3),
            color: Colors.white,
            borderRadius:const BorderRadius.all(Radius.circular(6)),
          ),
          child: Text(mes,textAlign: TextAlign.center,style: const TextStyle(
            color: Color.fromRGBO(90,90,125, 1),
          ),)),
    );
  }

  Widget storyBox(){
    return Align(
        alignment: Alignment.centerRight,
        child:Container(
          width: 290,
          height: 100,
          padding: const EdgeInsets.fromLTRB(20, 58, 20, 20),
          margin: const EdgeInsets.fromLTRB(10, 10, 15, 10),
          decoration:const BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.center,
              fit: BoxFit.fitWidth,
              image: AssetImage(
                  "assets/images/chattools/story.webp"),
            ),
          ),
          child: Text(
            messageBox.messageContentList[0].length>17? messageBox.messageContentList[0].substring(0,17):messageBox.messageContentList[0],
            textAlign:TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ));
  }
}