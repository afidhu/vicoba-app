CREATE TABLE "GroupAttachment" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "uploadedById" TEXT NOT NULL,
    "fileName" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "size" INTEGER NOT NULL,
    "data" BYTEA NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "GroupAttachment_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "GroupAttachment_groupId_createdAt_idx" ON "GroupAttachment"("groupId", "createdAt");
ALTER TABLE "GroupAttachment" ADD CONSTRAINT "GroupAttachment_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "Group"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "GroupAttachment" ADD CONSTRAINT "GroupAttachment_uploadedById_fkey" FOREIGN KEY ("uploadedById") REFERENCES "User"("id") ON UPDATE CASCADE;