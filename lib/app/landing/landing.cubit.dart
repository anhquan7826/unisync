import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/repository/connection.repository.dart';

import 'landing.state.dart';

class LandingCubit extends Cubit<LandingState> {
  LandingCubit(this.connectionRepo) : super(const LandingInitialState());

  final ConnectionRepository connectionRepo;

  void getLastUsedDevice() {
    connectionRepo.getLastUsedDevice().then((value) {
      emit(LastUsedDeviceState(device: value));
    });
  }
}
