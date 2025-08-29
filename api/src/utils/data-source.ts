import { DataSource } from 'typeorm';
import { User } from '../entities/user.entity';
import { Staff } from '../entities/staff.entity';
import { Course } from '../entities/course.entity';
import { Reservation } from '../entities/reservation.entity';
import { AvailableTime } from '../entities/availableTime.entity';
import { BusinessHours } from '../entities/businessHours.entity';
import { Company } from '../entities/company.entity';
import { Customer } from '../entities/customer.entity';
import { Payment } from '../entities/payment.entity';
import { Dental } from '../entities/dental.entity';
import { Dentist } from '../entities/dentist.entity';
import { CandidateDate } from '../entities/candidateDate,entity';

export const AppDataSource = new DataSource({
  type: 'mysql',
  host:
    process.env.NODE_ENV !== 'production' ? 'localhost' : process.env.DB_HOST,
  port: 3306,
  username:
    process.env.NODE_ENV !== 'production' ? 'develop' : process.env.DB_USERNAME,
  password:
    process.env.NODE_ENV !== 'production'
      ? 'password'
      : process.env.DB_PASSWORD,
  database:
    process.env.NODE_ENV !== 'production' ? 'develop' : process.env.DB_DATABASE,
  migrations:
    process.env.NODE_ENV === 'develop'
      ? ['src/migrations/*.ts']
      : ['dist/migrations/*.js'],
  synchronize: false,
  logging: true,
  entities: [
    User,
    Staff,
    Course,
    Reservation,
    AvailableTime,
    BusinessHours,
    Company,
    Customer,
    Payment,
    Dental,
    Dentist,
    CandidateDate,
  ],
});
