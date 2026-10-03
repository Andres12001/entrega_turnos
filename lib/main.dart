import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/demo.dart';
import 'screens/llenado.dart';
import 'state/entrega_controller.dart';
import 'theme/app_theme.dart';

/// Carga datos de ejemplo al iniciar: `flutter run --dart-define=DEMO_SEED=true`.
const bool kSembrarDemo = bool.fromEnvironment('DEMO_SEED');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Se lee el formulario guardado antes de mostrar la app: sin pantallas de
  // carga intermedias ni reconstrucciones innecesarias.
  final controller = EntregaController();
  await controller.inicializar();
  if (kSembrarDemo && controller.entrega.estaVacia) {
    controller.cargar(EntregaDemo.ejemplo());
  }

  runApp(AppEntregaTurno(controller: controller));
}

class AppEntregaTurno extends StatefulWidget {
  const AppEntregaTurno({super.key, required this.controller});

  final EntregaController controller;

  @override
  State<AppEntregaTurno> createState() => _AppEntregaTurnoState();
}

class _AppEntregaTurnoState extends State<AppEntregaTurno>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    // Si la app queda en segundo plano, lo escrito se guarda de inmediato.
    if (estado != AppLifecycleState.resumed) {
      widget.controller.guardarBorrador();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.guardarBorrador();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entrega de Turno',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(),
      scrollBehavior: const ComportamientoScroll(),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: PantallaLlenado(controller: widget.controller),
    );
  }
}
