import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AuditService {
  constructor(private prisma: PrismaService) {}

  async log(params: {
    userId: string;
    action: string;
    entity: string;
    entityId?: string;
    groupId?: string;
    metadata?: Record<string, any>;
  }) {
    const { userId, action, entity, entityId, groupId, metadata } = params;
    return this.prisma.auditLog.create({
      data: { userId, action, entity, entityId, groupId, metadata },
    });
  }
}
