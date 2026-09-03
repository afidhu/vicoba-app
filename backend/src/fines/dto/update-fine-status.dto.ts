import { IsEnum } from 'class-validator';

export class UpdateFineStatusDto {
  @IsEnum(['UNPAID', 'PAID', 'WAIVED'])
  status: string;
}
