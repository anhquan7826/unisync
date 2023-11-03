import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/overview/overview.state.dart';
import 'package:unisync/models/device_info/device_info.model.dart';

class OverviewCubit extends Cubit<OverviewState> {
  OverviewCubit() : super(const OverviewDeviceChangeState());

  DeviceInfo? _currentDevice;
  DeviceInfo? get currentDevice => _currentDevice;

  void changeDevice(DeviceInfo? device) {
    _currentDevice = device;
    emit(OverviewDeviceChangeState(device: _currentDevice));
  }
}
