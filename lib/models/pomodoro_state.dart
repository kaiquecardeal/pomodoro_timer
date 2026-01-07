/// Enum que representa as fases do ciclo Pomodoro
/// - work: Fase de trabalho/foco (25 minutos)
/// - shortBreak: Pausa curta entre pomodoros (5 minutos)
/// - longBreak: Pausa longa apos completar um ciclo (15 minutos)
enum PomodoroPhase { work, shortBreak, longBreak }

/// Classe imutavel que representa o estado do timer Pomodoro
/// Segue o padrao de imutabilidade para gerenciamento de estado
class PomodoroState {
  /// Segundos restantes no timer atual
  final int remainingSeconds;

  /// Fase atual do ciclo (trabalho, pausa curta ou pausa longa)
  final PomodoroPhase currentPhase;

  /// Total de pomodoros completados na sessao
  final int completedPomodoros;

  /// Indica se o timer esta rodando
  final bool isRunning;

  /// Indica se o timer esta pausado
  final bool isPaused;

  // ============ CONSTANTES DE DURACAO (em segundos) ============
  /// Duracao da fase de trabalho: 25 minutos
  static const int workDuration = 25 * 60;

  /// Duracao da pausa curta: 5 minutos
  static const int shortBreakDuration = 5 * 60;

  /// Duracao da pausa longa: 15 minutos
  static const int longBreakDuration = 15 * 60;

  /// Quantidade de pomodoros antes da pausa longa
  static const int pomodorosBeforeLongBreak = 4;

  /// Construtor const para garantir imutabilidade
  const PomodoroState({
    required this.remainingSeconds,
    required this.currentPhase,
    required this.completedPomodoros,
    required this.isRunning,
    required this.isPaused,
  });

  /// Factory que cria o estado inicial do Pomodoro
  /// Timer inicia na fase de trabalho, parado
  factory PomodoroState.initial() {
    return const PomodoroState(
      remainingSeconds: workDuration,
      currentPhase: PomodoroPhase.work,
      completedPomodoros: 0,
      isRunning: false,
      isPaused: false,
    );
  }

  /// Cria uma copia do estado com valores alterados
  /// Padrao imutavel - nao modifica o objeto original
  PomodoroState copyWith({
    int? remainingSeconds,
    PomodoroPhase? currentPhase,
    int? completedPomodoros,
    bool? isRunning,
    bool? isPaused,
  }) {
    return PomodoroState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentPhase: currentPhase ?? this.currentPhase,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  /// Retorna o tempo formatado como MM:SS
  /// Exemplo: 25:00, 04:59, 00:30
  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Retorna o titulo da fase atual em portugues
  String get phaseTitle => switch (currentPhase) {
    PomodoroPhase.work => 'Foco',
    PomodoroPhase.shortBreak => 'Pausa Curta',
    PomodoroPhase.longBreak => 'Pausa Longa',
  };

  static int getDurationForPhase(PomodoroPhase phase) {
    return switch (phase) {
      PomodoroPhase.work => workDuration,
      PomodoroPhase.shortBreak => shortBreakDuration,
      PomodoroPhase.longBreak => longBreakDuration,
    };
  }

  /// Calcula o progresso da fase atual (0.0 a 1.0)
  /// Usado para o indicador circular de progresso
  double get progress {
    final totalDuration = getDurationForPhase(currentPhase);
    return 1 - (remainingSeconds / totalDuration);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PomodoroState &&
          runtimeType == other.runtimeType &&
          remainingSeconds == other.remainingSeconds &&
          currentPhase == other.currentPhase &&
          completedPomodoros == other.completedPomodoros &&
          isRunning == other.isRunning &&
          isPaused == other.isPaused;

  @override
  int get hashCode => Object.hash(
    remainingSeconds,
    currentPhase,
    completedPomodoros,
    isRunning,
    isPaused,
  );
}
