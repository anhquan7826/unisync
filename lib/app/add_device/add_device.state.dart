import 'package:equatable/equatable.dart';

abstract class AddDeviceState extends Equatable {
  const AddDeviceState();
}

class AddDeviceInitialState extends AddDeviceState {
  const AddDeviceInitialState();

  @override
  List<Object?> get props => [];
}

class StartingDiscoveryService extends AddDeviceState {
  const StartingDiscoveryService();

  @override
  List<Object?> get props => [];
}

class StartedDiscoveryService extends AddDeviceState {
  const StartedDiscoveryService();

  @override
  List<Object?> get props => [];
}

class DiscoveryServiceError extends AddDeviceState {
  const DiscoveryServiceError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
