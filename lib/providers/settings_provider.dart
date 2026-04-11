import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool soundEnabled;
  final bool animationsEnabled;
  final String defaultAlgorithm;
  final bool isDarkMode;

  SettingsState({
    this.soundEnabled = true,
    this.animationsEnabled = true,
    this.defaultAlgorithm = 'BFS',
    this.isDarkMode = false,
  });

  SettingsState copyWith({
    bool? soundEnabled,
    bool? animationsEnabled,
    String? defaultAlgorithm,
    bool? isDarkMode,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      defaultAlgorithm: defaultAlgorithm ?? this.defaultAlgorithm,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SharedPreferences? _prefs;

  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      soundEnabled: _prefs?.getBool('soundEnabled') ?? true,
      animationsEnabled: _prefs?.getBool('animationsEnabled') ?? true,
      defaultAlgorithm: _prefs?.getString('defaultAlgorithm') ?? 'BFS',
      isDarkMode: _prefs?.getBool('isDarkMode') ?? false,
    );
  }

  void toggleSound(bool value) {
    state = state.copyWith(soundEnabled: value);
    _prefs?.setBool('soundEnabled', value);
  }

  void toggleAnimations(bool value) {
    state = state.copyWith(animationsEnabled: value);
    _prefs?.setBool('animationsEnabled', value);
  }

  void toggleDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
    _prefs?.setBool('isDarkMode', value);
  }

  void setDefaultAlgorithm(String algorithm) {
    state = state.copyWith(defaultAlgorithm: algorithm);
    _prefs?.setString('defaultAlgorithm', algorithm);
  }
}
