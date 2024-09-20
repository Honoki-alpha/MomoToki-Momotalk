import 'dart:io';
import 'package:image_picker/image_picker.dart';
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