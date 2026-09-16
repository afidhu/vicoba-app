import { PrismaService } from '../../prisma/prisma.service';

/** Loan statuses where a guarantor's pledged shares are still encumbered. */
export const ENCUMBERING_LOAN_STATUSES = ['PENDING', 'ACTIVE', 'OVERDUE', 'DEFAULTED'];

/**
 * Maps guarantorId -> total shares currently pledged across that member's
 * unresolved guaranteed loans in the group. A loan's pledge is excluded once
 * it's PAID or REJECTED, which is what makes pledge release automatic.
 */
export async function getPledgedSharesByGuarantor(
  prisma: PrismaService,
  groupId: string,
): Promise<Map<string, number>> {
  const grouped = await prisma.loan.groupBy({
    by: ['guarantorId'],
    where: {
      groupId,
      guarantorId: { not: null },
      status: { in: ENCUMBERING_LOAN_STATUSES as any },
    },
    _sum: { guaranteedShares: true },
  });

  const map = new Map<string, number>();
  for (const row of grouped) {
    if (row.guarantorId) map.set(row.guarantorId, row._sum.guaranteedShares ?? 0);
  }
  return map;
}
