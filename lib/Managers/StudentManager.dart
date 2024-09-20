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
  Map<int,String> studentNickName = {};//学生备注名
  List<String> usualStudents = [];//常用学生(以"ID||skinIndex"形式存储)
  EStudent noneStudent = EStudent.simpleDIY(0, "", "学生丢失", "//gitee.com/honoki/momotoki/raw/master/assets/NoneAvatar.jpg");

  EStudent getStudentById(int id){
    if(studentDirctory.containsKey(id)){
      return studentDirctory[id]!;
    }else if(toolStudentDirctory.containsKey(id)){
      return toolStudentDirctory[id]!;
    }else if(diyStudentDirctory.containsKey(id)){
      return diyStudentDirctory[id]!;
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

  String getStudentName(int id,{int? skinIndex}){
    int skin = skinIndex??0;
    EStudent student = getStudentById(id);
    String family = student.familyName["cn"];
    String given = student.givenName["cn"];
    String suffix = "";
    if(skin > 0 && skin < student.skinList.length){
      suffix = student.skinList[skin]["skin"];
    }
    String fullName = given;
    if(UserConfig.applyStudentFamilyName){
      fullName = "$family$given";
      if(UserConfig.applyNameReverse){
        fullName = "$given$family";
      }
    }
    if(studentNickName.containsKey(id)){
      fullName = studentNickName[id]!;
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

}