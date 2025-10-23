import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/screens/editOpus.dart';
import 'package:mobile/src/screens/auth/sign_in_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile/src/loginState.dart';
import 'package:mobile/src/widgets/custom_dialog.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';
import 'package:mobile/src/screens/venu/venue_detail_screen.dart';
import 'package:mobile/src/screens/creator/creator_detail_screen.dart';

class ProfileScreen extends HookWidget {
  final Function(bool)? onToggleTabLayout;
  final bool? isUsingSearchMatchingTabs;
  const ProfileScreen(
      {Key? key, this.onToggleTabLayout, this.isUsingSearchMatchingTabs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final creatorData = useState<List<dynamic>>([]);
    final venueData = useState<List<dynamic>>([]);
    final fromMeMatchingData = useState<List<dynamic>>([]);
    final toMeMatchingData = useState<List<dynamic>>([]);
    final completedMatchingData = useState<List<dynamic>>([]);
    final isLoadingCreator = useState<bool>(true);
    final isLoadingVenue = useState<bool>(true);
    final isLoadingOffer = useState<bool>(true);
    final selectedType = useState<String>('venue');
    final selectedCreator = useState<Map<String, dynamic>?>(null);
    final selectedVenue = useState<Map<String, dynamic>?>(null);
    final loginType = useState<String?>(null);
    final loginRelationId = useState<int?>(null);

    // 追加: オファータブの選択状態
    final offerTabIndex = useState<int>(0); // 0: 受信, 1: 送信, 2: マッチング

    // アカウント設定用の展開状態
    final accountExpanded = useState<bool>(false);

    Future<void> _fetchLoginMode() async {
      final prefs = await SharedPreferences.getInstance();
      loginType.value = prefs.getString('relationType');
      if (loginType.value != 'supporter') {
        loginRelationId.value = prefs.getInt('relationId');
      } else {
        loginRelationId.value = null;
      }
    }

    useEffect(() {
      _fetchUserCreators(context, creatorData, isLoadingCreator);
      _fetchUserVenues(context, venueData, isLoadingVenue);
      _fetchLoginMode();
      return null;
    }, []);

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
      if (items.isEmpty && selectedType.value != 'supporter') {
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
      return Column(
        children: [
          const SizedBox(height: 12),
          const Divider(
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                runAlignment: WrapAlignment.start,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isActive = (selectedType.value == 'venue' &&
                          selectedVenue.value?['id'] == item['id']) ||
                      (selectedType.value == 'creator' &&
                          selectedCreator.value?['id'] == item['id']);
                  return ElevatedButton(
                      onPressed: () {
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
                            isActive ? const Color(0xFF223a70) : Colors.white,
                        foregroundColor:
                            isActive ? Colors.white : const Color(0xFF223a70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: const Color(0xFF223a70),
                          ),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: Text(item['name'] ?? ''));
                }),
              ),
            ),
          )
        ],
      );
    }

    // クリエイターの基本情報カード
    Widget _buildCreatorInfoCard(Map<String, dynamic> creator) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        margin: const EdgeInsets.fromLTRB(6, 16, 6, 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (creator['imageUrl'] != null &&
                  creator['imageUrl'].toString().isNotEmpty)
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: Image.network(
                            creator['imageUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.person, size: 50),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          creator['name'] ?? '名前未設定',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (creator['description'] != null &&
                            creator['description'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 400,
                              ),
                              child: Text(
                                creator['description'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                        if (creator['website'] != null &&
                            creator['website'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Row(
                              children: [
                                const Icon(Icons.link,
                                    size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    creator['website'],
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.blue),
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
                                const Icon(Icons.phone,
                                    size: 18, color: Colors.grey),
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
                      ]),
                ),
              )
            ],
          ),
        ),
      );
    }

    Future<void> deleteOpus(int opusId) async {
      // 確認ダイアログを表示
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('作品を削除'),
            content: const Text('本当にこの作品を削除しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('削除'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');

        isLoadingCreator.value = true;
        final response = await http.delete(
          Uri.parse(
              '${dotenv.get('API_URL')}/creator/${selectedCreator.value!['id']}/opus/${opusId}'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          await _fetchUserCreators(context, creatorData, isLoadingCreator);
          selectedCreator.value = creatorData.value.firstWhere(
              (creator) => creator['id'] == selectedCreator.value!['id']);
          // Navigator.pop(context);

          showAnimatedSnackBar(
            context,
            message: '作品を削除しました',
            type: SnackBarType.deleteSuccess,
          );
        } else {
          showAnimatedSnackBar(
            context,
            message: '作品の削除に失敗しました',
            type: SnackBarType.error,
          );
          throw Exception('作品の削除に失敗しました');
        }
      } catch (e) {
        print('エラー: $e');
        showAnimatedSnackBar(
          context,
          message: '作品の削除に失敗しました',
          type: SnackBarType.error,
        );
      } finally {
        isLoadingCreator.value = false;
      }
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
        margin: const EdgeInsets.fromLTRB(6, 16, 6, 8),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                child: const Text(
                  '作品ギャラリー',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: opuses.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 3 / 5, // 縦長
                ),
                itemBuilder: (context, index) {
                  final opus = opuses[index];
                  final String title = opus['name'] ?? 'タイトル未設定';
                  final String? imageUrl =
                      (opus['imageUrl'] ?? '').toString().isNotEmpty
                          ? opus['imageUrl'] as String
                          : null;

                  // 共通で使う編集処理
                  void _openEditBottomSheet() {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: EditOpusBottomSheet(
                            opus: opus,
                            creatorId: selectedCreator.value!['id'],
                            onSuccess: () async {
                              // 作品更新後にデータを再取得
                              await _fetchUserCreators(
                                  context, creatorData, isLoadingCreator);
                              selectedCreator.value = creatorData.value
                                  .firstWhere((creator) =>
                                      creator['id'] ==
                                      selectedCreator.value!['id']);
                            },
                          ),
                        );
                      },
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext alertContext) {
                          return AlertDialog(
                            insetPadding: EdgeInsets.symmetric(horizontal: 65),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                // color: Colors.grey[300]!,
                                width: 0.5,
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            title: Text(
                              title,
                              textAlign: TextAlign.center,
                            ),
                            titlePadding:
                                const EdgeInsets.fromLTRB(30, 30, 30, 0),
                            // titleTextStyle:
                            //     const TextStyle(textAlign: TextAlign.center),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    opus['description'] != null &&
                                            (opus['description'] as String)
                                                .isNotEmpty
                                        ? opus['description']
                                        : '説明がありません',
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Divider(
                                        height: 0,
                                        thickness: 1,
                                        color:
                                            Color.fromARGB(255, 219, 212, 212),
                                      ),
                                      SizedBox(
                                        height: 48,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pop(alertContext);
                                            _openEditBottomSheet();
                                          },
                                          child: const Text(
                                            '編集',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        height: 0,
                                        thickness: 1,
                                        color:
                                            Color.fromARGB(255, 219, 212, 212),
                                      ),
                                      SizedBox(
                                        height: 48,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pop(alertContext);
                                            deleteOpus(opus['id']);
                                          },
                                          style: TextButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                            foregroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                          ),
                                          child: const Text(
                                            '削除',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.red),
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        height: 0,
                                        thickness: 1,
                                        color:
                                            Color.fromARGB(255, 219, 212, 212),
                                      ),
                                      SizedBox(
                                        height: 48,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pop(alertContext);
                                          },
                                          child: const Text(
                                            'キャンセル',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Card(
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
                          // 編集ボタン（右上） ※既存の編集ボタンは残す
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(
                                  Icons.drive_file_rename_outline_rounded,
                                  size: 20),
                              color: Colors.white,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                              padding: EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              onPressed: _openEditBottomSheet,
                              tooltip: '編集',
                            ),
                          ),
                        ],
                      ),
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
      return SizedBox(
        width: double.infinity,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          margin: const EdgeInsets.fromLTRB(6, 16, 6, 8),
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
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (venue['description'] != null &&
                    venue['description'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      venue['description'],
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                const SizedBox(height: 12),
                if (venue['email'] != null &&
                    venue['email'].toString().isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.email, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(venue['email'],
                          style: const TextStyle(fontSize: 15)),
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
                            style: const TextStyle(
                                fontSize: 15, color: Colors.blue),
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
        margin: const EdgeInsets.fromLTRB(6, 16, 6, 8),
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
                        selectedCreator.value = null;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedType.value == 'venue'
                            ? Theme.of(context).colorScheme.primary
                            //赤色使うならこんな色？
                            // ? const Color(0xFF881337)
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
                      child: const Text('会場'),
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
                      child: const Text('クリエイター'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        selectedType.value = 'supporter';
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedType.value == 'supporter'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        foregroundColor: selectedType.value == 'supporter'
                            ? Colors.white
                            : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('サポーター'),
                    ),
                  ),
                ],
              ),
              if (selectedType.value != 'supporter') _buildNameButtons(),
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

    // --- ここからオファータブUI ---
    Future<void> _fetchOfferData(
        BuildContext context,
        ValueNotifier<List<dynamic>> fromMeMatchingData,
        ValueNotifier<List<dynamic>> toMeMatchingData,
        ValueNotifier<List<dynamic>> completedMatchingData,
        ValueNotifier<bool> isLoadingOffer) async {
      print('fetchOfferData-is-running');
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');
        String? relationType;
        int? relationId;
        if (selectedType.value == 'creator' && selectedCreator.value != null) {
          relationType = 'creator';
          relationId = selectedCreator.value!['id'];
        } else if (selectedType.value == 'venue' &&
            selectedVenue.value != null) {
          relationType = 'venue';
          relationId = selectedVenue.value!['id'];
        }
        if (relationType == null || relationId == null) {
          throw Exception('クリエイターまたは会場が取得できませんでした');
        }

        final uri = Uri.parse(
                '${dotenv.get('API_URL')}/matching/request/$relationType/$relationId')
            .replace(queryParameters: {
          'relationType': relationType,
          'relationId': relationId.toString(),
        });

        final response = await http.get(
          uri,
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('オファーデータ: $data');
          fromMeMatchingData.value = data
              .where((matching) =>
                  matching['requestorType'] != relationType &&
                  matching['status'] != 'matching')
              .toList();
          toMeMatchingData.value = data
              .where((matching) =>
                  matching['requestorType'] == relationType &&
                  matching['status'] != 'matching')
              .toList();
          completedMatchingData.value = data
              .where((matching) => matching['status'] == 'matching')
              .toList();
        } else {
          throw Exception('オファーデータの取得に失敗しました');
        }
      } catch (e) {
        print('エラーが発生しました: $e');
      } finally {
        isLoadingOffer.value = false;
      }
    }

    // 承認（Accept Matching Request）API通信
    Future<void> _acceptMatchingRequest(int matchingId) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');
        final response = await http.patch(
          Uri.parse('${dotenv.get('API_URL')}/matching/request/$matchingId'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('オファーを承認しました。')),
          );
          // 承認後にデータ再取得
          isLoadingOffer.value = true;
          await _fetchOfferData(context, fromMeMatchingData, toMeMatchingData,
              completedMatchingData, isLoadingOffer);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('承認に失敗しました: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }

    // 拒否（Reject Matching Request）API通信
    Future<void> _rejectMatchingRequest(int matchingId) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');
        final response = await http.patch(
          Uri.parse(
              '${dotenv.get('API_URL')}/matching/request/$matchingId/reject'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('オファーを拒否しました。')),
          );
          // 拒否後にデータ再取得
          isLoadingOffer.value = true;
          await _fetchOfferData(context, fromMeMatchingData, toMeMatchingData,
              completedMatchingData, isLoadingOffer);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('拒否に失敗しました: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }

    useEffect(() {
      _fetchOfferData(context, fromMeMatchingData, toMeMatchingData,
          completedMatchingData, isLoadingOffer);
      return null;
    }, [selectedVenue.value, selectedCreator.value]);

    Widget _buildOfferTabButton(String label, int index) {
      final bool selected = offerTabIndex.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            offerTabIndex.value = index;
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

    Widget _buildOfferTabContent() {
      List<dynamic> data;
      String emptyText;
      String partnerType =
          selectedType.value == 'creator' ? 'venue' : 'creator';

      if (offerTabIndex.value == 0) {
        data = fromMeMatchingData.value;
        emptyText = '受信したオファーはありません';
      } else if (offerTabIndex.value == 1) {
        data = toMeMatchingData.value;
        emptyText = '送信したオファーはありません';
      } else {
        data = completedMatchingData.value;
        emptyText = 'マッチングしたオファーはありません';
      }

      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        margin: const EdgeInsets.only(top: 0, bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: data.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text(
                      emptyText,
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                )
              : Column(
                  children: List.generate(data.length, (index) {
                    final item = data[index];

                    // 受信タブだけ承認/拒否ボタン追加
                    if (offerTabIndex.value == 0) {
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
                            if (partnerType == 'venue') {
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
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 画像部分
                                  Container(
                                    width: 68,
                                    height: 68,
                                    margin: const EdgeInsets.only(
                                        left: 16, top: 16, bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Colors.grey[200],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: (item[partnerType]?['imageUrl'] ??
                                                '')
                                            .toString()
                                            .isNotEmpty
                                        ? Image.network(
                                            item[partnerType]['imageUrl'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
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
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 16, 16, 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // メインの情報（名前・住所）
                                          Text(
                                            item[partnerType]['name'] ??
                                                'タイトル未設定',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          // もし venue なら住所を表示
                                          if (partnerType == 'venue')
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 2.0, bottom: 2.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.location_on,
                                                      size: 15,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      item[partnerType]
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
                                  // 右端に日時 Paddingの外
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0, right: 16),
                                    child: Text(
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
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8, left: 16, right: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextButton.icon(
                                        onPressed: () async {
                                          await _rejectMatchingRequest(
                                              item['id']);
                                        },
                                        icon: Icon(Icons.close,
                                            color: Colors.blueGrey[500]!),
                                        label: Text(
                                          '拒否',
                                          style: TextStyle(
                                              color: Colors.blueGrey[500]!),
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.grey,
                                          backgroundColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side: BorderSide(
                                              color: Colors.blueGrey[100]!,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 7,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          await _acceptMatchingRequest(
                                              item['id']);
                                        },
                                        icon: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        ),
                                        label: const Text('承認',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // child: Column(
                        //   children: [
                        //     Padding(
                        //       padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        //       child: InkWell(
                        //         onTap: () {
                        //           if (partnerType == 'venue') {
                        //             Navigator.push(
                        //               context,
                        //               MaterialPageRoute(
                        //                 builder: (context) => VenueDetailScreen(
                        //                     venueId: item['venue']['id']),
                        //               ),
                        //             );
                        //           } else {
                        //             Navigator.push(
                        //               context,
                        //               MaterialPageRoute(
                        //                 builder: (context) =>
                        //                     CreatorDetailScreen(
                        //                         creatorId: item['creator']
                        //                             ['id']),
                        //               ),
                        //             );
                        //           }
                        //         },
                        //         borderRadius: BorderRadius.circular(8),
                        //         child: Row(
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           children: [
                        //             // 画像部分
                        //             Container(
                        //               width: 48,
                        //               height: 48,
                        //               decoration: BoxDecoration(
                        //                 borderRadius: BorderRadius.circular(8),
                        //                 color: Colors.grey[200],
                        //               ),
                        //               clipBehavior: Clip.antiAlias,
                        //               child: (item[partnerType]?['imageUrl'] ??
                        //                           '')
                        //                       .toString()
                        //                       .isNotEmpty
                        //                   ? Image.network(
                        //                       item[partnerType]['imageUrl'],
                        //                       fit: BoxFit.cover,
                        //                       errorBuilder: (context, error,
                        //                               stackTrace) =>
                        //                           Icon(
                        //                               Icons.image_not_supported,
                        //                               color: Colors.grey[400],
                        //                               size: 28),
                        //                     )
                        //                   : Icon(Icons.image,
                        //                       color: Colors.grey[400],
                        //                       size: 28),
                        //             ),
                        //             const SizedBox(width: 16),
                        //             // タイトル・日時部分
                        //             Expanded(
                        //               child: Column(
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.start,
                        //                 children: [
                        //                   Text(
                        //                     item[partnerType]['name'] ??
                        //                         'タイトル未設定',
                        //                     style: const TextStyle(
                        //                       fontSize: 16,
                        //                       fontWeight: FontWeight.w500,
                        //                     ),
                        //                     overflow: TextOverflow.ellipsis,
                        //                   ),
                        //                   const SizedBox(height: 4),
                        //                   Text(
                        //                     item['requestAt'] ?? '',
                        //                     style: const TextStyle(
                        //                       fontSize: 13,
                        //                       color: Colors.grey,
                        //                     ),
                        //                     overflow: TextOverflow.ellipsis,
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //     Padding(
                        //       padding: const EdgeInsets.only(
                        //           bottom: 8, left: 16, right: 16),
                        //       child: Row(
                        //         children: [
                        //           Expanded(
                        //             flex: 3,
                        //             child: TextButton.icon(
                        //               onPressed: () async {
                        //                 await _rejectMatchingRequest(
                        //                     item['id']);
                        //               },
                        //               icon: Icon(Icons.close,
                        //                   color: Colors.blueGrey[500]!),
                        //               label: Text(
                        //                 '拒否',
                        //                 style: TextStyle(
                        //                     color: Colors.blueGrey[500]!),
                        //               ),
                        //               style: TextButton.styleFrom(
                        //                 foregroundColor: Colors.grey,
                        //                 backgroundColor: Colors.transparent,
                        //                 padding: const EdgeInsets.symmetric(
                        //                     vertical: 10),
                        //                 shape: RoundedRectangleBorder(
                        //                   borderRadius:
                        //                       BorderRadius.circular(8),
                        //                   side: BorderSide(
                        //                     color: Colors.blueGrey[100]!,
                        //                     width: 1.5,
                        //                   ),
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //           const SizedBox(width: 10),
                        //           Expanded(
                        //             flex: 7,
                        //             child: ElevatedButton.icon(
                        //               onPressed: () async {
                        //                 await _acceptMatchingRequest(
                        //                     item['id']);
                        //               },
                        //               icon: const Icon(
                        //                 Icons.check,
                        //                 color: Colors.white,
                        //               ),
                        //               label: const Text('承認',
                        //                   style:
                        //                       TextStyle(color: Colors.white)),
                        //               style: ElevatedButton.styleFrom(
                        //                 backgroundColor:
                        //                     Theme.of(context).primaryColor,
                        //                 foregroundColor: Colors.white,
                        //                 padding: const EdgeInsets.symmetric(
                        //                     vertical: 10),
                        //                 shape: RoundedRectangleBorder(
                        //                   borderRadius:
                        //                       BorderRadius.circular(8),
                        //                   side: BorderSide(
                        //                     color:
                        //                         Theme.of(context).primaryColor,
                        //                     width: 1.5,
                        //                   ),
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      );
                    } else {
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
                            if (partnerType == 'venue') {
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
                                child: (item[partnerType]?['imageUrl'] ?? '')
                                        .toString()
                                        .isNotEmpty
                                    ? Image.network(
                                        item[partnerType]['imageUrl'],
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
                                        item[partnerType]['name'] ?? 'タイトル未設定',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // もし venue なら住所を表示
                                      if (partnerType == 'venue')
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
                                                  item[partnerType]
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
                              // 右端に日時 Paddingの外
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 0, right: 16),
                                child: Text(
                                  (() {
                                    final dateTimeStr = item['requestAt'];
                                    if (dateTimeStr == null ||
                                        dateTimeStr.isEmpty) {
                                      return '';
                                    }
                                    try {
                                      final dt =
                                          DateTime.parse(dateTimeStr).toLocal();
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
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }),
                ),
        ),
      );
    }

    Widget _buildOfferTabs() {
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
                    'オファー管理',
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
                        _buildOfferTabButton('受信', 0),
                        _buildOfferTabButton('送信', 1),
                        _buildOfferTabButton('マッチング', 2),
                      ],
                    ),
                  ),
                  // タブ内容
                  _buildOfferTabContent(),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // -------------- アカウント設定用のExpandableList --------------
    // ログアウト処理
    Future<void> _handleLogout() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('userToken');
      await prefs.remove('relationId');
      await prefs.remove('relationType');
      // 必要に応じて他のストレージ情報も削除
      Provider.of<LoginState>(context, listen: false).logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }

    //以下退会処理
    // Future<void> _handleDeleteAccount(BuildContext context) async {
    //   final prefs = await SharedPreferences.getInstance();
    //   final token = prefs.getString('userToken');
    //   final response = await http.delete(
    //     Uri.parse('${dotenv.get('API_URL')}/user'),
    //     headers: <String, String>{
    //       'Authorization': 'Bearer $token',
    //       'Content-Type': 'application/json',
    //     },
    //   );
    //   if (response.statusCode == 200) {
    //     showAnimatedSnackBar(
    //       context,
    //       message: '退会しました',
    //       type: SnackBarType.success,
    //     );
    //     _handleLogout();
    //   } else {
    //     showAnimatedSnackBar(
    //       context,
    //       message: '退会に失敗しました',
    //       type: SnackBarType.error,
    //     );
    //     Navigator.pop(context);
    //   }
    // }

    // Future<void> _showDeleteAccountConfirmDialog(BuildContext context) async {
    //   showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return CustomDialog(
    //         icon: const Icon(Icons.delete, size: 40, color: Colors.red),
    //         title: '退会する',
    //         message: "本当に退会しますか？",
    //         actions: [
    //           ElevatedButton(
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //               _handleDeleteAccount(context);
    //             },
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Colors.deepOrangeAccent,
    //               padding:
    //                   const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    //               shape: RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.circular(8)),
    //             ),
    //             child: const Text(
    //               "退会する",
    //               style: TextStyle(
    //                   color: Colors.white, fontWeight: FontWeight.bold),
    //             ),
    //           ),
    //           TextButton(
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //             child: const Text('キャンセル'),
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }

    // void _showDeleteAccountDialog(BuildContext context) {
    //   showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return CustomDialog(
    //         icon: const Icon(Icons.delete, size: 40, color: Colors.red),
    //         title: '退会する',
    //         message: "一度退会するとこのアカウントを復元することはできません。\n退会しますか？",
    //         actions: [
    //           ElevatedButton(
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //               _showDeleteAccountConfirmDialog(context);
    //             },
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Colors.deepOrangeAccent,
    //               padding:
    //                   const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    //               shape: RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.circular(8)),
    //             ),
    //             child: const Text(
    //               "退会する",
    //               style: TextStyle(
    //                   color: Colors.white, fontWeight: FontWeight.bold),
    //             ),
    //           ),
    //           TextButton(
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //             child: const Text('キャンセル'),
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
    //以上退会処理

    Widget _buildAccountExpandable() {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        margin: const EdgeInsets.fromLTRB(6, 8, 6, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => accountExpanded.value = !accountExpanded.value,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.grey),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'アカウント設定',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: accountExpanded.value ? 0.5 : 0.0,
                      child: const Icon(Icons.expand_more),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const Divider(height: 2, thickness: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('ログアウト',
                        style: TextStyle(color: Colors.redAccent)),
                    onTap: () async {
                      await _handleLogout();
                    },
                  ),
                  // ListTile(
                  //   leading:
                  //       const Icon(Icons.delete_forever, color: Colors.red),
                  //   title:
                  //       const Text('退会', style: TextStyle(color: Colors.red)),
                  //   onTap: () async {
                  //     // await _handleDeleteAccount(context);
                  //     _showDeleteAccountDialog(context);
                  //   },
                  // ),
                ],
              ),
              crossFadeState: accountExpanded.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      );
    }
    // --------- アカウント設定用ExpandableList ここまで ---------

    //サポーターとしてのログイン処理
    void supporterLogin() async {
      try {
        final prefs = await SharedPreferences.getInstance();

        final token = prefs.getString('userToken');
        final response = await http.patch(
          Uri.parse('${dotenv.get('API_URL')}/user/mode-switch/normal'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          await prefs.remove('relationId');
          await prefs.setString('relationType', 'supporter');
          await _fetchLoginMode();
          if (onToggleTabLayout != null) {
            print('onToggleTabLayout-is-running');
            onToggleTabLayout!(false);
          }
        } else {
          throw Exception('サポーターとしてのログイン処理に失敗しました');
        }
      } catch (e) {
        print('サポーターとしてのログイン処理に失敗しました: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('サポーターとしてのログインに失敗しました'),
          ),
        );
      }
    }

    //クリエイター / 会場の各名義としてのログイン処理
    void relationLogin(String relationType, int relationId) async {
      try {
        final prefs = await SharedPreferences.getInstance();

        final token = prefs.getString('userToken');
        final response = await http.patch(
          Uri.parse('${dotenv.get('API_URL')}/user/mode-switch/business'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          await prefs.setString('relationType', relationType);
          await prefs.setInt('relationId', relationId);
          await _fetchLoginMode();
          if (onToggleTabLayout != null) {
            onToggleTabLayout!(true);
          }
        }
      } catch (e) {
        print('ログイン処理に失敗しました: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ログインに失敗しました'),
          ),
        );
      }
    }

    // 画面下部に常に表示する「このクリエイターでログインする」ボタン
    Widget buildSubLoginButton() {
      final bool showButton = (selectedType.value == 'venue' &&
              selectedVenue.value != null) ||
          selectedType.value == 'creator' && selectedCreator.value != null ||
          selectedType.value == 'supporter';
      bool isCurrentMode = false;
      if (selectedType.value == 'venue') {
        isCurrentMode = loginType.value == 'venue' &&
            selectedVenue.value?['id'] == loginRelationId.value;
      } else if (selectedType.value == 'creator') {
        isCurrentMode = loginType.value == 'creator' &&
            selectedCreator.value?['id'] == loginRelationId.value;
      } else {
        isCurrentMode = loginType.value == 'supporter';
      }
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: AnimatedOpacity(
            opacity: showButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !showButton,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: showButton && !isCurrentMode
                      ? () {
                          if (selectedType.value == 'supporter') {
                            supporterLogin();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('サポーターとしてログインしました'),
                              ),
                            );
                          } else {
                            final typeName = selectedType.value == 'creator'
                                ? 'クリエイター'
                                : '会場';
                            final name = selectedType.value == 'creator'
                                ? selectedCreator.value!['name']
                                : selectedVenue.value!['name'];
                            relationLogin(
                                selectedType.value,
                                selectedType.value == 'creator'
                                    ? selectedCreator.value!['id']
                                    : selectedVenue.value!['id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$typeName: $name でログインしました'),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                  child: Text(
                    isCurrentMode
                        ? 'ログイン中'
                        : selectedType.value == 'supporter'
                            ? 'サポーターとしてログインする'
                            : 'この名義でログインする',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
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
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAccountExpandable(),
              _buildSwitchProfile(),
              if (selectedType.value == 'creator' &&
                  selectedCreator.value != null)
                _buildCreatorProfile(),
              if (selectedType.value == 'venue' && selectedVenue.value != null)
                _buildVenueInfoCard(selectedVenue.value!),
              if ((selectedType.value == 'venue' &&
                      selectedVenue.value != null) ||
                  (selectedType.value == 'creator' &&
                      selectedCreator.value != null))
                _buildOfferTabs(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildSubLoginButton(),
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
        throw Exception('クリエイター情報の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      throw Exception('クリエイター情報の取得に失敗しました');
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
      throw Exception('会場情報の取得に失敗しました');
    } finally {
      print('venue-finally-is-running');
      isLoading.value = false;
    }
  }
}
