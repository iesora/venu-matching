import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/utils/userInfo.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';
import 'package:mobile/src/screens/editProfile.dart';

class ProfileScreen extends HookWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final creatorData = useState<List<dynamic>>([]);
    final venueData = useState<List<dynamic>>([]);
    final isLoadingCreator = useState<bool>(true);
    final isLoadingVenue = useState<bool>(true);
    final selectedType = useState<String>('venue'); // 'venue' or 'creator'
    final selectedCreator = useState<Map<String, dynamic>?>(null);
    final selectedVenue = useState<Map<String, dynamic>?>(null);

    useEffect(() {
      _fetchUserCreators(context, creatorData, isLoadingCreator);
      _fetchUserVenues(context, venueData, isLoadingVenue);
      return null;
    }, []);

    useEffect(() {
      print('selectedCreator: ${selectedCreator.value}');
      print('selectedVenue: ${selectedVenue.value}');
    }, [selectedCreator.value, selectedVenue.value]);

    // 展開するリストのウィジェット
    Widget _buildNameButtons() {
      if (isLoadingCreator.value || isLoadingVenue.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final items =
          selectedType.value == 'venue' ? venueData.value : creatorData.value;
      if (items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              selectedType.value == 'venue' ? '会場がありません' : 'クリエイターがいません',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(items.length, (index) {
            final item = items[index];
            return ElevatedButton(
              onPressed: () {
                // ここで各ボタン押下時の処理を追加できる
                if (selectedType.value == 'venue') {
                  selectedVenue.value = item;
                  selectedCreator.value = null;
                } else {
                  selectedCreator.value = item;
                  selectedVenue.value = null;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(item['name'] ?? ''),
            );
          }),
        ),
      );
    }

    // クリエイターの基本情報カード
    Widget _buildCreatorInfoCard(Map<String, dynamic> creator) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (creator['imageUrl'] != null &&
                  creator['imageUrl'].toString().isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      creator['imageUrl'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.person, size: 40),
                      ),
                    ),
                  ),
                ),
              if (creator['imageUrl'] != null &&
                  creator['imageUrl'].toString().isNotEmpty)
                const SizedBox(height: 16),
              Text(
                creator['name'] ?? '名前未設定',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (creator['description'] != null &&
                  creator['description'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    creator['description'],
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              const SizedBox(height: 12),
              if (creator['email'] != null &&
                  creator['email'].toString().isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.email, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(creator['email'],
                        style: const TextStyle(fontSize: 15)),
                  ],
                ),
              if (creator['website'] != null &&
                  creator['website'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      const Icon(Icons.link, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          creator['website'],
                          style:
                              const TextStyle(fontSize: 15, color: Colors.blue),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (creator['phoneNumber'] != null &&
                  creator['phoneNumber'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(creator['phoneNumber'],
                          style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              if (creator['socialMediaHandle'] != null &&
                  creator['socialMediaHandle'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      const Icon(Icons.alternate_email,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(creator['socialMediaHandle'],
                          style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    Widget _buildCreatorOpusesList(Map<String, dynamic> creator) {
      final List<dynamic> opuses = creator['opuses'] ?? [];
      if (opuses.isEmpty) {
        return const SizedBox.shrink();
      }

      // 1列か2列か判定
      final int crossAxisCount = opuses.length == 1 ? 1 : 2;

      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '作品ギャラリー',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: opuses.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  childAspectRatio: 1 / 2, // 縦長
                ),
                itemBuilder: (context, index) {
                  final opus = opuses[index];
                  final String title = opus['name'] ?? 'タイトル未設定';
                  final String? imageUrl =
                      (opus['imageUrl'] ?? '').toString().isNotEmpty
                          ? opus['imageUrl'] as String
                          : null;
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 画像部分（カード幅いっぱい、正方形）
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              child: Column(children: [
                                AspectRatio(
                                  aspectRatio: 1, // 正方形
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stack) =>
                                                  Container(
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 40),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Icon(Icons.image,
                                                size: 40,
                                                color: Colors.white70),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if ((opus['description'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6.0),
                                          child: Text(
                                            opus['description'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                        // 編集ボタン（右上）
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            color: Colors.grey[700],
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              // 編集ボタン押下時の処理をここに追加
                              // 例: Navigator.pushで編集画面へ遷移など
                            },
                            tooltip: '編集',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    // 会場の基本情報カード
    Widget _buildVenueInfoCard(Map<String, dynamic> venue) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        margin: const EdgeInsets.only(top: 20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (venue['imageUrl'] != null &&
                  venue['imageUrl'].toString().isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      venue['imageUrl'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.location_on, size: 40),
                      ),
                    ),
                  ),
                ),
              if (venue['imageUrl'] != null &&
                  venue['imageUrl'].toString().isNotEmpty)
                const SizedBox(height: 16),
              Text(
                venue['name'] ?? '会場名未設定',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (venue['description'] != null &&
                  venue['description'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    venue['description'],
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              const SizedBox(height: 12),
              if (venue['email'] != null &&
                  venue['email'].toString().isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.email, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(venue['email'], style: const TextStyle(fontSize: 15)),
                  ],
                ),
              if (venue['website'] != null &&
                  venue['website'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      const Icon(Icons.link, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          venue['website'],
                          style:
                              const TextStyle(fontSize: 15, color: Colors.blue),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (venue['phoneNumber'] != null &&
                  venue['phoneNumber'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(venue['phoneNumber'],
                          style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              if (venue['address'] != null &&
                  venue['address'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          venue['address'],
                          style: const TextStyle(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // プロフィール切り替えボタン
    Widget _buildSwitchProfile() {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('プロフィール切り替え',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        selectedType.value = 'venue';
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedType.value == 'venue'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        foregroundColor: selectedType.value == 'venue'
                            ? Colors.white
                            : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Venue'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        selectedType.value = 'creator';
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedType.value == 'creator'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        foregroundColor: selectedType.value == 'creator'
                            ? Colors.white
                            : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Creator'),
                    ),
                  ),
                ],
              ),
              // 名前リストを下部に展開
              _buildNameButtons(),
            ],
          ),
        ),
      );
    }

    Widget _buildCreatorProfile() {
      return Column(
        children: [
          _buildCreatorInfoCard(selectedCreator.value!),
          _buildCreatorOpusesList(selectedCreator.value!),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'プロフィール',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 丸角のカードに切り替えボタンと展開リストを入れる
              _buildSwitchProfile(),
              // selectedCreatorがセットされている場合、基本情報カードを表示
              if (selectedType.value == 'creator' &&
                  selectedCreator.value != null)
                _buildCreatorProfile(),
              // selectedVenueがセットされている場合、基本情報カードを表示
              if (selectedType.value == 'venue' && selectedVenue.value != null)
                _buildVenueInfoCard(selectedVenue.value!),
              // もし他に追加したい内容があればここに
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchUserCreators(
      BuildContext context,
      ValueNotifier<List<dynamic>> creatorData,
      ValueNotifier<bool> isLoading) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse(
            '${dotenv.get('API_URL')}/creator/user/${prefs.getInt('userId')}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        creatorData.value = data;
      } else {
        throw Exception('ユーザー情報の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      //   showAnimatedSnackBar(
      //     context,
      //     message: 'ユーザー情報の取得に失敗しました',
      //     type: SnackBarType.error,
      //   );
    } finally {
      print('creator-finally-is-running');
      isLoading.value = false;
    }
  }

  Future<void> _fetchUserVenues(
      BuildContext context,
      ValueNotifier<List<dynamic>> venueData,
      ValueNotifier<bool> isLoading) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse(
            '${dotenv.get('API_URL')}/venue?userId=${prefs.getInt('userId')}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        venueData.value = data;
      } else {
        throw Exception('会場情報の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      //   showAnimatedSnackBar(
      //     context,
      //     message: '会場情報の取得に失敗しました',
      //     type: SnackBarType.error,
      //   );
    } finally {
      print('venue-finally-is-running');
      isLoading.value = false;
    }
  }
}
