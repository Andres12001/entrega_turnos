// Punto de entrada solo para desarrollo: abre la pantalla del mensaje con
// datos de ejemplo, sin pasar por el formulario.
//
//   flutter run -t tool/demo_preview.dart            # pantalla del mensaje
//   flutter run -t tool/demo_preview.dart --dart-define=VISTA=2  # solo la tarjeta
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:entrega_turno/models/demo.dart';
import 'package:entrega_turno/screens/llenado.dart';
import 'package:entrega_turno/screens/mensaje.dart';
import 'package:entrega_turno/state/entrega_controller.dart';
import 'package:entrega_turno/theme/app_theme.dart';
import 'package:entrega_turno/widgets/captura_mensaje.dart';

const int kVista = int.fromEnvironment('VISTA');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = EntregaController();
  await controller.inicializar();
  controller.cargar(EntregaDemo.ejemplo());

  final Widget inicio = switch (kVista) {
    2 => Scaffold(
        backgroundColor: AppTheme.fondo,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    width: 400,
                    child: CapturaMensaje(entrega: controller.entrega),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    // Formulario completo a escala, para revisar el diseño entero.
    3 => FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 411,
          height: 1900,
          child: PantallaLlenado(controller: controller),
        ),
      ),
    _ => PantallaMensaje(controller: controller),
  };

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: inicio,
    ),
  );
}
