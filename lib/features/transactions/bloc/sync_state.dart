import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {}

class SyncLoading extends SyncState {}

class SyncSuccess extends SyncState {}

class SyncError extends SyncState {
  final String message;

  SyncError(this.message);

  @override
  List<Object?> get props => [message];
}