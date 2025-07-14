import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

enum Methods {
  GET,POST,PUT,DELETE,PATCH,HEAD
}
class Requests{
  static Requests? _instance;
  factory Requests() => _instance??Requests._();
  Dio _dio = Dio();
  Requests._(){
    _instance = this;
    _dio = Dio(
      BaseOptions(
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        connectTimeout: const Duration(seconds: 10)
      )
    );
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
        continue;
      }
    }
  }

}