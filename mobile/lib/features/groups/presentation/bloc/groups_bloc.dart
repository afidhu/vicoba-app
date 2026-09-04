import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/group.dart';
import '../../domain/usecases/create_group_usecase.dart';
import '../../domain/usecases/get_group_details_usecase.dart';
import '../../domain/usecases/get_groups_usecase.dart';
import 'groups_event.dart';
import 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GetGroupsUseCase getGroupsUseCase;
  final GetGroupDetailsUseCase getGroupDetailsUseCase;
  final CreateGroupUseCase createGroupUseCase;
  final SecureStorageService storageService;

  List<Group> _cachedGroups = [];
  Group? _activeGroup;

  GroupsBloc({
    required this.getGroupsUseCase,
    required this.getGroupDetailsUseCase,
    required this.createGroupUseCase,
    required this.storageService,
  }) : super(GroupsInitial()) {
    on<LoadGroupsEvent>(_onLoadGroups);
    on<LoadGroupDetailsEvent>(_onLoadGroupDetails);
    on<CreateGroupEvent>(_onCreateGroup);
    on<SelectActiveGroupEvent>(_onSelectActiveGroup);
  }

  Future<void> _onLoadGroups(
    LoadGroupsEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    final result = await getGroupsUseCase();
    await result.fold(
      (failure) async => emit(GroupsError(failure.message)),
      (groups) async {
        _cachedGroups = groups;
        final savedGroupId = await storageService.getActiveGroupId();
        if (savedGroupId != null) {
          try {
            _activeGroup = groups.firstWhere((g) => g.id == savedGroupId);
          } catch (_) {
            _activeGroup = groups.isNotEmpty ? groups.first : null;
          }
        } else if (groups.isNotEmpty) {
          _activeGroup = groups.first;
          await storageService.saveActiveGroupId(_activeGroup!.id);
          await storageService.saveActiveGroupName(_activeGroup!.name);
        } else {
          _activeGroup = null;
        }
        emit(GroupsLoaded(groups: _cachedGroups, activeGroup: _activeGroup));
      },
    );
  }

  Future<void> _onLoadGroupDetails(
    LoadGroupDetailsEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    final result = await getGroupDetailsUseCase(event.groupId);
    result.fold(
      (failure) => emit(GroupsError(failure.message)),
      (group) => emit(GroupDetailsLoaded(group)),
    );
  }

  Future<void> _onCreateGroup(
    CreateGroupEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    final result = await createGroupUseCase(
      name: event.name,
      location: event.location,
      meetingDay: event.meetingDay,
      weeklyContribution: event.weeklyContribution,
      sharePrice: event.sharePrice,
      fineDefaultAmount: event.fineDefaultAmount,
      loanInterestRate: event.loanInterestRate,
    );
    result.fold(
      (failure) => emit(GroupsError(failure.message)),
      (group) {
        _activeGroup = group;
        storageService.saveActiveGroupId(group.id);
        storageService.saveActiveGroupName(group.name);
        emit(GroupOperationSuccess('Group created successfully', createdGroup: group));
        add(LoadGroupsEvent());
      },
    );
  }

  Future<void> _onSelectActiveGroup(
    SelectActiveGroupEvent event,
    Emitter<GroupsState> emit,
  ) async {
    await storageService.saveActiveGroupId(event.groupId);
    await storageService.saveActiveGroupName(event.groupName);
    try {
      _activeGroup = _cachedGroups.firstWhere((g) => g.id == event.groupId);
    } catch (_) {
      _activeGroup = null;
    }
    emit(GroupsLoaded(groups: _cachedGroups, activeGroup: _activeGroup));
  }
}
