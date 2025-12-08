import 'package:flutter/material.dart';
import 'package:motoki/AppData/AppLibrary.dart';
import 'package:motoki/AppData/UserConfig.dart';

class AdView extends StatelessWidget {
  const AdView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLibrary.adTitle),),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 6),
        child: Column(
          children: [
            Text(AppLibrary.adContent),
            if(!UserConfig.applyOfflineMode) Image.network(AppLibrary.adImage)
          ],
        ),
      ),
    );
  }
}