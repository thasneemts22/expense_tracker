import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SyncNowEvent extends SyncEvent {}