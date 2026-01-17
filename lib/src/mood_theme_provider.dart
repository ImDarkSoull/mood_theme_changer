import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mood_enum.dart';
import 'mood_theme_config.dart';
import 'mood_defaults.dart';

/// A utility class to bind UI data with a mood's theme configuration.
///
/// This is what makes the "Easy Setup" possible.
class MoodDefinition {
  final UserMood mood;
  final String label;

  /// Optional standard Material icon.
  final IconData? icon;

  /// Optional asset path for SVG or Image icons.
  final String? iconAsset;
  final MoodThemeConfig? themeConfig;

  const MoodDefinition({
    required this.mood,
    required this.label,
    this.icon,
    this.iconAsset,
    this.themeConfig,
  });
}

class MoodThemeProvider extends StatefulWidget {
  /// Pass a list of definitions for easy setup.
  final List<MoodDefinition>? definitions;

  /// Alternatively, pass explicit maps.
  final Map<UserMood, MoodThemeConfig>? moodThemes;
  final Map<UserMood, MoodThemeConfig>? overrides;

  final Widget child;
  final UserMood initialMood;
  final Duration transitionDuration;
  final String prefsKey;

  /// Optional SharedPreferences instance for synchronous initialization.
  /// Used to prevent "flash of default content" on app restart.
  final SharedPreferences? savedPrefs;

  const MoodThemeProvider({
    super.key,
    this.definitions,
    this.moodThemes,
    this.overrides,
    required this.child,
    this.initialMood = UserMood.happy,
    this.transitionDuration = const Duration(milliseconds: 600),
    this.prefsKey = 'mood_theme_changer_index',
    this.savedPrefs,
  });

  static MoodThemeProviderState of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedMoodProvider>();
    if (inherited != null) return inherited.state;
    throw FlutterError(
        'MoodThemeProvider.of() called without a MoodThemeProvider in tree.');
  }

  @override
  MoodThemeProviderState createState() => MoodThemeProviderState();
}

class MoodThemeProviderState extends State<MoodThemeProvider> {
  late UserMood _currentMood;
  late Map<UserMood, MoodThemeConfig> _resolvedThemes;
  int _themeVersion = 0;

  /// Stores custom user seed colors per mood.
  final Map<UserMood, Color> _customSeedColors = {};

  /// Stores custom user brightness preference per mood.
  final Map<UserMood, Brightness> _customBrightness = {};

  UserMood get currentMood => _currentMood;
  Map<UserMood, MoodThemeConfig> get moodThemes => _resolvedThemes;

  @override
  void initState() {
    super.initState();
    if (widget.savedPrefs != null) {
      _loadMoodSync(widget.savedPrefs!);
      _loadCustomColorsSync(widget.savedPrefs!);
    } else {
      _currentMood = widget.initialMood;
      _loadMood();
      _loadCustomColors();
    }
    _resolveThemes();
  }

  void _loadMoodSync(SharedPreferences prefs) {
    final index = prefs.getInt(widget.prefsKey);
    if (index != null && index >= 0 && index < UserMood.values.length) {
      _currentMood = UserMood.values[index];
    } else {
      _currentMood = widget.initialMood;
    }
  }

  void _loadCustomColorsSync(SharedPreferences prefs) {
    for (final mood in UserMood.values) {
      final seedKey = '${widget.prefsKey}_custom_${mood.name}_seed';
      final colorValue = prefs.getInt(seedKey);
      if (colorValue != null) {
        _customSeedColors[mood] = Color(colorValue);
      }

      final brightnessKey = '${widget.prefsKey}_custom_${mood.name}_brightness';
      final brightnessValue = prefs.getInt(brightnessKey);
      if (brightnessValue != null) {
        _customBrightness[mood] = Brightness.values[brightnessValue];
      }
    }
  }

  void _resolveThemes() {
    final base = Map<UserMood, MoodThemeConfig>.from(defaultMoodThemes);

    if (widget.moodThemes != null) base.addAll(widget.moodThemes!);

    if (widget.definitions != null) {
      for (var def in widget.definitions!) {
        if (def.themeConfig != null) {
          base[def.mood] = def.themeConfig!;
        }
      }
    }

    if (widget.overrides != null) base.addAll(widget.overrides!);

    // Apply custom stored properties if any
    for (final mood in UserMood.values) {
      if (_customSeedColors.containsKey(mood) ||
          _customBrightness.containsKey(mood)) {
        final config = base[mood] ?? const MoodThemeConfig();
        base[mood] = config.copyWith(
          seedColor: _customSeedColors[mood],
          brightness: _customBrightness[mood],
        );
      }
    }

    _resolvedThemes = base;
    _themeVersion++;
  }

