import { IsDateString, IsNotEmpty, IsNumber, IsOptional, IsUUID, Min } from 'class-validator';

export class CreateLoanDto {
  @IsNotEmpty()
  memberId: string;

  @IsOptional()
  @IsUUID()
  guarantorId?: string;

  @IsNumber()
  @Min(1)
  principal: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  interestRate?: number;

  @IsDateString()
  issueDate: string;

  @IsDateString()
  dueDate: string;
}
