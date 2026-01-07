import 'package:shared_preferences/shared_preferences.dart';

/// Servico responsavel pela persistencia de dados simples usando SharedPreferences.
///
/// Este servico gerencia o armazenamento local de:
/// - Numero de pomodoros completados na sessao
/// - Preferencias de notificacoes do usuario
///
/// Utiliza SharedPreferences para armazenamento key-value persistente,
/// garantindo que os dados sejam mantidos entre sessoes do aplicativo.
class StorageService {
  // ============ CHAVES DE ARMAZENAMENTO ============

  /// Chave para armazenar o contador de pomodoros completados
  static const String _completedPomodorosKey = 'completed_pomodoros';

  /// Chave para armazenar a preferencia de notificacoes
  static const String _notificationsEnabledKey = 'notifications_enabled';

  static const String _darkModeEnabledKey = 'dark_mode_enabled';

  // ============ METODOS DE POMODOROS ============

  /// Salva o numero de pomodoros completados na sessao atual.
  ///
  /// [count] - Quantidade total de pomodoros completados.
  /// Exemplo: Apos completar um pomodoro, incrementa e salva o novo valor.
  Future<void> saveCompletedPomodoros(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_completedPomodorosKey, count);
  }

  /// Recupera o numero de pomodoros completados salvos anteriormente.
  ///
  /// Retorna 0 caso nao exista valor salvo (primeira execucao).
  /// Usado na inicializacao do app para restaurar o progresso.
  Future<int> getCompletedPomodoros() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_completedPomodorosKey) ?? 0;
  }

  // ============ METODOS DE NOTIFICACOES ============

  /// Salva a preferencia de notificacoes do usuario.
  ///
  /// [isEnabled] - true para ativar notificacoes, false para desativar.
  /// Permite ao usuario controlar notificacoes independente da permissao do sistema.
  Future<void> saveNotificationsEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, isEnabled);
  }

  /// Recupera a preferencia de notificacoes salva.
  ///
  /// Retorna true por padrao (notificacoes ativadas) caso nao exista valor salvo.
  /// Usado na inicializacao para restaurar a preferencia do usuario.
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> saveDarkModeEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeEnabledKey, isEnabled);
  }

  Future<bool> getDarkModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeEnabledKey) ?? false;
  }
}
