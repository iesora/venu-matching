import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/screens/threadDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mobile/utils/userInfo.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class SearchUserModal extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;
  const SearchUserModal({
    Key? key,
    this.initialFilters,
  }) : super(key: key);

  @override
  State<SearchUserModal> createState() => _SearchUserModalState();
}

class _SearchUserModalState extends State<SearchUserModal> {
  Prefecture? _selectedPrefecture;
  BodyType? _selectedBodyType;
  MaritalStatus? _selectedMaritalStatus;
  Occupation? _selectedOccupation;
  ConvenientTime? _selectedConvenientTime;
  Sex? _selectedSex;

  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _minHeightController = TextEditingController();
  final _maxHeightController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 渡された検索条件（フィルター）で各項目の初期値をセット
    if (widget.initialFilters != null) {
      if (widget.initialFilters!['minAge'] != null) {
        _minAgeController.text = widget.initialFilters!['minAge'].toString();
      }
      if (widget.initialFilters!['maxAge'] != null) {
        _maxAgeController.text = widget.initialFilters!['maxAge'].toString();
      }
      if (widget.initialFilters!['minHeight'] != null) {
        _minHeightController.text =
            widget.initialFilters!['minHeight'].toString();
      }
      if (widget.initialFilters!['maxHeight'] != null) {
        _maxHeightController.text =
            widget.initialFilters!['maxHeight'].toString();
      }
      if (widget.initialFilters!['prefecture'] != null) {
        try {
          _selectedPrefecture = Prefecture.values.firstWhere(
            (pref) => pref.value == widget.initialFilters!['prefecture'],
          );
        } catch (e) {
          _selectedPrefecture = null;
        }
      }
      if (widget.initialFilters!['bodyType'] != null) {
        try {
          _selectedBodyType = BodyType.values.firstWhere(
            (body) => body.value == widget.initialFilters!['bodyType'],
          );
        } catch (e) {
          _selectedBodyType = null;
        }
      }
      if (widget.initialFilters!['occupation'] != null) {
        try {
          _selectedOccupation = Occupation.values.firstWhere(
            (occ) => occ.value == widget.initialFilters!['occupation'],
          );
        } catch (e) {
          _selectedOccupation = null;
        }
      }
      if (widget.initialFilters!['convenientTime'] != null) {
        try {
          _selectedConvenientTime = ConvenientTime.values.firstWhere(
            (time) => time.value == widget.initialFilters!['convenientTime'],
          );
        } catch (e) {
          _selectedConvenientTime = null;
        }
      }
      if (widget.initialFilters!['sex'] != null) {
        try {
          _selectedSex = Sex.values.firstWhere(
            (s) => s.value == widget.initialFilters!['sex'],
          );
        } catch (e) {
          _selectedSex = null;
        }
      }
      if (widget.initialFilters!['maritalStatus'] != null) {
        try {
          _selectedMaritalStatus = MaritalStatus.values.firstWhere(
            (m) => m.value == widget.initialFilters!['maritalStatus'],
          );
        } catch (e) {
          _selectedMaritalStatus = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _minHeightController.dispose();
    _maxHeightController.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    final minAge = int.tryParse(_minAgeController.text);
    final maxAge = int.tryParse(_maxAgeController.text);
    final minHeight = int.tryParse(_minHeightController.text);
    final maxHeight = int.tryParse(_maxHeightController.text);

    final filters = <String, dynamic>{};
    if (minAge != null) filters['minAge'] = minAge;
    if (maxAge != null) filters['maxAge'] = maxAge;
    if (minHeight != null) filters['minHeight'] = minHeight;
    if (maxHeight != null) filters['maxHeight'] = maxHeight;
    if (_selectedPrefecture != null) {
      filters['prefecture'] = _selectedPrefecture!.value;
      print('prefecture: ${_selectedPrefecture!.value}');
    }
    if (_selectedBodyType != null) {
      filters['bodyType'] = _selectedBodyType!.value;
      print('bodyType: ${_selectedBodyType!.value}');
    }
    if (_selectedOccupation != null) {
      filters['occupation'] = _selectedOccupation!.value;
      print('occupation: ${_selectedOccupation!.value}');
    }
    if (_selectedConvenientTime != null) {
      filters['convenientTime'] = _selectedConvenientTime!.value;
      print('convenientTime: ${_selectedConvenientTime!.value}');
    }
    if (_selectedSex != null) {
      filters['sex'] = _selectedSex!.value;
      print('sex: ${_selectedSex!.value}');
    }
    if (_selectedMaritalStatus != null) {
      filters['maritalStatus'] = _selectedMaritalStatus!.value;
      print('maritalStatus: ${_selectedMaritalStatus!.value}');
    }

    // モーダルを閉じる際にフィルター条件を返す
    Navigator.pop(context, filters);
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
                    'ユーザー検索',
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
              // 年齢ラベル
              Row(
                children: [
                  Icon(
                    Icons.cake,
                    size: 12,
                    color: Colors.deepOrange,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '年齢',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 年齢の最小〜最大を横並びにする
              Row(
                children: [
                  // 最小年齢
                  Expanded(
                    child: TextFormField(
                      controller: _minAgeController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '何歳から',
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
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 最大年齢
                  Expanded(
                    child: TextFormField(
                      controller: _maxAgeController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '何歳まで',
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 都道府県
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: Colors.redAccent,
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
              DropdownButtonFormField<Prefecture?>(
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
                items: [
                  DropdownMenuItem<Prefecture?>(
                    value: null,
                    child: const Text('こだわらない'),
                  ),
                  ...Prefecture.values
                      .map((prefecture) => DropdownMenuItem<Prefecture?>(
                            value: prefecture,
                            child: Text(prefecture.japanName),
                          )),
                ],
                onChanged: (Prefecture? newValue) {
                  setState(() {
                    _selectedPrefecture = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              // 身長ラベル
              Row(
                children: [
                  Icon(
                    Icons.straighten,
                    size: 12,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '身長',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 身長の最小〜最大を横並びにする
              Row(
                children: [
                  // 最小身長
                  Expanded(
                    child: TextFormField(
                      controller: _minHeightController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '何cmから',
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
                  ),
                  const SizedBox(width: 16),
                  // 最大身長
                  Expanded(
                    child: TextFormField(
                      controller: _maxHeightController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '何cmまで',
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
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 体型
              Row(
                children: [
                  Icon(
                    Icons.accessibility_new,
                    size: 12,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '体型',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<BodyType?>(
                decoration: InputDecoration(
                  hintText: '体型を選択',
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
                value: _selectedBodyType,
                items: [
                  DropdownMenuItem<BodyType?>(
                    value: null,
                    child: const Text('こだわらない'),
                  ),
                  ...BodyType.values
                      .map((bodyType) => DropdownMenuItem<BodyType?>(
                            value: bodyType,
                            child: Text(bodyType.japanName),
                          )),
                ],
                onChanged: (BodyType? newValue) {
                  setState(() {
                    _selectedBodyType = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              // 職業
              Row(
                children: [
                  Icon(
                    Icons.work,
                    size: 12,
                    color: Colors.indigo,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '職業',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Occupation?>(
                decoration: InputDecoration(
                  hintText: '職業を選択',
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
                value: _selectedOccupation,
                items: [
                  DropdownMenuItem<Occupation?>(
                    value: null,
                    child: const Text('こだわらない'),
                  ),
                  ...Occupation.values
                      .map((occupation) => DropdownMenuItem<Occupation?>(
                            value: occupation,
                            child: Text(occupation.japanName),
                          )),
                ],
                onChanged: (Occupation? newValue) {
                  setState(() {
                    _selectedOccupation = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              // 都合の良い時間帯
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 12,
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '都合の良い時間帯',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ConvenientTime?>(
                decoration: InputDecoration(
                  hintText: '都合の良い時間帯を選択',
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
                value: _selectedConvenientTime,
                items: [
                  DropdownMenuItem<ConvenientTime?>(
                    value: null,
                    child: const Text('こだわらない'),
                  ),
                  ...ConvenientTime.values.map(
                      (convenientTime) => DropdownMenuItem<ConvenientTime?>(
                            value: convenientTime,
                            child: Text(convenientTime.japanName),
                          )),
                ],
                onChanged: (ConvenientTime? newValue) {
                  setState(() {
                    _selectedConvenientTime = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              // 性別
              Row(
                children: [
                  Icon(
                    Icons.transgender,
                    size: 12,
                    color: Colors.pinkAccent,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '性別',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Sex?>(
                decoration: InputDecoration(
                  hintText: '性別',
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
                value: _selectedSex,
                items: [
                  DropdownMenuItem<Sex?>(
                    value: null,
                    child: const Text('こだわらない'),
                  ),
                  ...Sex.values.map((sex) => DropdownMenuItem<Sex?>(
                        value: sex,
                        child: Text(sex.japanName),
                      )),
                ],
                onChanged: (Sex? newValue) {
                  setState(() {
                    _selectedSex = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              // 婚姻状況
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 12,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '婚姻状況',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<MaritalStatus?>(
                decoration: InputDecoration(
                  hintText: '婚姻状況を選択',
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
                value: _selectedMaritalStatus,
                items: [
                  DropdownMenuItem<MaritalStatus?>(
                    value: null,
                    child: const Text('こだわらない'),
                  ),
                  ...MaritalStatus.values
                      .map((maritalStatus) => DropdownMenuItem<MaritalStatus?>(
                            value: maritalStatus,
                            child: Text(maritalStatus.japanName),
                          )),
                ],
                onChanged: (MaritalStatus? newValue) {
                  setState(() {
                    _selectedMaritalStatus = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 24),
              // 検索ボタン
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _searchUser,
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
                      : const Text(
                          '検索',
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
    );
  }
}
