import 'package:flutter_bloc/flutter_bloc.dart';

import 'devices/devices.repo.dart';
import 'devices/devices.repo.impl.dart';

final providers = [
  RepositoryProvider<DevicesRepository>(create: (context) => DevicesRepositoryImpl()),
];