  @override
  void didUpdateWidget(MoodThemeProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.moodThemes != oldWidget.moodThemes ||
        widget.overrides != oldWidget.overrides ||
        widget.definitions != oldWidget.definitions) {
      setState(() => _resolveThemes());
    }
  }

  Future<void> _loadMood() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(widget.prefsKey);
      if (index != null && index >= 0 && index < UserMood.values.length) {
        final mood = UserMood.values[index];
        if (_resolvedThemes.containsKey(mood)) {
          setState(() => _currentMood = mood);
        }
      }
    } catch (e) {
      debugPrint('Error loading mood: $e');
    }
  }

  Future<void> _loadCustomColors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool changed = false;

      for (final mood in UserMood.values) {
        // Load custom seed color
        final seedKey = '${widget.prefsKey}_custom_${mood.name}_seed';
        final colorValue = prefs.getInt(seedKey);
        if (colorValue != null) {
          _customSeedColors[mood] = Color(colorValue);
          changed = true;
        }

        // Load custom brightness
        final brightnessKey =
            '${widget.prefsKey}_custom_${mood.name}_brightness';
        final brightnessValue = prefs.getInt(brightnessKey);
        if (brightnessValue != null) {
          _customBrightness[mood] = Brightness.values[brightnessValue];
          changed = true;
        }
      }

      if (changed) {
        setState(() => _resolveThemes());
      }
    } catch (e) {
      debugPrint('Error loading custom properties: $e');
    }
  }

  Future<void> setMood(UserMood mood) async {
    if (_currentMood == mood || !_resolvedThemes.containsKey(mood)) return;
    setState(() => _currentMood = mood);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(widget.prefsKey, mood.index);
    } catch (e) {
      debugPrint('Error saving mood: $e');
    }
  }

  /// Updates the theme (seed color and/or brightness) for a mood and persists it.
  Future<void> updateMoodTheme(
    UserMood mood, {
    Color? seedColor,
    Brightness? brightness,
  }) async {
    setState(() {
      if (seedColor != null) {
        _customSeedColors[mood] = seedColor;
      }
      if (brightness != null) {
        _customBrightness[mood] = brightness;
      }
      _resolveThemes();
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      if (seedColor != null) {
        await prefs.setInt(
          '${widget.prefsKey}_custom_${mood.name}_seed',
          seedColor.toARGB32(),
        );
      }
      if (brightness != null) {
        await prefs.setInt(
          '${widget.prefsKey}_custom_${mood.name}_brightness',
          brightness.index,
        );
      }
    } catch (e) {
      debugPrint('Error saving custom theme properties: $e');
    }
  }

  /// Alias only for backward compatibility for color updates.
  Future<void> updateMoodColor(UserMood mood, Color color) async {
    await updateMoodTheme(mood, seedColor: color);
  }

  /// Resets a specific mood's customization to defaults.
  Future<void> resetMoodColor(UserMood mood) async {
    if (!_customSeedColors.containsKey(mood) &&
        !_customBrightness.containsKey(mood)) {
      return;
    }

    setState(() {
      _customSeedColors.remove(mood);
      _customBrightness.remove(mood);
      _resolveThemes();
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${widget.prefsKey}_custom_${mood.name}_seed');
      await prefs.remove('${widget.prefsKey}_custom_${mood.name}_brightness');
    } catch (e) {
      debugPrint('Error resetting custom properties: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final config =
        _resolvedThemes[_currentMood] ?? _resolvedThemes[widget.initialMood]!;
    return _InheritedMoodProvider(
      state: this,
      currentMood: _currentMood,
      themeVersion: _themeVersion,
      child: AnimatedTheme(
        data: config.toThemeData(),
        duration: widget.transitionDuration,
        curve: Curves.easeInOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _InheritedMoodProvider extends InheritedWidget {
  final MoodThemeProviderState state;
  final UserMood currentMood;
  final int themeVersion;
  const _InheritedMoodProvider({
    required this.state,
    required this.currentMood,
    required this.themeVersion,
    required super.child,
  });
  @override
  bool updateShouldNotify(_InheritedMoodProvider oldWidget) =>
      currentMood != oldWidget.currentMood ||
      themeVersion != oldWidget.themeVersion;
}
