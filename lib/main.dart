import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro_timer/viewmodels/pomodoro_viewmodel.dart';
import 'package:pomodoro_timer/views/home_view.dart';
import 'package:provider/provider.dart';

/// Ponto de entrada principal da aplicacao Pomodoro Timer
/// Configura orientacao da tela e inicializa o app
void main() {
  // Garante que os bindings do Flutter estejam inicializados
  // Necessario para usar plugins antes do runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Define a orientacao da aplicacao para retrato apenas
  // Bloqueia rotacao para landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const PomodoroApp());
}

/// Widget raiz da aplicacao Pomodoro Timer
/// Configura o Provider (MVVM) e o tema do app
class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider injeta o ViewModel na arvore de widgets
    // Permite que qualquer widget filho acesse o estado do Pomodoro
    return ChangeNotifierProvider(
      create: (_) => PomodoroViewModel(),
      child: MaterialApp(
        title: 'Pomodoro Timer',
        debugShowCheckedModeBanner: false, // Remove o banner de debug
        theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
        home: const HomeView(),
      ),
    );
  }
}
