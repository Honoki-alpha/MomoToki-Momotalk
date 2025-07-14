import 'package:flutter/material.dart';

class SettingBox extends StatelessWidget {
  const SettingBox({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.07),
          borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        children: children,
      ),
    );
  }
}