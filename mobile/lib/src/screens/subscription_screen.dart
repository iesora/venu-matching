import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:mobile/src/services/purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/src/widgets/custom_snackbar.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  SubscriptionScreenState createState() => SubscriptionScreenState();
}

class SubscriptionScreenState extends State<SubscriptionScreen> {
  String? profileImageUrl; // サンプル画像を設定
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDetail();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        final products = offerings.current!.availablePackages;
        setState(() {
          _products = products.map((package) {
            final product = package.storeProduct;
            return {
              'id': product.identifier,
              'title': product.title,
              'description': product.description,
              'price': product.priceString,
              'package': package,
            };
          }).toList();
        });
      }
    } catch (e) {
      print('商品情報の取得に失敗しました: $e');
      setState(() {
        _errorMessage = '商品情報の取得に失敗しました';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makePurchase(Package package) async {
    // 購入処理開始前にロード中状態にする
    setState(() {
      _isLoading = true;
    });
    try {
      final purchaseResult = await PurchaseService.purchasePackage(package);
      if (purchaseResult) {
        // ポイント追加処理もawaitを付け、完了を待つ
        await _addUserPoint(1000);
        showAnimatedSnackBar(
          context,
          message: '購入が完了しました',
          type: SnackBarType.success,
        );
        // 必要に応じて画面の更新処理などを追加
      } else {
        showAnimatedSnackBar(
          context,
          message: '購入に失敗しました',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      showAnimatedSnackBar(
        context,
        message: 'エラーが発生しました',
        type: SnackBarType.error,
      );
    } finally {
      // 購入処理完了後にロード状態を解除
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/user'), // TODO: ユーザーIDを動的に設定
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);
          if (_userData != null) {
            profileImageUrl = _userData!['avatar'];
          }
        });
      } else {
        throw Exception('ユーザー情報の取得に失敗しました');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      if (mounted) {
        showAnimatedSnackBar(
          context,
          message: 'ユーザー情報の取得に失敗しました',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _addUserPoint(int point) async {
    // ポイント追加開始前にロード中状態にする
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/user/change-point'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "id": _userData!["id"],
          'point': point,
        }),
      );

      if (response.statusCode == 200) {
        showAnimatedSnackBar(
          context,
          message: '$pointポイントを追加しました',
          type: SnackBarType.success,
        );
        print('ポイントの追加に成功しました');
        // ユーザー情報を再取得して画面の更新
        _fetchUserDetail();
      } else {
        showAnimatedSnackBar(
          context,
          message: 'ポイントの追加に失敗しました',
          type: SnackBarType.error,
        );
        print('ポイントの追加に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('ポイントの追加に失敗しました: $e');
      if (mounted) {
        showAnimatedSnackBar(
          context,
          message: 'ポイントの追加に失敗しました',
          type: SnackBarType.error,
        );
      }
    } finally {
      // ポイント追加処理完了後にロード状態を解除
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ポイント購入'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // カスタムの戻るアイコン
          onPressed: () {
            Navigator.pop(context, true); // 戻る際にtrueを返す
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _products.isEmpty
                  ? const Center(child: Text('現在利用可能な商品はありません'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  product['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(product['description']),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product['price'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('ポイント購入'),
                                              content: const Text(
                                                  '「1000ポイント」を購入しますか？'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // ダイアログを閉じる
                                                  },
                                                  child: const Text('キャンセル'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // ダイアログを閉じる
                                                    _makePurchase(
                                                        product['package']);
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                      },
                                      child: const Text('購入'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
