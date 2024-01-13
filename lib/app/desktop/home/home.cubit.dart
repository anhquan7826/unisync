import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/desktop/home/home.state.dart';
import 'package:unisync/app/desktop/home/status/status.state.dart';
import 'package:unisync_backend/models/device_info/device_info.model.dart';

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
