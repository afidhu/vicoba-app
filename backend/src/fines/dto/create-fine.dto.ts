import { IsNotEmpty, IsNumber, IsOptional, Min } from 'class-validator';

export class CreateFineDto {
  @IsNotEmpty()
  memberId: string;

  @IsNotEmpty()
  reason: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  amount?: number;
}
