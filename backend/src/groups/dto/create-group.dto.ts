import { IsNotEmpty, IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class CreateGroupDto {
  @IsNotEmpty()
  name: string;

  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @IsString()
  meetingDay?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  weeklyContribution?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  sharePrice?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  fineDefaultAmount?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  loanInterestRate?: number;
}
