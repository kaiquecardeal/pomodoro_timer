import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pomodoro_timer/models/pomodoro_state.dart';
import 'package:pomodoro_timer/services/notification_services.dart';
import 'package:pomodoro_timer/services/storage_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// ViewModel responsavel pela logica de negocio do Pomodoro Timer.
///
/// Segue o padrao MVVM (Model-View-ViewModel), atuando como intermediario
/// entre a View (interface) e o Model (PomodoroState).
///
/// Responsabilidades:
/// - Gerenciar o ciclo de vida do timer (iniciar, pausar, resetar, pular)
/// - Controlar as transicoes entre fases (trabalho, pausa curta, pausa longa)
/// - Coordenar notificacoes e persistencia de dados
/// - Manter a tela ativa durante o timer (wakelock)
///
/// Extende ChangeNotifier para notificar a UI sobre mudancas de estado.
class PomodoroViewModel extends ChangeNotifier {
  // ============ SERVICOS ============

  /// Servico de notificacoes locais
  final NotificationServices _notificationServices = NotificationServices();

  /// Servico de persistencia de dados
  final StorageService _storageService = StorageService();

  // ============ ESTADO ============

  /// Estado atual do Pomodoro (imutavel)
  PomodoroState _state = PomodoroState.initial();

  /// Getter publico para acesso ao estado
  PomodoroState get state => _state;

  // ============ CONTROLE DE PERMISSOES ============

  /// Indica se o app tem permissao do sistema para enviar notificacoes
  bool _hasNotificationPermission = false;
  bool get hasNotificationPermission => _hasNotificationPermission;

  /// Indica se o usuario optou por receber notificacoes (preferencia do app)
  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // ============ TIMER ============

  /// Timer periodico que controla a contagem regressiva
  Timer? _timer;

  // ============ INICIALIZACAO ============

  /// Inicializa o ViewModel e configura os servicos.
  ///
  /// Deve ser chamado uma vez apos a criacao do ViewModel.
  /// Executa as seguintes operacoes:
  /// 1. Inicializa o servico de notificacoes
  /// 2. Verifica permissao de notificacoes do sistema
  /// 3. Recupera preferencias salvas (notificacoes habilitadas)
  /// 4. Restaura contador de pomodoros da sessao anterior
  Future<void> initialize() async {
    await _notificationServices.initialize();
    _hasNotificationPermission = await _notificationServices.checkPermission();

    // Recupera preferencias de notificacoes salvas
    _notificationsEnabled = await _storageService.getNotificationsEnabled();
    _notificationServices.setNotificationsEnabled(_notificationsEnabled);

    _isDarkMode = await _storageService.getDarkModeEnabled();

    // Recupera contador de pomodoros da sessao anterior
    final savedPomodoros = await _storageService.getCompletedPomodoros();
    if (savedPomodoros > 0) {
      _state = _state.copyWith(completedPomodoros: savedPomodoros);
    }

    notifyListeners();
  }

  // ============ CONTROLE DE NOTIFICACOES ============

  /// Solicita permissao para enviar notificacoes ao sistema.
  ///
  /// Retorna true se a permissao foi concedida, false caso contrario.
  /// Atualiza [hasNotificationPermission] e [notificationsEnabled] internamente.
  Future<bool> requestNotificationPermission() async {
    _hasNotificationPermission = await _notificationServices
        .requestPermission();
    _notificationsEnabled = _notificationServices.notificationsEnabled;
    notifyListeners();
    return _hasNotificationPermission;
  }

