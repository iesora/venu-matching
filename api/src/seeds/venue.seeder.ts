import { DataSource } from "typeorm";
import { Seeder } from "typeorm-extension";
import { User, UserRole } from "../entities/user.entity";
import { Venue } from "../entities/venue.entity";

export default class VenueSeeder implements Seeder {
  public async run(dataSource: DataSource): Promise<any> {
    const userRepository = dataSource.getRepository(User);
    const venueRepository = dataSource.getRepository(Venue);
    const venueData = [
      {
        name: "東京国際フォーラム",
        address: "東京都千代田区丸の内3-5-1",
        tel: "03-5221-9000",
        description:
          "国際会議から展示会、コンサートまで幅広く対応可能な大型複合施設。",
        capacity: 5000,
        facilities: "音響設備, 照明, プロジェクター, 会議室, Wi-Fi, 駐車場",
        availableTime: "09:00-21:00",
        imageUrl:
          "https://lh3.googleusercontent.com/gps-cs-s/AC9h4nrsyTCKZEan5oDviaQCbxpCR8GQn3UYHzxU12itXdFMNJtF8J8gDPw3mPPZajcLxVLPmCtwdXeocNG9B4NIMDZPdZ9_940fVgZ2gu_itjHlkQ04DgIcGjpv8xyoOndcStJibCnW=s1360-w1360-h1020-rw",
        latitude: 35.681236,
        longitude: 139.767125,
      },
      {
        name: "日本武道館",
        address: "東京都千代田区北の丸公園2-3",
        tel: "03-3216-5100",
        description: "武道大会や大規模コンサートで知られる多目的アリーナ。",
        capacity: 14000,
        facilities: "音響設備, 照明, 控室, ロッカー, Wi-Fi",
        availableTime: "09:00-22:00",
        imageUrl:
          "https://lh3.googleusercontent.com/gps-cs-s/AC9h4nrsyTCKZEan5oDviaQCbxpCR8GQn3UYHzxU12itXdFMNJtF8J8gDPw3mPPZajcLxVLPmCtwdXeocNG9B4NIMDZPdZ9_940fVgZ2gu_itjHlkQ04DgIcGjpv8xyoOndcStJibCnW=s1360-w1360-h1020-rw",
        latitude: 35.681236,
        longitude: 139.767125,
      },
      {
        name: "横浜アリーナ",
        address: "神奈川県横浜市西区みなとみらい3-1-1",
        tel: "045-682-2000",
        description: "国内有数の規模を誇る大規模イベント会場。",
        capacity: 17000,
        facilities: "音響設備, 照明, ステージ, 電源, Wi-Fi",
        availableTime: "10:00-22:00",
        imageUrl:
          "https://lh3.googleusercontent.com/gps-cs-s/AC9h4nrsyTCKZEan5oDviaQCbxpCR8GQn3UYHzxU12itXdFMNJtF8J8gDPw3mPPZajcLxVLPmCtwdXeocNG9B4NIMDZPdZ9_940fVgZ2gu_itjHlkQ04DgIcGjpv8xyoOndcStJibCnW=s1360-w1360-h1020-rw",
        latitude: 35.681236,
        longitude: 139.767125,
      },
      {
        name: "大阪城ホール",
        address: "大阪府大阪市中央区大阪城3-1-1",
        tel: "06-6941-0351",
        description: "コンサートやスポーツイベントに最適な多目的ホール。",
        capacity: 16000,
        facilities: "音響設備, 照明, 控室, ステージ, Wi-Fi",
        availableTime: "09:00-22:00",
        imageUrl:
          "https://lh3.googleusercontent.com/gps-cs-s/AC9h4nrsyTCKZEan5oDviaQCbxpCR8GQn3UYHzxU12itXdFMNJtF8J8gDPw3mPPZajcLxVLPmCtwdXeocNG9B4NIMDZPdZ9_940fVgZ2gu_itjHlkQ04DgIcGjpv8xyoOndcStJibCnW=s1360-w1360-h1020-rw",
        latitude: 35.681236,
        longitude: 139.767125,
      },
      {
        name: "名古屋ドーム",
        address: "愛知県名古屋市東区大幸南1-1-1",
        tel: "052-719-2121",
        description:
          "野球場として有名な大規模ドーム、展示会やコンサートにも対応。",
        capacity: 40000,
        facilities: "音響設備, 照明, 大型ビジョン, 電源, Wi-Fi, 駐車場",
        availableTime: "08:00-22:00",
        imageUrl:
          "https://lh3.googleusercontent.com/gps-cs-s/AC9h4nrsyTCKZEan5oDviaQCbxpCR8GQn3UYHzxU12itXdFMNJtF8J8gDPw3mPPZajcLxVLPmCtwdXeocNG9B4NIMDZPdZ9_940fVgZ2gu_itjHlkQ04DgIcGjpv8xyoOndcStJibCnW=s1360-w1360-h1020-rw",
        latitude: 35.681236,
        longitude: 139.767125,
      },
      {
        name: "福岡PayPayドーム",
        address: "福岡県福岡市中央区地行浜2-2-2",
        tel: "092-847-1006",
        description: "九州最大級の多目的ドーム施設。",
        capacity: 38500,
        facilities: "音響設備, 照明, 大型スクリーン, 電源, Wi-Fi, 駐車場",
        availableTime: "08:00-22:00",
        imageUrl: "https://example.com/images/venues/fukuoka_paypay_dome.jpg",
        latitude: 35.681236,
        longitude: 139.767125,
      },
      {
        name: "札幌ドーム",
        address: "北海道札幌市豊平区羊ヶ丘1",
        tel: "011-850-1000",
        description:
          "スポーツ・コンサート・展示会など多彩なイベントに対応可能。",
        capacity: 42000,
        facilities: "音響設備, 照明, 電源, 控室, Wi-Fi, 駐車場",
        availableTime: "09:00-22:00",
        imageUrl:
          "https://lh3.googleusercontent.com/gps-cs-s/AC9h4nrsyTCKZEan5oDviaQCbxpCR8GQn3UYHzxU12itXdFMNJtF8J8gDPw3mPPZajcLxVLPmCtwdXeocNG9B4NIMDZPdZ9_940fVgZ2gu_itjHlkQ04DgIcGjpv8xyoOndcStJibCnW=s1360-w1360-h1020-rwpg",
        latitude: 35.681236,
        longitude: 139.767125,
      },
      {
        name: "仙台アリーナ",
        address: "宮城県仙台市宮城野区宮城野2-11-6",
        tel: "022-297-5858",
        description: "東北地方の主要イベントを支えるアリーナ施設。",
        capacity: 7000,
        facilities: "音響設備, 照明, 電源, Wi-Fi",
        availableTime: "10:00-21:00",
        imageUrl:
          "https://lh3.googleusercontent.com/gps-cs-s/AC9h4nrsyTCKZEan5oDviaQCbxpCR8GQn3UYHzxU12itXdFMNJtF8J8gDPw3mPPZajcLxVLPmCtwdXeocNG9B4NIMDZPdZ9_940fVgZ2gu_itjHlkQ04DgIcGjpv8xyoOndcStJibCnW=s1360-w1360-h1020-rw",
        latitude: 35.681236,
        longitude: 139.767125,
      },
      {
        name: "広島グリーンアリーナ",
        address: "広島県広島市南区比治山公園1-1",
        tel: "082-568-7000",
        description: "コンサートやスポーツ大会に利用される多目的アリーナ。",
        capacity: 10000,
        facilities: "音響設備, 照明, ステージ, 電源, Wi-Fi",
        availableTime: "09:00-21:00",
        imageUrl:
          "https://lh3.googleusercontent.com/gps-cs-s/AC9h4nrsyTCKZEan5oDviaQCbxpCR8GQn3UYHzxU12itXdFMNJtF8J8gDPw3mPPZajcLxVLPmCtwdXeocNG9B4NIMDZPdZ9_940fVgZ2gu_itjHlkQ04DgIcGjpv8xyoOndcStJibCnW=s1360-w1360-h1020-rw",
        latitude: 35.681236,
        longitude: 139.767125,
      },
      {
        name: "神戸ワールド記念ホール",
        address: "兵庫県神戸市中央区港島中町6-9-1",
        tel: "078-302-5200",
        description:
          "神戸ポートアイランドに位置するコンサートや展示会向けホール。",
        capacity: 8000,
        facilities: "音響設備, 照明, 電源, Wi-Fi, 駐車場",
        availableTime: "09:00-21:00",
        imageUrl:
          "https://lh3.googleusercontent.com/gps-cs-s/AC9h4nrsyTCKZEan5oDviaQCbxpCR8GQn3UYHzxU12itXdFMNJtF8J8gDPw3mPPZajcLxVLPmCtwdXeocNG9B4NIMDZPdZ9_940fVgZ2gu_itjHlkQ04DgIcGjpv8xyoOndcStJibCnW=s1360-w1360-h1020-rw",
        latitude: 35.681236,
        longitude: 139.767125,
      },
    ];

    const users: User[] = [];
    const venues: Venue[] = [];

    //ユーザーデータ作成
    for (let i = 0; i < 10; i++) {
      const user = new User();
      user.email = `admin${i + 1}@example.com`;
      user.password = User.encryptPassword("password");
      user.role = UserRole.ADMIN;

      users.push(user);
    }

    //先にユーザーを保存
    const savedUsers: User[] = await userRepository.save(users);

    //保存したユーザーのデータを紐付けvenueデータ作成
    for (let i = 0; i < 10; i++) {
      const venue = new Venue();

      venue.name = venueData[i].name;
      venue.address = venueData[i].address;
      venue.latitude = venueData[i].latitude;
      venue.longitude = venueData[i].longitude;
      venue.tel = venueData[i].tel;
      venue.description = venueData[i].description;
      venue.capacity = venueData[i].capacity;
      venue.facilities = venueData[i].facilities;
      venue.availableTime = venueData[i].availableTime;
      venue.imageUrl = venueData[i].imageUrl;
      venue.user = savedUsers[i];

      venues.push(venue);
    }
    //venue保存
    await venueRepository.save(venues);
    console.log("Venue seeder completed successfully");
  }
}
