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
  tel?: string;
  description?: string;
  capacity?: number;
  facilities?: string;
  availableTime?: string;
  imageUrl?: string;
  user: User;
  createdAt: Date;
  updatedAt: Date;
};

export type Creator = {
  id: number;
  name: string;
  description?: string;
  email?: string;
  website?: string;
  phoneNumber?: string;
  socialMediaHandle?: string;
  imageUrl?: string;
  user: User;
  createdAt: Date;
  updatedAt: Date;
};

export enum MatchingFrom {
  CREATOR = "creator",
  VENUE = "venue",
}

export type Event = {
  id: number;
  title: string;
  description: string;
  startDate: Date;
  endDate: Date;
  venue: Venue;
  creators: Creator[];
  createdAt: Date;
  updatedAt: Date;
};

export type Matching = {
  id: number;
  from: MatchingFrom;
  matchingFlag: boolean;
  creator?: Creator;
  venue?: Venue;
  fromUser?: User;
  toUser?: User;
  requestAt?: Date;
  matchingAt?: Date;
  createdAt: Date;
  updatedAt: Date;
};
