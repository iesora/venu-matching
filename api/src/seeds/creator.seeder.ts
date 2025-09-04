import { DataSource } from 'typeorm';
import { Seeder } from 'typeorm-extension';
import { User, UserRole } from '../entities/user.entity';
import { Creator } from '../entities/creator.entity';

export default class CreatorSeeder implements Seeder {
  public async run(dataSource: DataSource): Promise<any> {
    const userRepository = dataSource.getRepository(User);
    const creatorRepository = dataSource.getRepository(Creator);
    const creatorData = [
      {
        name: '田中美咲',
        description:
          'フォトグラファーとして風景写真を専門に撮影しています。自然の美しさを切り取ることが私の情熱です。',
      },
      {
        name: 'Alex Johnson',
        description:
          'Digital artist specializing in concept art for video games. I love creating immersive fantasy worlds.',
      },
      {
        name: '山田健太',
        description:
          'イラストレーター兼デザイナー。キャラクターデザインとロゴ制作を得意としています。',
      },
      {
        name: 'Maria Rodriguez',
        description:
          'Fashion photographer with 10 years of experience. I capture the essence of style and elegance.',
      },
      {
        name: '佐藤花音',
        description:
          '音楽プロデューサーとして様々なアーティストの楽曲制作に携わっています。ジャンルを問わず幅広く活動中。',
      },
      {
        name: 'Chen Wei',
        description:
          'Web developer and UI/UX designer. I create beautiful and functional digital experiences.',
      },
      {
        name: '鈴木太郎',
        description:
          '動画編集者として企業のプロモーション映像やYouTube動画の制作を行っています。',
      },
      {
        name: 'Sophie Martin',
        description:
          'Content writer and blogger focusing on travel and lifestyle topics. Words are my passion.',
      },
      {
        name: '高橋麗奈',
        description:
          'グラフィックデザイナーとしてブランディングとパッケージデザインを手がけています。',
      },
      {
        name: 'David Kim',
        description:
          '3D animator working in the film industry. I bring characters and stories to life through animation.',
      },
    ];

    const users = [];
    const creators = [];

    for (let i = 0; i < 10; i++) {
      const user = new User();
      user.email = `creator${i + 1}@example.com`;
      user.password = 'password';
      user.role = UserRole.MEMBER;

      users.push(user);
    }

    const savedUsers: User[] = await userRepository.save(users);

    for (let i = 0; i < 10; i++) {
      const creator = new Creator();

      creator.name = creatorData[i].name;
      creator.description = creatorData[i].description;
      creator.user = savedUsers[i];

      creators.push(creator);
    }
    await creatorRepository.save(creators);
    console.log('Creator seeder completed successfully');
  }
}
