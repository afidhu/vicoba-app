import { Module } from '@nestjs/common';
import { FinesService } from './fines.service';
import { FinesController } from './fines.controller';

@Module({
  providers: [FinesService],
  controllers: [FinesController],
})
export class FinesModule {}
