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

  const MoodThemeProvider({
    super.key,
    this.definitions,
    this.moodThemes,
    this.overrides,
    required this.child,
    this.initialMood = UserMood.happy,
    this.transitionDuration = const Duration(milliseconds: 600),
    this.prefsKey = 'mood_theme_changer_index',
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

  UserMood get currentMood => _currentMood;
  Map<UserMood, MoodThemeConfig> get moodThemes => _resolvedThemes;

  @override
  void initState() {
    super.initState();
    _currentMood = widget.initialMood;
    _resolveThemes();
    _loadMood();
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

    _resolvedThemes = base;
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

  @override
  Widget build(BuildContext context) {
    final config =
        _resolvedThemes[_currentMood] ?? _resolvedThemes[widget.initialMood]!;
    return _InheritedMoodProvider(
      state: this,
      currentMood: _currentMood,
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
  const _InheritedMoodProvider({
    required this.state,
    required this.currentMood,
    required super.child,
  });
  @override
  bool updateShouldNotify(_InheritedMoodProvider oldWidget) =>
      currentMood != oldWidget.currentMood;
}
