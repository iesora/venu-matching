import { DataSource } from "typeorm";
import { Seeder } from "typeorm-extension";
import { User, UserRole } from "../entities/user.entity";
import { Creator } from "../entities/creator.entity";
import { Opus } from "../entities/opus.entity";

export default class CreatorSeeder implements Seeder {
  public async run(dataSource: DataSource): Promise<any> {
    const userRepository = dataSource.getRepository(User);
    const creatorRepository = dataSource.getRepository(Creator);
    const opusRepository = dataSource.getRepository(Opus);

    const creatorData = [
      {
        name: "田中美咲",
        description:
          "フォトグラファーとして風景写真を専門に撮影しています。自然の美しさを切り取ることが私の情熱です。",
        imageUrl:
          "https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0",
        email: "tanaka@example.com",
        website: "https://tanaka-photos.com",
        phoneNumber: "080-1234-5678",
        socialMediaHandle: "@tanaka_photo",
        opus: [
          {
            name: "自然の美",
            description: "美しい自然の風景を捉えた作品集。",
            imageUrl:
              "https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg",
          },
        ],
      },
      {
        name: "Alex Johnson",
        description:
          "Digital artist specializing in concept art for video games. I love creating immersive fantasy worlds.",
        imageUrl: "https://placekitten.com/800/600",
        email: "alex@example.com",
        website: "https://alexart.com",
        phoneNumber: "090-8765-4321",
        socialMediaHandle: "@alex_art",
        opus: [
          {
            name: "ファンタジーの世界",
            description: "ゲームのためのコンセプトアート集。",
            imageUrl: "https://picsum.photos/800/600",
          },
        ],
      },
      // 他のクリエイターのデータも同様に追加
    ];

    const users = [];
    const creators = [];

    for (let i = 0; i < creatorData.length; i++) {
      const user = new User();
      user.email = creatorData[i].email;
      user.password = User.encryptPassword("password");
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

    console.log("Creator and Opus seeder completed successfully");
  }
}
