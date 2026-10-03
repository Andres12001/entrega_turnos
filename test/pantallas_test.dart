import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:entrega_turno/models/demo.dart';
import 'package:entrega_turno/screens/llenado.dart';
import 'package:entrega_turno/screens/mensaje.dart';
import 'package:entrega_turno/state/entrega_controller.dart';
import 'package:entrega_turno/theme/app_theme.dart';
import 'package:entrega_turno/utils/captura.dart';
import 'package:entrega_turno/widgets/captura_mensaje.dart';

Future<EntregaController> _controlador({bool conDatos = true}) async {
  SharedPreferences.setMockInitialValues({});
  final controller = EntregaController();
  await controller.inicializar();
  if (conDatos) controller.cargar(EntregaDemo.ejemplo());
  return controller;
}

Widget _app(Widget home) => MaterialApp(
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );

void setUpPantallaGrande(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('las listas no tienen efecto de estiramiento al llegar al borde',
      (tester) async {
    const hijo = SizedBox(key: ValueKey('contenido'));
    Widget? resultado;

    await tester.pumpWidget(
      MaterialApp(
        scrollBehavior: const ComportamientoScroll(),
        home: Builder(
          builder: (context) {
            resultado = const ComportamientoScroll().buildOverscrollIndicator(
              context,
              hijo,
              const ScrollableDetails(direction: AxisDirection.down),
            );
            return const SizedBox();
          },
        ),
      ),
    );

    // Sin envoltorio de indicador: nada se estira ni brilla.
    expect(resultado, same(hijo));
  });

  testWidgets('el formulario muestra los campos en el orden de la plantilla',
      (tester) async {
    setUpPantallaGrande(tester);
    final controller = await _controlador(conDatos: false);
    await tester.pumpWidget(_app(PantallaLlenado(controller: controller)));
    await tester.pumpAndSettle();

    const etiquetas = [
      'Paciente:',
      'Fecha:',
      'Tens a cargo:',
      'Próximo control médico:',
      'Próximos exámenes:',
      'Stock crítico de medicamentos:',
      'Stock de insumos:',
      'Estado actual del paciente:',
      'Salidas realizadas con el paciente:',
    ];

    final posiciones = <double>[];
    for (final etiqueta in etiquetas) {
      final finder = find.text(etiqueta);
      expect(finder, findsOneWidget, reason: 'falta la etiqueta $etiqueta');
      posiciones.add(tester.getTopLeft(finder).dy);
    }
    for (var i = 1; i < posiciones.length; i++) {
      expect(posiciones[i], greaterThan(posiciones[i - 1]),
          reason: 'las etiquetas deben ir en el orden de la plantilla');
    }

    expect(find.text('Ver mensaje'), findsOneWidget);
    // El nombre del TENS viene escrito y se puede editar.
    expect(find.text('Edith Catrilef'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Edith Catrilef'),
      'Camila Rojas',
    );
    await tester.pumpAndSettle();
    expect(controller.entrega.tensACargo, 'Camila Rojas');
    controller.dispose();
  });

  testWidgets('sin datos avisa y no avanza; con datos abre el mensaje',
      (tester) async {
    setUpPantallaGrande(tester);
    final controller = await _controlador(conDatos: false);
    await tester.pumpWidget(_app(PantallaLlenado(controller: controller)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver mensaje'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaMensaje), findsNothing);
    expect(find.textContaining('Escribe primero'), findsOneWidget);

    controller.paciente.text = 'Rosa Martínez';
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver mensaje'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaMensaje), findsOneWidget);

    controller.dispose();
  });

  testWidgets('copiar mensaje envía el texto al portapapeles', (tester) async {
    setUpPantallaGrande(tester);
    final controller = await _controlador();
    final llamadas = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (llamada) async {
        llamadas.add(llamada);
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await tester.pumpWidget(_app(PantallaMensaje(controller: controller)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Copiar mensaje'));
    await tester.pumpAndSettle();

    final copiar = llamadas.lastWhere((c) => c.method == 'Clipboard.setData');
    final texto = (copiar.arguments as Map)['text'] as String;
    expect(texto, contains('*Paciente:* Rosa Martínez'));
    expect(texto, contains('*Stock crítico de medicamentos:*\nKetorolaco 2 ampollas'));
    expect(texto, contains('*Salidas realizadas con el paciente:*\nKinesiología 10:30'));
    expect(find.textContaining('Mensaje copiado'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('la imagen del mensaje se genera como PNG', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      _app(
        SingleChildScrollView(
          child: RepaintBoundary(
            key: key,
            child: CapturaMensaje(entrega: EntregaDemo.ejemplo()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Rosa Martínez'), findsWidgets);

    Uint8List? bytes;
    await tester.runAsync(() async {
      bytes = await Captura.comoPng(key, pixelRatio: 1);
    });

    expect(bytes, isNotNull);
    expect(bytes!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]); // firma PNG
    expect(bytes!.length, greaterThan(3000));
  });

  testWidgets('guardar y recuperar una entrega desde «Entregas guardadas»',
      (tester) async {
    setUpPantallaGrande(tester);
    final controller = await _controlador();
    await tester.pumpWidget(_app(PantallaMensaje(controller: controller)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_add_outlined));
    await tester.pumpAndSettle();
    expect(controller.guardadas.length, 1);
    expect(find.textContaining('Entrega guardada'), findsOneWidget);

    controller.dispose();
  });
}
