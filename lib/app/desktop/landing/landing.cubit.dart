import 'package:flutter_bloc/flutter_bloc.dart';

import 'landing.state.dart';

class LandingCubit extends Cubit<LandingState> {
  LandingCubit() : super(const LandingInitialState());
}
