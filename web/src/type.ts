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

export type Venue = {
  id: number;
  name: string;
  address: string;
  description?: string;
  capacity?: number;
  price?: number;
  imageUrl?: string;
  userId: number;
  createdAt: Date;
  updatedAt: Date;
};

export type Creator = {
  id: number;
  name: string;
  description?: string;
  profileImageUrl?: string;
  userId: number;
  createdAt: Date;
  updatedAt: Date;
};
