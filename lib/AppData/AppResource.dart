
import 'dart:io';

import 'package:flutter/material.dart';

class AppResource{
  static Map<int,List<Image>> studentAvatars = {};

  static void addImage(int id,String type,String path){
    Image img = Image.network(
      path,
      scale: 30,
      filterQuality: FilterQuality.low,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress){
        if(loadingProgress == null){
          return child;
        }else{
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        }
      },
    );
    if(type == "file"){
      img = Image.file(File(path),errorBuilder: (b,o,t){
        return Image.asset("assets/images/icon/IMAGELOST.png",fit: BoxFit.fitWidth,);
      });
    }
    if(studentAvatars.containsKey(id)){
      studentAvatars[id]!.add(img);
    }else{
      studentAvatars[id] = [img];
    }
  }

  static void alterImage(int id,String path){
    studentAvatars[id] = [Image.file(File(path),errorBuilder: (b,o,t){
      return Image.asset("assets/images/icon/IMAGELOST.png",fit: BoxFit.fitWidth,);
    })];
  }
}