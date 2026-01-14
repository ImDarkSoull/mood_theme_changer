import 'package:flutter/material.dart';
import 'mood_enum.dart';
import 'mood_theme_config.dart';

/// Default pre-built themes for each mood with psychologically appropriate colors.
const Map<UserMood, MoodThemeConfig> defaultMoodThemes = {
  // Warm yellow-orange for joy and optimism
  UserMood.happy: MoodThemeConfig(
    seedColor: Color(0xFFFFA726), // Warm orange
    brightness: Brightness.light,
    surfaceTintFactor: 0.08,
  ),

  // Soft teal-green for tranquility and balance
  UserMood.calm: MoodThemeConfig(
    seedColor: Color(0xFF26A69A), // Calming teal
    brightness: Brightness.light,
    surfaceTintFactor: 0.12,
  ),

  // Deep blue for concentration and productivity
  UserMood.focused: MoodThemeConfig(
    seedColor: Color(0xFF1976D2), // Professional blue
    brightness: Brightness.dark,
    surfaceTintFactor: 0.0,
  ),

  // Vibrant red-orange for motivation and action
  UserMood.energetic: MoodThemeConfig(
    seedColor: Color(0xFFFF5722), // Energetic red-orange
    brightness: Brightness.light,
    surfaceTintFactor: 0.1,
  ),

  // Muted blue-grey for melancholy and reflection
  UserMood.sad: MoodThemeConfig(
    seedColor: Color(0xFF607D8B), // Soft blue-grey
    brightness: Brightness.dark,
    surfaceTintFactor: 0.25,
  ),

  // Soft purple for stress relief and comfort
  UserMood.anxious: MoodThemeConfig(
    seedColor: Color(0xFF9575CD), // Calming lavender
    brightness: Brightness.light,
    surfaceTintFactor: 0.15,
  ),

  // Vibrant magenta-purple for imagination and innovation
  UserMood.creative: MoodThemeConfig(
    seedColor: Color(0xFFAB47BC), // Creative purple
    brightness: Brightness.dark,
    surfaceTintFactor: 0.12,
  ),

  // Warm rose-pink for affection and warmth
  UserMood.loved: MoodThemeConfig(
    seedColor: Color(0xFFEC407A), // Loving pink
    brightness: Brightness.light,
    surfaceTintFactor: 0.1,
  ),
};
