import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { UserModule } from './modules/user/user.module';
import { User } from './entities/user.entity';
import { AuthModule } from './modules/auth/auth.module';
import { ReservationModule } from './modules/reservation/reservation.module';
import { StaffModule } from './modules/staff/staff.module';
import { CourseModule } from './modules/course/course.module';
import { Reservation } from './entities/reservation.entity';
import { Staff } from './entities/staff.entity';
import { Course } from './entities/course.entity';
import { AvailableTime } from './entities/availableTime.entity';
import { AvailableTimeModule } from './modules/available-time/available-time.module';
import { BusinessHours } from './entities/businessHours.entity';
import { BusinessHoursModule } from './modules/business-hours/business-hours.module';
import { Company } from './entities/company.entity';
import { Customer } from './entities/customer.entity';
import { CompanyModule } from './modules/company/company.module';
import { CustomerModule } from './modules/customer/customer.module';
import { Payment } from './entities/payment.entity';
//import { PaymentModule } from './modules/payment/payment.module';
import { Dental } from './entities/dental.entity';
import { Dentist } from './entities/dentist.entity';
import { DentalModule } from './modules/dental/dental.module';
import { CandidateDate } from './entities/candidateDate,entity';

@Module({
  imports: [
    ConfigModule.forRoot({ envFilePath: '.development.env' }),
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: process.env.DB_HOST,
      port: 3306,
      username: process.env.DB_USERNAME,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_DATABASE,
      synchronize: false,
      migrationsRun: false,
      entities: [
        User,
        Reservation,
        Staff,
        Course,
        AvailableTime,
        BusinessHours,
        Company,
        Customer,
        Payment,
        Dental,
        Dentist,
        CandidateDate,
      ],
    }),
    UserModule,
    AuthModule,
    ReservationModule,
    StaffModule,
    CourseModule,
    AvailableTimeModule,
    BusinessHoursModule,
    CompanyModule,
    CustomerModule,
    DentalModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
