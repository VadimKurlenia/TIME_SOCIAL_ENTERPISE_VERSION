import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AppSettingsEvent {}

class ToggleThemeEvent extends AppSettingsEvent {}

class ChangeLanguageEvent extends AppSettingsEvent {
  final Locale locale;
  ChangeLanguageEvent(this.locale);
}

class AppSettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  AppSettingsState({required this.themeMode, required this.locale});

  AppSettingsState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  AppSettingsBloc()
    : super(
        AppSettingsState(
          themeMode: ThemeMode.light,
          locale: const Locale('ru'),
        ),
      ) {
    on<ToggleThemeEvent>((event, emit) {
      final nextTheme = state.themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      emit(state.copyWith(themeMode: nextTheme));
    });

    on<ChangeLanguageEvent>((event, emit) {
      emit(state.copyWith(locale: event.locale));
    });
  }
}
