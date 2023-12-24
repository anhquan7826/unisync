import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/device_pair/device_pair.state.dart';
import 'package:unisync/repository/connection.repository.dart';
import 'package:unisync/repository/pairing.repository.dart';

class DevicePairCubit extends Cubit<DevicePairState> {
  DevicePairCubit({
    required this.connectionRepo,
    required this.pairingRepo,
  }) : super(const InitialDevicePairState()) {
    load();
  }

  final ConnectionRepository connectionRepo;
  final PairingRepository pairingRepo;

  Future<void> load() async {
    emit(GetAllDeviceState(await connectionRepo.getAvailableDevices()));
    connectionRepo.addDeviceChangeListener(
      onDeviceAdd: (device) {
        emit(OnDeviceAddState(device));
      },
      onDeviceRemove: (device) {
        emit(OnDeviceRemoveState(device));
      },
    );
  }

  void connectToIp(String ip) {
    connectionRepo.connectToAddress(ip);
  }

  @override
  Future<void> close() {
    connectionRepo.removeDeviceChangeListener();
    return super.close();
  }
}
