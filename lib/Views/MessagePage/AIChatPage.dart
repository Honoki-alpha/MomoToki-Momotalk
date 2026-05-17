import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:motoki/Components/MessageBox.dart';
import 'package:motoki/Entity/EMessageBox.dart';
import 'package:motoki/Managers/MessageManager.dart';
import 'package:motoki/Managers/Students.dart';
import '../../Apis/Requests.dart';
import '../../Components/StudentCircleAvatar.dart';
import '../../Entity/EStudent.dart';

class AIChatPage extends StatefulWidget{
  const AIChatPage({super.key, required this.isDeepSeek});
  final bool isDeepSeek;

  @override
  State<StatefulWidget> createState() => _AiChatPage();

}

class _AiChatPage extends State<AIChatPage>{
  //当前选择的学生
  EStudent currentStudent = Students().studentMap.entries.first.value;
  RxInt currentStudentSkinIndex = 0.obs;
  ScrollController sc = ScrollController();
  TextEditingController input = TextEditingController();

  RxBool isWating = false.obs;
  RxBool usualVisable = false.obs;
  var isReasoner = false.obs;

  // 1. 配置 Dio 实例
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.deepseek.com/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Authorization':"Bearer ${UserConfig.deepSeekKey}" , // apikey
    },
  ));

  final List<Map<String,String>> historyMessage = [{
    "role": "system",
    "content": "You are a student."
  }];
  final Map errorCodeMap = {
    "400 Bad_Request":"请求格式错误或无效。老师的请求参数有误，请检查请求信息中是否含有非法字符并修正请求参数。",
    "401 Unauthorized":"API密钥无效或未提供。请老师检查API密钥是否正确，并确保在请求中正确提供。",
    "403 Forbidden":"老师的余额不足。",
    "404 Not_Found":"请求的资源未找到。老师可能正在试图访问一个不存在的端点。",
    "413 Request_Entity_Too_Large":"请求体太大。老师可能需要减少你的请求数据量。",
    "429 Too_Many_Requests":"由于短时间内发送过多的请求，老师已经超过了你的速率限制。",
    "500 Internal_Server_Error":"服务器内部错误。这可能是OpenAI服务器的问题，并非老师的问题，可切换HOST尝试，若仍出现问题，请等待OpenAI解决。",
    "503 Service_Unavailable":"服务暂时不可用。这可能是由于OpenAI正在进行维护或者服务器过载引起，请耐心等待一段时间后尝试。",
  };
  String hostlink = "https://api.chatanywhere.tech";
  int hostIndex = Random().nextInt(1);
  final Map<String,String> headers = {
    'Authorization': 'Bearer ${UserConfig.aiChatKey}',
    'Content-Type': 'application/json'
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentStudent = Students().getStudentById(MessageManager.instance.currentStudentId);
    hostlink = UserConfig.aiChatUrl ?? "https://api.chatanywhere.tech";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppLibrary.appLandscapeMode? null:
        AppBar(title: Text("AI聊天"),actions: [
          IconButton(onPressed: saveButtonClick, icon: const Icon(Icons.save))
        ],),
      body:Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: Container(
            color: Colors.white,
            child: ListView.builder(
                shrinkWrap: true,
                controller: sc,
                itemCount: MessageManager.instance.aiMessages.length,
                itemBuilder: (context,index){
                  return GestureDetector(
                    child: MessageBox(index:index, isPlayMode: true,tempBox: MessageManager.instance.aiMessages[index],),
                    onDoubleTap: (){
                      String mes = MessageManager.instance.aiMessages[index]["messageContentList"][0];
                      Clipboard.setData(ClipboardData(text: mes));
                      BotToast.showText(text: "复制文字成功");
                    },
                  );
                }),
          )),
          Obx(()=>Container(child: isWating.value?const Text("获取消息中..."):null,)),
          Row(
            children: [
              //expanded用于限制输入范围
              const SizedBox(width: 10,),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                      icon:GestureDetector(
                        child: StudentCircleAvatar(id:MessageManager.instance.currentStudentId,skinIndex: currentStudentSkinIndex.value),
                        onTap: (){
                          usualVisable.value = !usualVisable.value;
                        },)
                  ),
                  controller: input,
                  maxLines: null,
                ),
              ),
              //点击“发送”按钮效果

            ],
          ),
          Row(
            children: [
              Obx(()=>Checkbox(value: isReasoner.value, onChanged: (change){
                isReasoner.value = change ?? false;
              })),
              const Text("深度思考"),
              Spacer(),
              ElevatedButton(onPressed: sendButtonClick, child:const Text("发送")),
            ],
          ),
          const SizedBox(height: 5,),
          Obx(()=>SizedBox(
              child: usualVisable.value?SizedBox(
                  height: 120,
                  child: GridView.builder(
                      itemCount: Students().usualStudents.length,
                      gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 5,
                        crossAxisCount: AppLibrary.appLandscapeMode?9:7, //每行五列
                        childAspectRatio: 1.0, //显示区域宽高相等
                      ), itemBuilder: (context, index){
                    List studentAndSkin = Students().usualStudents[index].split("||");
                    var iconId = int.parse(studentAndSkin[0]);
                    var iconSkin = int.parse(studentAndSkin[1]);
                    return GestureDetector(
                      child:StudentCircleAvatar(id:iconId,skinIndex: iconSkin),
                      onTap: (){
                        currentStudentSkinIndex.value = iconSkin;
                        currentStudent = Students().getStudentById(iconId);
                        setState(() {});
                      },
                    );
                  })):const SizedBox()
          ))
        ],
      ),
    );
  }


  void saveButtonClick()async{
    var cancel = BotToast.showLoading();
    await MessageManager.instance.saveAIMessages();
    cancel();
    BotToast.showText(text: "保存成功( •̀ ω •́ )y");
  }

  void sendButtonClick()async{
    if(input.text.isEmpty) return;
    isWating.value = true;
    //使用添加消息函数
    addMessage(1, input.text);
    updateHistoryMessage("user",input.text);
    input.text = "";
    //使用获取AI消息函数
    if(widget.isDeepSeek){
      await getDeepSeekMessage();
    }else{
      await getAIMessage();
    }
    isWating.value = false;

  }

  Future getAIMessage()async{
    var body = json.encode({
      "model": "gpt-3.5-turbo",
      "messages": historyMessage
    });
    var result = await post(
        Uri.parse("$hostlink/v1/chat/completions"),
        headers: headers,
        body: body,
        encoding:Encoding.getByName("UTF-8"));
    if(result.statusCode == 200){
      var responseBody = utf8.decode(result.bodyBytes);
      var decodedData = json.decode(responseBody);
      String mes = decodedData["choices"][0]["message"]["content"];
      updateHistoryMessage("assistant", mes);//历史对话中添加上AI的回复
      addMessage(currentStudent.id, mes);
      refreshBottom();
    }else{
      var responseBody = utf8.decode(result.bodyBytes);
      var decodedData = json.decode(responseBody);
      var errorMes = decodedData["error"]["code"];
      addMessage(currentStudent.id, "老师，请求过程中出现错误\n错误代码：$errorMes\n请前往链接查看原因：https://chatanywhere.apifox.cn/doc-2664690}");
      refreshBottom();
    }
  }

  Future getDeepSeekMessage()async{
    // 构建请求体
    final data = {
      "model": isReasoner.value?"deepseek-v4-pro":"deepseek-v4-flash",
      "messages": historyMessage,
      "stream": false
    };

    try {
      // 发送 POST 请求
      final response = await dio.post('/chat/completions', data: data);
      // 解析响应
      if (response.statusCode == 200) {
        final answer = response.data['choices'][0]['message']['content'];
        updateHistoryMessage("assistant", answer);//历史对话中添加上AI的回复
        addMessage(currentStudent.id, answer);
        refreshBottom();
      } else {
        addMessage(currentStudent.id, "请求错误，错误原因可能为:\n1.Api Key填写错误；\n2.Api Key余额不足请前往deepseek官网充值\n3.网络问题");
        refreshBottom();
      }
    } catch (e) {
      addMessage(currentStudent.id, "请求错误，错误原因可能为:\n1.Api Key填写错误；\n2.Api Key余额不足请前往deepseek官网充值\n3.网络问题");
      refreshBottom();
    }
  }

  void updateHistoryMessage(String role,String content){
    historyMessage.add({
      "role":role,
      "content":content
    });
  }

  void refreshBottom(){
    Timer(const Duration(milliseconds: 100), () {
      sc.animateTo(
        sc.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuart,
      );
    });
  }

  void addMessage(int senderId,String text){
    EMessageBox eMessageBox = EMessageBox(
        senderId,
        currentStudentSkinIndex.value,
        0,
        Students().getStudentName(senderId),
        [text],
        false,
        {});
    setState(() {
      MessageManager.instance.addAIMessageBox(eMessageBox);
    });
  }
}