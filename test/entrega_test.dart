import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:entrega_turno/models/demo.dart';
import 'package:entrega_turno/models/entrega.dart';
import 'package:entrega_turno/state/entrega_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('el mensaje respeta el orden y los nombres de la plantilla', () {
    final entrega = Entrega(
      paciente: 'Rosa Martínez',
      fecha: DateTime(2026, 10, 3),
      tensACargo: 'Camila Rojas',
      proximoControl: 'Dr. Soto miércoles 10:00',
      proximosExamenes: 'Hemograma completo',
      medicamentos: 'Ketorolaco 2 ampollas',
      estadoActual: 'paciente en BEG, cooperadora',
      salidas: 'Kinesiología 10:30',
    );

    final m = entrega.formatear();

    expect(m, startsWith('*ENTREGA DE TURNO*'));
    expect(m, contains('*Paciente:* Rosa Martínez'));
    expect(m, contains('*Fecha:* 03/10/2026'));
    expect(m, contains('*Tens a cargo:* Camila Rojas'));
    expect(m, contains('*Próximo control médico:* Dr. Soto miércoles 10:00'));
    expect(m, contains('*Próximos exámenes:* Hemograma completo'));
    expect(m, contains('*Stock crítico de medicamentos:*\nKetorolaco 2 ampollas'));
    expect(m, contains('*Estado actual del paciente:*\npaciente en BEG, cooperadora'));
    expect(m, contains('*Salidas realizadas con el paciente:*\nKinesiología 10:30'));

    // Mismo orden que la plantilla.
    final orden = [
      '*Paciente:*',
      '*Fecha:*',
      '*Tens a cargo:*',
      '*Próximo control médico:*',
      '*Próximos exámenes:*',
      '*Stock crítico de medicamentos:*',
      '*Estado actual del paciente:*',
      '*Salidas realizadas con el paciente:*',
    ].map(m.indexOf).toList();
    for (var i = 1; i < orden.length; i++) {
      expect(orden[i], greaterThan(orden[i - 1]));
    }
  });

  test('los campos vacíos no aparecen en el mensaje', () {
    final entrega = Entrega(paciente: 'Rosa Martínez', fecha: DateTime(2026, 1, 5));
    final m = entrega.formatear();

    expect(m, contains('*Paciente:* Rosa Martínez'));
    // El TENS por defecto sí aparece; el resto de lo vacío no.
    expect(m, contains('*Tens a cargo:* Edith Catrilef'));
    expect(m, isNot(contains('Stock de insumos')));
    expect(m, isNot(contains('Estado actual')));
    expect(m, isNot(contains('Salidas realizadas')));
  });

  test('camposVacios lista lo que falta', () {
    final entrega = Entrega(paciente: 'Rosa Martínez');
    expect(entrega.camposVacios.first, 'Próximo control médico');
    expect(entrega.camposVacios.contains('Paciente'), isFalse);
    expect(entrega.camposVacios.contains('Tens a cargo'), isFalse);
  });

  test('Tens a cargo viene con el nombre por defecto y se puede cambiar', () {
    final entrega = Entrega();
    expect(entrega.tensACargo, 'Edith Catrilef');
    // El formulario recién abierto sigue considerándose vacío aunque ya traiga
    // el nombre por defecto.
    expect(entrega.estaVacia, isTrue);

    entrega.tensACargo = 'Otro nombre';
    expect(entrega.formatear(), contains('*Tens a cargo:* Otro nombre'));

    // Si se borra el nombre, se avisa que falta.
    entrega.tensACargo = '';
    expect(entrega.camposVacios.contains('Tens a cargo'), isTrue);
  });

  test('el borrador se guarda y se recupera con todos los campos', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = EntregaController();
    await controller.inicializar();
    controller.cargar(EntregaDemo.ejemplo());
    controller.paciente.text = 'Paciente de prueba';
    await controller.guardarBorrador();

    final otro = EntregaController();
    await otro.inicializar();

    expect(otro.entrega.paciente, 'Paciente de prueba');
    expect(otro.entrega.medicamentos, contains('Ketorolaco'));
    expect(otro.entrega.salidas, contains('Kinesiología'));
    expect(otro.paciente.text, 'Paciente de prueba');

    otro.dispose();
    controller.dispose();
  });

  test('agregar frases arma el texto del estado con puntos', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = EntregaController();
    await controller.inicializar();
    controller.limpiar();

    controller.agregarFrase('paciente en BEG');
    controller.agregarFrase('diuresis (+)');
    controller.agregarFrase('dep (-)');

    expect(controller.estadoActual.text, 'paciente en BEG. diuresis (+). dep (-)');
    controller.dispose();
  });

  test('las entregas guardadas se pueden volver a usar', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = EntregaController();
    await controller.inicializar();
    controller.cargar(EntregaDemo.ejemplo());
    await controller.guardarEnLista();
    expect(controller.guardadas.length, 1);
    expect(controller.guardadas.first.titulo, 'Rosa Martínez');

    controller.limpiar();
    expect(controller.entrega.paciente, '');

    controller.cargar(controller.guardadas.first.entrega);
    expect(controller.paciente.text, 'Rosa Martínez');

    // Persisten entre sesiones.
    final otra = EntregaController();
    await otra.inicializar();
    expect(otra.guardadas.length, 1);
    expect(otra.guardadas.first.titulo, 'Rosa Martínez');

    otra.dispose();
    controller.dispose();
  });
}
