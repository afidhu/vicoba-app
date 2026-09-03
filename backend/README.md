# VICOBA Backend (NestJS + Prisma + PostgreSQL)

## 1. Prerequisites
- Node.js 18+
- PostgreSQL running locally (or reachable)

## 2. Setup

```bash
cd backend
npm install
cp .env.example .env
```

Edit `.env` — it's already pre-filled to match the credentials you gave:

```
DATABASE_URL="postgresql://postgres:2002afidhu@localhost:5432/vicoba_db?schema=public"
JWT_SECRET="change-this-to-a-long-random-secret"
JWT_EXPIRES_IN="7d"
PORT=3000
CORS_ORIGIN="http://localhost:5173"
```

Create the database (if it doesn't exist yet):

```bash
psql -U postgres -h localhost -c "CREATE DATABASE vicoba_db;"
```

## 3. Run migrations & generate the Prisma client

```bash
npx prisma migrate dev --name init
```

This creates all tables from `prisma/schema.prisma` and generates the client.

## 4. (Optional) Seed demo data

```bash
npx prisma db seed
```

Creates a demo group "Umoja VICOBA Group" with an owner login:
- email: `owner@vicoba.test`
- password: `password123`

## 5. Start the API

```bash
npm run start:dev
```

API base URL: `http://localhost:3000/api`

## API overview

- `POST /api/auth/register` / `POST /api/auth/login` / `GET /api/auth/me`
- `POST /api/auth/forgot-password` / `POST /api/auth/reset-password` (dev: token returned in body; TODO email delivery)
- `GET /api/users/me` / `PATCH /api/users/me`
- `POST /api/groups` / `GET /api/groups` / `GET /api/groups/:groupId` / `PATCH /api/groups/:groupId`
- `POST /api/groups/:groupId/members` / `GET .../members` / `PATCH .../members/:memberId`
- `POST /api/groups/:groupId/members/:memberId/shares` (purchase shares)
- `GET /api/groups/:groupId/members/shares-summary`
- `POST /api/groups/:groupId/contributions` / `GET .../contributions`
- `POST /api/groups/:groupId/fines` / `GET .../fines` / `PATCH .../fines/:fineId/status`
- `POST /api/groups/:groupId/loans` (officer direct-issue) / `POST .../loans/request` (member request)
- `PATCH .../loans/:loanId/approve` / `PATCH .../loans/:loanId/reject` (Admin/Treasurer)
- `GET .../loans` / `GET .../loans/:loanId` / `POST .../loans/:loanId/repayments`
- `POST /api/groups/:groupId/expenses` / `GET .../expenses`
- `POST /api/groups/:groupId/meetings` / `GET .../meetings` / `GET .../meetings/:meetingId`
- `POST .../meetings/:meetingId/attendance` (Admin/Secretary)
- `GET /api/groups/:groupId/transactions` / `GET .../transactions/audit-log`
- `GET /api/groups/:groupId/dashboard`
- `GET /api/groups/:groupId/reports/{contributions|shares|fines|loans|expenses|transactions|summary}`

All group-scoped routes require a `Bearer` JWT and active membership in the group.
Role checks (Owner always has full access):
- Members: Admin, Secretary
- Contributions: Admin, Treasurer
- Shares purchase: Admin, Treasurer
- Fines create: Admin, Treasurer, Secretary — fines status update: Admin, Treasurer
- Loans & repayments: Admin, Treasurer
- Expenses: Admin, Treasurer
- Meetings: Admin, Secretary
- Group settings update: Admin
