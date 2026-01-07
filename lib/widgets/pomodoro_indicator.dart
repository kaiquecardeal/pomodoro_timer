import 'package:flutter/material.dart';
import 'package:pomodoro_timer/models/pomodoro_state.dart';

/// Widget que exibe os indicadores de pomodoros completados
/// Mostra circulos com check para cada pomodoro do ciclo atual
class PomodoroIndicator extends StatefulWidget {
  /// Numero total de pomodoros completados na sessao
  final int completedPomodoros;

  /// Cor dos indicadores (muda conforme a fase)
  final Color foregroundColor;

  const PomodoroIndicator({
    super.key,
    required this.completedPomodoros,
    required this.foregroundColor,
  });

  @override
  State<PomodoroIndicator> createState() => _PomodoroIndicatorState();
}

class _PomodoroIndicatorState extends State<PomodoroIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _popController;

  late Animation<double> _popAnimation;

  int _previousCount = 0;

  @override
  void initState() {
    super.initState();

    _previousCount = widget.completedPomodoros;

    _popController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _popAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticInOut)),
        weight: 50,
      ),
    ]).animate(_popController);
  }

  @override
  void didUpdateWidget(covariant PomodoroIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.completedPomodoros > _previousCount) {
      _popController.forward(from: 0);
    }

    _previousCount = widget.completedPomodoros;
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calcula pomodoros no ciclo atual (0 a 3)
    // Usa modulo para resetar apos pausa longa
    final currentCyclePomodoros =
        widget.completedPomodoros % PomodoroState.pomodorosBeforeLongBreak;

    // Calcula quantos ciclos completos (4 pomodoros = 1 ciclo)
    final completedCycles =
        widget.completedPomodoros ~/ PomodoroState.pomodorosBeforeLongBreak;

    return Column(
      children: [
        // Linha de indicadores circulares
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(PomodoroState.pomodorosBeforeLongBreak, (
            index,
          ) {
            // Verifica se este indicador representa um pomodoro completado
            final isCompleted = index < currentCyclePomodoros;

            final isLastCompleted =
                index == currentCyclePomodoros - 1 &&
                widget.completedPomodoros > 0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: AnimatedBuilder(
                animation: _popAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isLastCompleted ? _popAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Preenchido se completado, semi-transparente se nao
                    color: isCompleted
                        ? widget.foregroundColor
                        : widget.foregroundColor.withOpacity(0.3),
                    border: Border.all(
                      color: widget.foregroundColor,
                      width: 2.5,
                    ),
                    boxShadow: isCompleted
                        ? [
                            BoxShadow(
                              color: widget.foregroundColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isCompleted ? 1.0 : 0.0,
                    child: Icon(
                      Icons.check,
                      size: 18,
                      // Cor do check adaptada ao fundo
                      color: isCompleted
                          ? (widget.foregroundColor == Colors.white
                                ? Colors.black54
                                : Colors.white)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // Texto com contagem total de pomodoros
        Text(
          completedCycles > 0
              // Mostra ciclos se houver algum completo
              ? '${widget.completedPomodoros} Pomodoros ($completedCycles ciclo${completedCycles > 1 ? 's' : ''} completo${completedCycles > 1 ? 's' : ''})'
              // Mostra apenas pomodoros se nenhum ciclo completo
              : '${widget.completedPomodoros} Pomodoro${widget.completedPomodoros != 1 ? 's' : ''} completado${widget.completedPomodoros != 1 ? 's' : ''}',
          style: TextStyle(
            fontSize: 14,
            color: widget.foregroundColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
