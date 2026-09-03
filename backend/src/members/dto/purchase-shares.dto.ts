import { IsInt, Min } from 'class-validator';

export class PurchaseSharesDto {
  @IsInt()
  @Min(1)
  quantity: number;
}
