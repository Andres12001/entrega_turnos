import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tarjeta blanca que agrupa el formulario.
class Tarjeta extends StatelessWidget {
  const Tarjeta({super.key, required this.hijos, this.padding});

  final List<Widget> hijos;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: AppTheme.tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: hijos,
      ),
    );
  }
}

/// Un campo del formulario: etiqueta grande siempre visible + casilla.
class Campo extends StatelessWidget {
  const Campo({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.pista,
    this.ayuda,
    this.lineas = 1,
    this.teclado,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final String? pista;
  final String? ayuda;
  final int lineas;
  final TextInputType? teclado;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Etiqueta(texto: etiqueta),
        const SizedBox(height: 8),
        TextField(
          controller: controlador,
          // Los campos largos crecen solos: nada queda escondido.
          maxLines: lineas == 1 ? 1 : null,
          minLines: lineas > 1 ? lineas : 1,
          keyboardType: teclado,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 16, height: 1.35, color: AppTheme.texto),
          decoration: InputDecoration(hintText: pista),
          // Al tocar fuera se cierra el teclado.
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        if (ayuda != null) ...[
          const SizedBox(height: 6),
          Text(
            ayuda!,
            style: const TextStyle(fontSize: 13, color: AppTheme.suave, height: 1.3),
          ),
        ],
      ],
    );
  }
}

/// Etiqueta del formulario, con el mismo texto de la plantilla.
class Etiqueta extends StatelessWidget {
  const Etiqueta({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.etiqueta,
      ),
    );
  }
}

/// Campo de fecha: se ve igual que los demás, pero abre el calendario.
class CampoFecha extends StatelessWidget {
  const CampoFecha({super.key, required this.fecha, required this.onTap});

  final DateTime fecha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Etiqueta(texto: 'Fecha:'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E5EF), width: 1.2),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _texto(fecha),
                      style: const TextStyle(fontSize: 16, color: AppTheme.texto),
                    ),
                  ),
                  const Icon(Icons.calendar_month_outlined,
                      size: 22, color: AppTheme.primario),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Toca la casilla para elegir el día',
          style: TextStyle(fontSize: 13, color: AppTheme.suave),
        ),
      ],
    );
  }

  static String _texto(DateTime f) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${f.day} de ${meses[f.month - 1]} de ${f.year}';
  }
}
