import 'package:flutter/material.dart';
import 'package:pomodoro_timer/models/pomodoro_state.dart';

/// Widget que exibe os botoes de controle do timer
/// Inclui botoes para iniciar, pausar, resetar e pular fase
class ControlButtons extends StatelessWidget {
  /// Estado atual do Pomodoro
  final PomodoroState state;

  /// Cor dos icones e texto dos botoes
  final Color foregroundColor;

  /// Cor de fundo (usada como cor do texto no botao principal)
  final Color backgroundColor;

  /// Callbacks para as acoes dos botoes
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  const ControlButtons({
    super.key,
    required this.state,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onSkip,
  });

  /// Exibe dialogo de confirmacao antes de resetar o timer
  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Timer'),
        content: Text(
          'Deseja resetar o timer atual?\n\n'
          'Tempo restante: ${state.formattedTime}\n',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onReset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: foregroundColor,
              foregroundColor: backgroundColor,
            ),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }

  /// Exibe dialogo de confirmacao antes de pular para proxima fase.
  /// Calcula e mostra qual sera a proxima fase (Trabalho, Pausa Curta ou Pausa Longa)
  /// baseado na fase atual e quantidade de pomodoros completados.
  void _showSkipConfirmation(BuildContext context) {
    String nextPhaseName;
    // Determina qual sera a proxima fase
    if (state.currentPhase == PomodoroPhase.work) {
      // Apos trabalho, verifica se vai para pausa longa ou curta
      final nextPomodoros = state.completedPomodoros + 1;
      if (nextPomodoros % PomodoroState.pomodorosBeforeLongBreak == 0) {
        nextPhaseName = 'Pausa Longa';
      } else {
        nextPhaseName = 'Pausa Curta';
      }
    } else {
      // Apos qualquer pausa, volta para trabalho
      nextPhaseName = 'Trabalho';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pular fase'),
        content: Text('Deseja pular para a proxima fase: $nextPhaseName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onSkip();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: foregroundColor,
              foregroundColor: backgroundColor,
            ),
            child: const Text('Pular'),
          ),
        ],
      ),
    );
  }

  /// Retorna o texto de tooltip do botao principal baseado no estado atual.
  /// - Rodando: "Pausar o timer atual."
  /// - Pausado: "Retomar o timer atual."
  /// - Parado: "Iniciar o timer Pomodoro"
  String _getMainButtonTooltip() {
    if (state.isRunning) {
      return 'Pausar o timer atual.';
    } else if (state.isPaused) {
      return 'Retomar o timer atual.';
    } else {
      return 'Iniciar o timer Pomodoro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botao de reset (esquerda) - aparece apenas quando pausado
        // SizedBox com largura fixa mantem o botao central alinhado
        SizedBox(
          width: 56,
          height: 56,
          child: state.isPaused
              ? Tooltip(
                  message: 'Reiniciar o timer da fase atual.',
                  child: IconButton(
                    onPressed: () => _showResetConfirmation(context),
                    icon: Icon(Icons.refresh, color: foregroundColor, size: 28),
                  ),
                )
              : const SizedBox(), // Espaco vazio quando nao pausado
        ),
        const SizedBox(width: 10),

        // Botao principal (centro) - iniciar/pausar/retomar
        Tooltip(
          message: _getMainButtonTooltip(),
          child: ElevatedButton(
            onPressed: state.isRunning ? onPause : onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: foregroundColor,
              foregroundColor: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icone muda conforme estado
                Icon(
                  state.isRunning ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
                const SizedBox(width: 8),
                // Texto muda conforme estado
                Text(
                  state.isRunning
                      ? 'PAUSAR'
                      : (state.isPaused ? 'RETOMAR' : 'INICIAR'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Botao de pular (direita) - aparece quando nao rodando
        SizedBox(
          width: 56,
          height: 56,
          child: !state.isRunning
              ? Tooltip(
                  message: 'Pular para a proxima fase.',
                  child: IconButton(
                    onPressed: () => _showSkipConfirmation(context),
                    icon: Icon(
                      Icons.skip_next,
                      color: foregroundColor,
                      size: 28,
                    ),
                  ),
                )
              : const SizedBox(), // Espaco vazio quando rodando
        ),
      ],
    );
  }
}
