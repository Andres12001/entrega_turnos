import 'package:flutter/material.dart';

import '../state/entrega_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/campo.dart';
import 'guardadas.dart';
import 'mensaje.dart';

/// Formulario único: se completa de arriba hacia abajo, en el orden de la
/// plantilla de entrega de turno.
class PantallaLlenado extends StatelessWidget {
  const PantallaLlenado({super.key, required this.controller});

  final EntregaController controller;

  static const List<String> _frases = [
    'paciente en BEG',
    'al examen físico destaca:',
    'cooperadora',
    'diuresis (+)',
    'dep (-)',
    'realiza sus terapias de Kine y TO',
    'durante el día buena ingesta de líquidos',
    'come su desayuno y almuerzo sin signos de dificultad al tragar',
    'se mantiene afebril',
    'sin signos de dificultad respiratoria',
  ];

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrega de turno'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            icon: const Icon(Icons.more_vert),
            onSelected: (valor) {
              if (valor == 'guardadas') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PantallaGuardadas(controller: c),
                  ),
                );
              } else if (valor == 'limpiar') {
                _confirmarLimpiar(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'guardadas',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.bookmark_border),
                  title: Text('Entregas guardadas'),
                ),
              ),
              PopupMenuItem(
                value: 'limpiar',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline),
                  title: Text('Borrar y empezar de nuevo'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _Indicacion(),
          const SizedBox(height: 16),
          Tarjeta(
            hijos: [
              Campo(
                etiqueta: 'Paciente:',
                controlador: c.paciente,
                pista: 'Nombre y apellidos',
              ),
              const SizedBox(height: 22),
              // Solo este campo se redibuja cuando cambia la fecha.
              ListenableBuilder(
                listenable: c,
                builder: (contexto, _) => CampoFecha(
                  fecha: c.entrega.fecha,
                  onTap: () => _elegirFecha(contexto),
                ),
              ),
              const SizedBox(height: 22),
              Campo(
                etiqueta: 'Tens a cargo:',
                controlador: c.tensACargo,
                pista: 'Nombre del TENS del turno',
              ),
              const SizedBox(height: 22),
              Campo(
                etiqueta: 'Próximo control médico:',
                controlador: c.proximoControl,
                pista: 'Ej: Dr. Soto miércoles 10:00',
              ),
              const SizedBox(height: 22),
              Campo(
                etiqueta: 'Próximos exámenes:',
                controlador: c.proximosExamenes,
                pista: 'Ej: hemograma, perfil bioquímico',
                lineas: 2,
              ),
              const SizedBox(height: 22),
              Campo(
                etiqueta: 'Stock crítico de medicamentos:',
                controlador: c.medicamentos,
                pista: 'Ej: Ketorolaco 2 ampollas',
                ayuda: 'Escribe uno por línea.',
                lineas: 3,
              ),
              const SizedBox(height: 22),
              Campo(
                etiqueta: 'Stock de insumos:',
                controlador: c.insumos,
                pista: 'Ej: Guantes M 1 caja',
                ayuda: 'Escribe uno por línea.',
                lineas: 3,
              ),
              const SizedBox(height: 22),
              Campo(
                etiqueta: 'Estado actual del paciente:',
                controlador: c.estadoActual,
                pista: 'paciente en beg, al examen físico destaca…, cooperadora, '
                    'diuresis (+) dep (-), realiza sus terapias de Kine y TO…',
                lineas: 6,
              ),
              const SizedBox(height: 6),
              _AyudaEstado(onInsertar: c.agregarFrase),
              const SizedBox(height: 14),
              Campo(
                etiqueta: 'Salidas realizadas con el paciente:',
                controlador: c.salidas,
                pista: 'Ej: Kinesiología 10:30',
                ayuda: 'Escribe una por línea.',
                lineas: 3,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: FilledButton.icon(
              onPressed: () => _verMensaje(context),
              icon: const Icon(Icons.visibility_outlined, size: 22),
              label: const Text('Ver mensaje'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _elegirFecha(BuildContext context) async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: controller.entrega.fecha,
      firstDate: DateTime(hoy.year - 2),
      lastDate: DateTime(hoy.year + 2),
      helpText: 'Fecha de la entrega',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (elegida != null) controller.setFecha(elegida);
  }

  Future<void> _verMensaje(BuildContext context) async {
    if (controller.entrega.estaVacia) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Escribe primero los datos de la entrega.'),
          ),
        );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PantallaMensaje(controller: controller)),
    );
  }

  Future<void> _confirmarLimpiar(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar y empezar de nuevo'),
        content: const Text('Se borrarán todos los datos escritos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok == true) controller.limpiar();
  }
}

/// Recordatorio corto de qué hacer.
class _Indicacion extends StatelessWidget {
  const _Indicacion();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, size: 20, color: AppTheme.primario),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Completa las casillas de arriba hacia abajo. Al final toca '
              '«Ver mensaje» para copiarlo o compartirlo.',
              style: TextStyle(fontSize: 13.5, height: 1.35, color: AppTheme.etiqueta),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ayuda plegada con frases típicas para el estado del paciente.
class _AyudaEstado extends StatelessWidget {
  const _AyudaEstado({required this.onInsertar});

  final void Function(String) onInsertar;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 6),
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: AppTheme.primario,
        collapsedIconColor: AppTheme.primario,
        title: const Text(
          '¿No sabes cómo escribirlo?',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.primario,
          ),
        ),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Toca una frase y se agrega sola al estado del paciente:',
              style: TextStyle(fontSize: 13, color: AppTheme.suave),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final frase in PantallaLlenado._frases)
                ActionChip(
                  label: Text(frase),
                  backgroundColor: const Color(0xFFF1F3FB),
                  side: BorderSide.none,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.etiqueta,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: () => onInsertar(frase),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
