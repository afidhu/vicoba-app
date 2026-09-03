import { IsDateString, IsNumber, IsOptional, Min } from 'class-validator';

export class RequestLoanDto {
  @IsOptional()
  memberId?: string;

  @IsNumber()
  @Min(1)
  principal: number;

  @IsOptional()
  @IsDateString()
  dueDate?: string;

  @IsOptional()
  notes?: string;
}
