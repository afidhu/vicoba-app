import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/meeting_usecases.dart';
import 'meetings_event.dart';
import 'meetings_state.dart';

class MeetingsBloc extends Bloc<MeetingsEvent, MeetingsState> {
  final GetMeetingsUseCase getMeetingsUseCase;
  final CreateMeetingUseCase createMeetingUseCase;
  final GetMeetingDetailsUseCase getMeetingDetailsUseCase;
  final RecordAttendanceUseCase recordAttendanceUseCase;

  MeetingsBloc({
    required this.getMeetingsUseCase,
    required this.createMeetingUseCase,
    required this.getMeetingDetailsUseCase,
    required this.recordAttendanceUseCase,
  }) : super(MeetingsInitial()) {
    on<LoadMeetings>(_onLoadMeetings);
    on<CreateMeeting>(_onCreateMeeting);
    on<LoadMeetingDetails>(_onLoadMeetingDetails);
    on<RecordAttendance>(_onRecordAttendance);
  }

  Future<void> _onLoadMeetings(LoadMeetings event, Emitter<MeetingsState> emit) async {
    emit(MeetingsLoading());
    final result = await getMeetingsUseCase(event.groupId);
    result.fold(
      (failure) => emit(MeetingsError(failure.message)),
      (meetings) => emit(MeetingsLoaded(meetings)),
    );
  }

  Future<void> _onCreateMeeting(CreateMeeting event, Emitter<MeetingsState> emit) async {
    emit(MeetingsLoading());
    final result = await createMeetingUseCase(
      groupId: event.groupId,
      title: event.title,
      meetingDate: event.meetingDate,
      location: event.location,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(MeetingsError(failure.message)),
      (_) {
        emit(MeetingActionSuccess());
        add(LoadMeetings(event.groupId));
      },
    );
  }

  Future<void> _onLoadMeetingDetails(LoadMeetingDetails event, Emitter<MeetingsState> emit) async {
    emit(MeetingsLoading());
    final result = await getMeetingDetailsUseCase(event.groupId, event.meetingId);
    result.fold(
      (failure) => emit(MeetingsError(failure.message)),
      (meeting) => emit(MeetingDetailsLoaded(meeting)),
    );
  }

  Future<void> _onRecordAttendance(RecordAttendance event, Emitter<MeetingsState> emit) async {
    emit(MeetingsLoading());
    final result = await recordAttendanceUseCase(event.groupId, event.meetingId, event.attendance);
    result.fold(
      (failure) => emit(MeetingsError(failure.message)),
      (meeting) {
        emit(MeetingActionSuccess());
        emit(MeetingDetailsLoaded(meeting));
      },
    );
  }
}
