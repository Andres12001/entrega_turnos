import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/entrega.dart';

/// Una entrega guardada en el historial.
class Guardada {
  Guardada({required this.id, required this.guardadoEn, required this.entrega});

  final String id;
  final DateTime guardadoEn;
  final Entrega entrega;

  String get titulo =>
      entrega.paciente.trim().isEmpty ? 'Sin nombre' : entrega.paciente.trim();

  String get fechaHora =>
      '${Entrega.dosDigitos(guardadoEn.day)}/${Entrega.dosDigitos(guardadoEn.month)} '
      '${Entrega.dosDigitos(guardadoEn.hour)}:${Entrega.dosDigitos(guardadoEn.minute)}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'guardadoEn': guardadoEn.toIso8601String(),
        'entrega': entrega.toJson(),
      };

  factory Guardada.fromJson(Map<String, dynamic> json) => Guardada(
        id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
        guardadoEn: DateTime.tryParse(json['guardadoEn'] as String? ?? '') ?? DateTime.now(),
        entrega: Entrega.fromJson(Map<String, dynamic>.from(json['entrega'] as Map)),
      );
}

/// Estado del formulario: se escribe una vez y queda guardado solo.
class EntregaController extends ChangeNotifier {
  EntregaController();

  static const _kBorrador = 'entrega_turno_simple_v1';
  static const _kGuardadas = 'entrega_turno_guardadas_v1';
  static const int _maximo = 30;

  Entrega entrega = Entrega();
  List<Guardada> guardadas = [];
  bool cargado = false;

  late final TextEditingController paciente = _campo((v) => entrega.paciente = v);
  late final TextEditingController tensACargo = _campo((v) => entrega.tensACargo = v);
  late final TextEditingController proximoControl = _campo((v) => entrega.proximoControl = v);
  late final TextEditingController proximosExamenes = _campo((v) => entrega.proximosExamenes = v);
  late final TextEditingController medicamentos = _campo((v) => entrega.medicamentos = v);
  late final TextEditingController insumos = _campo((v) => entrega.insumos = v);
  late final TextEditingController estadoActual = _campo((v) => entrega.estadoActual = v);
  late final TextEditingController salidas = _campo((v) => entrega.salidas = v);

  Timer? _temporizador;

  TextEditingController _campo(void Function(String) asignar) {
    final c = TextEditingController();
    c.addListener(() {
      asignar(c.text);
      _programarGuardado();
    });
    return c;
  }

  Future<void> inicializar() async {
    final prefs = await SharedPreferences.getInstance();

    final borrador = prefs.getString(_kBorrador);
    if (borrador != null && borrador.isNotEmpty) {
      try {
        entrega = Entrega.fromJson(jsonDecode(borrador) as Map<String, dynamic>);
      } catch (_) {
        entrega = Entrega();
      }
    }

    final lista = prefs.getString(_kGuardadas);
    if (lista != null && lista.isNotEmpty) {
      try {
        guardadas = (jsonDecode(lista) as List)
            .map((e) => Guardada.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        guardadas = [];
      }
    }

    _sincronizar();
    cargado = true;
    notifyListeners();
  }

  void _sincronizar() {
    paciente.text = entrega.paciente;
    tensACargo.text = entrega.tensACargo;
    proximoControl.text = entrega.proximoControl;
    proximosExamenes.text = entrega.proximosExamenes;
    medicamentos.text = entrega.medicamentos;
    insumos.text = entrega.insumos;
    estadoActual.text = entrega.estadoActual;
    salidas.text = entrega.salidas;
  }

  void _programarGuardado() {
    _temporizador?.cancel();
    _temporizador = Timer(const Duration(milliseconds: 300), guardarBorrador);
  }

  Future<void> guardarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBorrador, jsonEncode(entrega.toJson()));
  }

  void setFecha(DateTime fecha) {
    entrega.fecha = fecha;
    _programarGuardado();
    notifyListeners();
  }

  /// Agrega una frase al final del estado actual, con punto y espacio.
  void agregarFrase(String frase) {
    var actual = estadoActual.text.trimRight();
    if (actual.isNotEmpty && !actual.endsWith('.') && !actual.endsWith(':')) {
      actual = '$actual.';
    }
    final nuevo = actual.isEmpty ? frase : '$actual $frase';
    estadoActual.text = nuevo;
    estadoActual.selection = TextSelection.collapsed(offset: nuevo.length);
  }

  void limpiar() {
    entrega = Entrega(fecha: DateTime.now());
    _sincronizar();
    guardarBorrador();
    notifyListeners();
  }

  Future<void> guardarEnLista() async {
    guardadas.insert(
      0,
      Guardada(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        guardadoEn: DateTime.now(),
        entrega: entrega.copy(),
      ),
    );
    if (guardadas.length > _maximo) {
      guardadas = guardadas.sublist(0, _maximo);
    }
    await _persistirGuardadas();
    notifyListeners();
  }

  void cargar(Entrega otra) {
    entrega = otra.copy();
    _sincronizar();
    guardarBorrador();
    notifyListeners();
  }

  Future<void> eliminarGuardada(String id) async {
    guardadas.removeWhere((g) => g.id == id);
    await _persistirGuardadas();
    notifyListeners();
  }

  Future<void> _persistirGuardadas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kGuardadas,
      jsonEncode(guardadas.map((g) => g.toJson()).toList()),
    );
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    paciente.dispose();
    tensACargo.dispose();
    proximoControl.dispose();
    proximosExamenes.dispose();
    medicamentos.dispose();
    insumos.dispose();
    estadoActual.dispose();
    salidas.dispose();
    super.dispose();
  }
}
