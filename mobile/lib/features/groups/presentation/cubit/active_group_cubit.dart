import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_service.dart';

class ActiveGroupState extends Equatable {
  final String? groupId;
  final String? groupName;
  final String? role;

  const ActiveGroupState({this.groupId, this.groupName, this.role});

  ActiveGroupState copyWith({String? groupId, String? groupName, String? role}) {
    return ActiveGroupState(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [groupId, groupName, role];
}

/// Holds the group the user is currently working in and their role in it,
/// so any page can gate actions without re-fetching membership.
class ActiveGroupCubit extends Cubit<ActiveGroupState> {
  final SecureStorageService storage;

  ActiveGroupCubit(this.storage) : super(const ActiveGroupState());

  Future<void> hydrate() async {
    emit(ActiveGroupState(
      groupId: await storage.getActiveGroupId(),
      groupName: await storage.getActiveGroupName(),
      role: await storage.getActiveUserRole(),
    ));
  }

  Future<void> setGroup({required String groupId, required String groupName}) async {
    await storage.saveActiveGroupId(groupId);
    await storage.saveActiveGroupName(groupName);
    emit(state.copyWith(groupId: groupId, groupName: groupName));
  }

  Future<void> setRole(String role) async {
    await storage.saveActiveUserRole(role);
    emit(state.copyWith(role: role));
  }

  void clear() => emit(const ActiveGroupState());
}
