import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/entrega_controller.dart';
import '../theme/app_theme.dart';
import '../utils/captura.dart';
import '../widgets/captura_mensaje.dart';

/// Pantalla final: el mensaje listo para copiar o para compartir como imagen.
class PantallaMensaje extends StatefulWidget {
  const PantallaMensaje({super.key, required this.controller});

  final EntregaController controller;

  @override
  State<PantallaMensaje> createState() => _PantallaMensajeState();
}

class _PantallaMensajeState extends State<PantallaMensaje> {
  final GlobalKey _clave = GlobalKey();
  bool _ocupado = false;

  String get _mensaje => widget.controller.entrega.formatear();

  void _aviso(String texto, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: error ? const Color(0xFFB3261E) : null,
          duration: Duration(seconds: error ? 4 : 2),
        ),
      );
  }

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: _mensaje));
    await HapticFeedback.mediumImpact();
    _aviso('Mensaje copiado. Pégalo en el grupo de la entrega de turno.');
  }

  Future<void> _compartirImagen() async {
    if (_ocupado) return;
    setState(() => _ocupado = true);
    try {
      final bytes = await Captura.comoPng(_clave);
      if (bytes == null) {
        _aviso('No se pudo generar la imagen.', error: true);
        return;
      }
      final ruta = await Captura.guardarImagen(bytes);
      await Captura.compartirArchivo(ruta, texto: 'Entrega de turno');
      _aviso('Imagen lista en $ruta');
    } catch (e) {
      _aviso('No se pudo compartir la imagen: $e', error: true);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _guardar() async {
    await widget.controller.guardarEnLista();
    _aviso('Entrega guardada en «Entregas guardadas».');
  }

  @override
  Widget build(BuildContext context) {
    final vacios = widget.controller.entrega.camposVacios;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu mensaje'),
        actions: [
          IconButton(
            tooltip: 'Guardar para después',
            onPressed: _guardar,
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          RepaintBoundary(
            key: _clave,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(14),
              child: CapturaMensaje(entrega: widget.controller.entrega),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.content_copy_outlined, size: 20, color: AppTheme.primario),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Toca «Copiar mensaje» y pégalo en el grupo. También puedes '
                    'enviarlo como imagen.',
                    style: TextStyle(fontSize: 13.5, height: 1.35, color: AppTheme.etiqueta),
                  ),
                ),
              ],
            ),
          ),
          if (vacios.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 20, color: Color(0xFF9A6700)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Quedó sin escribir: ${vacios.join(', ')}.',
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: Color(0xFF7A5200),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: _copiar,
                  icon: const Icon(Icons.copy_all_outlined, size: 22),
                  label: const Text('Copiar mensaje'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _ocupado ? null : _compartirImagen,
                  icon: const Icon(Icons.image_outlined, size: 22),
                  label: Text(_ocupado ? 'Preparando…' : 'Compartir como imagen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
