import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/Dialog/InquireDialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart';


Future<String> getPictureFromDevice(String savePath)async{
  XFile? file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
  );
  if(file == null) return "error";
  Directory dir = Directory(savePath);
  if(!dir.existsSync()) await dir.create(recursive: true);
  String path = join(dir.path,file.name);
  await file.saveTo(path);
  return path;
}


//获取最新版本
void getLastVersion()async{
  Dio dio = Dio();
  var response = await dio.get("https://gitee.com/api/v5/repos/honoki/momotoki/releases/latest");
  if(response.data["tag_name"] == AppLibrary.appVersion){
    BotToast.showText(text: "已是最新版本");
  }else{
    var result = (await Get.dialog(Inquiredialog(title:"发现最新版本",content: "发现最新版本${response.data["tag_name"]}，是否前往下载？")))??false;
    if(!result) return;
    //初始化最新版的网页，如果获取不到就去最新版的网页
    String path = "https://gitee.com/honoki/momotoki/releases/latest";
    for(int i = 0;i<response.data["assets"].length;i++){
      String keyWord = "android";
      if(Platform.isAndroid){
        keyWord = "android";
      }else if(Platform.isWindows){
        keyWord = "windows";
      }
      if(response.data["assets"][i]["name"].toString().contains(keyWord)){
        path = response.data["assets"][i]["browser_download_url"];
        break;
      }
    }
    //打开解析好的最新的网页
    final Uri url = Uri.parse(path);
    if (!await launchUrl(url,mode:LaunchMode.platformDefault)) {
      BotToast.showText(text: "打开错误");
    }
  }
}