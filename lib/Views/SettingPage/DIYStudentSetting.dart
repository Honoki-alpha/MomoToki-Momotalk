import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motoki/AppData/AppResource.dart';
import 'package:path/path.dart';

import '../../AppData/AppLibrary.dart';
import '../../Dialog/InquireDialog.dart';
import '../../Entity/EStudent.dart';
import '../../Managers/StudentManager.dart';
import '../../Utils/CommonComponents.dart';
import '../../Utils/CommonFunctions.dart';

class DIYStudentSetting extends StatefulWidget{
  const DIYStudentSetting({super.key});

  @override
  State<StatefulWidget> createState() => _DIYSeitoState();
  
}

class _DIYSeitoState extends State<DIYStudentSetting>{
  List<EStudent> diyList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //每次重置界面都要刷新下列表
    diyList = StudentManager.instance.diyStudentDirctory.values.toList();
    return Scaffold(
      appBar: getPlatformAppBar(const Text("自定义学生列表")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30,),
          Expanded(
            child: ListView.builder(
              itemCount: StudentManager.instance.diyStudentDirctory.length,
              itemBuilder: (context, index){
                EStudent student = diyList[index];
                return ListTile(
                  leading:getCicleStudentAvatar(student.id),
                  title: Text(StudentManager.instance.getStudentName(student.id)),
                  subtitle: Text("学生ID: ${student.id}"),
                  onTap: ()=>onTap(index)
                );
          }),)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addButtonClick,
        child: const Icon(Icons.person_add_alt),
      ),
    );
  }

  void addButtonClick() async{
    int id = 0;
    int num = Random().nextInt(10000)+10000;
    while(StudentManager.instance.diyStudentDirctory.containsKey(num)){
      num = Random().nextInt(10000)+10000;
    }
    id = num;
    diyImgPath = RxString("");
    var result = await Get.dialog(addOrEditDialog(id));
    if(result == null) return;
    List<String> names = result["name"].split(" ");
    String fn = "";String gn = "";
    if(names.length == 1) {
      gn = names[0];
    }else{
      fn = names[0];
      gn = names[1];
    }
    EStudent newStudent = EStudent.simpleDIY(
        id, fn, gn, result["avatar"]);
    AppResource.addDIYAvatar(id,result["avatar"]);
    setState(() {
      StudentManager.instance.addDIYStudent(newStudent);
    });
  }

  void onTap(int index)async{
    int? result = await Get.dialog(bottomSheet());
    switch(result){
      case 1:diyDelete(index);break;
      case 2:diyEdit(index);break;
      case 3:importFaceImage(index);break;
      case 4:deleteFaceImage(index);break;
      default: BotToast.showText(text: "取消操作");
    }
  }

  //导入自定义差分
  void importFaceImage(int index)async{
    int id = diyList[index].id;
    List<XFile> resultList = [];
    final ImagePicker picker = ImagePicker();
    try{
      resultList = await picker.pickMultiImage(limit: 20);
    }catch(e){
      BotToast.showText(text: "取消图片选择");
    }
    if(resultList.isEmpty || !mounted) return;
    Directory dir = Directory(join(AppLibrary.applicationPath,"DIYemotion",id.toString()));
    int i = 0;
    if(!dir.existsSync()){
      await dir.create(recursive: true);
    }
    BotToast.showText(text: "开始复制图片");
    var cancel = BotToast.showLoading();
    for(var file in resultList){
      i++;
      await file.saveTo(join(dir.path,file.name));
    }
    cancel();
    BotToast.showText(text: "复制完成，可前往聊天界面使用");
  }

  //清除自定义差分
  void deleteFaceImage(int index)async{
    int id = diyList[index].id;
    Directory dir = Directory(join(AppLibrary.applicationPath,"DIYemotion",id.toString()));
    if(!dir.existsSync()) return;
    dir.delete(recursive: true);
    BotToast.showText(text: "删除差分成功");
  }

  //删除操作
  void diyDelete(int index) async{
    bool? result = await Get.dialog(const Inquiredialog(title: "删除学生",content: "老师，您选择了删除学生，是否继续？\n(请确保该学生未存在于其他消息记录)！"));
    if(result != true) return;
    int id = diyList[index].id;
    setState(() {
      StudentManager.instance.deleteDIYStudent(id);
    });
  }

  //编辑操作
  void diyEdit(int index) async{
    int originId = diyList[index].id;//记录原来的ID便于修改
    EStudent student = StudentManager.instance.getStudentById(originId);
    diyImgPath = RxString(student.avatar);
    var result = await Get.dialog(addOrEditDialog(originId,name:"${student.familyName["cn"]} ${student.givenName["cn"]}"));
    if(result == null) return;
    List<String> names = result["name"].split(" ");
    String fn = "";String gn = "";
    if(names.length == 1) {
      gn = names[0];
    }else{
      fn = names[0];
      gn = names[1];
    }
    EStudent newStudent = EStudent.simpleDIY(int.parse(result["id"]),fn, gn, result["avatar"]);
    AppResource.addDIYAvatar(int.parse(result["id"]), result["avatar"]);
    setState(() {
      StudentManager.instance.alterDIYStudent(originId,newStudent);
    });
  }

  //创建或编辑对话框
  TextEditingController studentId = TextEditingController();
  TextEditingController studentName = TextEditingController();
  RxString diyImgPath = "".obs;
  Widget addOrEditDialog(int id,{String? name=""}){
    studentId.text = id.toString();
    studentName.text = name ?? "";
    return AlertDialog(
      title: const Text("学生信息"),
      content: SizedBox(
        height: 240,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: TextField(
                readOnly: name == "",
                controller: studentId,
                decoration: const InputDecoration(
                  labelText: "ID",
                  hintText: "创建时不必填写",
                ))),
            Expanded(child: TextField(controller: studentName,
                decoration: const InputDecoration(
                  labelText: "姓名",
                  hintText: "请使用空格分割姓和名",
                ))),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Obx(()=>Image.file(File(diyImgPath.value),errorBuilder: (b,o,t){
                    return Image.asset("assets/images/icon/DISUPLOAD.jpg");
                  },))),
                IconButton(onPressed: ()=>imagePickButtonClick(id), icon: const Icon(Icons.image)),
                TextButton(onPressed: (){
                  Get.back(result: {"id":studentId.text,"name":studentName.text,"avatar":diyImgPath.value});
                }, child: const Text("保存"))
              ],
            )
          ],
        ),
      ),
    );
  }

  void imagePickButtonClick(int id)async{
    var cancel = BotToast.showLoading();
    String savePath = join(AppLibrary.applicationPath,"PictureCache","DIY");
    String fileName = await getPictureFromDevice(savePath);
    cancel();
    if(fileName == "error") return;
    diyImgPath.value = fileName;
  }

  //底部对话框
  Widget bottomSheet(){
    return AlertDialog(
      content: SizedBox(
        height: 240,
        child: ListView(
        children: [
          ListTile(title:const Text("删除学生"),onTap: ()=>Get.back(result: 1),),
          ListTile(title:const Text("编辑学生信息"),onTap: ()=>Get.back(result: 2),),
          ListTile(title:const Text("导入自定义差分"),onTap: ()=>Get.back(result: 3),),
          ListTile(title:const Text("删除自定义差分"),onTap: ()=>Get.back(result: 4),),
        ],
      ),),
    );
  }
}