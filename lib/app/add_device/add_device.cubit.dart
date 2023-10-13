import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/add_device/add_device.state.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/repository/pairing.repository.dart';

class AddDeviceCubit extends Cubit<AddDeviceState> {
  AddDeviceCubit(this.context) : super(const AddDeviceLoading());

  final BuildContext context;
  PairingRepository get _pairingRepository {
    return context.read();
  }

  List<DeviceInfo> devices = [];

  Future<void> loadDevices() async {
    emit(const AddDeviceLoading());
    final discoveredDevices = await _pairingRepository.getDiscoveredDevices();
    if (discoveredDevices == null) {
      emit(const AddDeviceError('Cannot get discovered devices!'));
    } else {
      devices = discoveredDevices;
      emit(const AddDeviceLoaded());
    }
  }
}
