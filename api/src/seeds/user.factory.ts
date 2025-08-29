import { setSeederFactory } from 'typeorm-extension';
import { User } from 'src/entities/user.entity';

setSeederFactory(User, async (faker) => {
  const user = new User();
  user.email = faker.internet.email();
  user.password = faker.internet.password();
  return user;
});
