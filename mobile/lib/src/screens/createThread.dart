import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/screens/threadDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mobile/utils/userInfo.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class CreateThreadModal extends StatefulWidget {
  final Function? onSuccess;
  final String? initialRestaurantName;
  final String? initialRestaurantAddress;
  final String? initialRestaurantUrl;

  const CreateThreadModal({
    Key? key,
    this.onSuccess,
    this.initialRestaurantName,
    this.initialRestaurantAddress,
    this.initialRestaurantUrl,
  }) : super(key: key);

  @override
  State<CreateThreadModal> createState() => _CreateThreadModalState();
}

class _CreateThreadModalState extends State<CreateThreadModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _restaurantAddressController = TextEditingController();
  final _restaurantUrlController = TextEditingController();

  PurposeCategory? _selectedPurposeCategory;
  FoodCategory? _selectedFoodCategory;
  Prefecture? _selectedPrefecture;
  bool _isLoading = false;

  bool get _isFormValid {
    return _titleController.text.isNotEmpty &&
        _titleController.text.length <= 20 &&
        _selectedPurposeCategory != null &&
        _selectedFoodCategory != null &&
        _selectedPrefecture != null;
  }

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _restaurantNameController.addListener(_onFormChanged);
    _restaurantAddressController.addListener(_onFormChanged);
    _restaurantUrlController.addListener(_onFormChanged);

    // 受け取った初期値を各コントローラーに設定する
    _restaurantNameController.text = widget.initialRestaurantName ?? '';
    _restaurantAddressController.text = widget.initialRestaurantAddress ?? '';
    _restaurantUrlController.text = widget.initialRestaurantUrl ?? '';

    // デフォルトの都道府県を東京都に設定
    _selectedPrefecture = Prefecture.TOKYO;
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _restaurantNameController.removeListener(_onFormChanged);
    _restaurantAddressController.removeListener(_onFormChanged);
    _restaurantUrlController.removeListener(_onFormChanged);
    _titleController.dispose();
    _restaurantNameController.dispose();
    _restaurantAddressController.dispose();
    _restaurantUrlController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {
      // フォームの状態が変化したときにUI更新
    });
  }

  Future<void> _createThread() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/thread'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'purposeCategory': _selectedPurposeCategory?.value,
          'foodCategory': _selectedFoodCategory?.value,
          'prefecture': _selectedPrefecture?.value,
          'restaurantName': _restaurantNameController.text,
          'restaurantAddress': _restaurantAddressController.text,
          'restaurantUrl': _restaurantUrlController.text,
        }),
      );

      if (response.statusCode == 201) {
        // レスポンスから作成したスレッドの情報を取得（IDなど）
        final threadData = jsonDecode(response.body);
        final int createdThreadId = threadData['id'];

        // onSuccessが設定されていれば呼び出す
        if (widget.onSuccess != null) widget.onSuccess!();

        // モーダルを閉じる
        Navigator.pop(context);

        // モーダルが閉じた後にThreadDetailScreenに遷移する
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ThreadDetailScreen(threadId: createdThreadId),
            ),
          );
        });

        showAnimatedSnackBar(
          context,
          message: 'スレッドを作成しました',
          type: SnackBarType.success,
        );
      } else {
        throw Exception('スレッドの作成に失敗しました');
      }
    } catch (e) {
      showAnimatedSnackBar(
        context,
        message: 'スレッドの作成に失敗しました',
        type: SnackBarType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCategoryChip(dynamic category, bool isPurpose) {
    final bool isSelected = isPurpose
        ? _selectedPurposeCategory == category
        : _selectedFoodCategory == category;
    // 目的カテゴリなら紫系、料理カテゴリなら青系の色に設定
    final Color chipSelectedColor = isPurpose
        ? (Colors.purple[600] ?? Colors.purple)
        : (Colors.blue[600] ?? Colors.blue);

    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        label: Text(
          category.japanName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 11,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            if (isPurpose) {
              _selectedPurposeCategory = selected ? category : null;
            } else {
              _selectedFoodCategory = selected ? category : null;
            }
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: chipSelectedColor,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? chipSelectedColor : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 667.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // モーダルのハンドル
                Center(
                  child: Container(
                    width: 30,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ヘッダー
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'スレッド作成',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                      iconSize: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // タイトル入力
                Row(
                  children: [
                    Icon(
                      Icons.title,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'タイトル（最大20文字）',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: 'スレッドのタイトルを入力',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'タイトルを入力してください';
                    }
                    if (value.length > 20) {
                      return 'タイトルは20文字以内で入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 目的カテゴリー
                Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 12,
                      color: Colors.purple[400],
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '目的',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: PurposeCategory.values
                      .map((category) => _buildCategoryChip(category, true))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // 料理カテゴリー
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      size: 12,
                      color: Colors.blue[400],
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '料理カテゴリ',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: FoodCategory.values
                      .map((category) => _buildCategoryChip(category, false))
                      .toList(),
                ),
                const SizedBox(height: 20),

                // 都道府県
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: Colors.green[400],
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '都道府県',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Prefecture>(
                  decoration: InputDecoration(
                    hintText: '都道府県を選択',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  value: _selectedPrefecture,
                  items: Prefecture.values.map((prefecture) {
                    return DropdownMenuItem(
                      value: prefecture,
                      child: Text(prefecture.japanName),
                    );
                  }).toList(),
                  onChanged: (Prefecture? newValue) {
                    setState(() {
                      _selectedPrefecture = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return '都道府県を選択してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 飲食店名入力（任意）
                Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 12,
                      color: Colors.orange[400],
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '飲食店名（任意）',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _restaurantNameController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '飲食店名を入力',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 20),

                // 飲食店住所入力（任意）
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: Colors.red[400],
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '飲食店住所（任意）',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _restaurantAddressController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '飲食店住所を入力',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 20),

                // 飲食店URL入力（任意）
                Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 12,
                      color: Colors.blue[400],
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '飲食店URL（任意）',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _restaurantUrlController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '飲食店URLを入力',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 24),

                // 作成ボタン
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading || !_isFormValid ? null : _createThread,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'スレッドを作成',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                              color: !_isFormValid
                                  ? Colors.grey[600]
                                  : Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
