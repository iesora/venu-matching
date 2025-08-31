import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

class PurchaseService {
  static Future<List<Offering>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      print(offerings.all.values.toList());
      return offerings.all.values.toList();
    } catch (e) {
      print('オファリングの取得に失敗しました: $e');
      return [];
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      if (purchaseResult.entitlements.active.isNotEmpty) {
        print('購入成功: ${purchaseResult.entitlements.active}');
        return true;
      }
      print('購入失敗: エンタイトルメントがアクティブではありません');
      return false;
    } catch (e) {
      if (e is PlatformException) {
        print('購入処理に失敗しました: ${e.message}');
        print('エラーコード: ${e.code}');
        print('詳細: ${e.details}');

        // ユーザーによるキャンセルの場合
        if (e.details?['userCancelled'] == true) {
          print('ユーザーが購入をキャンセルしました');
        }
      } else {
        print('予期せぬエラーが発生しました: $e');
      }
      return false;
    }
  }

  static Future<bool> checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      print('サブスクリプション状態の確認に失敗しました: $e');
      return false;
    }
  }

  static Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      print('購入の復元に失敗しました: $e');
    }
  }
}
