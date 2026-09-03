class AppConstants {
  AppConstants._();

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String activeGroupIdKey = 'active_group_id';
  static const String activeGroupNameKey = 'active_group_name';
  static const String activeUserRoleKey = 'active_user_role';

  // Roles (match backend enum values)
  static const String roleOwner = 'OWNER';
  static const String roleAdmin = 'ADMIN';
  static const String roleTreasurer = 'TREASURER';
  static const String roleSecretary = 'SECRETARY';
  static const String roleMember = 'MEMBER';

  // App metadata
  static const String appName = 'VICOBA Hub';
  static const int defaultPageSize = 20;
}

