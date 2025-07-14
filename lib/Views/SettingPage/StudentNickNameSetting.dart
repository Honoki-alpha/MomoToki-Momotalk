import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motoki/Managers/Students.dart';
import 'package:motoki/Views/Secondary/SelectPage.dart';

import '../../Components/StudentCircleAvatar.dart';
import '../../Entity/EStudent.dart';
import '../../Utils/WidgetUtils.dart';

class StudentNickNameSetting extends StatefulWidget{
  const StudentNickNameSetting({super.key});

  @override
  State<StatefulWidget> createState() => _StudentNickNameSettingState();
}

class _StudentNickNameSettingState extends State<StudentNickNameSetting>{
  int shownIndex = -1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils().getPlatformAppBar(const Text("学生备注")),
      body: ListView.builder(
        itemCount: Students().studentNickName.length,
        itemBuilder: (b,index){
          int id = int.parse(Students().studentNickName.keys.elementAt(index));
          String name = Students().getStudentName(id,skinIndex: 0);
          Map skins = Students().studentNickName.values.elementAt(index);
          return ExpansionPanelList(
            expansionCallback:(eIndex,isOpen){
              setState(() {
                if(shownIndex == index){
                  shownIndex = -1;
                }else{
                  shownIndex = index;
                }
              });
            },
            children: [
              ExpansionPanel(
                canTapOnHeader: true,
                isExpanded: shownIndex ==index,
                headerBuilder: (context,open){
                  return ListTile(
                    leading: StudentCircleAvatar(id:id),
                    title: Text(name),
                  );
                },
                body: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: skins.length,
                    itemBuilder: (builder,skinIndex){
                      return ListTile(
                        leading: StudentCircleAvatar(id:id,skinIndex:int.parse(skins.keys.elementAt(skinIndex))),
                        title: Text(skins.values.elementAt(skinIndex)),
                        onLongPress: (){
                          Students().removeNickName(id, skinIndex);
                          setState(() {});
                        },
                      );
                    })
              )
            ],
          );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>addStudentNickName(),
        child: const Icon(Icons.add)),
    );
  }

  TextEditingController textEditingController = TextEditingController();
  void addStudentNickName()async{
    EStudent? result = await Get.to(()=>const SelectPage(multiple: false,));
    if(result==null) return;
    int skinIndex = 0;
    if(result.skinList.length > 1){
      skinIndex = ( await Get.dialog(skinIndexSelectDialog(result.skinList)) ) ?? 0;
    }
    await Get.defaultDialog(title:"请输入备注",content: TextField(controller: textEditingController));
    if(textEditingController.text.isEmpty) return;
    Students().addNickName(result.id, skinIndex, textEditingController.text);
    textEditingController.text = "";
    setState(() {});
  }

  //选择常用学生的皮肤
  Widget skinIndexSelectDialog(List skinList){
    return AlertDialog(
      title: const Text("点击框外选择原皮"),
      content: SizedBox(
        height: 140,
        child: SingleChildScrollView(
          child: Column(
            children: skinList.map<Widget>((element){
              return ListTile(
                title: Text(element["skin"]==""?"普通":element["skin"]),
                onTap: ()=>Get.back(result:skinList.indexOf(element)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

}