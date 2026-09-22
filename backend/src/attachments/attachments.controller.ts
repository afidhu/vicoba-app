import {
  Controller,
  Get,
  Param,
  Post,
  Delete,
  Res,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Response } from 'express';
import { AttachmentsService } from './attachments.service';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';
import { Roles } from '../common/decorators/roles.decorator';

@Controller('groups/:groupId/attachments')
@UseGuards(GroupRolesGuard)
export class AttachmentsController {
  constructor(private attachmentsService: AttachmentsService) {}

  @Get()
  list(@Param('groupId') groupId: string) {
    return this.attachmentsService.list(groupId);
  }

  @Post()
  @Roles('ADMIN')
  @UseInterceptors(FileInterceptor('file'))
  create(
    @Param('groupId') groupId: string,
    @CurrentUser('id') userId: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.attachmentsService.create(groupId, userId, file);
  }

  @Get(':attachmentId/download')
  async download(
    @Param('groupId') groupId: string,
    @Param('attachmentId') attachmentId: string,
    @Res() response: Response,
  ) {
    const file = await this.attachmentsService.download(groupId, attachmentId);
    response.set({
      'Content-Type': file.mimeType,
      'Content-Length': file.size.toString(),
      'Content-Disposition': `attachment; filename="${file.fileName.replace(/"/g, '')}"`,
    });
    response.send(file.data);
  }

  @Delete(':attachmentId')
  @Roles('ADMIN')
  remove(
    @Param('groupId') groupId: string,
    @Param('attachmentId') attachmentId: string,
  ) {
    return this.attachmentsService.remove(groupId, attachmentId);
  }
}