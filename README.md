# 🍅 Pomodoro Timer

<p align="center">
  <img src="assets/images/logo.png" alt="Pomodoro Timer Logo" width="150"/>
</p>

<p align="center">
  <strong>Um aplicativo de timer Pomodoro desenvolvido em Flutter, seguindo a arquitetura MVVM (Model-View-ViewModel).</strong>
</p>

<p align="center">
  <a href="#-sobre-a-técnica-pomodoro">Técnica</a> •
  <a href="#-funcionalidades">Funcionalidades</a> •
  <a href="#-arquitetura">Arquitetura</a> •
  <a href="#-instalação">Instalação</a> •
  <a href="#-documentação-técnica">Documentação</a>
</p>

---

## 📖 Sobre a Técnica Pomodoro

A **Técnica Pomodoro** é um método de gerenciamento de tempo desenvolvido por **Francesco Cirillo** no final dos anos 1980. O método utiliza um timer para dividir o trabalho em intervalos, tradicionalmente de 25 minutos de duração, separados por pequenas pausas.

### Como Funciona

| Fase | Duração | Descrição |
|------|---------|-----------|
| 🔴 **Foco** | 25 min | Período de concentração total em uma tarefa |
| 🟢 **Pausa Curta** | 5 min | Descanso breve entre pomodoros |
| 🔵 **Pausa Longa** | 15 min | Descanso prolongado após 4 pomodoros |

### Ciclo Completo

```
[Foco 25min] → [Pausa 5min] → [Foco 25min] → [Pausa 5min] → 
[Foco 25min] → [Pausa 5min] → [Foco 25min] → [Pausa Longa 15min]
```

---

## ✨ Funcionalidades

### Timer Pomodoro
- ⏱️ **Timer Pomodoro**: Ciclos de 25 minutos de foco intenso
- ☕ **Pausa Curta**: 5 minutos de descanso entre pomodoros
- 🎉 **Pausa Longa**: 15 minutos de descanso após completar 4 pomodoros

### Interface
- 🎨 **Interface Adaptativa**: Cores mudam conforme a fase atual
  - 🔴 Vermelho: Fase de trabalho/foco
  - 🟢 Verde: Pausa curta
  - 🔵 Azul: Pausa longa
- 🌙 **Modo Escuro**: Tema escuro para uso noturno
- ✨ **Animações**: Transições suaves entre fases e estados
- 📊 **Indicador de Progresso**: Círculo animado mostrando progresso da fase

### Controles
- ▶️ **Iniciar/Pausar**: Controle total do timer
- 🔄 **Resetar**: Reinicia a fase atual
- ⏭️ **Pular**: Avança para a próxima fase
- 🗑️ **Resetar Progresso**: Zera todos os pomodoros completados

### Sistema
- 🔔 **Notificações**: Alertas locais ao finalizar cada fase
- 💾 **Persistência**: Progresso salvo automaticamente entre sessões
- 📱 **Wakelock**: Tela permanece ligada durante o timer ativo
- 📊 **Estatísticas**: Visualização de pomodoros completados e tempo de foco

---

## 📸 Screenshots

| Estado Inicial | Fase de Trabalho | Pausa Curta | Pausa Longa |
|----------------|------------------|-------------|-------------|
| Tela branca com timer pronto | Fundo vermelho durante foco | Fundo verde durante descanso | Fundo azul na pausa longa |

---

## 🏗️ Arquitetura

O projeto segue o padrão **MVVM (Model-View-ViewModel)** com separação clara de responsabilidades:

### Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                           VIEW LAYER                            │
│  ┌───────────────┐  ┌────────────────┐  ┌───────────────────┐  │
│  │   HomeView    │  │  SettingsView  │  │     Widgets       │  │
│  │   (UI/Tela)   │  │   (Configs)    │  │  (Componentes)    │  │
│  └───────┬───────┘  └───────┬────────┘  └─────────┬─────────┘  │
└──────────┼──────────────────┼─────────────────────┼────────────┘
           │                  │                     │
           └──────────────────┼─────────────────────┘
                              │ Consumer<ViewModel>
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        VIEWMODEL LAYER                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  PomodoroViewModel                       │   │
│  │  • Gerencia estado do timer                              │   │
│  │  • Lógica de transição de fases                          │   │
│  │  • Coordena serviços (notificações, storage)             │   │
│  │  • Notifica UI sobre mudanças (ChangeNotifier)           │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
           ┌──────────────────┼──────────────────┐
           │                  │                  │
           ▼                  ▼                  ▼
