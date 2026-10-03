/// Datos de la entrega de turno: un campo por cada línea de la plantilla.
///
/// Paciente / Fecha / Tens a cargo / Próximo control médico / Próximos exámenes /
/// Stock crítico de medicamentos / Stock de insumos / Estado actual del paciente /
/// Salidas realizadas con el paciente.
class Entrega {
  Entrega({
    this.paciente = '',
    DateTime? fecha,
    this.tensACargo = tensPorDefecto,
    this.proximoControl = '',
    this.proximosExamenes = '',
    this.medicamentos = '',
    this.insumos = '',
    this.estadoActual = '',
    this.salidas = '',
  }) : fecha = fecha ?? DateTime.now();

  /// Nombre que viene escrito por defecto en «Tens a cargo» (se puede cambiar).
  static const String tensPorDefecto = 'Edith Catrilef';

  String paciente;
  DateTime fecha;
  String tensACargo;
  String proximoControl;
  String proximosExamenes;
  String medicamentos;
  String insumos;
  String estadoActual;
  String salidas;

  static const List<String> _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  static const List<String> _dias = [
    'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
  ];

  static String dosDigitos(int n) => n.toString().padLeft(2, '0');

  /// 03/10/2026
  String get fechaCorta =>
      '${dosDigitos(fecha.day)}/${dosDigitos(fecha.month)}/${fecha.year}';

  /// Sábado 03 de octubre de 2026
  String get fechaLarga {
    final dia = _dias[(fecha.weekday - 1) % 7];
    final mes = _meses[(fecha.month - 1) % 12];
    return '${dia[0].toUpperCase()}${dia.substring(1)} '
        '${dosDigitos(fecha.day)} de $mes de ${fecha.year}';
  }

  /// ¿El formulario está sin datos? (la fecha y el nombre por defecto del TENS
  /// no cuentan).
  bool get estaVacia =>
      paciente.trim().isEmpty &&
      proximoControl.trim().isEmpty &&
      proximosExamenes.trim().isEmpty &&
      medicamentos.trim().isEmpty &&
      insumos.trim().isEmpty &&
      estadoActual.trim().isEmpty &&
      salidas.trim().isEmpty;

  /// Campos de la plantilla que todavía están vacíos.
  List<String> get camposVacios => [
        if (paciente.trim().isEmpty) 'Paciente',
        if (tensACargo.trim().isEmpty) 'Tens a cargo',
        if (proximoControl.trim().isEmpty) 'Próximo control médico',
        if (proximosExamenes.trim().isEmpty) 'Próximos exámenes',
        if (medicamentos.trim().isEmpty) 'Stock crítico de medicamentos',
        if (insumos.trim().isEmpty) 'Stock de insumos',
        if (estadoActual.trim().isEmpty) 'Estado actual del paciente',
        if (salidas.trim().isEmpty) 'Salidas realizadas con el paciente',
      ];

  Entrega copy() => Entrega(
        paciente: paciente,
        fecha: fecha,
        tensACargo: tensACargo,
        proximoControl: proximoControl,
        proximosExamenes: proximosExamenes,
        medicamentos: medicamentos,
        insumos: insumos,
        estadoActual: estadoActual,
        salidas: salidas,
      );

  Map<String, dynamic> toJson() => {
        'paciente': paciente,
        'fecha': fecha.toIso8601String(),
        'tensACargo': tensACargo,
        'proximoControl': proximoControl,
        'proximosExamenes': proximosExamenes,
        'medicamentos': medicamentos,
        'insumos': insumos,
        'estadoActual': estadoActual,
        'salidas': salidas,
      };

  factory Entrega.fromJson(Map<String, dynamic> json) => Entrega(
        paciente: json['paciente'] as String? ?? '',
        fecha: DateTime.tryParse(json['fecha'] as String? ?? '') ?? DateTime.now(),
        tensACargo: json.containsKey('tensACargo')
            ? (json['tensACargo'] as String? ?? '')
            : tensPorDefecto,
        proximoControl: json['proximoControl'] as String? ?? '',
        proximosExamenes: json['proximosExamenes'] as String? ?? '',
        medicamentos: json['medicamentos'] as String? ?? '',
        insumos: json['insumos'] as String? ?? '',
        estadoActual: json['estadoActual'] as String? ?? '',
        salidas: json['salidas'] as String? ?? '',
      );

  // ---------------------------------------------------------------------------
  // Mensaje final
  // ---------------------------------------------------------------------------

  /// Líneas del mensaje, en el orden exacto de la plantilla.
  ///
  /// [bloque] indica que la etiqueta va en una línea y el contenido debajo
  /// (para textos largos como el estado o los stocks).
  List<LineaEntrega> contenido() => [
        if (paciente.trim().isNotEmpty) LineaEntrega('Paciente', paciente.trim()),
        LineaEntrega('Fecha', fechaCorta),
        if (tensACargo.trim().isNotEmpty) LineaEntrega('Tens a cargo', tensACargo.trim()),
        if (proximoControl.trim().isNotEmpty)
          LineaEntrega('Próximo control médico', proximoControl.trim()),
        if (proximosExamenes.trim().isNotEmpty)
          LineaEntrega('Próximos exámenes', proximosExamenes.trim()),
        if (medicamentos.trim().isNotEmpty)
          LineaEntrega('Stock crítico de medicamentos', medicamentos.trim(), bloque: true),
        if (insumos.trim().isNotEmpty)
          LineaEntrega('Stock de insumos', insumos.trim(), bloque: true),
        if (estadoActual.trim().isNotEmpty)
          LineaEntrega('Estado actual del paciente', estadoActual.trim(), bloque: true),
        if (salidas.trim().isNotEmpty)
          LineaEntrega('Salidas realizadas con el paciente', salidas.trim(), bloque: true),
      ];

  /// Mensaje para pegar en WhatsApp (con negritas de WhatsApp).
  String formatear() {
    final b = StringBuffer('*ENTREGA DE TURNO*\n\n');
    for (final linea in contenido()) {
      if (linea.bloque) {
        b
          ..writeln()
          ..writeln('*${linea.etiqueta}:*')
          ..writeln(linea.valor);
      } else {
        b.writeln('*${linea.etiqueta}:* ${linea.valor}');
      }
    }
    return b.toString().trimRight();
  }
}

/// Una línea del mensaje: etiqueta de la plantilla + contenido.
class LineaEntrega {
  const LineaEntrega(this.etiqueta, this.valor, {this.bloque = false});

  final String etiqueta;
  final String valor;
  final bool bloque;
}
