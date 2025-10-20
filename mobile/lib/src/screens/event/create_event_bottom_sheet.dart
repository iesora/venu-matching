import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

enum RequestorType {
  venue,
  creator,
}

class CreateEventBottomSheet extends StatefulWidget {
  final int matchingId;
  final RequestorType requestorType;
  final Function? onSuccess;

  const CreateEventBottomSheet({
    Key? key,
    required this.matchingId,
    required this.requestorType,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<CreateEventBottomSheet> createState() => _CreateEventBottomSheetState();
}

class _CreateEventBottomSheetState extends State<CreateEventBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  bool _isLoading = false;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    _startDateController.addListener(_onFormChanged);
    _endDateController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _startDateController.removeListener(_onFormChanged);
    _endDateController.removeListener(_onFormChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
  }

  bool get _isFormValid {
    return _titleController.text.isNotEmpty &&
        _titleController.text.length <= 50 &&
        _descriptionController.text.isNotEmpty &&
        _selectedStartDate != null &&
        _selectedEndDate != null;
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedStartDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          _startDateController.text = _formatDateTime(_selectedStartDate!);
        });
      }
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedStartDate ?? DateTime.now(),
      firstDate: _selectedStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedEndDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          _endDateController.text = _formatDateTime(_selectedEndDate!);
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/event/matching'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'matchingId': widget.matchingId,
          'title': _titleController.text,
          'description': _descriptionController.text,
          'startDate': _selectedStartDate!.toIso8601String(),
          'endDate': _selectedEndDate!.toIso8601String(),
          'requestorType': widget.requestorType.name,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }

        Navigator.pop(context);

        showAnimatedSnackBar(
          context,
          message: 'イベントを作成しました',
          type: SnackBarType.success,
        );
      } else {
        showAnimatedSnackBar(
          context,
          message: 'イベントの作成に失敗しました',
          type: SnackBarType.error,
        );
        throw Exception('イベントの作成に失敗しました');
      }
    } catch (e) {
      print('エラー: $e');
      showAnimatedSnackBar(
        context,
        message: 'イベントの作成に失敗しました',
        type: SnackBarType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 700.0),
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
                      'イベント作成',
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

                // イベントタイトル入力
                Row(
                  children: [
                    const Icon(
                      Icons.event,
                      size: 12,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'イベントタイトル',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  maxLength: 50,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'イベントタイトルを入力',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    counterText: '${_titleController.text.length}/50',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
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
                      return 'イベントタイトルを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // イベント説明入力
                Row(
                  children: [
                    const Icon(
                      Icons.description,
                      size: 12,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'イベント説明',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLength: 500,
                  maxLines: 4,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'イベントの説明を入力',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    counterText: '${_descriptionController.text.length}/500',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
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
                      return 'イベント説明を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 開始日時入力
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 12,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '開始日時',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _startDateController.text.isEmpty
                                ? '開始日時を選択'
                                : _startDateController.text,
                            style: TextStyle(
                              color: _startDateController.text.isEmpty
                                  ? Colors.grey[600]
                                  : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 終了日時入力
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 12,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '終了日時',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectEndDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _endDateController.text.isEmpty
                                ? '終了日時を選択'
                                : _endDateController.text,
                            style: TextStyle(
                              color: _endDateController.text.isEmpty
                                  ? Colors.grey[600]
                                  : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 作成ボタン
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed:
                        (_isFormValid && !_isLoading) ? _createEvent : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      disabledBackgroundColor: Colors.grey[300],
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
                        : const Text(
                            'イベント作成',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                              color: Colors.white,
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
