import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropperDemo extends StatefulWidget {
  @override
  _ImageCropperDemoState createState() => _ImageCropperDemoState();
}

class _ImageCropperDemoState extends State<ImageCropperDemo> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _pickAndCropImage() async {
    // 画像を選択
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // クロッピング
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '画像をクロップ',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: '画像をクロップ',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = XFile(croppedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Cropper Demo')),
      body: Center(
        child: _imageFile == null
            ? Text('画像を選択してください')
            : Image.file(File(_imageFile!.path)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndCropImage,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
