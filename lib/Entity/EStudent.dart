class EStudent{
  int id;
  int kivoId;
  List<Map> skinList;
  Map familyName;
  Map givenName;
  String avatar;
  String introduction;
  List<String> mosign;
  Map birthday;
  int school;
  String weaponType;
  Map characterData;
  List<Map> gallery;
  int release;

  EStudent(this.id,this.kivoId,this.skinList,this.familyName,this.givenName,this.avatar,this.introduction,
     this.school,this.weaponType,this.characterData,this.mosign,this.gallery,this.birthday,this.release);

  factory EStudent.simpleDIY(int id,String fName,String gName,String avatar){
    return EStudent(id, 0, [], {"cn":fName}, {"cn":gName}, avatar,
        "DIY学生", 0, "weaponType", {}, [], [],
        {"month":0,"day":0}, 2);
  }

  factory EStudent.fromMap(Map map){
    Map birthday = {"month":1,"day":1};
    if(map["birthday"].toString().contains("-")){
       birthday = {
        "month":map["birthday"].split("-")[0],
        "day":map["birthday"].split("-")[1]
      };
    }
    List<Map> skinList = [];
    for(var skin in map["skinList"]){
      skinList.add({
        "kivoId":skin["kivoId"],
        "avatar":skin["avatar"],
        "skin":skin["skin"]
      });
    }
    List<Map> gallery = [];
    for(var gal in map["gallery"]){
      gallery.add({
        "title":gal["title"],
        "images":gal["images"]
      });
    }
    List<String> mosign = [];
    for(var ms in map["mosign"]){
      mosign.add(ms.toString());
    }
    return EStudent(map["id"], map["kivoId"]??0,skinList, map["familyName"], map["givenName"],map["avatar"], map["introduction"],
        map["school"]??-1,map["weaponType"]??"",map["characterData"]??{},mosign,gallery, birthday, map["release"]);
  }

  Map<String,dynamic> toJson(){
    return {
      "id": id,
      "kivoId":kivoId,
      "skinList": skinList,
      "familyName": familyName,
      "givenName": givenName,
      "avatar": avatar,
      "school":school,
      "weaponType":weaponType,
      "characterData":characterData,
      "introduction": introduction,
      "mosign": mosign,
      "gallery": gallery,
      "birthday": "${birthday["month"]}-${birthday["day"]}",
      "release": release
    };
  }

  @override
  String toString() {
    return 'EStudent{id: $id, kivoId: $kivoId, skinList: $skinList, familyName: $familyName, givenName: $givenName, avatar: $avatar, introduction: $introduction, mosign: $mosign, birthday: $birthday, school: $school, weaponType: $weaponType, characterData: $characterData, gallery: $gallery, release: $release}';
  }
}