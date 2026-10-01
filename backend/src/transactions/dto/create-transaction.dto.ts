import { IsIn, IsNotEmpty, IsNumber, IsString, Min } from 'class-validator';

export class CreateTransactionDto {
  @IsIn(['IN', 'OUT'])
  direction: 'IN' | 'OUT';

  @IsNumber()
  @Min(0.01)
  amount: number;

  @IsString()
  @IsNotEmpty()
  description: string;
}
