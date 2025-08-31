import 'dart:convert';
import 'package:mobile/src/plugins/swipe_stack/swipe_stack.dart';
import 'package:mobile/src/widgets/custom_badge.dart';
import 'package:mobile/src/widgets/default_card_border.dart';
import 'package:mobile/src/widgets/show_like_or_dislike.dart';
import 'package:mobile/src/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:mobile/src/datas/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileCard extends StatelessWidget {
  /// Screen to be checked
  final String? page;

  /// Swiper position
  final SwiperPosition? position;

  final Map<String, dynamic> user;

  ProfileCard({
    super.key,
    this.page,
    this.position,
    required this.user,
  });

  Future<void> _createReport(List<int> userIds) async {
    if (userIds.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/report'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'toUserId': userIds[0],
        }),
      );

      if (response.statusCode == 201) {
        print('報告に成功しました');
      } else {
        print('報告に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('報告に失敗しました: $e');
    }
  }

  // Local variables

  @override
  Widget build(BuildContext context) {
    // Variables
    final bool requireVip = page == 'require_vip' && false; // サンプルデータ
    late ImageProvider userPhoto;
    // Check user vip status
    if (requireVip) {
      userPhoto = const AssetImage('assets/images/crow_badge.png');
    } else {
      userPhoto = NetworkImage(user['avatar']); // サンプルデータ
    }

    // Get User Birthday
    String? birthDateString = user['birthDate'];
    DateTime userBirthday;

    if (birthDateString != null && birthDateString.isNotEmpty) {
      userBirthday = DateTime.parse(birthDateString); // StringをDateTimeに変換
    } else {
      userBirthday = DateTime.now(); // デフォルト値として現在の日付を設定
    }

    // Get User Current Age
    DateTime now = DateTime.now();
    final int userAge = now.year -
        userBirthday.year -
        (now.month < userBirthday.month ||
                (now.month == userBirthday.month && now.day < userBirthday.day)
            ? 1
            : 0);

    // Build profile card
    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.all(9.0),
      child: Stack(
        children: [
          /// User Card
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            margin: const EdgeInsets.all(0),
            shape: defaultCardBorder(),
            child: Container(
              decoration: BoxDecoration(
                /// User profile image
                image: DecorationImage(

                    /// Show VIP icon if user is not vip member
                    image: userPhoto,
                    fit: requireVip ? BoxFit.contain : BoxFit.cover),
              ),
              child: Container(
                /// BoxDecoration to make user info visible
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [Colors.deepOrangeAccent, Colors.transparent]),
                ),

                /// User info container
                child: Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// User fullname
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${user['nickname'] ?? ""}',
                              style: TextStyle(
                                  fontSize: page == 'discover' ? 20 : 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8.0),

                      // User location
                      Row(
                        children: [
                          /*
                          // Icon
                          const SvgIcon("assets/icons/location_point_icon.svg",
                              color: Color(0xffFFFFFF), width: 24, height: 24),
                          // Locality & Country
                          */
                          Expanded(
                            child: Text(
                              "${userAge.toString()}歳  ${user['prefecture'] ?? ""}", // サンプルデータ
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      /// User education

                      // Note: Uncoment the code below if you want to show the education

                      // Row(
                      //   children: [
                      //     const SvgIcon("assets/icons/university_icon.svg",
                      //         color: Colors.white, width: 20, height: 20),
                      //     const SizedBox(width: 5),
                      //     Expanded(
                      //       child: Text(
                      //         user.userSchool,
                      //         style: const TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 16,
                      //         ),
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      // const SizedBox(height: 3),

                      // User job title
                      // Note: Uncoment the code below if you want to show the job title

                      // Row(
                      //   children: [
                      //     const SvgIcon("assets/icons/job_bag_icon.svg",
                      //         color: Colors.white, width: 17, height: 17),
                      //     const SizedBox(width: 5),
                      //     Expanded(
                      //       child: Text(
                      //         user.userJobTitle,
                      //         style: const TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 16,
                      //         ),
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      page == 'discover'
                          ? const SizedBox(height: 70)
                          : const SizedBox(width: 0, height: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Show location distance
          /*
          Positioned(
            top: 10,
            left: page == 'discover' ? 8 : 5,
            child: CustomBadge(
                icon: page == 'discover'
                    ? const SvgIcon("assets/icons/location_point_icon.svg",
                        color: Colors.white, width: 15, height: 15)
                    : null,
                text: '5km'), // サンプルデータ
          ),
          */

          /// Show Like or Dislike
          page == 'discover'
              ? ShowLikeOrDislike(position: position!)
              : const SizedBox(width: 0, height: 0),

          /// Show message icon
          page == 'matches'
              ? Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const SvgIcon("assets/icons/message_icon.svg",
                          color: Colors.white, width: 30, height: 30)),
                )
              : const SizedBox(width: 0, height: 0),

          /// Show Report/Block profile button
          page == 'discover'
              ? Positioned(
                  right: 0,
                  child: IconButton(
                      icon: const Icon(Icons.flag,
                          color: Colors.deepOrangeAccent, size: 32),
                      onPressed: () {
                        // ユーザーを報告するか確認するダイアログを表示
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('このユーザーを報告しますか？',
                                    style: TextStyle(fontSize: 16)),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // ダイアログを閉じる
                                    },
                                    child: const Text('キャンセル'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _createReport(
                                          [user['id']]); // ユーザーIDを渡して報告を作成
                                      Navigator.of(context).pop(); // ダイアログを閉じる
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            });
                      }))
              : const SizedBox(width: 0, height: 0),
        ],
      ),
    );
  }
}
