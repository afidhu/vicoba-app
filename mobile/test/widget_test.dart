// Smoke tests for VICOBA mobile helpers that don't require the DI container.

import 'package:flutter_test/flutter_test.dart';
import 'package:vikoba_app/core/auth/permissions.dart';
import 'package:vikoba_app/features/fines/domain/entities/fine.dart';

void main() {
  test('role permissions follow least privilege', () {
    expect(Permissions.canManageMembers('OWNER'), isTrue);
    expect(Permissions.canManageMembers('SECRETARY'), isTrue);
    expect(Permissions.canManageMembers('MEMBER'), isFalse);
    expect(Permissions.canRecordContribution('TREASURER'), isTrue);
    expect(Permissions.canRecordContribution('SECRETARY'), isFalse);
    expect(Permissions.canRequestLoan('MEMBER'), isTrue);
  });

  test('fine status parsing is case-insensitive and round-trips', () {
    expect(fineStatusFromString('PAID'), FineStatus.paid);
    expect(fineStatusFromString('waived'), FineStatus.waived);
    expect(fineStatusFromString(null), FineStatus.unpaid);
    expect(fineStatusToApi(FineStatus.waived), 'WAIVED');
  });
}
