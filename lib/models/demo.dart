
import 'entrega.dart';

/// Datos de ejemplo usados en demostraciones y capturas.
///
/// Se cargan solo al compilar con `--dart-define=DEMO_SEED=true`.
class EntregaDemo {
  EntregaDemo._();

  static Entrega ejemplo() => Entrega(
        paciente: 'Rosa Martínez',
        fecha: DateTime.now(),
        tensACargo: Entrega.tensPorDefecto,
        proximoControl: 'Dr. Soto miércoles 10:00',
        proximosExamenes: 'Hemograma completo, perfil bioquímico, orina completa',
        medicamentos: 'Ketorolaco 2 ampollas\nInsulina NPH 4 unidades',
        insumos: 'Guantes M 1 caja\nGasas estériles 10 unidades',
        estadoActual: 'paciente en BEG, al examen físico destaca leve edema en '
            'extremidades inferiores, cooperadora, diuresis (+) dep (-). '
            'realiza sus terapias de Kine y TO, durante el día buena ingesta de '
            'líquidos, come su desayuno y almuerzo sin signos de dificultad al '
            'tragar. Entrego a la colega María Fernández',
        salidas: 'Kinesiología 10:30\nTerapia ocupacional 16:00',
      );
}
