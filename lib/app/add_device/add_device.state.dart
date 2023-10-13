import 'package:equatable/equatable.dart';

abstract class AddDeviceState extends Equatable {
  const AddDeviceState();
}

class AddDeviceInitialState extends AddDeviceState {
  const AddDeviceInitialState();

  @override
  List<Object?> get props => [];
}

class AddDeviceLoading extends AddDeviceState {
  const AddDeviceLoading();

  @override
  List<Object?> get props => [];
}

class AddDeviceLoaded extends AddDeviceState {
  const AddDeviceLoaded();

  @override
  List<Object?> get props => [];
}

class AddDeviceError extends AddDeviceState {
  const AddDeviceError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
