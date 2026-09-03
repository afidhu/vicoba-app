import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_member_usecase.dart';
import '../../domain/usecases/get_members_usecase.dart';
import '../../domain/usecases/update_member_usecase.dart';
import 'members_event.dart';
import 'members_state.dart';

class MembersBloc extends Bloc<MembersEvent, MembersState> {
  final GetMembersUseCase getMembersUseCase;
  final AddMemberUseCase addMemberUseCase;
  final GetMemberUseCase? getMemberUseCase;
  final UpdateMemberUseCase? updateMemberUseCase;

  MembersBloc({
    required this.getMembersUseCase,
    required this.addMemberUseCase,
    this.getMemberUseCase,
    this.updateMemberUseCase,
  }) : super(MembersInitial()) {
    on<LoadMembersEvent>(_onLoadMembers);
    on<LoadMemberDetailsEvent>(_onLoadMemberDetails);
    on<AddMemberEvent>(_onAddMember);
    on<UpdateMemberEvent>(_onUpdateMember);
  }

  Future<void> _onLoadMembers(
    LoadMembersEvent event,
    Emitter<MembersState> emit,
  ) async {
    emit(MembersLoading());
    final result = await getMembersUseCase(event.groupId);
    result.fold(
      (failure) => emit(MembersError(failure.message)),
      (members) => emit(MembersLoaded(members)),
    );
  }

  Future<void> _onLoadMemberDetails(
    LoadMemberDetailsEvent event,
    Emitter<MembersState> emit,
  ) async {
    if (getMemberUseCase == null) return;
    emit(MembersLoading());
    final result = await getMemberUseCase!(event.groupId, event.memberId);
    result.fold(
      (failure) => emit(MembersError(failure.message)),
      (member) => emit(MemberDetailsLoaded(member)),
    );
  }

  Future<void> _onAddMember(
    AddMemberEvent event,
    Emitter<MembersState> emit,
  ) async {
    emit(MembersLoading());
    final result = await addMemberUseCase(
      groupId: event.groupId,
      name: event.name,
      phone: event.phone,
      role: event.role,
      userId: event.userId,
    );
    result.fold(
      (failure) => emit(MembersError(failure.message)),
      (member) {
        emit(MemberOperationSuccess('Member registered successfully', member: member));
        add(LoadMembersEvent(event.groupId));
      },
    );
  }

  Future<void> _onUpdateMember(
    UpdateMemberEvent event,
    Emitter<MembersState> emit,
  ) async {
    if (updateMemberUseCase == null) return;
    emit(MembersLoading());
    final result = await updateMemberUseCase!(
      groupId: event.groupId,
      memberId: event.memberId,
      name: event.name,
      phone: event.phone,
      role: event.role,
      isActive: event.isActive,
    );
    result.fold(
      (failure) => emit(MembersError(failure.message)),
      (member) {
        emit(MemberOperationSuccess('Member updated successfully', member: member));
        add(LoadMembersEvent(event.groupId));
      },
    );
  }
}
