import { IsNumber, Min } from 'class-validator';

export class RepayLoanDto {
  @IsNumber()
  @Min(0.01)
  amount: number;
}
