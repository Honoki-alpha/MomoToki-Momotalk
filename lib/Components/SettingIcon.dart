import 'package:flutter/material.dart';

class SettingIcon extends StatelessWidget {
  const SettingIcon({super.key, required this.icon, required this.label,this.color,this.onTap,this.onDoubleTap, this.onLongPress});
  final IconData icon;
  final String label;
  final Color? color;
  final Function()? onTap;
  final Function()? onDoubleTap;
  final Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: 80,
        height: 60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,color: color,),
            Text(label,style: const TextStyle(fontSize: 10),),
          ],
        ),
      ),
    );
  }


}
