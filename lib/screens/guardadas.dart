import 'package:flutter/material.dart';

import '../state/entrega_controller.dart';
import '../theme/app_theme.dart';

/// Entregas guardadas, para volver a usarlas en otro turno.
class PantallaGuardadas extends StatelessWidget {
  const PantallaGuardadas({super.key, required this.controller});

  final EntregaController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entregas guardadas')),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (controller.guardadas.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Todavía no has guardado ninguna entrega.\n\n'
                  'Cuando tengas un mensaje listo, toca el marcador de la '
                  'esquina para guardarlo y volver a usarlo después.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.5, color: AppTheme.suave),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: controller.guardadas.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final g = controller.guardadas[i];
              return Container(
                decoration: AppTheme.tarjeta(),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    // Se toma el messenger antes de cerrar la pantalla.
                    final messenger = ScaffoldMessenger.of(context);
                    controller.cargar(g.entrega);
                    Navigator.of(context).pop();
                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text('Entrega de ${g.titulo} cargada.')),
                      );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g.titulo,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.texto,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Guardada el ${g.fechaHora}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.suave,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          onPressed: () => controller.eliminarGuardada(g.id),
                          icon: const Icon(Icons.delete_outline,
                              color: Color(0xFFB3261E)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
