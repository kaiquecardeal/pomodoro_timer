import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pomodoro_timer/models/pomodoro_state.dart';

/// Servico responsavel por gerenciar notificacoes locais
/// Implementado como Singleton para garantir unica instancia em toda a app
class NotificationServices {
  // ============ IMPLEMENTACAO SINGLETON ============
  /// Instancia unica do servico
  static final NotificationServices _instance =
      NotificationServices._internal();

  /// Factory que retorna sempre a mesma instancia
  factory NotificationServices() => _instance;

  /// Construtor privado para evitar instanciacao externa
  NotificationServices._internal();

  // ============ PROPRIEDADES ============
  /// Plugin de notificacoes locais do Flutter
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Estado da permissao de notificacoes do sistema
  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  /// Controle se o usuario quer receber notificacoes
  /// Mesmo tendo permissao, o usuario pode desativar pelo app
  bool _notificationsEnabled = true;

  /// Retorna true apenas se tiver permissao E estiver habilitado pelo usuario
  bool get notificationsEnabled => _notificationsEnabled && _hasPermission;

  /// ID unico para notificacoes de fase completa
  static const int _phaseCompleteNotificationId = 1;

  /// Inicializa o servico de notificacoes
  /// Deve ser chamado uma vez no inicio do app
  Future<void> initialize() async {
    // Configuracoes especificas para Android
    // Usa o icone do launcher como icone da notificacao
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    // Criar canal de notificacoes Android
    // O canal define como as notificacoes serao exibidas
    const androidChannel = AndroidNotificationChannel(
      'pomodoro_timer_channel', // ID unico do canal
      'Alertas Pomodoro Timer', // Nome visivel ao usuario
      description: 'Notificacoes do timer Pomodoro',
      importance: Importance.high, // Alta prioridade para alertas
    );

    // Registra o canal no sistema Android
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Solicita permissao de notificacao ao sistema
  /// Tenta primeiro via permission_handler, depois via plugin de notificacoes
  Future<bool> requestPermission() async {
    // Primeira tentativa: via permission_handler
    final status = await Permission.notification.request();
    _hasPermission = status.isGranted;

    // Segunda tentativa: via plugin de notificacoes (fallback)
    if (!_hasPermission) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        _hasPermission = granted ?? false;
      }
    }

    // Habilita notificacoes se permissao concedida
    if (_hasPermission) {
      _notificationsEnabled = true;
    }

    return _hasPermission;
  }

  /// Verifica se a permissao de notificacao esta concedida
  /// Nao solicita permissao, apenas verifica o status atual
  Future<bool> checkPermission() async {
    final status = await Permission.notification.status;
    _hasPermission = status.isGranted;
    return _hasPermission;
  }

  /// Define se as notificacoes estao habilitadas pelo usuario
  /// Permite desativar notificacoes mesmo tendo permissao do sistema
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
  }

  /// Exibe notificacao quando uma fase e completada
  /// Mostra mensagem diferente dependendo da fase que terminou
  Future<void> showPhaseCompleteNotification(
    PomodoroPhase completedPhase,
    PomodoroPhase nextPhase,
  ) async {
    // Nao mostra se nao tiver permissao
    if (!_hasPermission) return;

    String title = '';
    String body = '';

    // Define titulo e corpo baseado na fase completada
    switch (completedPhase) {
      case PomodoroPhase.work:
        // Pomodoro de trabalho concluido
        title = 'Pomodoro Completo!';
        body = nextPhase == PomodoroPhase.longBreak
            ? 'Otimo Trabalho! Hora de uma pausa longa de 15 minutos.'
            : 'Bom Trabalho! Hora de uma pausa curta de 5 minutos.';
        break;
      case PomodoroPhase.shortBreak:
        // Pausa curta concluida
        title = 'Pausa Completa!';
        body = 'Hora de voltar ao trabalho!';
        break;
      case PomodoroPhase.longBreak:
        // Pausa longa concluida
        title = 'Pausa Completa!';
        body = 'Hora de voltar ao trabalho!';
        break;
    }

    // Configuracoes da notificacao Android
    const androidDetails = AndroidNotificationDetails(
      'pomodoro_timer_channel', // Mesmo ID do canal criado
      'Alertas Pomodoro Timer',
      channelDescription: 'Notificacoes do timer Pomodoro',
      importance: Importance.high, // Aparece como heads-up
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true, // Vibra ao receber
      playSound: true, // Toca som padrao
    );

    const details = NotificationDetails(android: androidDetails);

    // Exibe a notificacao com ID unico
    // O mesmo ID substitui notificacao anterior (evita acumular)
    await _notifications.show(
      _phaseCompleteNotificationId,
      title,
      body,
      details,
    );
  }

  /// Cancela todas as notificacoes pendentes do app
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
