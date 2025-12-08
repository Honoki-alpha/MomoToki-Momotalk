import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:motoki/Apis/Requests.dart';
import 'package:motoki/Dialog/InquireDialog.dart';
import 'package:motoki/Utils/Utils.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:motoki/Managers/Students.dart';
import 'package:motoki/Views/SettingPage/AppSetting.dart';
import 'package:motoki/Views/SettingPage/BackUpData.dart';
import 'package:universal_html/html.dart' hide File,Text;
import 'package:motoki/Managers/ThemeManager.dart';
import 'package:motoki/Views/Home/AndroidHome.dart';
import 'package:motoki/Views/Home/WindowHome.dart';
import 'dart:io';
import '../../Entity/EChatTileGroup.dart';
import '../../Entity/EStudent.dart';
import '../../Managers/ChatGroups.dart';
import '../../Managers/Files.dart';


class AnimationPage extends StatefulWidget{
  const AnimationPage({super.key});

  @override
  State<StatefulWidget> createState() => _AnimationPageState();

}

class _AnimationPageState extends State<AnimationPage> with TickerProviderStateMixin{
  bool isLoaded = false;
  @override
  void initState() {
    super.initState();
    initApp();
  }

  @override
  Widget build(BuildContext context) {


    return Container(
      color: Colors.white,
      child: Container(
        color: ThemeManager.currentTheme.appBarTheme.backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child:Column(
          children: [
            SizedBox(
              height: 300,
              width: 300,
              child: Image.asset("assets/images/icon/start_logo.png"),),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: ()async{
                  if(!isLoaded){
                    var result = await Get.dialog(Inquiredialog(title: "警告",content: "急救模式下将进入消息备份界面，可进行备份消息",));
                    if (result ?? false) return;
                    Get.off(()=>BackUpData());
                  }else{
                    Get.off(()=>BackUpData());
                  }
                }, child: Text("急救模式",style: TextStyle(color: Colors.white),)),
                TextButton(onPressed: ()async{
                  if(!isLoaded){
                    var result = await Get.dialog(Inquiredialog(title: "警告",content: "进入设置页面可关闭部分配置导致的报错问题",));
                    if (result ?? false) return;
                    Get.off(()=>AppSetting());
                  }else{
                    Get.off(()=>AppSetting());
                  }
                }, child: Text("进入设置",style: TextStyle(color: Colors.white),)),
                TextButton(onPressed: ()async{
                  if(!isLoaded){
                    var result = await Get.dialog(Inquiredialog(title: "警告",content: "当前所有数据暂未加载成功，是否继续进入？（可能会造成消息和自定义学生等文件的丢失）",));
                    if (result ?? false) return;
                    Timer(const Duration(milliseconds: 300), enterHomePage);
                  }else{
                    Timer(const Duration(milliseconds: 300), enterHomePage);
                  }
                }, child: Text("强制进入",style: TextStyle(color: Colors.white),)),
              ],

            )

          ],
        ),
      ),
    );
  }

  ///
  /// 进入主页前加载App
  ///
  void initApp()async{
    // 获取学生json列表以及app部分必要资源
    if(UserConfig.applyOfflineMode){
      await loadStudentInfoFromLocal();
      await loadAppDataFromLocal();
    }else{
      await loadStudentInfoFromNet();
      await loadAppDataFromNet();
    }
    // 实例化特殊学生
    initSpecialStudent();
    await loadJsonFiles();//获取本地聊天记录
    await loadDIYJson();//获取DIY学生
    await loadStudentNickName();//获取学生备注
    await loadUsualJson();//添加常用学生
    isLoaded = true;
    // 进入主页
    Timer(const Duration(milliseconds: 300), enterHomePage);
  }

  ///
  /// 获取学生信息-从网络
  /// 并计算出学生的生日差值导入到生日列表
  /// 获取工具类
  ///
  Future loadStudentInfoFromNet()async{
    var netData = await Requests().request("https://gitee.com/honoki/mtkresouce/raw/master/public/students.json");
    if(netData == null) return;
    for(var student in netData){
      Students().studentMap[student["id"]] = EStudent.fromMap(student);

      int birthDayDifference = Utils().getDayDifference(student);
      //print("该学生是：${student["givenName"]["nm"]},她的差值是：${birthDayDifference}");
      if(birthDayDifference >= 0 && birthDayDifference < 5){
        Students().birthdayStudentMap[student["id"]] = birthDayDifference;
      }
    }
    String chatTools = await rootBundle.loadString("assets/datas/chatTools.json");
    for(var tool in Files().jsonDecode(chatTools)){
      Students().toolStudentMap[tool["id"]] = EStudent.fromMap(tool);
    }
  }

  ///
  /// 实例化特殊学生
  ///
  //实例化特殊学生
  void initSpecialStudent(){
    //空学生
    Students().noneStudent.release = 0;
    //社团学生
    EStudent circle = EStudent.simpleDIY(7, "社团", "表情", "");
    List circles = ["//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_01_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_01_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_01_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_02_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_02_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_02_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_03_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_03_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_03_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_04_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_04_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_04_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_05_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_05_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_05_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_06_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_06_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_06_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_07_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_07_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_07_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_08_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_08_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_08_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_09_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_09_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_09_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_100_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_100_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_100_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_101_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_101_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_101_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_102_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_102_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_102_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_103_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_103_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_103_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_104_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_104_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_104_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_105_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_105_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_105_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_106_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_106_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_106_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_107_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_107_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_107_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_108_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_108_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_108_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_109_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_109_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_109_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_10_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_10_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_10_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_110_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_110_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_110_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_111_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_111_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_111_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_112_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_112_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_112_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_113_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_114_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_115_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_116_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_117_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_118_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_119_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_11_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_11_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_11_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_120_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_121_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_122_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_123_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_124_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_125_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_126_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_127_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_128_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_129_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_12_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_12_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_12_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_130_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_131_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_132_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_133_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_134_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_135_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_136_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_137_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_138_CN.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_139_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_139_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_139_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_13_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_13_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_13_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_140_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_140_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_140_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_141_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_141_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_141_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_142_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_142_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_142_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_143_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_143_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_143_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_144_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_144_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_144_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_14_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_14_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_14_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_15_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_15_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_15_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_16_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_16_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_16_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_17_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_17_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_17_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_18_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_18_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_18_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_19_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_19_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_19_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_20_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_20_Kr (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_20_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_21_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_21_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_22_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_22_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_23_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_23_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_24_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_24_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_25_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_25_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_26_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_26_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_27_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_27_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_28_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_28_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_29_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_29_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_30_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_30_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_31_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_31_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_32_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_32_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_33_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_33_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_34_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_34_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_35_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_35_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_36_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_36_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_37_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_37_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_38_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_38_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_39_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_39_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_40_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_40_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_41_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_41_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_42_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_42_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_43_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_43_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_44_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_44_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_45_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_45_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_46_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_46_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_47_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_47_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_48_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_48_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_49_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_49_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_50_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_50_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_51_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_51_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_52_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_52_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_53_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_53_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_54_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_54_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_55_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_55_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_56_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_56_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_57_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_57_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_58_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_58_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_59_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_59_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_60_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_60_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_61_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_61_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_62_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_62_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_63_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_63_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_64_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_64_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_65_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_65_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_66_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_66_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_67_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_67_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_68_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_68_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_69_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_69_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_70_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_70_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_71_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_71_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_72_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_72_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_73_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_73_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_74_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_74_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_75_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_75_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_76_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_76_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_77_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_77_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_78_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_78_Jp.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_79_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_79_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_800_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_801_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_802_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_803_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_804_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_805_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_806_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_807_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_808_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_809_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_80_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_80_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_810_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_811_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_812_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_813_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_814_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_815_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_816_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_817_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_818_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_819_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_81_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_81_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_81_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_820_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_821_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_822_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_823_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_824_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_825_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_826_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_827_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_828_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_829_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_82_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_82_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_82_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_830_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_831_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_83_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_83_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_83_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_84_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_84_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_84_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_85_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_85_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_85_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_86_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_86_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_86_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_87_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_87_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_87_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_88_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_88_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_88_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_89_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_89_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_89_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_90_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_90_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_90_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_91_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_91_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_91_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_92_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_92_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_92_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_93_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_93_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_93_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_94_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_94_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_94_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_95_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_95_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_95_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_96_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_96_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_96_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_97_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_97_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_97_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_98_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_98_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_98_Kr.png",
      "//static.kivo.wiki/images/gallery/3.游戏内-表情包/ClanChat_Emoji_99_CN.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_99_Jp.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_99_Kr.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Dummy01 (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Dummy01.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Dummy02 (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Dummy02.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Dummy03 (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Dummy03.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Dummy04 (1).png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Dummy04.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Tab_1.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Tab_2.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Tab_3.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Tab_4.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Tab_5.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Tab_6.png",
      "//static.kivo.wiki/images/gallery/16/ClanChat_Emoji_Tab_7.png",
    ];
    circle.gallery = [{
      "title":"社团表情",
      "images":circles
    }];
    Students().circleStudent = circle;
  }

  ///
  /// 获取学生信息-从本地
  /// 并计算出学生的生日差值导入到生日列表
  ///
  Future loadStudentInfoFromLocal()async{
    File students = File(Files().joinAppPath("Resources","students.json"));
    if(!students.existsSync()) {
      UserConfig.sp.setBool("applyOfflineMode", false);
      return;
    }
    for(var student in Files().jsonDecode(students.readAsStringSync())){
      Students().studentMap[student["id"]] = EStudent.fromMap(student);
      int birthDayDifference = Utils().getDayDifference(student);
      if(birthDayDifference >= 0 && birthDayDifference < 5){
        Students().birthdayStudentMap[student["id"]] = birthDayDifference;
      }
    }
    String chatTools = await rootBundle.loadString("assets/datas/chatTools.json");
    for(var tool in Files().jsonDecode(chatTools)){
      Students().toolStudentMap[tool["id"]] = EStudent.fromMap(tool);
    }
  }

  ///
  /// 从网络获取软件信息
  ///
  Future loadAppDataFromNet()async{
    dynamic resource = await Requests().request("https://gitee.com/honoki/mtkresouce/raw/master/public/appDatas.json");
    if(resource == null) return;
    AppLibrary.schoolList = resource["schoolList"];
    AppLibrary.adTitle = resource["adtitle"];
    AppLibrary.adContent = resource["adcontent"];
    AppLibrary.adImage = resource["adimage"];
  }
  ///
  /// 从本地获取部分资源
  ///
  Future loadAppDataFromLocal()async{
    File datas = File(Files().joinAppPath("Resources","appDatas.json"));
    if(!datas.existsSync()) {
      UserConfig.sp.setBool("applyOfflineMode", false);
      return;
    }
    var resource = Files().jsonDecode(datas.readAsStringSync());
    AppLibrary.schoolList = resource["schoolList"];
    AppLibrary.adTitle = resource["adtitle"];
    AppLibrary.adContent = resource["adcontent"];
    AppLibrary.adImage = resource["adimage"];
  }

  ///
  /// 读取本地json聊天块列表记录
  ///
  Future loadJsonFiles()async{
    File chatTileGroupJson = File(Files().joinAppPath("ChatTiles","ChatTilesGroups.json"));
    if(!chatTileGroupJson.existsSync()) {
      chatTileGroupJson.create(recursive: true);
      return;
    }
    for(var chatGroup in Files().jsonDecode(chatTileGroupJson.readAsStringSync())){
      ChatGroups().chatTileGroups.add(EChatTileGroup.fromMap(chatGroup));
    }
  }

  ///
  ///读取本地DIY学生列表
  ///
  Future loadDIYJson()async{
    File diyStudent = File(Files().joinAppPath("Users","DIY.json"));
    if(!diyStudent.existsSync()) return;
    for(var student in Files().jsonDecode(diyStudent.readAsStringSync())){
      EStudent s = EStudent.fromMap(student);
      Students().diyStudentMap[s.id] = s;
    }
  }

  ///
  /// 获取常用学生
  ///
  Future loadUsualJson()async{
    File usualStudent = File(Files().joinAppPath("Users","Usually.json"));
    if(!usualStudent.existsSync()) return;
    try{
      for(var usual in Files().jsonDecode(usualStudent.readAsStringSync())){
        Students().usualStudents.add(usual);
      }
    }catch(e){
      Students().usualStudents = [];
    }

  }

  ///
  /// 获取学生备注
  ///
  Future loadStudentNickName()async{
    File? studentNickName = File(Files().joinAppPath("Users","NickName.json"));
    if(!studentNickName.existsSync()){
      Students().studentNickName = {};
      studentNickName.create(recursive: true);
    }else{
      Students().studentNickName = Files().jsonDecode(studentNickName.readAsStringSync());
    }
  }

  ///
  /// 进入主页
  ///
  void enterHomePage(){
    Get.off(
        ()=>getHome(),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 600),
        curve: Curves.ease
    );
  }

  ///
  /// 获取主页
  ///
  Widget getHome(){
    return OrientationBuilder(builder: (context,orientation){
      bool isWebPC = GetPlatform.isWeb && window.navigator.platform.toString().contains("Win");
      if( ( ( orientation == Orientation.landscape || GetPlatform.isDesktop ) &&
        UserConfig.applyLandscape ) || isWebPC){
        AppLibrary.appLandscapeMode = true;
        return const WindowHome();
      }else{
        AppLibrary.appLandscapeMode = false;
        return const AndroidHome();
      }
    });
  }

}