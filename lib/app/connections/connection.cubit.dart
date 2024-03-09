import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/core/device_provider.dart';
import 'package:unisync/core/pairing_handler.dart';
import 'package:unisync/database/database.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/extensions/cubit.ext.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';
import 'package:unisync/utils/logger.dart';

import 'connection.state.dart';

class ConnectionCubit extends Cubit<DeviceConnectionState> with BaseCubit {
  ConnectionCubit() : super(const DeviceConnectionState()) {
    load();
  }

  late StreamSubscription<List<DeviceInfo>> _subscription;

  Future<void> load() async {
    _subscription = DeviceProvider.notifier.listen((value) {
      final available = <Device>[];
      final requested = <Device>[];
      for (final info in value) {
        final device = Device(info);
        switch (device.pairState) {
          case PairState.unpaired:
            available.add(device);
            break;
          case PairState.pairRequested:
            requested.add(device);
            break;
          default:
            break;
        }
      }
      safeEmit(DeviceConnectionState(
        availableDevices: available,
        requestedDevices: requested,
      ));
    });
  }

  void acceptPair(Device device) {
    device.pairOperation.acceptPair();
  }

  void rejectPair(Device device) {
    device.pairOperation.rejectPair();
  }

  Future<DeviceInfo?> getLastConnected() async {
    final entity = await UnisyncDatabase.i.pairedDeviceDao.getLastUsed();
    return entity?.let((it) {
      return DeviceInfo(
        id: it.id,
        name: it.name,
        deviceType: it.type,
      );
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
