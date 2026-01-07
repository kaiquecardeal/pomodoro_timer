import 'package:flutter/material.dart';

class AppConfig {
  static const int workDuration = 25 * 60; // 25 minutos
  static const int shortBreakDuration = 5 * 60; // 5 minutos
  static const int longBreakDuration = 15 * 60; // 15 minutos
  static const int pomodorosBeforeLongBreak = 4;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration phaseTransitionDuration = Duration(milliseconds: 500);

  static const Map<String, Color> phaseColors = {
    'work': Color(0xFFE53935), // Vermelho
    'shortBreak': Color(0xFF1E88E5), // Azul
    'longBreak': Color(0xFF43A047), // Verde
  };
}
