import { DataSource } from 'typeorm';
import { Seeder } from 'typeorm-extension';
import { User, UserRole } from '../entities/user.entity';
import { Venu } from '../entities/venu.entity';

export default class VenuSeeder implements Seeder {
  public async run(dataSource: DataSource): Promise<any> {
    const userRepository = dataSource.getRepository(User);
    const venuRepository = dataSource.getRepository(Venu);
    const venuData = [
      {
        name: '東京国際フォーラム',
        address: '東京都千代田区丸の内3-5-1',
        tel: '03-5221-9000',
      },
      {
        name: '日本武道館',
        address: '東京都千代田区北の丸公園2-3',
        tel: '03-3216-5100',
      },
      {
        name: '横浜アリーナ',
        address: '神奈川県横浜市西区みなとみらい3-1-1',
        tel: '045-682-2000',
      },
      {
        name: '大阪城ホール',
        address: '大阪府大阪市中央区大阪城3-1-1',
        tel: '06-6941-0351',
      },
      {
        name: '名古屋ドーム',
        address: '愛知県名古屋市東区大幸南1-1-1',
        tel: '052-719-2121',
      },
      {
        name: '福岡PayPayドーム',
        address: '福岡県福岡市中央区地行浜2-2-2',
        tel: '092-847-1006',
      },
      {
        name: '札幌ドーム',
        address: '北海道札幌市豊平区羊ヶ丘1',
        tel: '011-850-1000',
      },
      {
        name: '仙台アリーナ',
        address: '宮城県仙台市宮城野区宮城野2-11-6',
        tel: '022-297-5858',
      },
      {
        name: '広島グリーンアリーナ',
        address: '広島県広島市南区比治山公園1-1',
        tel: '082-568-7000',
      },
      {
        name: '神戸ワールド記念ホール',
        address: '兵庫県神戸市中央区港島中町6-9-1',
        tel: '078-302-5200',
      },
    ];

    const users = [];
    const venues = [];

    //ユーザーデータ作成
    for (let i = 0; i < 10; i++) {
      const user = new User();
      user.email = `admin${i + 1}@example.com`;
      user.password = 'password';
      user.role = UserRole.ADMIN;

      users.push(user);
    }

    //先にユーザーを保存
    const savedUsers: User[] = await userRepository.save(users);

    //保存したユーザーのデータを紐付けvenuデータ作成
    for (let i = 0; i < 10; i++) {
      const venu = new Venu();

      venu.name = venuData[i].name;
      venu.address = venuData[i].address;
      venu.tel = venuData[i].tel;
      venu.user = savedUsers[i];

      venues.push(venu);
    }
    //venu保存
    await venuRepository.save(venues);
    console.log('Venu seeder completed successfully');
  }
}
