class ApiConstants {
  // Default to Android emulator host (10.0.2.2).
  // For physical devices or local testing, you can change to your local network IP (e.g. http://192.168.1.x:3000/api) or http://localhost:3000/api
  static const String baseUrl = 'http://192.168.1.149:3000/api';
  
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Users endpoint
  static const String usersMe = '/users/me';

  // Groups endpoints
  static const String groups = '/groups';
  static String groupDetails(String groupId) => '/groups/$groupId';

  // Members endpoints
  static String members(String groupId) => '/groups/$groupId/members';
  static String memberDetails(String groupId, String memberId) => '/groups/$groupId/members/$memberId';
  static String purchaseShares(String groupId, String memberId) => '/groups/$groupId/members/$memberId/shares';
  static String sharesSummary(String groupId) => '/groups/$groupId/members/shares-summary';

  // Dashboard endpoint
  static String dashboard(String groupId) => '/groups/$groupId/dashboard';

  // Contributions endpoints
  static String contributions(String groupId) => '/groups/$groupId/contributions';

  // Fines endpoints
  static String fines(String groupId) => '/groups/$groupId/fines';
  static String updateFineStatus(String groupId, String fineId) => '/groups/$groupId/fines/$fineId/status';

  // Loans & Repayments endpoints
  static String loans(String groupId) => '/groups/$groupId/loans';
  static String requestLoan(String groupId) => '/groups/$groupId/loans/request';
  static String loanDetails(String groupId, String loanId) => '/groups/$groupId/loans/$loanId';
  static String approveLoan(String groupId, String loanId) => '/groups/$groupId/loans/$loanId/approve';
  static String rejectLoan(String groupId, String loanId) => '/groups/$groupId/loans/$loanId/reject';
  static String repayLoan(String groupId, String loanId) => '/groups/$groupId/loans/$loanId/repayments';

  // Expenses endpoints
  static String expenses(String groupId) => '/groups/$groupId/expenses';

  // Meetings endpoints
  static String meetings(String groupId) => '/groups/$groupId/meetings';
  static String meetingDetails(String groupId, String meetingId) => '/groups/$groupId/meetings/$meetingId';
  static String meetingAttendance(String groupId, String meetingId) => '/groups/$groupId/meetings/$meetingId/attendance';

  // Transactions & Audit endpoints
  static String transactions(String groupId) => '/groups/$groupId/transactions';
  static String auditLog(String groupId) => '/groups/$groupId/transactions/audit-log';

  // Reports endpoints
  static String financialSummaryReport(String groupId) => '/groups/$groupId/reports/summary';
  static String contributionsReport(String groupId) => '/groups/$groupId/reports/contributions';
  static String sharesReport(String groupId) => '/groups/$groupId/reports/shares';
  static String finesReport(String groupId) => '/groups/$groupId/reports/fines';
  static String loansReport(String groupId) => '/groups/$groupId/reports/loans';
  static String expensesReport(String groupId) => '/groups/$groupId/reports/expenses';
  static String transactionsReport(String groupId) => '/groups/$groupId/reports/transactions';
}
