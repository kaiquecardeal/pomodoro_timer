import 'package:flutter/material.dart';
import 'package:pomodoro_timer/models/pomodoro_state.dart';

/// Widget que exibe o timer principal do Pomodoro
/// Mostra um indicador circular de progresso com o tempo restante
class TimerDisplay extends StatefulWidget {
  /// Estado atual do Pomodoro (tempo, fase, etc)
  final PomodoroState state;

  /// Cor do texto e indicador (muda conforme a fase)
  final Color foregroundColor;

  const TimerDisplay({
    super.key,
    required this.state,
    required this.foregroundColor,
  });

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  late Animation<double> _pulseAnimation;

  late AnimationController _progressController;

  late Animation<double> _progressAnimation;

  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initPulseAnimation();
    _initProgressAnimation();
  }

  void _initPulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.state.isRunning) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _initProgressAnimation() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _previousProgress = widget.state.progress;
    _progressAnimation =
        Tween<double>(begin: _previousProgress, end: _previousProgress).animate(
          CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state.isRunning && !oldWidget.state.isRunning) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.state.isRunning && oldWidget.state.isRunning) {
      _pulseController.stop();
      _pulseController.reset();
    }

    if (widget.state.progress != _previousProgress) {
      _progressAnimation =
          Tween<double>(
            begin: _previousProgress,
            end: widget.state.progress,
          ).animate(
            CurvedAnimation(
              parent: _progressController,
              curve: Curves.easeInOut,
            ),
          );
      _previousProgress = widget.state.progress;
      _progressController.forward(from: 0.0);
    }

    if (widget.state.currentPhase != oldWidget.state.currentPhase) {
      _previousProgress = 0.0;
      _progressAnimation = Tween<double>(begin: 0.0, end: widget.state.progress)
          .animate(
            CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
          );
      _progressController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Container com tamanho fixo para o timer
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _progressAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.state.isRunning ? _pulseAnimation.value : 1.0,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 12,
                    backgroundColor: widget.foregroundColor.withValues(
                      alpha: 0.2,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.foregroundColor.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: _progressAnimation.value,
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.foregroundColor,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                _buildTimerText(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            widget.state.formattedTime,
            key: ValueKey(widget.state.formattedTime),
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w600,
              color: widget.foregroundColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: widget.state.isPaused ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            'Pausado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: widget.foregroundColor.withValues(alpha: 0.7),
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}
