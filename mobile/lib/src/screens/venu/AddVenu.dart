import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/utils/userInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class AddVenuScreen extends StatefulWidget {
  @override
  _AddVenuScreenState createState() => _AddVenuScreenState();
}

class _AddVenuScreenState extends State<AddVenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _telController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();
  final _facilitiesController = TextEditingController();
  final _availableTimeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _telController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _facilitiesController.dispose();
    _availableTimeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // フォームのデータを保存する処理をここに追加
      print('Name: ${_nameController.text}');
      print('Address: ${_addressController.text}');
      print('Tel: ${_telController.text}');
      print('Description: ${_descriptionController.text}');
      print('Capacity: ${_capacityController.text}');
      print('Facilities: ${_facilitiesController.text}');
      print('Available Time: ${_availableTimeController.text}');
      print('Image URL: ${_imageUrlController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      labelStyle: const TextStyle(color: Colors.black54),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepOrangeAccent),
      ),
      border: const OutlineInputBorder(),
      fillColor: Colors.grey.shade200,
      filled: true,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          '会場追加',
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Noto Sans JP',
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration.copyWith(
                  labelText: '会場名',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '会場名を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration.copyWith(
                  labelText: '住所',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telController,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration.copyWith(
                  labelText: '電話番号',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration.copyWith(
                  labelText: '説明',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration.copyWith(
                  labelText: '収容人数',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _facilitiesController,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration.copyWith(
                  labelText: '設備情報',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _availableTimeController,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration.copyWith(
                  labelText: '利用可能時間',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration.copyWith(
                  labelText: '画像URL',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                  ),
                  child: const Text('保存',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
