import 'package:flutter/material.dart';
import 'package:mood_theme_changer/mood_theme_changer.dart';

void main() => runApp(const MoodThemeApp());

class MoodThemeApp extends StatelessWidget {
  const MoodThemeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MoodDefinition> myMoods = [
      const MoodDefinition(
        mood: UserMood.happy,
        label: 'Happy',
        icon: Icons.sentiment_very_satisfied,
      ),
      const MoodDefinition(mood: UserMood.calm, label: 'Calm', icon: Icons.spa),
      const MoodDefinition(
        mood: UserMood.focused,
        label: 'Focused',
        icon: Icons.center_focus_strong,
      ),
      const MoodDefinition(
        mood: UserMood.energetic,
        label: 'Energetic',
        icon: Icons.bolt,
      ),
      const MoodDefinition(
        mood: UserMood.sad,
        label: 'Sad',
        icon: Icons.sentiment_dissatisfied,
      ),
      const MoodDefinition(
        mood: UserMood.anxious,
        label: 'Anxious',
        icon: Icons.waves,
      ),
      const MoodDefinition(
        mood: UserMood.creative,
        label: 'Creative',
        icon: Icons.brush,
      ),
      const MoodDefinition(
        mood: UserMood.loved,
        label: 'Loved',
        icon: Icons.favorite,
      ),
    ];

    return MoodThemeProvider(
      definitions: myMoods,
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mood Theme',
          theme: Theme.of(context),
          home: MoodSelectorScreen(moods: myMoods),
        ),
      ),
    );
  }
}

class MoodSelectorScreen extends StatelessWidget {
  final List<MoodDefinition> moods;
  const MoodSelectorScreen({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = MoodThemeProvider.of(context);
    final currentMood = provider.currentMood;
    final currentMoodDef = moods.firstWhere((m) => m.mood == currentMood);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          currentMoodDef.icon,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
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
                          color: theme.colorScheme.onPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle(context, '⚡ Quick Select'),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: moods.length,
                  itemBuilder: (context, index) => _buildQuickMoodButton(
                    context,
                    moods[index],
                    provider.currentMood == moods[index].mood,
                  ),
                ),
                const SizedBox(height: 32),

                _buildSectionTitle(context, '🌅 Start Your Day'),
                const SizedBox(height: 12),
                _buildMoodChips(context, [
                  UserMood.energetic,
                  UserMood.calm,
                  UserMood.focused,
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle(context, '💼 Work Mode'),
                const SizedBox(height: 12),
                _buildMoodChips(context, [
                  UserMood.focused,
                  UserMood.creative,
                  UserMood.energetic,
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle(context, '💭 Current Feeling'),
                const SizedBox(height: 12),
                _buildMoodList(context, [
                  UserMood.happy,
                  UserMood.loved,
                  UserMood.anxious,
                  UserMood.sad,
                  UserMood.calm,
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle(context, '🌙 Wind Down'),
                const SizedBox(height: 12),
                _buildMoodChips(context, [
                  UserMood.calm,
                  UserMood.loved,
                  UserMood.creative,
                ]),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildQuickMoodButton(
    BuildContext context,
    MoodDefinition mood,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final provider = MoodThemeProvider.of(context);

    return GestureDetector(
      onTap: () => provider.setMood(mood.mood),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              mood.icon,
              size: 28,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 4),
            Text(
              mood.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChips(BuildContext context, List<UserMood> moodList) {
    final provider = MoodThemeProvider.of(context);
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: moodList.map((mood) {
        final moodDef = moods.firstWhere((m) => m.mood == mood);
        final isSelected = provider.currentMood == mood;

        return InkWell(
          onTap: () => provider.setMood(mood),
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
                  moodDef.icon,
                  size: 20,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  moodDef.label,
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

  Widget _buildMoodList(BuildContext context, List<UserMood> moodList) {
    final provider = MoodThemeProvider.of(context);
    final theme = Theme.of(context);

    return Column(
      children: moodList.map((mood) {
        final moodDef = moods.firstWhere((m) => m.mood == mood);
        final isSelected = provider.currentMood == mood;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => provider.setMood(mood),
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      moodDef.icon,
                      size: 24,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      moodDef.label,
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
