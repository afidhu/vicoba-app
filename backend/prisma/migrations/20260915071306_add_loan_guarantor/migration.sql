-- AlterTable
ALTER TABLE "Loan" ADD COLUMN     "guaranteedShares" INTEGER,
ADD COLUMN     "guarantorId" TEXT;

-- AddForeignKey
ALTER TABLE "Loan" ADD CONSTRAINT "Loan_guarantorId_fkey" FOREIGN KEY ("guarantorId") REFERENCES "GroupMember"("id") ON DELETE SET NULL ON UPDATE CASCADE;
