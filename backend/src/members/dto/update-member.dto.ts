import { Transform } from 'class-transformer';
import { IsBoolean, IsEnum, IsOptional, IsString } from 'class-validator';
// import { GroupRole } from '@prisma/client';

const blankToUndefined = ({ value }: { value: unknown }) =>
  typeof value === 'string' && value.trim() === '' ? undefined : value;

export class UpdateMemberDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @Transform(blankToUndefined)
  @IsString()
  phone?: string;

  @IsOptional()
  // @IsEn um(GroupRole)
  role?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
