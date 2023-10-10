import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/add_device/add_device.state.dart';
import 'package:unisync/repository/pairing.repository.dart';

class AddDeviceCubit extends Cubit<AddDeviceState> {
  AddDeviceCubit(this.context) : super(const StartingDiscoveryService());

  final BuildContext context;
  PairingRepository get _pairingRepository {
    return context.read();
  }

  Future<void> init() async {
    _pairingRepository.startDiscoveryService().then(
      (value) {
        emit(const StartedDiscoveryService());
      },
      onError: (exception) {
        emit(DiscoveryServiceError(exception.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _pairingRepository.stopDiscoveryService();
    return super.close();
  }
}
