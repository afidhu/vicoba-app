import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AttachmentsService {
  constructor(private prisma: PrismaService) {}

  list(groupId: string) {
    return this.prisma.groupAttachment.findMany({
      where: { groupId },
      select: {
        id: true,
        groupId: true,
        uploadedById: true,
        fileName: true,
        mimeType: true,
        size: true,
        createdAt: true,
        uploadedBy: { select: { name: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(groupId: string, uploadedById: string, file?: Express.Multer.File) {
    if (!file?.buffer?.length) throw new BadRequestException('A file is required');
    return this.prisma.groupAttachment.create({
      data: {
        groupId,
        uploadedById,
        fileName: file.originalname,
        mimeType: file.mimetype || 'application/octet-stream',
        size: file.size,
        data: file.buffer,
      },
      select: {
        id: true,
        groupId: true,
        uploadedById: true,
        fileName: true,
        mimeType: true,
        size: true,
        createdAt: true,
      },
    });
  }

  async download(groupId: string, attachmentId: string) {
    const attachment = await this.prisma.groupAttachment.findFirst({
      where: { id: attachmentId, groupId },
    });
    if (!attachment) throw new NotFoundException('File not found');
    return attachment;
  }

  async remove(groupId: string, attachmentId: string) {
    const attachment = await this.prisma.groupAttachment.findFirst({
      where: { id: attachmentId, groupId },
      select: { id: true },
    });
    if (!attachment) throw new NotFoundException('File not found');
    return this.prisma.groupAttachment.delete({ where: { id: attachment.id } });
  }
}