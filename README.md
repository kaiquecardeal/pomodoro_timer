# Pomodoro Timer

Um aplicativo de timer Pomodoro desenvolvido em Flutter, seguindo a arquitetura MVVM (Model-View-ViewModel).

## Sobre a Técnica Pomodoro

A Técnica Pomodoro é um método de gerenciamento de tempo desenvolvido por Francesco Cirillo no final dos anos 1980. O método utiliza um timer para dividir o trabalho em intervalos, tradicionalmente de 25 minutos de duração, separados por pequenas pausas.

## Funcionalidades

- **Timer Pomodoro**: Ciclos de 25 minutos de foco intenso
- **Pausa Curta**: 5 minutos de descanso entre pomodoros
- **Pausa Longa**: 15 minutos de descanso após completar 4 pomodoros
- **Notificações**: Alertas locais ao finalizar cada fase
- **Persistência**: Progresso salvo automaticamente entre sessões
- **Wakelock**: Tela permanece ligada durante o timer ativo
- **Interface Adaptativa**: Cores mudam conforme a fase atual
  - Vermelho: Fase de trabalho/foco
  - Verde: Pausa curta
  - Azul: Pausa longa

## Screenshots

| Inicial | Trabalhando | Pausa |
|---------|-------------|-------|
| Tela branca com timer pronto | Fundo vermelho durante foco | Fundo verde/azul durante pausa |

## Arquitetura

O projeto segue o padrão **MVVM (Model-View-ViewModel)**:

```
lib/
├── main.dart                      # Ponto de entrada da aplicação
├── models/
│   └── pomodoro_state.dart        # Estado imutável do timer
├── viewmodels/
│   └── pomodoro_viewmodel.dart    # Lógica de negócio e gerenciamento de estado
├── views/
│   ├── home_view.dart             # Tela principal do timer
│   └── settings_view.dart         # Tela de configurações
├── widgets/
│   ├── control_buttons.dart       # Botões de controle (play/pause/reset/skip)
│   ├── timer_display.dart         # Display circular do timer
│   ├── pomodoro_indicator.dart    # Indicadores de pomodoros completados
│   └── permission_banner.dart     # Banner de permissão de notificações
└── services/
    ├── notification_services.dart # Gerenciamento de notificações locais
    └── storage_service.dart       # Persistência de dados com SharedPreferences
```

## Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento multiplataforma
- **Provider**: Gerenciamento de estado reativo
- **flutter_local_notifications**: Notificações locais no dispositivo
- **permission_handler**: Solicitação de permissões do sistema
- **shared_preferences**: Armazenamento local de dados
- **wakelock_plus**: Controle do estado da tela
- **audioplayers**: Reprodução de sons de alerta

## Requisitos

- Flutter SDK: ^3.10.0
- Dart SDK: ^3.0.0
- Android SDK: API 21+ (Android 5.0 Lollipop ou superior)
- iOS: 12.0 ou superior

## Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/kaiquecardeal/pomodoro_timer.git
   cd pomodoro_timer
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo**
   ```bash
   # Para Android
   flutter run

   # Para iOS
   cd ios && pod install && cd ..
   flutter run
   ```

## Permissões Necessárias

### Android
- `POST_NOTIFICATIONS`: Para enviar notificações de conclusão de fase
- `VIBRATE`: Para feedback de vibração nas notificações
- `WAKE_LOCK`: Para manter o dispositivo acordado durante o timer

### iOS
- Notificações locais

## Como Usar

1. **Iniciar**: Pressione o botão "INICIAR" para começar um pomodoro de 25 minutos
2. **Pausar**: Pressione "PAUSAR" para interromper temporariamente
3. **Retomar**: Pressione "RETOMAR" para continuar de onde parou
4. **Resetar**: Pressione o ícone de reset para reiniciar a fase atual
5. **Pular**: Pressione o ícone de skip para avançar para a próxima fase
6. **Configurações**: Acesse pelo ícone de engrenagem para gerenciar notificações

## Ciclo do Pomodoro

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   🍅 25 min → ☕ 5 min → 🍅 25 min → ☕ 5 min →               │
│   🍅 25 min → ☕ 5 min → 🍅 25 min → 🌴 15 min               │
│                                                             │
│   Após 4 pomodoros, você ganha uma pausa longa!             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Estrutura de Dados

### PomodoroState
```dart
class PomodoroState {
  final int remainingSeconds;       // Segundos restantes
  final PomodoroPhase currentPhase; // Fase atual (work/shortBreak/longBreak)
  final int completedPomodoros;     // Total de pomodoros completados
  final bool isRunning;             // Timer está rodando?
  final bool isPaused;              // Timer está pausado?
}
```

## Autor

Kaique D. Cardeal
