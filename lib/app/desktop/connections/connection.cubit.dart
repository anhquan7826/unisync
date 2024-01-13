import 'package:flutter_bloc/flutter_bloc.dart';

import 'connection.state.dart';

class ConnectionCubit extends Cubit<DeviceConnectionState> {
  ConnectionCubit() : super(const InitialDevicePairState()) {
    load();
  }

  Future<void> load() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    emit(const GetAllDeviceState([]));
  }

  void connectToIp(String ip) {}

  @override
  Future<void> close() {
    return super.close();
  }
}
