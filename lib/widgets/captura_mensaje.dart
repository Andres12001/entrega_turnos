import 'package:flutter/material.dart';

import '../models/entrega.dart';

/// Tarjeta formal con el mensaje: fondo blanco, títulos en negrita y sin
/// colores. Es exactamente lo que se guarda como imagen.
class CapturaMensaje extends StatelessWidget {
  const CapturaMensaje({super.key, required this.entrega});

  final Entrega entrega;

  static const Color _tinta = Color(0xFF111827);
  static const Color _etiqueta = Color(0xFF1F2937);
  static const Color _linea = Color(0xFFD9DDE4);

  @override
  Widget build(BuildContext context) {
    final lineas = entrega.contenido();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _linea, width: 1.2),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ENTREGA DE TURNO',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: _tinta,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1.4, color: _tinta),
          const SizedBox(height: 18),
          for (final linea in lineas) _lineaWidget(linea),
        ],
      ),
    );
  }

  Widget _lineaWidget(LineaEntrega linea) {
    if (linea.bloque) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${linea.etiqueta}:',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: _etiqueta,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              linea.valor,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: _tinta,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${linea.etiqueta}: ',
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.45,
                fontWeight: FontWeight.w800,
                color: _etiqueta,
              ),
            ),
            TextSpan(
              text: linea.valor,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: _tinta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
