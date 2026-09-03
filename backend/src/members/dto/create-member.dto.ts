import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
// import { GroupRole } from '@prisma/client';

export class CreateMemberDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  // @IsEnum(GroupRole)
  role?: string;

  @IsOptional()
  userId?: string;
}
