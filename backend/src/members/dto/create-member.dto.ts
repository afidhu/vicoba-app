import { Transform } from 'class-transformer';
import { IsEmail, IsNotEmpty, IsOptional, IsString, MinLength } from 'class-validator';
// import { GroupRole } from '@prisma/client';

/** Blank strings from a form (vs. omitted fields) shouldn't collide on unique DB constraints. */
const blankToUndefined = ({ value }: { value: unknown }) =>
  typeof value === 'string' && value.trim() === '' ? undefined : value;

export class CreateMemberDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsOptional()
  @Transform(blankToUndefined)
  @IsString()
  phone?: string;

  @IsOptional()
  // @IsEnum(GroupRole)
  role?: string;

  /** Link to an existing user account instead of creating a new one. */
  @IsOptional()
  userId?: string;

  /**
   * Set together with `password` to create a brand-new login for this member
   * so they can sign in to the app themselves. Ignored if `userId` is set.
   */
  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @MinLength(6)
  password?: string;
}
