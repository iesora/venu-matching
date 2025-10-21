import { Seeder } from 'typeorm-extension';
import { DataSource } from 'typeorm';
import { User } from '../entities/user.entity';
import {
  Matching,
  MatchingStatus,
  RequestorType,
} from '../entities/matching.entity';
import { Event, EventStatus } from '../entities/event.entity';

export default class MatchingSeeder implements Seeder {
  async run(dataSource: DataSource): Promise<void> {
    const userRepository = dataSource.getRepository(User);
    const matchingRepository = dataSource.getRepository(Matching);

    // ユーザーテーブルから10人のうち5人のユーザーを取得
    //残り5人はリクエストボタン検証等のためオファー作らず開けておく
    const users: User[] = await userRepository.find({
      take: 5,
      order: { id: 'ASC' },
      relations: ['creators', 'venues'],
    });

    const matchings: Matching[] = [];
    for (let i = 0; i < users.length; i++) {
      const venue = users[i].venues[0];
      for (let j = 0; j < users.length; j++) {
        //5つ作るマッチングのうち1つはMATCHING、4つはPENDING
        //PENDINGの4つは2つcreator発と2つvenue発のrequestorTypeで作成
        const caseStatus = (j + i) % 3;
        const caseRequestorType = (j + i) % 2;
        const matching = new Matching();
        matching.creator = users[j].creators[0];
        matching.venue = venue;
        matching.requestorType =
          caseRequestorType === 0 ? RequestorType.CREATOR : RequestorType.VENUE;
        matching.status =
          caseStatus === 0 ? MatchingStatus.MATCHING : MatchingStatus.PENDING;
        matching.requestAt = new Date();
        matching.matchingAt = caseStatus === 0 ? new Date() : null;
        matchings.push(matching);
      }
    }
    await matchingRepository.save(matchings);

    // statusがacceptedになっているmatchingを取得
    const acceptedMatchings = await matchingRepository.find({
      where: { status: MatchingStatus.MATCHING },
      relations: ['creator', 'venue'],
    });

    const eventRepository = dataSource.getRepository(Event);
    const eventsToSave = [];

    const exhibitionTitles = [
      '未来都市展',
      '光と影のアートフェスティバル',
      '現代イラストレーションの冒険',
      '音と空間：サウンドアート展',
      '色彩の交響曲',
      '時空を超えるインスタレーション',
      '静寂の記憶−写真展',
      '日本アニメーション芸術祭',
      'デジタルアート新世紀',
      'みんなの絵本原画展',
    ];

    const exhibitionDescriptions = [
      '近未来の都市風景をテーマに、現代アーティストによるインスタレーションや映像作品を展示。',
      '光と影を使った体験型アートで、空間の奥行きや変化を視覚的に楽しめます。',
      '新進気鋭のイラストレーターが描く、独創性と個性あふれる作品を集めた展覧会。',
      '音×空間をテーマにした現代サウンドアートの最前線を体感できます。',
      '絵画・写真・彫刻で色彩の持つエネルギーと美しさを多彩に表現します。',
      'タイムトラベル感覚で楽しめる、時空・記憶を表現した大型インスタレーション。',
      '静けさや時間の流れを切り取った写真家たちの新作と代表作を紹介。',
      '人気アニメからアーティストによるアニメーション作品まで、日本の多彩なアニメ文化を展示。',
      '最新のテクノロジーで進化するデジタルアートとその可能性を探る特別展。',
      '幅広い世代に親しまれる絵本の原画を多数公開し、創造力の世界を楽しめます。',
    ];

    let idx = 0;
    for (const matching of acceptedMatchings) {
      // 1. requestorType: creator, status: pending
      const eventFromCreator = new Event();
      eventFromCreator.title = exhibitionTitles[idx % exhibitionTitles.length];
      eventFromCreator.description =
        exhibitionDescriptions[idx % exhibitionDescriptions.length];
      eventFromCreator.imageUrl = '';
      eventFromCreator.matching = matching;
      eventFromCreator.venue = matching.venue;
      eventFromCreator.status = EventStatus.PENDING;
      eventFromCreator.requestorType = RequestorType.CREATOR;
      eventFromCreator.startDate = new Date(
        Date.now() + Math.floor(Math.random() * 100000000),
      );
      eventFromCreator.endDate = new Date(
        eventFromCreator.startDate.getTime() +
          Math.floor(Math.random() * 100000000),
      );
      eventsToSave.push(eventFromCreator);

      // 2. requestorType: venue, status: pending
      const eventFromVenue = new Event();
      eventFromVenue.title = `${
        exhibitionTitles[(idx + 1) % exhibitionTitles.length]
      } −スペシャル展示−`;
      eventFromVenue.description = `${
        exhibitionDescriptions[(idx + 1) % exhibitionDescriptions.length]
      } さらに新しい体験を提供します。`;
      eventFromVenue.imageUrl = '';
      eventFromVenue.matching = matching;
      eventFromVenue.venue = matching.venue;
      eventFromVenue.status = EventStatus.PENDING;
      eventFromVenue.requestorType = RequestorType.VENUE;
      eventFromVenue.startDate = new Date(
        Date.now() + Math.floor(Math.random() * 100000000),
      );
      eventFromVenue.endDate = new Date(
        eventFromVenue.startDate.getTime() +
          Math.floor(Math.random() * 100000000),
      );
      eventsToSave.push(eventFromVenue);

      // 3. requestorType: venue, status: accepted
      const eventStatusAccepted = new Event();
      eventStatusAccepted.title = `${
        exhibitionTitles[(idx + 2) % exhibitionTitles.length]
      } −クロージング展−`;
      eventStatusAccepted.description = `${
        exhibitionDescriptions[(idx + 2) % exhibitionDescriptions.length]
      } 展覧会の集大成となります。`;
      eventStatusAccepted.imageUrl = '';
      eventStatusAccepted.matching = matching;
      eventStatusAccepted.venue = matching.venue;
      eventStatusAccepted.status = EventStatus.ACCEPTED;
      eventStatusAccepted.requestorType = RequestorType.VENUE;
      eventStatusAccepted.startDate = new Date(
        Date.now() + Math.floor(Math.random() * 100000000),
      );
      eventStatusAccepted.endDate = new Date(
        eventStatusAccepted.startDate.getTime() +
          Math.floor(Math.random() * 100000000),
      );
      eventsToSave.push(eventStatusAccepted);

      idx++;
    }

    await eventRepository.save(eventsToSave);
  }
}
