import 'package:flutter/material.dart';
import 'package:pomodoro_timer/models/pomodoro_state.dart';
import 'package:pomodoro_timer/viewmodels/pomodoro_viewmodel.dart';
import 'package:pomodoro_timer/views/settings_view.dart';
import 'package:pomodoro_timer/widgets/control_buttons.dart';
import 'package:pomodoro_timer/widgets/pomodoro_indicator.dart';
import 'package:pomodoro_timer/widgets/timer_display.dart';
import 'package:provider/provider.dart';

/// Tela principal do aplicativo Pomodoro Timer
/// Exibe o timer, controles e indicadores de progresso
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _phaseTransitionController;

  PomodoroPhase? _previousPhase;

  @override
  void initState() {
    super.initState();
    _phaseTransitionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PomodoroViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _phaseTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer reconstroi apenas quando o ViewModel notifica mudancas
    return Consumer<PomodoroViewModel>(
      builder: (context, viewModel, _) {
        final state = viewModel.state;
        // Timer esta ativo se estiver rodando ou pausado
        final isActive = state.isRunning || state.isPaused;
        // Cores mudam baseado na fase e estado do timer
        final backgroundColor = _getBackgroundColor(
          state.currentPhase,
          isActive,
        );
        final foregroundColor = _getForegroundColor(
          state.currentPhase,
          isActive,
        );

        if (_previousPhase != null && _previousPhase != state.currentPhase) {
          _phaseTransitionController.forward(from: 0.0);
        }
        _previousPhase = state.currentPhase;

        // AnimatedContainer para transicao suave de cores
        return AnimatedContainer(
          color: backgroundColor,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Botao de configuracoes no lado esquerdo
              leading: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.settings,
                    key: ValueKey(foregroundColor),
                    color: foregroundColor,
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsView()),
                ),
                tooltip: 'Configurações',
              ),
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                child: const Text('Pomodoro Timer'),
              ),
              centerTitle: true,
              actions: [
                // Botao de reset aparece apenas se houver progresso
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: state.completedPomodoros > 0
                      ? IconButton(
                          key: const ValueKey('reset_button'),
                          icon: Icon(Icons.refresh, color: foregroundColor),
                          onPressed: () => _showResetDialog(context, viewModel),
                          tooltip: 'Resetar Tudo',
                        )
                      : const SizedBox(key: ValueKey('empty'), width: 48),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Indicador da fase atual (Foco, Pausa Curta, Pausa Longa)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _buildPhaseIndicator(
                      state,
                      foregroundColor,
                      isActive,
                    ),
                  ),

                  // Timer principal com indicador circular
                  Expanded(
                    child: Center(
                      child: TimerDisplay(
                        state: state,
                        foregroundColor: foregroundColor,
                      ),
                    ),
                  ),

                  // Indicadores de pomodoros completados (circulos com check)
                  PomodoroIndicator(
                    completedPomodoros: state.completedPomodoros,
                    foregroundColor: foregroundColor,
                  ),
                  const SizedBox(height: 20),

                  // Botoes de controle (iniciar, pausar, resetar, pular)
                  ControlButtons(
                    state: state,
                    foregroundColor: foregroundColor,
                    backgroundColor: backgroundColor,
                    onStart: viewModel.startTimer,
                    onPause: viewModel.pauseTimer,
                    onReset: viewModel.resetTimer,
                    onSkip: viewModel.skipPhase,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Constroi o indicador visual da fase atual
  /// Exibe o titulo da fase em um container estilizado
  Widget _buildPhaseIndicator(
    PomodoroState state,
    Color foregroundColor,
    bool isActive,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        // Cor de fundo muda se timer esta ativo
        color: isActive
            ? foregroundColor.withOpacity(0.15)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Text(
          state.phaseTitle,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Exibe dialogo de confirmacao para resetar todo o progresso
  void _showResetDialog(BuildContext context, PomodoroViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Timer'),
        content: Text(
          'Voce completo ${viewModel.state.completedPomodoros} pomodoros. Deseja resetar o timer?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.resetAllProgress();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }

  /// Retorna a cor de fundo baseada na fase e estado do timer
  /// Branco quando inativo, colorido quando ativo
  Color _getBackgroundColor(PomodoroPhase phase, bool isActive) {
    // Fundo branco quando timer nao esta ativo
    if (!isActive) {
      return Colors.white;
    }

    // Cores diferentes para cada fase
    switch (phase) {
      case PomodoroPhase.work:
        return Colors.red.shade700; // Vermelho para trabalho
      case PomodoroPhase.shortBreak:
        return Colors.green.shade600; // Verde para pausa curta
      case PomodoroPhase.longBreak:
        return Colors.blue.shade600; // Azul para pausa longa
    }
  }

  /// Retorna a cor do texto/icones baseada na fase e estado
  /// Cinza quando inativo, branco quando ativo
  Color _getForegroundColor(PomodoroPhase phase, bool isActive) {
    if (!isActive) {
      return Colors.grey.shade800;
    }
    return Colors.white;
  }
}
