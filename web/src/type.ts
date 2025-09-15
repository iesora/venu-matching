export enum UserRole {
  ADMIN = "admin",
  MEMBER = "member",
}

export enum UserMode {
  NORMAL = "normal",
  BUSINESS = "business",
}

export type User = {
  id: number;
  email: string;
  password: string;
  role: UserRole;
  mode: UserMode;
  createdAt: Date;
  updatedAt: Date;
};
