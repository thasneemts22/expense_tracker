import 'package:expense_manager/features/transactions/bloc/sync_event.dart';
import 'package:expense_manager/features/transactions/bloc/sync_state.dart';
import 'package:expense_manager/features/transactions/repository/sync_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncRepository repository;

  SyncBloc(this.repository) : super(SyncInitial()) {
    on<SyncNowEvent>(_onSyncNow);
  }

  Future<void> _onSyncNow(SyncNowEvent event, Emitter<SyncState> emit) async {
    emit(SyncLoading());

    try {
      await repository.syncData();

      print(" SYNC COMPLETED");

      emit(SyncSuccess());
    } catch (e) {
      print(" SYNC BLOC ERROR: $e");

      emit(SyncError(e.toString()));
    }
  }
}
