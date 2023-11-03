import 'package:equatable/equatable.dart';
import 'package:unisync/models/device_info/device_info.model.dart';

abstract class OverviewState extends Equatable {
  const OverviewState();
}

class OverviewDeviceChangeState extends OverviewState {
  const OverviewDeviceChangeState({this.device});

  final DeviceInfo? device;

  @override
  List<Object?> get props => [device];
}
