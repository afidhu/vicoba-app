import { apiClient } from './client';
import {
  Contribution,
  DashboardSummary,
  Expense,
  Fine,
  Group,
  GroupMember,
  Loan,
  Meeting,
  Transaction,
} from '../types';

// ---- Auth ----
export const authApi = {
  login: (email: string, password: string) =>
    apiClient.post('/auth/login', { email, password }),
  register: (data: { email: string; password: string; name: string; phone?: string }) =>
    apiClient.post('/auth/register', data),
  me: () => apiClient.get('/auth/me'),
};

// ---- Groups ----
export const groupsApi = {
  list: () => apiClient.get<Group[]>('/groups'),
  create: (data: Partial<Group>) => apiClient.post<Group>('/groups', data),
  get: (groupId: string) => apiClient.get<Group>(`/groups/${groupId}`),
  update: (groupId: string, data: Partial<Group>) =>
    apiClient.patch<Group>(`/groups/${groupId}`, data),
};

// ---- Members ----
export const membersApi = {
  list: (groupId: string) => apiClient.get<GroupMember[]>(`/groups/${groupId}/members`),
  create: (groupId: string, data: Partial<GroupMember>) =>
    apiClient.post<GroupMember>(`/groups/${groupId}/members`, data),
  update: (groupId: string, memberId: string, data: Partial<GroupMember>) =>
    apiClient.patch<GroupMember>(`/groups/${groupId}/members/${memberId}`, data),
  purchaseShares: (groupId: string, memberId: string, quantity: number) =>
    apiClient.post(`/groups/${groupId}/members/${memberId}/shares`, { quantity }),
  sharesSummary: (groupId: string) =>
    apiClient.get(`/groups/${groupId}/members/shares-summary`),
};

// ---- Contributions ----
export const contributionsApi = {
  list: (groupId: string, memberId?: string) =>
    apiClient.get<Contribution[]>(`/groups/${groupId}/contributions`, {
      params: memberId ? { memberId } : {},
    }),
  create: (
    groupId: string,
    data: { memberId: string; amount?: number; weekEnding: string },
  ) => apiClient.post(`/groups/${groupId}/contributions`, data),
};

// ---- Fines ----
export const finesApi = {
  list: (groupId: string) => apiClient.get<Fine[]>(`/groups/${groupId}/fines`),
  create: (groupId: string, data: { memberId: string; reason: string; amount?: number }) =>
    apiClient.post(`/groups/${groupId}/fines`, data),
  updateStatus: (groupId: string, fineId: string, status: string) =>
    apiClient.patch(`/groups/${groupId}/fines/${fineId}/status`, { status }),
};

// ---- Loans ----
export const loansApi = {
  list: (groupId: string) => apiClient.get<Loan[]>(`/groups/${groupId}/loans`),
  get: (groupId: string, loanId: string) =>
    apiClient.get<Loan>(`/groups/${groupId}/loans/${loanId}`),
  create: (
    groupId: string,
    data: {
      memberId: string;
      principal: number;
      interestRate?: number;
      issueDate: string;
      dueDate: string;
    },
  ) => apiClient.post(`/groups/${groupId}/loans`, data),
  repay: (groupId: string, loanId: string, amount: number) =>
    apiClient.post(`/groups/${groupId}/loans/${loanId}/repayments`, { amount }),
};

// ---- Expenses ----
export const expensesApi = {
  list: (groupId: string) => apiClient.get<Expense[]>(`/groups/${groupId}/expenses`),
  create: (groupId: string, data: { description: string; amount: number; date: string }) =>
    apiClient.post(`/groups/${groupId}/expenses`, data),
};

// ---- Meetings ----
export const meetingsApi = {
  list: (groupId: string) => apiClient.get<Meeting[]>(`/groups/${groupId}/meetings`),
  create: (groupId: string, data: { date: string; notes?: string }) =>
    apiClient.post(`/groups/${groupId}/meetings`, data),
};

// ---- Transactions ----
export const transactionsApi = {
  list: (groupId: string, params?: Record<string, string>) =>
    apiClient.get<Transaction[]>(`/groups/${groupId}/transactions`, { params }),
  auditLog: (groupId: string) => apiClient.get(`/groups/${groupId}/transactions/audit-log`),
};

// ---- Dashboard ----
export const dashboardApi = {
  get: (groupId: string) => apiClient.get<DashboardSummary>(`/groups/${groupId}/dashboard`),
};

// ---- Reports ----
export const reportsApi = {
  summary: (groupId: string, params?: Record<string, string>) =>
    apiClient.get(`/groups/${groupId}/reports/summary`, { params }),
  contributions: (groupId: string, params?: Record<string, string>) =>
    apiClient.get(`/groups/${groupId}/reports/contributions`, { params }),
  shares: (groupId: string) => apiClient.get(`/groups/${groupId}/reports/shares`),
  fines: (groupId: string, params?: Record<string, string>) =>
    apiClient.get(`/groups/${groupId}/reports/fines`, { params }),
  loans: (groupId: string, params?: Record<string, string>) =>
    apiClient.get(`/groups/${groupId}/reports/loans`, { params }),
  expenses: (groupId: string, params?: Record<string, string>) =>
    apiClient.get(`/groups/${groupId}/reports/expenses`, { params }),
};
