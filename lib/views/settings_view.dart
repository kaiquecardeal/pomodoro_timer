import 'package:flutter/material.dart';
import 'package:pomodoro_timer/viewmodels/pomodoro_viewmodel.dart';
import 'package:provider/provider.dart';

/// Tela de configurcoes do aplicativo
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Configurações'), centerTitle: true),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionTitle('Tema'),
              _buildDarkModeTile(context, viewModel),
              const SizedBox(height: 24),

              _buildSectionTitle('Notificações'),
              _buildNotificationTile(context, viewModel),
              const SizedBox(height: 24),

              _buildSectionTitle('Sobre o pomodoro'),
              _buildInfoCardExpandable(),

              const SizedBox(height: 24),

              _buildSectionTitle('Estatisticas da Sessao'),
              _buildStatsTile(viewModel),
            ],
          ),
        );
      },
    );
  }

  /// Constroi um titulo de secao estilizado.
  /// [title] - Texto do titulo a ser exibido.
  /// Usado para separar visualmente as secoes da tela de configuracoes.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// Constroi o tile de configuracao de notificacoes.
  /// Exibe um switch para ativar/desativar notificacoes.
  /// O switch fica desabilitado se o usuario nao concedeu permissao.
  Widget _buildNotificationTile(
    BuildContext context,
    PomodoroViewModel viewModel,
  ) {
    return Card(
      child: SwitchListTile(
        title: const Text('Notificações'),
        subtitle: Text(
          viewModel.hasNotificationPermission
              ? (viewModel.notificationsEnabled
                    ? 'Notificações ativadas'
                    : 'Notificacoes desativas')
              : 'Permissao nao concedida.',
        ),
        value: viewModel.notificationsEnabled,
        onChanged: viewModel.hasNotificationPermission
            ? (_) => viewModel.toggleNotifications()
            : null,
        secondary: Icon(
          viewModel.notificationsEnabled
              ? Icons.notifications_active
              : Icons.notifications_off,
          color: viewModel.notificationsEnabled ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  /// Constroi o card informativo sobre a Tecnica Pomodoro.
  /// Exibe uma breve descricao da historia e proposito da tecnica.
  Widget _buildInfoCardExpandable() {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.info_outline, color: Colors.blue),
        title: const Text(
          'Tecnica Pomodoro',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Toque para saber mais'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'A técnica Pomodoro é um método de gerenciamento de tempo desenvolvido por Francesco Cirillo no final dos anos 1980. '
              'Ela utiliza um cronômetro para dividir o trabalho em intervalos, tradicionalmente de 25 minutos de duração, '
              'separados por breves intervalos. Cada intervalo é conhecido como "pomodoro", a palavra italiana para "tomate", '
              'em homenagem ao cronômetro de cozinha em forma de tomate que Cirillo usava como estudante.',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  /// Constroi o tile de estatisticas da sessao atual.
  /// Exibe o numero de pomodoros completados e tempo total de foco.
  /// Calcula o tempo baseado em 25 minutos por pomodoro.
  Widget _buildStatsTile(PomodoroViewModel viewModel) {
    // Obtem quantidade de pomodoros completados
    final pomodoros = viewModel.state.completedPomodoros;
    // Calcula tempo total em minutos (25 min por pomodoro)
    final minutesFocused = pomodoros * 25;
    // Converte para horas e minutos restantes
    final hours = minutesFocused ~/ 60;
    final minutes = minutesFocused % 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatsRow(
              Icons.check_circle,
              'Pomodoros completados',
              '$pomodoros',
              Colors.green,
            ),
            const Divider(),
            _buildStatsRow(
              Icons.timer,
              'Tempo total do foco',
              hours > 0 ? '$hours h $minutes min' : '$minutes min',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  /// Constroi uma linha de estatistica com icone, label e valor.
  /// [icon] - Icone a ser exibido a esquerda.
  /// [label] - Texto descritivo da estatistica.
  /// [value] - Valor da estatistica formatado.
  /// [iconColor] - Cor do icone.
  Widget _buildStatsRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeTile(BuildContext context, PomodoroViewModel viewModel) {
    return Card(
      child: SwitchListTile(
        title: const Text('Modo Escuro'),
        subtitle: Text(viewModel.isDarkMode ? 'Ativado' : 'Desativado'),
        value: viewModel.isDarkMode,
        onChanged: (_) => viewModel.toggleDarkMode(),
        secondary: Icon(
          viewModel.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: viewModel.isDarkMode ? Colors.blueGrey : Colors.amber,
        ),
      ),
    );
  }
}
