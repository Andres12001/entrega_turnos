import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Utilidades para convertir el mensaje en imagen y compartirla.
class Captura {
  Captura._();

  /// Convierte el widget apuntado por [key] en bytes PNG.
  ///
  /// [maxPixeles] limita el tamaño final: si la entrega es muy larga se reduce
  /// la resolución en lugar de llenar la memoria del teléfono.
  static Future<Uint8List?> comoPng(
    GlobalKey key, {
    double pixelRatio = 3.0,
    double maxPixeles = 12e6,
  }) async {
    final contexto = key.currentContext;
    if (contexto == null) return null;
    final objeto = contexto.findRenderObject();
    if (objeto is! RenderRepaintBoundary) return null;
    // Sin tamaño todavía (pantalla recién abierta) no se puede rasterizar.
    if (!objeto.hasSize || objeto.size.isEmpty) return null;

    var escala = pixelRatio;
    final tamano = objeto.size;
    final area = tamano.width * tamano.height;
    if (area > 0) {
      final escalaMaxima = math.sqrt(maxPixeles / area);
      if (escala > escalaMaxima) escala = escalaMaxima;
    }

    // El árbol ya está pintado (la captura se dispara desde un toque del
    // usuario), por lo que se puede rasterizar de inmediato.
    final ui.Image imagen = await objeto.toImage(pixelRatio: escala);
    final dados = await imagen.toByteData(format: ui.ImageByteFormat.png);
    imagen.dispose();
    return dados?.buffer.asUint8List();
  }

  /// Guarda la imagen en la carpeta de la app y devuelve la ruta del archivo.
  static Future<String> guardarImagen(
    Uint8List bytes, {
    String nombreArchivo = 'entrega-turno',
  }) async {
    Directory base;
    try {
      base = (await getDownloadsDirectory()) ??
          await getApplicationDocumentsDirectory();
    } catch (_) {
      base = await getApplicationDocumentsDirectory();
    }
    final carpeta = Directory('${base.path}/Entregas de turno');
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
    final ruta = '${carpeta.path}/$nombreArchivo-'
        '${DateTime.now().millisecondsSinceEpoch}.png';
    await File(ruta).writeAsBytes(bytes, flush: true);
    return ruta;
  }

  /// Abre la hoja de compartir con la imagen ya guardada.
  static Future<void> compartirArchivo(String ruta, {String? texto}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(ruta, mimeType: 'image/png')],
        text: texto,
      ),
    );
  }
}
