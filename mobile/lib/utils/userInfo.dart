enum Prefecture {
  HOKKAIDO('北海道'),
  AOMORI('青森県'),
  IWATE('岩手県'),
  MIYAGI('宮城県'),
  AKITA('秋田県'),
  YAMAGATA('山形県'),
  FUKUSHIMA('福島県'),
  IBARAKI('茨城県'),
  TOCHIGI('栃木県'),
  GUNMA('群馬県'),
  SAITAMA('埼玉県'),
  CHIBA('千葉県'),
  TOKYO('東京都'),
  KANAGAWA('神奈川県'),
  NIIGATA('新潟県'),
  TOYAMA('富山県'),
  ISHIKAWA('石川県'),
  FUKUI('福井県'),
  YAMANASHI('山梨県'),
  NAGANO('長野県'),
  GIFU('岐阜県'),
  SHIZUOKA('静岡県'),
  AICHI('愛知県'),
  MIE('三重県'),
  SHIGA('滋賀県'),
  KYOTO('京都府'),
  OSAKA('大阪府'),
  HYOGO('兵庫県'),
  NARA('奈良県'),
  WAKAYAMA('和歌山県'),
  TOTTORI('鳥取県'),
  SHIMANE('島根県'),
  OKAYAMA('岡山県'),
  HIROSHIMA('広島県'),
  YAMAGUCHI('山口県'),
  TOKUSHIMA('徳島県'),
  KAGAWA('香川県'),
  EHIME('愛媛県'),
  KOCHI('高知県'),
  FUKUOKA('福岡県'),
  SAGA('佐賀県'),
  NAGASAKI('長崎県'),
  KUMAMOTO('熊本県'),
  OITA('大分県'),
  MIYAZAKI('宮崎県'),
  KAGOSHIMA('鹿児島県'),
  OKINAWA('沖縄県');

  final String value;
  const Prefecture(this.value);

  String get japanName => value;
}

enum BodyType {
  SLIM('スリム'),
  SLIGHTLY_SLIM('やや細め'),
  NORMAL('普通'),
  GLAMOROUS('グラマー'),
  MUSCULAR('筋肉質'),
  SLIGHTLY_CHUBBY('ややぽっちゃり'),
  CHUBBY('ぽっちゃり');

  final String value;
  const BodyType(this.value);

  String get japanName => value;
}

enum Income {
  UNDER_100('0-100万円'),
  UNDER_200('100-200万円'),
  UNDER_300('200-300万円'),
  UNDER_400('300-400万円'),
  UNDER_500('400-500万円'),
  UNDER_600('500-600万円'),
  UNDER_700('600-700万円'),
  UNDER_800('700-800万円'),
  UNDER_900('800-900万円'),
  UNDER_1000('900-1000万円'),
  OVER_1000('1000万円以上');

  final String value;
  const Income(this.value);

  String get japanName => value;
}

enum Occupation {
  COMPANY_EMPLOYEE('会社員'),
  CIVIL_SERVANT('公務員'),
  SELF_EMPLOYED('自営業'),
  MEDICAL('医療関係者'),
  EDUCATION('教育関係者'),
  IT_ENGINEER('ITエンジニア'),
  SALES('営業職'),
  SERVICE('サービス業'),
  STUDENT('学生'),
  HOUSEWIFE('専業主婦/主夫'),
  PART_TIME('パート・アルバイト'),
  FREELANCE('フリーランス'),
  AGRICULTURE('農林水産業'),
  CONSTRUCTION('建設・土木'),
  MANUFACTURING('製造業'),
  TRANSPORTATION('運輸・物流'),
  REAL_ESTATE('不動産業'),
  FINANCE('金融・保険業'),
  OTHER('その他');

  final String value;
  const Occupation(this.value);

  String get japanName => value;
}

enum ActivityType {
  INDOOR('インドア'),
  OUTDOOR('アウトドア');

  final String value;
  const ActivityType(this.value);

  String get japanName => value;
}

enum HeightType {
  UNDER_145('145cm未満'),
  UNDER_150('145cm 〜 149cm'),
  UNDER_155('150cm 〜 154cm'),
  UNDER_160('155cm 〜 159cm'),
  UNDER_165('160cm 〜 164cm'),
  UNDER_170('165cm 〜 169cm'),
  UNDER_175('170cm 〜 174cm'),
  UNDER_180('175cm 〜 179cm'),
  UNDER_185('180cm 〜 184cm'),
  OVER_185('185cm以上');

  final String value;
  const HeightType(this.value);

  String get japanName => value;
}

enum Sex {
  MALE('male', '男性'),
  FEMALE('female', '女性');
  /*
  LESBIAN('lesbian', 'レズビアン'),
  GAY('gay', 'ゲイ'),
  BISEXUAL('bisexual', 'バイセクシャル'),
  TRANSGENDER('transgender', 'トランスジェンダー'),
  QUESTIONING('questioning', 'クエスチョニング');
  */

  final String value;
  final String japanName;
  const Sex(this.value, this.japanName);
}

enum NotificationType {
  NEWS('news'),
  LIKE('like'),
  CHAT('chat'),
  COMMENT('comment');

  final String value;
  const NotificationType(this.value);

  String get japanName => value;
}

enum PlanType {
  BASIC('ベーシック'),
  PREMIUM('プレミアム');

  final String value;
  const PlanType(this.value);

  String get japanName => value;
}

enum PurposeCategory {
  DRINKING('飲み会'),
  DATING('出会い'),
  BUSINESS('ビジネス');

  final String value;
  const PurposeCategory(this.value);

  String get japanName => value;
}

enum FoodCategory {
  JAPANESE('和食'),
  YAKINIKU('焼肉'),
  WESTERN('洋食'),
  CHINESE('中華'),
  KOREAN('韓国料理'),
  SOUTHEAST_ASIAN('東南アジア料理'),
  FAST_FOOD('ファストフード');

  final String value;
  const FoodCategory(this.value);

  String get japanName => value;
}

enum MaritalStatus {
  SINGLE('single', '独身'),
  MARRIED('married', '既婚'),
  DIVORCED('divorced', '離婚経験あり'),
  OTHER('other', 'その他');

  final String value;
  final String displayName;

  const MaritalStatus(this.value, this.displayName);

  String get japanName => displayName;
}

enum ConvenientTime {
  WEEKEND_DAYTIME('週末の昼間'),
  WEEKEND_NIGHT('週末の夜'),
  WEEKDAY_DAYTIME('平日の昼間'),
  WEEKDAY_NIGHT('平日の夜'),
  ANYTIME('いつでも時間がある'),
  IRREGULAR('不定期'),
  OTHER('その他');

  final String value;
  const ConvenientTime(this.value);

  String get japanName => value;
}
