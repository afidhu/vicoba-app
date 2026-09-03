import { IsBoolean, IsEnum, IsOptional, IsString } from 'class-validator';
// import { GroupRole } from '@prisma/client';

export class UpdateMemberDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  // @IsEn um(GroupRole)
  role?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
