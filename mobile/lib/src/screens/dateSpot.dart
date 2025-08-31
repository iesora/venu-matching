import 'package:flutter/material.dart';
import 'package:mobile/src/widgets/web_view_page.dart';

class DateSpotScreen extends StatelessWidget {
  const DateSpotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 岡山の人気デートスポットの座標とラベルを設定
    /*
    const spots = [
      {'label': '岡山城', 'lat': 34.6664, 'lng': 133.9357},
      {'label': '後楽園', 'lat': 34.6673, 'lng': 133.9357},
      {'label': 'イオンモール岡山', 'lat': 34.6615, 'lng': 133.9199},
      {'label': '倉敷美観地区', 'lat': 34.5947, 'lng': 133.7717},
      {'label': 'アウトレットモール倉敷', 'lat': 34.6183, 'lng': 133.8557},
      {'label': '王子が岳', 'lat': 34.7697, 'lng': 134.1523},
      {'label': '玉野渋川海水浴場', 'lat': 34.4855, 'lng': 133.9493},
      {'label': 'RSKバラ園', 'lat': 34.6889, 'lng': 133.9318},
    ];
    */

    // マップURLを生成（岡山市中心部にフォーカス）
    String generateMapUrl() {
      /*
      // 中心座標を設定（岡山駅付近）
      const centerLat = 34.6617;
      const centerLng = 133.9349;

      // スポットのクエリを生成
      final query = spots
          .map((spot) => '${spot['label']}+@${spot['lat']},${spot['lng']}')
          .join('/');
      */
      // Google MapsのURL
      return 'https://www.google.com/maps/d/u/3/embed?mid=1O8BX_L7gm-i3GWNDuScB_92UfaZkoFg&ehbc=2E312F&noprof=1';
    }

    return WebViewPage(
      title: 'デートスポット',
      url: generateMapUrl(),
      automaticallyImplyLeading: false,
    );
  }
}
