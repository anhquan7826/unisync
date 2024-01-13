import '../home.state.dart';

abstract class StatusState extends HomeState {
  const StatusState();
}

class LoadingStatusState extends StatusState {
  const LoadingStatusState();

  @override
  List<Object?> get props => [];
}

class StatusLoadedState extends StatusState {
  const StatusLoadedState({
    required this.isConnected,
    this.battery = -1,
    this.connectivity = const [],
  });

  final bool isConnected;
  final int battery;
  final List<String> connectivity;

  @override
  List<Object?> get props => [isConnected, battery, ...connectivity];
}
