# VICOBA Management Platform

A full-stack app for digitizing VICOBA (Village Community Bank) group administration:
members, weekly contributions, shares, fines, loans & repayments, expenses, meetings,
transaction history, an audit log, a dashboard, and financial reports.

## Stack

- **Backend:** Node.js, NestJS, Prisma ORM, PostgreSQL, JWT auth
- **Frontend:** React (TypeScript) + Vite, Bootstrap 5

## Project structure

```
vicoba-app/
├── backend/     # NestJS API
└── frontend/    # React + Vite app
```

## Quick start

### 1. Backend

```bash
cd backend
npm install
cp .env.example .env      # already pre-filled with your Postgres credentials
psql -U postgres -h localhost -c "CREATE DATABASE vicoba_db;"
npx prisma migrate dev --name init
npx prisma db seed         # optional demo data
npm run start:dev
```

API runs at `http://localhost:3000/api`.
Demo login (if seeded): `owner@vicoba.test` / `password123`.

See `backend/README.md` for the full endpoint list and role permissions.

### 2. Frontend

```bash
cd frontend
npm install
cp .env.example .env       # points to http://localhost:3000/api by default
npm run dev
```

App runs at `http://localhost:5173`.

## Features implemented

- Account registration & JWT login
- Multiple groups per user, with group switching
- Group configuration: weekly contribution, share price, default fine, loan interest
- Member management with roles (Owner, Admin, Treasurer, Secretary, Member) and activate/deactivate
- Weekly contributions (defaults to group contribution amount)
- Share purchases with automatic share-capital calculation
- Fines with reason, status (unpaid/paid/waived)
- Loans with configurable interest, repayments, automatic outstanding-balance and overdue detection
- Expenses
- Meetings log
- Full transaction ledger (auto-generated from every financial action) + audit log of user actions
- Dashboard with live summary stats and recent activity
- Reports: contributions, shares, fines, loans, expenses, cash flow, with date filters
- Role-based UI (buttons/actions hidden per role) backed by server-side role guards

## Notes / next steps (matches the spec's "future" items)

- Phone/OTP login, invitations & approval workflows are not implemented (spec marks these "future")
- PDF/Excel export of reports is not implemented (spec marks this "future")
- Meeting attendance & automatic absence fines are not implemented (spec marks these "future")
- The spec's tech section suggested Supabase; this build uses NestJS + Prisma + PostgreSQL directly, as you requested, with equivalent role-based access control implemented via NestJS guards instead of Postgres Row-Level Security
