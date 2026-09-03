/// Client-side mirror of the backend `GroupRolesGuard` role checks.
/// The server remains the source of truth — this only hides UI a role can't use.
class Permissions {
  Permissions._();

  static const _owner = 'OWNER';
  static const _admin = 'ADMIN';
  static const _treasurer = 'TREASURER';
  static const _secretary = 'SECRETARY';

  static bool _in(String? role, List<String> allowed) =>
      role != null && (role == _owner || allowed.contains(role));

  static bool canManageMembers(String? role) => _in(role, [_admin, _secretary]);
  static bool canRecordContribution(String? role) => _in(role, [_admin, _treasurer]);
  static bool canPurchaseShares(String? role) => _in(role, [_admin, _treasurer]);
  static bool canCreateFine(String? role) => _in(role, [_admin, _treasurer, _secretary]);
  static bool canUpdateFineStatus(String? role) => _in(role, [_admin, _treasurer]);
  static bool canManageLoans(String? role) => _in(role, [_admin, _treasurer]);
  static bool canManageExpenses(String? role) => _in(role, [_admin, _treasurer]);
  static bool canManageMeetings(String? role) => _in(role, [_admin, _secretary]);
  static bool canEditGroupSettings(String? role) => _in(role, [_admin]);

  /// Every active member can raise a loan request for themselves.
  static bool canRequestLoan(String? role) => role != null;
}
