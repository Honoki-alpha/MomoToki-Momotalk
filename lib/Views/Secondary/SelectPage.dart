import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../Entity/EStudent.dart';
import '../../AppData/AppLibrary.dart';
import '../../Managers/StudentManager.dart';
import '../../Utils/CommonComponents.dart';


class SelectPage extends StatefulWidget{
  const SelectPage({super.key});

  @override
  State<StatefulWidget> createState() => _selectPageState();
}

class _selectPageState extends State<SelectPage> with SingleTickerProviderStateMixin{
  List<EStudent> eStudentList = StudentManager.instance.studentDirctory.values.toList();
  List<EStudent> diyStudentList = StudentManager.instance.diyStudentDirctory.values.toList();
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
        appBar: AppBar(title: const Text("请选择学生"),centerTitle: true,bottom:TabBar(
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
                        return GestureDetector(child:getRectangleStudentAvatar(eStudentList[index].id),onTap: (){
                          Get.back(result: eStudentList[index]);
                        },);
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
                        return GestureDetector(child:getRectangleStudentAvatar(diyStudentList[index].id),onTap: (){
                          Get.back(result: diyStudentList[index]);
                        },);
                      }),
                ]))
          ],
        ),
        
    );
  }

  void searchButtonClick(String text) async{
    eStudentList.clear();
    List<EStudent> temp = [];
    for(var item in StudentManager.instance.studentDirctory.values.toList()){
      if(item.familyName.values.toList().join(".").contains(text) ||
          item.givenName.values.toList().join(".").contains(text)){
        temp.add(item);
      }
    }
    setState(() {
      eStudentList = temp;
    });
  }

  //
  // void FilterCheck() async{
  //   Map? result = await Get.dialog(const FilterDialog());
  //   var db = await AppDataBase.instance.database;
  //   if(result == null) return;
  //   //这一步只是为了凑个and
  //   String Sr = result["SR"]==""?"":"t.SR = '${result["SR"]}'";
  //   String month = result["month"]==""?"":"t.month = '${result["month"]}'";
  //   String bt = result["bulletType"]==""?"":"t.bulletType = '${result["bulletType"]}'";
  //   String at = result["armorType"]==""?"":"t.armorType = '${result["armorType"]}'";
  //   String sc = result["school"]==""?"":"t.school = '${result["school"]}'";
  //   var list = [Sr,month,bt,at,sc];
  //   var resultList = [];
  //   for (var element in list) {if(element!="") resultList.add(element);}
  //   String sqls = """SELECT * FROM (SELECT * FROM Seito union SELECT * FROM DIYs) t
  //   WHERE ${resultList.join(" and ")} and (t.id >30049 or t.id < 30000);
  //   """;
  //   List charas = await db.rawQuery(sqls);
  //   List<Seito> Ss = [];
  //   for (var element in charas) {
  //     Ss.add(Seito.fromMap(element));
  //   }
  //   setState(() {
  //     studentList = Ss;
  //   });
  // }

  void resetButtonClick(){
    setState(() {
      searchField.text = "";
      initPageData();
    });
  }
  //初始化数据
  void initPageData() async{
    eStudentList = StudentManager.instance.studentDirctory.values.toList();
  }


  //注册快捷键
  void addHotKey()async{
    await hotKeyManager.register(hotKey,keyDownHandler: (detalis)=>searchButtonClick(searchField.text));
  }
  //注销快捷键
  void removeHotKey()async{
    await hotKeyManager.unregister(hotKey);
  }
}