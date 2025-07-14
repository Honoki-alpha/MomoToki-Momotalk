import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../Components/StudentCircleAvatar.dart';
import '../../Entity/EStudent.dart';
import '../../AppData/AppLibrary.dart';
import '../../Managers/Students.dart';


class SelectPage extends StatefulWidget{
  const SelectPage({super.key, required this.multiple});
  final bool multiple;

  @override
  State<StatefulWidget> createState() => _selectPageState();
}

class _selectPageState extends State<SelectPage> with SingleTickerProviderStateMixin{
  List<EStudent> eStudentList = Students().studentMap.values.toList();
  List<EStudent> diyStudentList = Students().diyStudentMap.values.toList();
  //多选返回列表
  final List<int> backList = [];
  
  TextEditingController searchField = TextEditingController();
  HotKey hotKey = HotKey(KeyCode.enter,scope: HotKeyScope.inapp);
  late final TabController tbc;

  @override
  void initState() {
    super.initState();
    addHotKey();
    tbc = TabController(length: 2, vsync: this);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    removeHotKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("请选择学生"),
          centerTitle: true,
          actions: [
            if(widget.multiple) IconButton(onPressed: returnStudents, icon: const Icon(Icons.check))
          ],
          bottom:TabBar(
          controller: tbc,
          tabs: const [Tab(text: "内置"),Tab(text: "自定义")])),
        body: Column(
          children: [
            Row(children: [
              const SizedBox(width: 10,),
              Expanded(child: TextField(
                controller: searchField,
                decoration: const InputDecoration(
                    labelText: "学生",
                    hintText: "支持游戏所支持的语言"
                ),
                onSubmitted: searchButtonClick,
              )),
              IconButton(onPressed: filterButtonClick, icon: const Icon(Icons.select_all))
              //IconButton(onPressed: SearchButtonClick, icon: const Icon(Icons.search)),
              //ElevatedButton(onLongPress: ResetButtonClick,onPressed: FilterCheck, child:const Text("筛选/重置"),)
            ],),
            Expanded(child: TabBarView(
                controller: tbc,
                children: [
                  GridView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: eStudentList.length,
                      gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 10,
                        crossAxisCount: AppLibrary.appLandscapeMode?12:5,
                        childAspectRatio: 1.0, //显示区域宽高相等
                      ),
                      itemBuilder: (context, index){
                        return GestureDetector(
                            child:StudentCircleAvatar(
                                id:eStudentList[index].id,selected: backList.contains(eStudentList[index].id),),
                            onTap: ()=>studentAvatarClick(false,index));
                      }),
                  GridView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: diyStudentList.length,
                      gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 10,
                        crossAxisCount: AppLibrary.appLandscapeMode?12:5,
                        childAspectRatio: 1.0, //显示区域宽高相等
                      ),
                      itemBuilder: (context, index){
                        return  GestureDetector(
                          child:StudentCircleAvatar(id:diyStudentList[index].id,selected: backList.contains(diyStudentList[index].id),),
                          onTap: ()=>studentAvatarClick(true,index));
                      }),
                ]))
          ],
        ),
        
    );
  }

  void studentAvatarClick(bool diy,index)async{
    List current = diy?diyStudentList:eStudentList;
    if(!widget.multiple){
      Get.back(result: eStudentList[index]);
    }else{
      if(backList.contains(current[index].id)){
        backList.remove(current[index].id);
      }else{
        backList.add(current[index].id);
      }
      setState(() {});
    }
  }

  void returnStudents(){
    List<EStudent> ss = [];
    for(int id in backList){
      EStudent s = Students().getStudentById(id);
      ss.add(s);
    }
    Get.back(result: ss);
  }

  void searchButtonClick(String text) async{
    eStudentList.clear();
    List<EStudent> temp = [];
    for(var item in Students().studentMap.values.toList()){
      if(item.familyName.values.toList().join(".").contains(text) ||
          item.givenName.values.toList().join(".").contains(text)){
        temp.add(item);
      }
    }
    setState(() {
      eStudentList = temp;
    });
  }

  void filterButtonClick()async{
    var result = await Get.dialog(filterDialog());
    resetButtonClick();
    if(result == true){
      filterStudent();
    }
  }

  void resetButtonClick(){
    setState(() {
      searchField.text = "";
      initPageData();
    });
  }
  //初始化数据
  void initPageData() async{
    eStudentList = Students().studentMap.values.toList();
  }


  //注册快捷键
  void addHotKey()async{
    await hotKeyManager.register(hotKey,keyDownHandler: (detalis)=>searchButtonClick(searchField.text));
  }
  //注销快捷键
  void removeHotKey()async{
    await hotKeyManager.unregister(hotKey);
  }

  List bulletType = ["爆发","贯通","神秘","振动","全部"];
  List defenceType = ["轻装甲","重装甲","特殊装甲","弹力装甲","全部"];
  RxBool isRealased = true.obs;
  RxInt currentSchoolIndex = 0.obs;
  RxInt currentBulletIndex = 0.obs;
  RxInt currentDefenceIndex = 0.obs;
  Widget filterDialog(){
    return AlertDialog(
      title: const Text("筛选选择"),
      content: SizedBox(
        width: 400,
        height: 230,
        child: ListView(
          children: [
            Obx(()=>ElevatedButton(onPressed: (){
              isRealased.value = !isRealased.value;
            }, child: Text(isRealased.value?"已实装":"未实装"))),
            ListTile(title: const Text("所属组织"),
              trailing: Obx(()=>DropdownButton(
                value: currentSchoolIndex.value,
                items: List.generate(AppLibrary.schoolList.length, (index){
                  return DropdownMenuItem(value: index,child: Text(AppLibrary.schoolList[index]));
                }), onChanged: (int? value) {
                currentSchoolIndex.value = value ?? 0;
              },
              )),),
            ListTile(title: const Text("攻击类型"),
              trailing: Obx(()=>DropdownButton(
                value: currentBulletIndex.value,
                items: List.generate(bulletType.length, (index){
                  return DropdownMenuItem(value: index,child: Text(bulletType[index]));
                }), onChanged: (int? value) {
                currentBulletIndex.value = value ?? 0;
              },
              )),),
            ListTile(title: const Text("防御类型"),
              trailing: Obx(()=>DropdownButton(
                value: currentDefenceIndex.value,
                items: List.generate(defenceType.length, (index){
                  return DropdownMenuItem(value: index,child: Text(defenceType[index]));
                }), onChanged: (int? value) {
                currentDefenceIndex.value = value ?? 0;
              },
              )),),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed:(){Get.back(result: false);} , child: const Text("重置")),
        TextButton(onPressed:(){Get.back(result: true);}, child: const Text("确认")),
      ],
    );
  }

  void filterStudent(){
    int re = isRealased.value?0:1;
    eStudentList = eStudentList.where((EStudent s){
      return (s.school == currentSchoolIndex.value && (currentBulletIndex.value == 4 || s.characterData["bullet"] == currentBulletIndex.value)
          && (currentDefenceIndex.value == 4 || s.characterData["defence"] == currentDefenceIndex.value)
          && s.release == re);
    }).toList();
    setState(() {

    });
  }
}