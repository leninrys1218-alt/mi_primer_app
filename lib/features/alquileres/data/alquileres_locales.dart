import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:mi_primer_proyecto_flutter/core/json.dart';
import 'package:mi_primer_proyecto_flutter/features/alquileres/domain/alquiler.dart';
import 'package:mi_primer_proyecto_flutter/features/alquileres/domain/alquileres_repository.dart';

/// Cómo se lee un archivo de texto. Se inyecta para poder probar sin assets.
typedef LectorDeAssets = Future<String> Function(String ruta);

class AlquileresLocales implements AlquileresRepository {
  /// En producción es `rootBundle`; en las pruebas, una función que devuelve
  /// una cadena. Esa costura es lo que permite probar sin Flutter inicializado.
  AlquileresLocales({
    LectorDeAssets? lector,
    this.ruta = 'assets/data/alquileres.json',
  }) : _lector = lector ?? rootBundle.loadString;

  final LectorDeAssets _lector;
  final String ruta;

  List<Alquiler>? _cache;

  @override
  Future<List<Alquiler>> obtenerTodos() async {
    final guardado = _cache;
    if (guardado != null) return guardado;

    final crudo = await _lector(ruta);
    final decodificado = jsonDecode(crudo);

    if (decodificado is! List) {
      throw const CampoInvalido(
        '(raíz)',
        'el archivo debe contener una lista',
        null,
      );
    }

    return _cache = decodificado
        .map((e) => Alquiler.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Alquiler?> obtenerPorId(String id) async {
    for (final alquiler in await obtenerTodos()) {
      if (alquiler.id == id) return alquiler;
    }
    return null;
  }
}
