import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/device_info/device_info.model.dart';
import 'home.state.dart';
import 'status/status.state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.device) : super(const InitialHomeState()) {
    getStatus();
  }

  final DeviceInfo device;

  Future<void> getStatus() async {
    emit(const LoadingStatusState());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(const StatusLoadedState(isConnected: true));
  }
}
