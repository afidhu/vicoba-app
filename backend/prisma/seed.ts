import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash('password123', 10);

  const owner = await prisma.user.upsert({
    where: { email: 'owner@vicoba.test' },
    update: {},
    create: {
      email: 'owner@vicoba.test',
      passwordHash,
      name: 'Amina Juma',
      phone: '0712000000',
    },
  });

  const group = await prisma.group.create({
    data: {
      name: 'Umoja VICOBA Group',
      location: 'Dar es Salaam',
      meetingDay: 'Saturday',
      weeklyContribution: 5000,
      sharePrice: 10000,
      fineDefaultAmount: 1000,
      loanInterestRate: 10,
      ownerId: owner.id,
      members: {
        create: [
          { userId: owner.id, name: owner.name, phone: owner.phone, role: "OWNER", shareHoldings: 5 },
          { name: 'Baraka Mushi', phone: '0713000001', role: "TREASURER", shareHoldings: 3 },
          { name: 'Catherine Mrema', phone: '0714000002', role: "SECRETARY", shareHoldings: 2 },
          { name: 'David Kessy', phone: '0715000003', role: "MEMBER", shareHoldings: 1 },
        ],
      },
    },
  });

  console.log('Seeded demo group:', group.name);
  console.log('Login with: owner@vicoba.test / password123');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
