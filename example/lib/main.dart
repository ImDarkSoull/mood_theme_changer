import 'package:flutter/material.dart';
import 'package:mood_theme_changer/mood_theme_changer.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MoodThemeApp(prefs: prefs));
}

const _kMoodDefinitions = [
  MoodDefinition(
    mood: UserMood.happy,
    label: 'Happy',
    icon: Icons.sentiment_very_satisfied,
  ),
  MoodDefinition(mood: UserMood.calm, label: 'Calm', icon: Icons.spa),
  MoodDefinition(
    mood: UserMood.focused,
    label: 'Focused',
    icon: Icons.center_focus_strong,
  ),
  MoodDefinition(
    mood: UserMood.energetic,
    label: 'Energetic',
    icon: Icons.bolt,
  ),
  MoodDefinition(
    mood: UserMood.sad,
    label: 'Sad',
    icon: Icons.sentiment_dissatisfied,
  ),
  MoodDefinition(mood: UserMood.anxious, label: 'Anxious', icon: Icons.waves),
  MoodDefinition(mood: UserMood.creative, label: 'Creative', icon: Icons.brush),
  MoodDefinition(mood: UserMood.loved, label: 'Loved', icon: Icons.favorite),
];

const _kColorOptions = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
  Colors.black,
];

class MoodThemeApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MoodThemeApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MoodThemeProvider(
      savedPrefs: prefs,
      definitions: _kMoodDefinitions,
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mood Theme',
          theme: Theme.of(context),
          home: const MoodSelectorScreen(),
        ),
      ),
    );
  }
}

class MoodSelectorScreen extends StatelessWidget {
  const MoodSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = MoodThemeProvider.of(context);
    final currentMoodDef = _kMoodDefinitions.firstWhere(
      (m) => m.mood == provider.currentMood,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, currentMoodDef, theme),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionHeader(title: '⚡ Quick Select'),
                const SizedBox(height: 12),
                _QuickSelectGrid(
                  currentMood: provider.currentMood,
                  onMoodSelected: provider.setMood,
                ),
                const SizedBox(height: 32),
                _SectionHeader(title: '🎨 Customize Current Mood'),
                const SizedBox(height: 12),
                _ColorPickerButton(moodDef: currentMoodDef),
                const SizedBox(height: 32),
                _SectionHeader(title: '🌅 Start Your Day'),
                const SizedBox(height: 12),
                _MoodChipGroup(
                  moods: const [
                    UserMood.energetic,
                    UserMood.calm,
                    UserMood.focused,
                  ],
                  currentMood: provider.currentMood,
                  onMoodSelected: provider.setMood,
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: '💼 Work Mode'),
                const SizedBox(height: 12),
                _MoodChipGroup(
                  moods: const [
                    UserMood.focused,
                    UserMood.creative,
                    UserMood.energetic,
                  ],
                  currentMood: provider.currentMood,
                  onMoodSelected: provider.setMood,
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: '💭 Current Feeling'),
                const SizedBox(height: 12),
                _MoodListGroup(
                  moods: const [
                    UserMood.happy,
                    UserMood.loved,
                    UserMood.anxious,
                    UserMood.sad,
                    UserMood.calm,
                  ],
                  currentMood: provider.currentMood,
                  onMoodSelected: provider.setMood,
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    MoodDefinition currentMoodDef,
    ThemeData theme,
  ) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: theme.colorScheme.primary,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _CircleIcon(
                  icon: currentMoodDef.icon,
                  color: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surface,
                  size: 48,
                  padding: 20,
                  shadow: true,
                ),
                const SizedBox(height: 16),
                Text(
                  currentMoodDef.label.toUpperCase(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Active Theme',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _QuickSelectGrid extends StatelessWidget {
  final UserMood currentMood;
  final ValueChanged<UserMood> onMoodSelected;

  const _QuickSelectGrid({
    required this.currentMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _kMoodDefinitions.length,
      itemBuilder: (context, index) {
        final def = _kMoodDefinitions[index];
        final isSelected = currentMood == def.mood;
        final theme = Theme.of(context);

        return GestureDetector(
          onTap: () => onMoodSelected(def.mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  def.icon,
                  size: 28,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  def.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MoodChipGroup extends StatelessWidget {
  final List<UserMood> moods;
  final UserMood currentMood;
  final ValueChanged<UserMood> onMoodSelected;

  const _MoodChipGroup({
    required this.moods,
    required this.currentMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: moods.map((mood) {
        final def = _kMoodDefinitions.firstWhere((m) => m.mood == mood);
        final isSelected = currentMood == mood;
        final theme = Theme.of(context);

        return InkWell(
          onTap: () => onMoodSelected(mood),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  def.icon,
                  size: 20,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  def.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MoodListGroup extends StatelessWidget {
  final List<UserMood> moods;
  final UserMood currentMood;
  final ValueChanged<UserMood> onMoodSelected;

  const _MoodListGroup({
    required this.moods,
    required this.currentMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: moods.map((mood) {
        final def = _kMoodDefinitions.firstWhere((m) => m.mood == mood);
        final isSelected = currentMood == mood;
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onMoodSelected(mood),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.secondaryContainer,
                        ],
                      )
                    : null,
                color: isSelected ? null : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  _CircleIcon(
                    icon: def.icon,
                    size: 24,
                    padding: 10,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    backgroundColor: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      def.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData? icon;
  final Color color;
  final Color backgroundColor;
  final double size;
  final double padding;
  final bool shadow;

  const _CircleIcon({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.size = 24,
    this.padding = 8,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: shadow
            ? [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Icon(icon, size: size, color: color),
    );
  }
}

class _ColorPickerButton extends StatelessWidget {
  final MoodDefinition moodDef;

  const _ColorPickerButton({required this.moodDef});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (c) => _ColorPickerModal(moodDef: moodDef),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.primary, width: 2),
        ),
        child: Row(
          children: [
            _CircleIcon(
              icon: Icons.colorize,
              color: Colors.white,
              backgroundColor: theme.colorScheme.primary,
              shadow: true,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personalize ${moodDef.label}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tap to choose a seed color',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPickerModal extends StatelessWidget {
  final MoodDefinition moodDef;

  const _ColorPickerModal({required this.moodDef});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = MoodThemeProvider.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Personalize Theme',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a seed color for "${moodDef.label}"',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: _kColorOptions.length,
              itemBuilder: (context, index) {
                final color = _kColorOptions[index];
                final currentSeed =
                    provider.moodThemes[moodDef.mood]?.seedColor ??
                    Colors.transparent;
                final isSelected = color.value == currentSeed.value;

                return GestureDetector(
                  onTap: () =>
                      provider.updateMoodTheme(moodDef.mood, seedColor: color),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: isSelected ? 4 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Brightness Toggle
          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Switch between light and dark theme',
              style: theme.textTheme.bodySmall,
            ),
            secondary: Icon(
              provider.moodThemes[moodDef.mood]?.brightness == Brightness.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
            value:
                provider.moodThemes[moodDef.mood]?.brightness ==
                Brightness.dark,
            onChanged: (isDark) {
              provider.updateMoodTheme(
                moodDef.mood,
                brightness: isDark ? Brightness.dark : Brightness.light,
              );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            tileColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
              0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ModalButton(
                  onPressed: () => provider.resetMoodColor(moodDef.mood),
                  icon: Icons.refresh,
                  label: 'Reset',
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModalButton(
                  onPressed: () => Navigator.pop(context),
                  label: 'Done',
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModalButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const _ModalButton({
    required this.onPressed,
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    );
  }
}
