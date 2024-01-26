import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension ContextExtension on BuildContext {
  bool get isDarkMode {
    return MediaQuery.of(this).platformBrightness == Brightness.dark;
  }

  T getRepo<T>() {
    return RepositoryProvider.of<T>(this);
  }

  T getCubit<T extends Cubit>() {
    return BlocProvider.of<T>(this);
  }
}