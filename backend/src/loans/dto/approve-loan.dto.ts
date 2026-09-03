import { IsDateString, IsNumber, IsOptional, Min } from 'class-validator';

export class ApproveLoanDto {
  @IsOptional()
  @IsNumber()
  @Min(0)
  interestRate?: number;

  @IsOptional()
  @IsDateString()
  issueDate?: string;

  @IsOptional()
  @IsDateString()
  dueDate?: string;
}
