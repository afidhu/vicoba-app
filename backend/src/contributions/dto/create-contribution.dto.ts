import { IsDateString, IsNotEmpty, IsNumber, IsOptional, Min } from 'class-validator';

export class CreateContributionDto {
  @IsNotEmpty()
  memberId: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  amount?: number;

  @IsDateString()
  weekEnding: string;
}
