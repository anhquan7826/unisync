import 'package:equatable/equatable.dart';

import '../../models/device_info/device_info.model.dart';

abstract class LandingState extends Equatable {
  const LandingState();
}

class LandingInitialState extends LandingState {
  const LandingInitialState();

  @override
  List<Object?> get props => [];
}

class LastUsedDeviceState extends LandingState {
  const LastUsedDeviceState({this.device});

  final DeviceInfo? device;

  @override
  List<Object?> get props => [device];
}
