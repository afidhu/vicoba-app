-- DropForeignKey
ALTER TABLE "GroupAttachment" DROP CONSTRAINT "GroupAttachment_uploadedById_fkey";

-- AddForeignKey
ALTER TABLE "GroupAttachment" ADD CONSTRAINT "GroupAttachment_uploadedById_fkey" FOREIGN KEY ("uploadedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