  /// Alterna o estado de ativacao das notificacoes.
  ///
  /// Permite ao usuario desativar notificacoes mesmo tendo permissao do sistema.
  /// Persiste a preferencia usando StorageService.
  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    _notificationServices.setNotificationsEnabled(_notificationsEnabled);
    _storageService.saveNotificationsEnabled(_notificationsEnabled);
    notifyListeners();
  }

  // ============ CONTROLE DO TIMER ============

  /// Inicia o timer Pomodoro.
  ///
  /// Cria um Timer periodico que decrementa o tempo restante a cada segundo.
  /// Ativa o wakelock para manter a tela ligada durante a execucao.
  /// Se o timer ja estiver rodando, a chamada e ignorada.
  void startTimer() {
    // Evita iniciar se ja estiver rodando
    if (_state.isRunning) return;

    // Ativa wakelock para manter tela ligada
    WakelockPlus.enable();

    // Cria um timer que executa a cada 1 segundo.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state.remainingSeconds > 0) {
        // Decrementa o tempo restante
        _state = _state.copyWith(remainingSeconds: _state.remainingSeconds - 1);
        notifyListeners();

        // Verifica se a fase foi completada
        if (_state.remainingSeconds == 0) {
          _onPhaseComplete();
        }
      }
    });

    // Atualiza o estado para "rodando"
    _state = _state.copyWith(isRunning: true, isPaused: false);
    notifyListeners();
  }

  /// Pausa o timer sem resetar o tempo restante.
  ///
  /// O usuario pode retomar de onde parou chamando [startTimer] novamente.
  /// Desativa o wakelock quando pausado para economizar bateria.
  void pauseTimer() {
    // Ignora se o timer nao estiver rodando
    if (!_state.isRunning) return;

    _timer?.cancel();
    WakelockPlus.disable();
    _state = _state.copyWith(isPaused: true, isRunning: false);
    notifyListeners();
  }

  /// Reseta o timer para o inicio da fase atual.
  ///
  /// Nao muda a fase, apenas reinicia o tempo para a duracao total da fase.
  /// Util quando o usuario quer recomecar a fase atual do zero.
  void resetTimer() {
    _timer?.cancel();
    WakelockPlus.disable();

    // Determina a duracao inicial baseada na fase atual
    final duration = PomodoroState.getDurationForPhase(_state.currentPhase);

    _state = _state.copyWith(
      remainingSeconds: duration,
      isRunning: false,
      isPaused: false,
    );
    notifyListeners();
  }

  /// Pula a fase atual e avanca para a proxima.
  ///
  /// Comportamento:
  /// - Se estiver em trabalho: conta como pomodoro completado e vai para pausa
  /// - Se estiver em pausa: vai direto para a proxima fase de trabalho
  void skipPhase() {
    _timer?.cancel();
    _skipToNextPhase();
  }

  // ============ TRANSICAO DE FASES ============

  /// Callback executado quando uma fase e completada (tempo chega a zero).
  ///
  /// Determina a proxima fase baseado nas regras do Pomodoro:
  /// - Apos trabalho: pausa curta (ou longa a cada 4 pomodoros)
  /// - Apos qualquer pausa: volta para trabalho
  ///
  /// Envia notificacao e persiste o progresso.
  void _onPhaseComplete() {
    _timer?.cancel();

    // Guarda referencia da fase que acabou de completar
    final completedPhase = _state.currentPhase;
    PomodoroPhase nextPhase;
    int nextDuration;
    int newCompletedPomodoros = _state.completedPomodoros;

    // Se completou fase de trabalho
    if (completedPhase == PomodoroPhase.work) {
      newCompletedPomodoros++;
      _storageService.saveCompletedPomodoros(newCompletedPomodoros);
      // Verifica se deve fazer pausa longa (a cada 4 pomodoros)
      if (newCompletedPomodoros % PomodoroState.pomodorosBeforeLongBreak == 0) {
        nextPhase = PomodoroPhase.longBreak;
        nextDuration = PomodoroState.longBreakDuration;
      } else {
        // Pausa curta entre pomodoros
        nextPhase = PomodoroPhase.shortBreak;
        nextDuration = PomodoroState.shortBreakDuration;
      }
    } else {
      // Apos qualquer pausa, volta para trabalho
      nextPhase = PomodoroPhase.work;
      nextDuration = PomodoroState.workDuration;
    }

    // Envia notificacao de fase completa
    _notificationServices.showPhaseCompleteNotification(
      completedPhase,
      nextPhase,
    );

    // Atualiza estado para proxima fase
    _state = state.copyWith(
      remainingSeconds: nextDuration,
      currentPhase: nextPhase,
      completedPomodoros: newCompletedPomodoros,
      isRunning: false,
      isPaused: false,
    );
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _storageService.saveDarkModeEnabled(_isDarkMode);
    notifyListeners();
  }

  /// Transiciona para a proxima fase sem esperar o tempo acabar.
  ///
  /// Usado pelo botao de pular fase.
  /// Segue a mesma logica de [_onPhaseComplete], mas nao envia notificacao.
  void _skipToNextPhase() {
    final currentPhase = _state.currentPhase;
    PomodoroPhase nextPhase;
    int nextDuration;
    int newCompletedPomodoros = _state.completedPomodoros;

    // Logica de transicao: mesma de _onPhaseComplete
    if (currentPhase == PomodoroPhase.work) {
      // Apos trabalho, incrementa contador e vai para pausa
      newCompletedPomodoros++;
      if (newCompletedPomodoros % PomodoroState.pomodorosBeforeLongBreak == 0) {
        nextPhase = PomodoroPhase.longBreak;
        nextDuration = PomodoroState.longBreakDuration;
      } else {
        nextPhase = PomodoroPhase.shortBreak;
        nextDuration = PomodoroState.shortBreakDuration;
      }
    } else {
      nextPhase = PomodoroPhase.work;
      nextDuration = PomodoroState.workDuration;
    }

    _state = state.copyWith(
      remainingSeconds: nextDuration,
      currentPhase: nextPhase,
      completedPomodoros: newCompletedPomodoros,
      isRunning: false,
      isPaused: false,
    );
    notifyListeners();
  }

  // ============ RESET COMPLETO ============

  /// Reseta todo o progresso da sessao.
  ///
  /// Volta ao estado inicial:
  /// - Zera contador de pomodoros
  /// - Retorna para fase de trabalho
  /// - Limpa persistencia e notificacoes pendentes
  /// - Desativa wakelock
  void resetAllProgress() {
    _timer?.cancel();
    WakelockPlus.disable();
    _state = PomodoroState.initial();
    _storageService.saveCompletedPomodoros(0);
    _notificationServices.cancelAllNotifications();
    notifyListeners();
  }

  // ============ LIFECYCLE ============

  /// Libera recursos quando o ViewModel e destruido.
  ///
  /// Cancela o timer ativo e desativa o wakelock.
  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }
}
