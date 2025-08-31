import 'package:flutter/material.dart';
import 'package:mobile/src/widgets/web_view_page.dart';

class TermsOfServiceRow extends StatelessWidget {
  // Params
  final Color color;
  final String privacyPolicyUrl =
      "https://dating-demo-web-584693937256.asia-northeast1.run.app/privacy-policy";

  final String termsOfServiceUrl =
      "https://dating-demo-web-584693937256.asia-northeast1.run.app/terms-of-service";

  TermsOfServiceRow({super.key, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          child: Text(
            "利用規約",
            style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          onTap: () {
            if (Navigator.of(context, rootNavigator: true).mounted) {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => WebViewPage(
                    title: '利用規約',
                    url: termsOfServiceUrl,
                  ),
                ),
              );
            }
          },
        ),
        Text(
          ' | ',
          style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          child: Text(
            "プライバシーポリシー",
            style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          onTap: () {
            if (Navigator.of(context, rootNavigator: true).mounted) {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => WebViewPage(
                    title: 'プライバシーポリシー',
                    url: privacyPolicyUrl,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
