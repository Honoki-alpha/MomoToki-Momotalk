import 'dart:convert';
import '../AppData/UserConfig.dart';
import '../Entity/EStudent.dart';
import 'JsonFileManager.dart';

class StudentManager{
  //单例
  static StudentManager instance = StudentManager._();
  StudentManager._(); // 私有构造函数

  Map<int,EStudent> studentDirctory = {};//学生列表
  Map<int,EStudent> diyStudentDirctory = {};//自定义学生列表
  Map<int,EStudent> toolStudentDirctory = {};//聊天工具列表
  Map<int,int> birthdayStudent = {};
  Map<String,dynamic> studentNickName = {};//学生备注名
  List<String> usualStudents = [];//常用学生(以"ID||skinIndex"形式存储)

  //丢失学生
  EStudent noneStudent = EStudent.simpleDIY(0, "", "学生丢失", "//gitee.com/honoki/momotoki/raw/master/assets/NoneAvatar.jpg");
  //社团学生
  late EStudent circleStudent;

  EStudent getStudentById(int id){
    if(studentDirctory.containsKey(id)){
      return studentDirctory[id]!;
    }else if(toolStudentDirctory.containsKey(id)){
      return toolStudentDirctory[id]!;
    }else if(diyStudentDirctory.containsKey(id)){
      return diyStudentDirctory[id]!;
    }else if(id == 7){
      return circleStudent;
    }else{
      return noneStudent;
    }
  }

  int getStudentSkinIndex(int id,int skinIndex){
    EStudent student = getStudentById(id);
    if(skinIndex < student.skinList.length){
      return skinIndex;
    }else{
      return 0;
    }
  }

  String getStudentName(int id,{int? skinIndex,bool? showFullName}){
    int skin = skinIndex??0;
    //如果有备注直接返回
    if(studentNickName.containsKey(id.toString()) && studentNickName[id.toString()]!.containsKey(skin.toString())){
      return studentNickName[id.toString()]![skin.toString()];
    }
    //后缀名
    EStudent student = getStudentById(id);
    String family = student.familyName[UserConfig.studentNameLanguage] ?? student.familyName["nm"];
    String given = student.givenName[UserConfig.studentNameLanguage] ?? student.givenName["nm"];

    //如果取不到的话返回normal名字
    if(family==""||given==""){
      family = student.familyName["nm"] ??"";
      given = student.givenName["nm"]??"";
    }

    //后缀名
    String suffix = "";

    if(skin > 0 && skin < student.skinList.length){
      suffix = student.skinList[skin]["skin"];
    }
    String fullName = given;
    String mildle = " ";
    if(family == "") mildle = "";
    if(UserConfig.applyStudentFamilyName || (showFullName ?? false)){
      fullName = "$family$mildle$given";
      if(UserConfig.applyNameReverse){
        fullName = "$given$mildle$family";
      }
    }
    if(suffix != ""){
      return "$fullName ($suffix)";
    }
    return fullName;
  }

  void addUsualStudent(int id,int skinIndex){
    usualStudents.add("$id||$skinIndex");
    saveUsualStudent();
  }

  void deleteUsualStudent(int index){
    usualStudents.removeAt(index);
    saveUsualStudent();
  }

  Future saveUsualStudent()async{
    await JsonFileManager.instance.saveJsonFile("Users", "Usually.json", json.encode(usualStudents));
  }

  void addDIYStudent(EStudent student){
    diyStudentDirctory[student.id] = student;
    saveDIYStudent();
  }

  void alterDIYStudent(int originID,EStudent student){
    diyStudentDirctory.remove(originID);
    diyStudentDirctory[student.id] = student;
    saveDIYStudent();
  }

  void deleteDIYStudent(int id){
    diyStudentDirctory.remove(id);
    saveDIYStudent();
  }

  Future saveDIYStudent()async{
    List dList = diyStudentDirctory.values.toList();
    await JsonFileManager.instance.saveJsonFile("Users", "DIY.json", json.encode(dList));
  }

  void addNickName(int id,int skinIndex,String name){
    if(studentNickName.containsKey(id.toString())){
      studentNickName[id.toString()]![skinIndex.toString()] = name;
    }else{
      studentNickName[id.toString()]= {
        "$skinIndex":name
      };
    }
    saveNickName();
  }

  void removeNickName(int id,int skinIndex){
    Map skins = studentNickName["$id"]!;
    var skinId = skins.entries.elementAt(skinIndex);
    skins.remove(skinId.key);
    if(skins.isEmpty) studentNickName.remove("$id");
    saveNickName();
  }


  Future saveNickName()async{
    await JsonFileManager.instance.saveJsonFile("Users", "NickName.json", json.encode(studentNickName));
  }

}