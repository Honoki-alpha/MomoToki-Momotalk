import 'dart:developer';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:motoki/AppData/UserConfig.dart';
import 'package:path/path.dart';

enum Methods {
  GET,POST,PUT,DELETE,PATCH,HEAD
}
class Requests{
  static Requests? _instance;
  factory Requests() => _instance??Requests._();
  Dio _dio = Dio();
  Dio _deepseek = Dio();
  Requests._(){
    _instance = this;
    _dio = Dio(
      BaseOptions(
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        connectTimeout: const Duration(seconds: 10)
      )
    );
    _deepseek = Dio(BaseOptions(
        headers: {
          //'Content-Type': 'application/json',
          //'Accept': 'application/json',
          'Authorization': 'Bearer ${UserConfig.deepSeekKey}'
        },
        validateStatus: (status) {
          return true; // 这样就不会因为状态码而抛出异常，我们可以自己处理
        },
    ));

  }


  final Map _methodValues = {
    Methods.GET: 'get',
    Methods.POST: 'post',
    Methods.PUT: 'put',
    Methods.DELETE: 'delete',
    Methods.PATCH: 'patch',
    Methods.HEAD: 'head'
  };

  ///
  /// 网络请求
  ///
  Future request(String path,
      {Methods methods = Methods.GET,
        Map<String, dynamic>? params,
        dynamic data,
        CancelToken? cancelToken,
        Options? options,
        Function(int,int)? onSendProgress,
        Function(int,int)? onReceiveProgress,
      })async{
    Options options = Options(method: _methodValues[methods]);
    try{
      var result = await _dio.request(
          path,queryParameters: params,data: data,options:options,
          cancelToken: cancelToken,onSendProgress: onSendProgress,onReceiveProgress:onReceiveProgress);
      return result.data;
    }on DioException catch(e){
      log("发送请求异常:$e");
      BotToast.showText(text: "网络请求异常，请稍后再试");
      return null;
    }
  }

  Future downloadList(String path,List urls)async{
    for(var url in urls){
      try{
        _dio.download(url, path);
      }catch(e){
        BotToast.showText(text: "资源下载失败，请检查网络问题");
        continue;
      }
    }
  }

  Future getAiMessage(String content)async{
    try {
      final response = await _deepseek.post(
        'https://api.deepseek.com/chat/completions',
        data: {
          "model": "deepseek-chat",
          "messages": "hi",
        },
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
    }
  }
}