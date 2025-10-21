import { DataSource } from 'typeorm';
import { Seeder } from 'typeorm-extension';
import { User, UserRole } from '../entities/user.entity';
import { Creator } from '../entities/creator.entity';
import { Opus } from '../entities/opus.entity';

export default class CreatorSeeder implements Seeder {
  public async run(dataSource: DataSource): Promise<any> {
    const userRepository = dataSource.getRepository(User);
    const creatorRepository = dataSource.getRepository(Creator);
    const opusRepository = dataSource.getRepository(Opus);

    const creatorData = [
      {
        name: '田中美咲',
        description:
          'フォトグラファーとして風景写真を専門に撮影しています。自然の美しさを切り取ることが私の情熱です。',
        imageUrl:
          'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0',
        email: 'tanaka@example.com',
        website: 'https://tanaka-photos.com',
        phoneNumber: '080-1234-5678',
        socialMediaHandle: '@tanaka_photo',
        opus: [
          {
            name: '自然の美',
            description: '美しい自然の風景を捉えた作品集。',
            imageUrl:
              'https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg',
          },
        ],
      },
      {
        name: 'Alex Johnson',
        description:
          'Digital artist specializing in concept art for video games. I love creating immersive fantasy worlds.',
        imageUrl: 'https://placekitten.com/800/600',
        email: 'alex@example.com',
        website: 'https://alexart.com',
        phoneNumber: '090-8765-4321',
        socialMediaHandle: '@alex_art',
        opus: [
          {
            name: 'ファンタジーの世界',
            description: 'ゲームのためのコンセプトアート集。',
            imageUrl: 'https://picsum.photos/800/600',
          },
        ],
      },
      {
        name: '佐藤 翔太',
        description:
          'アニメーターとして活動しています。キャラクターの躍動感を重視しています。',
        imageUrl: '',
        email: 'sato@example.com',
        website: 'https://shota-anim.com',
        phoneNumber: '070-1111-2222',
        socialMediaHandle: '@shota_anim',
        opus: [
          {
            name: 'キャラクターの動き',
            description: '様々な動作を描いたアニメーション作品。',
            imageUrl: '',
          },
        ],
      },
      {
        name: 'Maria García',
        description: 'スペイン出身のペインター。色鮮やかな抽象画を制作します。',
        imageUrl: '',
        email: 'maria@example.com',
        website: 'https://mariagarcia-art.com',
        phoneNumber: '+34-600-123-456',
        socialMediaHandle: '@mariagarcia_paint',
        opus: [
          {
            name: 'ビビッドアブストラクト',
            description: '独自のカラーパレットで描かれた抽象作品。',
            imageUrl: '',
          },
          {
            name: '夜明けのカンバス',
            description: '夜明けの空から感じるインスピレーション。',
            imageUrl: '',
          },
        ],
      },
      {
        name: '山田 一郎',
        description: '彫刻家として木材と金属を使った作品を制作。',
        imageUrl: '',
        email: 'yamada@example.com',
        website: 'https://yamada-sculpture.com',
        phoneNumber: '090-3456-7890',
        socialMediaHandle: '@yamada_sculptor',
        opus: [
          {
            name: '木と鉄の融合',
            description: '自然素材と人工素材のコントラストを表現。',
            imageUrl: '',
          },
        ],
      },
      {
        name: 'Sophie Dubois',
        description:
          'フランスのファッションデザイナー。独自のスタイルが評価されています。',
        imageUrl: '',
        email: 'sophie@example.com',
        website: 'https://sophiedesign.fr',
        phoneNumber: '+33-601-234-567',
        socialMediaHandle: '@sophie_dubois',
        opus: [
          {
            name: '春夏コレクション2024',
            description: '軽やかで洗練されたデザインの新作コレクション。',
            imageUrl: '',
          },
        ],
      },
      {
        name: '陳 偉',
        description:
          '中国出身の現代美術家。インスタレーションアートを中心に活動。',
        imageUrl: '',
        email: 'chen@example.com',
        website: 'https://chenwei-art.cn',
        phoneNumber: '+86-138-1234-5678',
        socialMediaHandle: '@chenwei_art',
        opus: [
          {
            name: '都市のざわめき',
            description: '都市の喧騒から生まれたインスタレーション作品。',
            imageUrl: '',
          },
        ],
      },
      {
        name: 'Ava Smith',
        description:
          'イギリス在住のイラストレーター。児童書のための挿絵を多く手がけています。',
        imageUrl: '',
        email: 'smith@example.com',
        website: 'https://avasmith-illustration.uk',
        phoneNumber: '+44-7911-123456',
        socialMediaHandle: '@ava_smith_illus',
        opus: [
          {
            name: '森のともだち',
            description: '動物たちを描いた心温まる挿絵集。',
            imageUrl: '',
          },
        ],
      },
      {
        name: '佐々木 結衣',
        description:
          '日本のグラフィックデザイナー。広告やパッケージデザインが得意です。',
        imageUrl: '',
        email: 'sasaki@example.com',
        website: 'https://sasakiyui-design.jp',
        phoneNumber: '080-2222-3333',
        socialMediaHandle: '@sasaki_yui',
        opus: [
          {
            name: 'ブランドイメージ刷新',
            description:
              '大手企業のブランドアイデンティティ再構築プロジェクト。',
            imageUrl: '',
          },
        ],
      },
      {
        name: 'David Kim',
        description:
          '韓国系アメリカ人の3Dモデラー。ゲームや映画向けのモデル作成が得意。',
        imageUrl: '',
        email: 'david@example.com',
        website: 'https://david3d.com',
        phoneNumber: '+1-555-777-8888',
        socialMediaHandle: '@david3d',
        opus: [
          {
            name: 'ゲームアバター3Dモデル',
            description: 'アバター用の高精細3Dモデルのセット。',
            imageUrl: '',
          },
        ],
      },
    ];

    const users = [];
    const creators = [];

    for (let i = 0; i < creatorData.length; i++) {
      const user = new User();
      user.email = creatorData[i].email;
      user.password = User.encryptPassword('password');
      user.role = UserRole.MEMBER;

      users.push(user);
    }

    const savedUsers: User[] = await userRepository.save(users);

    for (let i = 0; i < creatorData.length; i++) {
      const creator = new Creator();

      creator.name = creatorData[i].name;
      creator.description = creatorData[i].description;
      creator.imageUrl = creatorData[i].imageUrl;
      creator.email = creatorData[i].email;
      creator.website = creatorData[i].website;
      creator.phoneNumber = creatorData[i].phoneNumber;
      creator.socialMediaHandle = creatorData[i].socialMediaHandle;
      creator.user = savedUsers[i];

      creators.push(creator);
    }

    const savedCreators: Creator[] = await creatorRepository.save(creators);

    for (let i = 0; i < savedCreators.length; i++) {
      const opusData = creatorData[i].opus;
      const opuses = opusData.map((opus) => {
        const newOpus = new Opus();
        newOpus.name = opus.name;
        newOpus.description = opus.description;
        newOpus.imageUrl = opus.imageUrl;
        newOpus.creator = savedCreators[i];
        return newOpus;
      });
      await opusRepository.save(opuses);
    }

    console.log('Creator and Opus seeder completed successfully');
  }
}
