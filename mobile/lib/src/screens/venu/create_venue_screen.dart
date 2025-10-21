import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class CreateVenueScreen extends HookWidget {
  const CreateVenueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final addressController = useTextEditingController();
    final telController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final capacityController = useTextEditingController();
    final facilitiesController = useTextEditingController();
    final availableTimeController = useTextEditingController();
    final imageUrlController = useTextEditingController();
    final latitudeController = useTextEditingController();
    final longitudeController = useTextEditingController();
    final isLoading = useState<bool>(false);

    Future<void> _createVenue() async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      try {
        isLoading.value = true;
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');

        final venueData = {
          'name': nameController.text,
          'address':
              addressController.text.isNotEmpty ? addressController.text : null,
          'tel': telController.text.isNotEmpty ? telController.text : null,
          'description': descriptionController.text.isNotEmpty
              ? descriptionController.text
              : null,
          'capacity': capacityController.text.isNotEmpty
              ? int.tryParse(capacityController.text)
              : null,
          'facilities': facilitiesController.text.isNotEmpty
              ? facilitiesController.text
              : null,
          'availableTime': availableTimeController.text.isNotEmpty
              ? availableTimeController.text
              : null,
          'imageUrl': imageUrlController.text.isNotEmpty
              ? imageUrlController.text
              : null,
          'latitude': latitudeController.text.isNotEmpty
              ? double.tryParse(latitudeController.text)
              : null,
          'longitude': longitudeController.text.isNotEmpty
              ? double.tryParse(longitudeController.text)
              : null,
        };

        final response = await http.post(
          Uri.parse('${dotenv.get('API_URL')}/venue'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(venueData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          showAnimatedSnackBar(
            context,
            message: '会場が正常に作成されました！',
            type: SnackBarType.success,
          );
          Navigator.pop(context, true); // 成功時にtrueを返す
        } else {
          final errorData = jsonDecode(response.body);
          showAnimatedSnackBar(
            context,
            message: errorData['message'] ?? '会場の作成に失敗しました',
            type: SnackBarType.error,
          );
        }
      } catch (e) {
        print('エラー: $e');
        showAnimatedSnackBar(
          context,
          message: '会場の作成に失敗しました',
          type: SnackBarType.error,
        );
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '会場登録',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 基本情報セクション
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '基本情報',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: '会場名 *',
                          hintText: '会場名を入力',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '会場名は必須です';
                          }
                          if (value.length > 255) {
                            return '255文字以内で入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: '住所',
                          hintText: '住所を入力してください',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.map),
                        ),
                        maxLines: 2,
                        maxLength: 500,
                        validator: (value) {
                          if (value != null && value.length > 500) {
                            return '500文字以内で入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: telController,
                        decoration: const InputDecoration(
                          labelText: '電話番号',
                          hintText: '03-1234-5678',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length > 20) {
                            return '20文字以内で入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: '説明',
                          hintText: '会場について説明してください',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 4,
                        maxLength: 1000,
                        validator: (value) {
                          if (value != null && value.length > 1000) {
                            return '1000文字以内で入力してください';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 会場詳細情報セクション
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '会場詳細情報',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: capacityController,
                        decoration: const InputDecoration(
                          labelText: '収容人数',
                          hintText: '100',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final capacity = int.tryParse(value);
                            if (capacity == null) {
                              return '有効な数値を入力してください';
                            }
                            if (capacity < 0) {
                              return '0以上の数値を入力してください';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: facilitiesController,
                        decoration: const InputDecoration(
                          labelText: '設備情報',
                          hintText: '音響設備、照明設備など',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.build),
                        ),
                        maxLines: 3,
                        maxLength: 1000,
                        validator: (value) {
                          if (value != null && value.length > 1000) {
                            return '1000文字以内で入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: availableTimeController,
                        decoration: const InputDecoration(
                          labelText: '利用可能時間',
                          hintText: '9:00-21:00',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length > 255) {
                            return '255文字以内で入力してください';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 位置情報セクション
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '位置情報',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: latitudeController,
                              decoration: const InputDecoration(
                                labelText: '緯度',
                                hintText: '35.6762',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.my_location),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final lat = double.tryParse(value);
                                  if (lat == null) {
                                    return '有効な数値を入力してください';
                                  }
                                  if (lat < -90 || lat > 90) {
                                    return '緯度は-90から90の間で入力してください';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: longitudeController,
                              decoration: const InputDecoration(
                                labelText: '経度',
                                hintText: '139.6503',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.my_location),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final lng = double.tryParse(value);
                                  if (lng == null) {
                                    return '有効な数値を入力してください';
                                  }
                                  if (lng < -180 || lng > 180) {
                                    return '経度は-180から180の間で入力してください';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 画像情報セクション
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '画像情報',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: '画像URL',
                          hintText: 'https://example.com/image.jpg',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final uri = Uri.tryParse(value);
                            if (uri == null || !uri.hasAbsolutePath) {
                              return '有効なURLを入力してください';
                            }
                            if (value.length > 1000) {
                              return '1000文字以内で入力してください';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 作成ボタン
              ElevatedButton(
                onPressed: isLoading.value ? null : _createVenue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
                child: isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '会場を作成',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
