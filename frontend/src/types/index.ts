export type GroupRole = 'OWNER' | 'ADMIN' | 'TREASURER' | 'SECRETARY' | 'MEMBER';
export type FineStatus = 'UNPAID' | 'PAID' | 'WAIVED';
export type LoanStatus = 'PENDING' | 'REJECTED' | 'ACTIVE' | 'PAID' | 'OVERDUE' | 'DEFAULTED';
export type TransactionType =
  | 'CONTRIBUTION'
  | 'SHARE_PURCHASE'
  | 'FINE'
  | 'LOAN_DISBURSEMENT'
  | 'LOAN_REPAYMENT'
  | 'EXPENSE';
export type TransactionDirection = 'IN' | 'OUT';

export interface AuthUser {
  id: string;
  email: string;
  name: string;
  phone?: string | null;
}

export interface Group {
  id: string;
  name: string;
  location?: string | null;
  meetingDay?: string | null;
  weeklyContribution: string | number;
  sharePrice: string | number;
  fineDefaultAmount: string | number;
  loanInterestRate: string | number;
  createdAt?: string;
  members?: GroupMember[];
  _count?: { members: number };
}

export interface GroupMember {
  id: string;
  groupId: string;
  userId?: string | null;
  name: string;
  phone?: string | null;
  role: GroupRole;
  shareHoldings: number;
  isActive: boolean;
  joinedAt: string;
}

export interface Contribution {
  id: string;
  groupId: string;
  memberId: string;
  member?: { id: string; name: string };
  amount: string | number;
  weekEnding: string;
  createdAt: string;
}

export interface Fine {
  id: string;
  groupId: string;
  memberId: string;
  member?: { id: string; name: string };
  reason: string;
  amount: string | number;
  status: FineStatus;
  createdAt: string;
}

export interface Loan {
  id: string;
  groupId: string;
  memberId: string;
  member?: { id: string; name: string };
  guarantorId?: string | null;
  guarantor?: { id: string; name: string } | null;
  guaranteedShares?: number | null;
  principal: string | number;
  interestRate: string | number;
  issueDate: string;
  dueDate: string;
  status: LoanStatus;
  repayments?: { id: string; amount: string | number; paidAt: string }[];
  totalRepaid?: number;
  outstanding?: number;
  isOverdue?: boolean;
}

export interface GroupAttachment {
  id: string;
  fileName: string;
  mimeType: string;
  size: number;
  createdAt: string;
  uploadedBy?: { name: string };
}

export interface LoanGuaranteeRef {
  loanId: string;
  guaranteedShares: number;
  status: LoanStatus;
}

export interface ShareBreakdownRow {
  memberId: string;
  name: string;
  shareHoldings: number;
  shareValue: number;
  pledgedShares: number;
  availableShares: number;
  asGuarantorFor: (LoanGuaranteeRef & { borrowerName: string })[];
  guaranteedBy: (LoanGuaranteeRef & { guarantorName: string })[];
}

export interface ShareSummary {
  sharePrice: number;
  totalShares: number;
  totalShareCapital: number;
  breakdown: ShareBreakdownRow[];
}

export interface Expense {
  id: string;
  groupId: string;
  description: string;
  amount: string | number;
  date: string;
}

export interface Meeting {
  id: string;
  groupId: string;
  date: string;
  notes?: string | null;
}

export interface Transaction {
  id: string;
  groupId: string;
  memberId?: string | null;
  member?: { id: string; name: string } | null;
  type: TransactionType;
  direction: TransactionDirection;
  amount: string | number;
  description?: string | null;
  createdAt: string;
}

export interface DashboardSummary {
  group: Group;
  counts: { totalMembers: number; activeMembers: number; activeLoans: number };
  totals: {
    totalContributions: string | number;
    totalShareCapital: number;
    outstandingLoans: number;
    unpaidFines: number;
    totalExpenses: string | number;
  };
  recentTransactions: Transaction[];
  attachments: GroupAttachment[];
}
