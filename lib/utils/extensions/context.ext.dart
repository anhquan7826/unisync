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

  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;
}

extension TypoExtension on BuildContext {
  TextStyle get displayL => Theme.of(this).textTheme.displayLarge!;

  TextStyle get displayM => Theme.of(this).textTheme.displayMedium!;

  TextStyle get displayS => Theme.of(this).textTheme.displaySmall!;

  TextStyle get headlineL => Theme.of(this).textTheme.headlineLarge!;

  TextStyle get headlineM => Theme.of(this).textTheme.headlineMedium!;

  TextStyle get headlineS => Theme.of(this).textTheme.headlineSmall!;

  TextStyle get titleL => Theme.of(this).textTheme.titleLarge!;

  TextStyle get titleM => Theme.of(this).textTheme.titleMedium!;

  TextStyle get titleS => Theme.of(this).textTheme.titleSmall!;

  TextStyle get bodyL => Theme.of(this).textTheme.bodyLarge!;

  TextStyle get bodyM => Theme.of(this).textTheme.bodyMedium!;

  TextStyle get bodyS => Theme.of(this).textTheme.bodySmall!;

  TextStyle get labelL => Theme.of(this).textTheme.labelMedium!;

  TextStyle get labelM => Theme.of(this).textTheme.labelMedium!;

  TextStyle get labelS => Theme.of(this).textTheme.labelMedium!;
}
