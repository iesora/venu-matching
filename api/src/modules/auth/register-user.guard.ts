import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Observable } from 'rxjs';
import { verify } from 'jsonwebtoken';

@Injectable()
export class RegisterUserGuard implements CanActivate {
  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const req = context.switchToHttp().getRequest<Request>();
    const token = req.headers['access-token'];
    const secret = process.env.REGISTER_SECRET_KEY;
    try {
      verify(token, secret);
      return true;
    } catch (error) {
      return false;
    }
  }
}
