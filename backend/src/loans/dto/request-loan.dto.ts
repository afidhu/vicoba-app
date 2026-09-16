import { IsDateString, IsNumber, IsOptional, IsUUID, Min } from 'class-validator';

export class RequestLoanDto {
  @IsOptional()
  memberId?: string;

  @IsOptional()
  @IsUUID()
  guarantorId?: string;

  @IsNumber()
  @Min(1)
  principal: number;

  @IsOptional()
  @IsDateString()
  dueDate?: string;

  @IsOptional()
  notes?: string;
}
