import 'dart:convert';
import 'package:mobile/src/widgets/custom_snackbar.dart';
import 'package:mobile/src/screens/venu/venue_detail_screen.dart';
import 'package:mobile/src/screens/creator/creator_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LikeList extends StatefulWidget {
  const LikeList({Key? key}) : super(key: key);

  @override
  State<LikeList> createState() => _LikeListState();
}

class _LikeListState extends State<LikeList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _likes = [];
  bool _isLoading = true;
  String _currentType = 'venue';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLikes(_currentType);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final newType = _indexToType(_tabController.index);
      if (_currentType != newType) {
        setState(() {
          _currentType = newType;
          _isLoading = true;
        });
        _loadLikes(newType);
      }
    });
  }

  String _indexToType(int index) {
    switch (index) {
      case 0:
        return 'venue';
      case 1:
        return 'creator';
      case 2:
        return 'supporter';
      default:
        return 'venue';
    }
  }

  Future<void> _loadLikes(String type) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      if (token == null) throw Exception("No token found");

      final uri = Uri.parse('${dotenv.get('API_URL')}/like/me')
          .replace(queryParameters: {
        'targetType': type,
      });

      final response = await http.get(
        uri,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _likes = (data as List).where((like) => like[type] != null).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _likes = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _likes = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _removeLike(int likeId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    if (token == null) throw Exception("No token found");

    final url = Uri.parse("${dotenv.get('API_URL')}/like/$likeId");
    final res = await http.delete(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 200 || res.statusCode == 204) {
      setState(() {
        _likes = _likes.where((like) => like['id'] != likeId).toList();
      });
    } else {
      showAnimatedSnackBar(
        context,
        message: 'いいねの削除に失敗しました',
        type: SnackBarType.error,
      );
    }
  }

  Widget _buildTabButton(String label, int index) {
    final bool selected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.index = index;
          _loadLikes(_indexToType(index));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    List<dynamic> data = _likes;
    String emptyText = '';

    if (_tabController.index == 0) {
      emptyText = '会場のいいねはありません';
    } else if (_tabController.index == 1) {
      emptyText = 'クリエイターのいいねはありません';
    } else if (_tabController.index == 2) {
      emptyText = 'サポーターのいいねはありません';
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      margin: const EdgeInsets.only(top: 0, bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : data.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text(
                        emptyText,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ),
                  )
                : Column(
                    children: List.generate(data.length, (index) {
                      final item = data[index];

                      return Container(
                        decoration: BoxDecoration(
                          border: index < data.length - 1
                              ? const Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFE0E0E0),
                                    width: 1,
                                  ),
                                )
                              : null,
                        ),
                        child: InkWell(
                          onTap: () {
                            if (_currentType == 'venue') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VenueDetailScreen(
                                      venueId: item['venue']['id']),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreatorDetailScreen(
                                      creatorId: item['creator']['id']),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 画像部分
                              Container(
                                width: 68,
                                height: 68,
                                margin: const EdgeInsets.only(
                                    left: 16, top: 16, bottom: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: Colors.grey[200],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: (item[_currentType]?['imageUrl'] ?? '')
                                        .toString()
                                        .isNotEmpty
                                    ? Image.network(
                                        item[_currentType]['imageUrl'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(Icons.image_not_supported,
                                                    color: Colors.grey[400],
                                                    size: 28),
                                      )
                                    : Icon(Icons.image,
                                        color: Colors.grey[400], size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 16, 16, 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // メインの情報（名前・住所）
                                      Text(
                                        item[_currentType]['name'] ?? 'タイトル未設定',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // もし venue なら住所を表示
                                      if (_currentType == 'venue')
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2.0, bottom: 2.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 15, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  item[_currentType]
                                                          ['address'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              // 右端に日時・いいねボタン
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 0, right: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // 日時
                                    Text(
                                      (() {
                                        final dateTimeStr = item['requestAt'];
                                        if (dateTimeStr == null ||
                                            dateTimeStr.isEmpty) {
                                          return '';
                                        }
                                        try {
                                          final dt = DateTime.parse(dateTimeStr)
                                              .toLocal();
                                          return '${dt.month.toString().padLeft(2, '0')}/'
                                              '${dt.day.toString().padLeft(2, '0')} '
                                              '${dt.hour.toString().padLeft(2, '0')}:'
                                              '${dt.minute.toString().padLeft(2, '0')}';
                                        } catch (_) {
                                          return dateTimeStr;
                                        }
                                      })(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // いいねボタン
                                    IconButton(
                                      icon: const Icon(Icons.favorite,
                                          color: Colors.pink),
                                      onPressed: () {
                                        _removeLike(item['id']);
                                      },
                                      tooltip: 'いいね解除',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      margin: const EdgeInsets.fromLTRB(6, 16, 6, 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'いいね',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // タブバー
                Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton('会場', 0),
                      _buildTabButton('クリエイター', 1),
                      // _buildTabButton('サポーター', 2),
                    ],
                  ),
                ),
                // タブ内容
                _buildTabContent(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
