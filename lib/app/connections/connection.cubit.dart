import 'package:flutter_bloc/flutter_bloc.dart';

import 'connection.state.dart';

class ConnectionCubit extends Cubit<DeviceConnectionState> {
  ConnectionCubit() : super(const InitialDevicePairState()) {
    load();
  }

  Future<void> load() async {
    emit(GetAllDeviceState([]));
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