┌──────────────────┐ ┌────────────────┐ ┌────────────────────┐
│   MODEL LAYER    │ │ SERVICE LAYER  │ │   SERVICE LAYER    │
│  ┌────────────┐  │ │ ┌────────────┐ │ │ ┌────────────────┐ │
│  │ Pomodoro   │  │ │ │Notification│ │ │ │ StorageService │ │
│  │   State    │  │ │ │ Services   │ │ │ │ (Persistência) │ │
│  │ (Imutável) │  │ │ │ (Alertas)  │ │ │ │                │ │
│  └────────────┘  │ │ └────────────┘ │ │ └────────────────┘ │
└──────────────────┘ └────────────────┘ └────────────────────┘
```

### Estrutura de Diretórios

```
lib/
├── main.dart                       # 🚀 Ponto de entrada da aplicação
├── config/
│   ├── app_config.dart             # ⚙️ Configurações globais (durações, cores)
│   └── strings.dart                # 📝 Strings da aplicação
├── models/
│   └── pomodoro_state.dart         # 📦 Estado imutável do timer
├── viewmodels/
│   └── pomodoro_viewmodel.dart     # 🧠 Lógica de negócio e gerenciamento de estado
├── views/
│   ├── home_view.dart              # 🏠 Tela principal do timer
│   └── settings_view.dart          # ⚙️ Tela de configurações
├── widgets/
│   ├── control_buttons.dart        # 🎮 Botões de controle (play/pause/reset/skip)
│   ├── timer_display.dart          # ⏱️ Display circular do timer
│   └── pomodoro_indicator.dart     # 🔘 Indicadores de pomodoros completados
└── services/
    ├── notification_services.dart  # 🔔 Gerenciamento de notificações locais
    └── storage_service.dart        # 💾 Persistência de dados com SharedPreferences
```

---

## 🛠️ Tecnologias Utilizadas

### Framework & Linguagem
| Tecnologia | Versão | Descrição |
|------------|--------|-----------|
| Flutter | ^3.10.4 | Framework de desenvolvimento multiplataforma |
| Dart | ^3.0.0 | Linguagem de programação |

### Dependências Principais
| Pacote | Versão | Descrição |
|--------|--------|-----------|
| `provider` | ^6.1.2 | Gerenciamento de estado reativo (MVVM) |
| `flutter_local_notifications` | ^18.0.1 | Notificações locais no dispositivo |
| `permission_handler` | ^11.3.1 | Solicitação de permissões do sistema |
| `shared_preferences` | ^2.5.4 | Armazenamento local de dados |
| `wakelock_plus` | ^1.4.0 | Controle do estado da tela |
| `audioplayers` | ^6.5.1 | Reprodução de sons de alerta |
| `flutter_foreground_task` | ^8.12.0 | Execução em foreground |

---

## 📋 Requisitos

### Sistema
- **Flutter SDK**: ^3.10.4
- **Dart SDK**: ^3.0.0

### Plataformas Suportadas
| Plataforma | Versão Mínima |
|------------|---------------|
| Android | API 21+ (Android 5.0 Lollipop) |
| iOS | 12.0+ |
| Linux | Suportado |
| macOS | Suportado |
| Windows | Suportado |
| Web | Suportado |

---

## 🚀 Instalação

### 1. Clone o repositório
```bash
git clone https://github.com/kaiquecardeal/pomodoro_timer.git
cd pomodoro_timer
```

### 2. Instale as dependências
```bash
flutter pub get
```

### 3. Execute o aplicativo

#### Android
```bash
flutter run
```

#### iOS
```bash
cd ios && pod install && cd ..
flutter run
```

#### Linux
```bash
flutter run -d linux
```

#### Web
```bash
flutter run -d chrome
```

---

## 🔐 Permissões Necessárias

### Android
| Permissão | Descrição |
|-----------|-----------|
| `POST_NOTIFICATIONS` | Enviar notificações de conclusão de fase |
| `VIBRATE` | Feedback de vibração nas notificações |
| `WAKE_LOCK` | Manter o dispositivo acordado durante o timer |

### iOS
| Permissão | Descrição |
|-----------|-----------|
| Notificações Locais | Alertas ao finalizar fases |

---

## 📱 Como Usar

### Controles Básicos

1. **▶️ Iniciar**: Pressione o botão "INICIAR" para começar um pomodoro de 25 minutos
2. **⏸️ Pausar**: Pressione "PAUSAR" para interromper temporariamente
3. **▶️ Retomar**: Pressione "RETOMAR" para continuar de onde parou
4. **🔄 Resetar**: Pressione o ícone de reset para reiniciar a fase atual
5. **⏭️ Pular**: Pressione o ícone de skip para avançar para a próxima fase
6. **⚙️ Configurações**: Acesse pelo ícone de engrenagem para gerenciar notificações e tema

### Ciclo do Pomodoro

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

---

## 📊 Estrutura de Dados

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

---

## 📚 Documentação Técnica

Para documentação mais detalhada, consulte:

| Documento | Descrição |
|-----------|-----------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Arquitetura MVVM e estrutura do projeto |
| [API_REFERENCE.md](docs/API_REFERENCE.md) | Referência completa das classes e métodos |
| [CONTRIBUTING.md](docs/CONTRIBUTING.md) | Guia para contribuidores |
| [GLOSSARY.md](docs/GLOSSARY.md) | Glossário de termos e conceitos |
| [CHANGELOG.md](CHANGELOG.md) | Histórico de versões e mudanças |

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor, leia o [Guia de Contribuição](docs/CONTRIBUTING.md) antes de enviar PRs.

```bash
# Fork e clone o repositório
git clone https://github.com/SEU_USUARIO/pomodoro_timer.git

# Crie uma branch para sua feature
git checkout -b feature/minha-feature

# Faça commit das mudanças
git commit -m "feat: adiciona minha feature"

# Push para o fork
git push origin feature/minha-feature

# Abra um Pull Request
```

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

**Kaique D. Cardeal**

- GitHub: [@kaiquecardeal](https://github.com/kaiquecardeal)

---

## 🙏 Agradecimentos

- Francesco Cirillo pela criação da Técnica Pomodoro
- Comunidade Flutter pelo framework incrível
- Todos os contribuidores deste projeto

---


