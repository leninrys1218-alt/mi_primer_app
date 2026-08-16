import 'package:mi_primer_proyecto_flutter/core/json.dart';
import 'package:mi_primer_proyecto_flutter/features/alquileres/domain/cliente.dart';
import 'package:mi_primer_proyecto_flutter/features/alquileres/domain/estado_alquiler.dart';
import 'package:mi_primer_proyecto_flutter/features/alquileres/domain/tipo_consola.dart';

/// Un alquiler de consola.
///
/// Es una **entidad**: tiene identidad propia. Dos alquileres con los mismos
/// datos son dos alquileres distintos si tienen `id` distinto.
class Alquiler {
  const Alquiler({
    required this.id,
    required this.consolaId,
    required this.tipoConsola,
    required this.cliente,
    required this.fechaInicio,
    required this.fechaEsperadaDevolucion,
    required this.estado,
    this.notas,
  });

  factory Alquiler.fromJson(Map<String, dynamic> json) => Alquiler(
    id: leerTexto(json, 'id'),
    consolaId: leerTexto(json, 'consolaId'),
    tipoConsola: TipoConsola.fromJson(leerTexto(json, 'tipoConsola')),
    cliente: Cliente.fromJson(leerMapa(json, 'cliente')),
    fechaInicio: leerFecha(json, 'fechaInicio'),
    fechaEsperadaDevolucion: leerFecha(json, 'fechaEsperadaDevolucion'),
    estado: EstadoAlquiler.fromJson(leerMapa(json, 'estado')),
    notas: leerTextoOpcional(json, 'notas'),
  );

  final String id;
  final String consolaId;
  final TipoConsola tipoConsola;
  final Cliente cliente;
  final DateTime fechaInicio;
  final DateTime fechaEsperadaDevolucion;
  final EstadoAlquiler estado;
  final String? notas;

  Map<String, dynamic> toJson() => {
    'id': id,
    'consolaId': consolaId,
    'tipoConsola': tipoConsola.toJson(),
    'cliente': cliente.toJson(),
    'fechaInicio': fechaInicio.toUtc().toIso8601String(),
    'fechaEsperadaDevolucion': fechaEsperadaDevolucion
        .toUtc()
        .toIso8601String(),
    'estado': estado.toJson(),
    if (notas != null) 'notas': notas,
  };

  // ── Reglas de negocio ───────────────────────────────────────────────────
  // Viven aquí, no en un widget: así se prueban en milisegundos.

  bool get consolaEnPoderDelCliente => estado.consolaEnPoder;

  bool get tieneNotas => notas != null && notas!.isNotEmpty;

  /// El reloj entra como parámetro: sin esto no se podría probar sin
  /// esperar a que pasen los días de verdad.
  bool estaVencido(DateTime ahora) =>
      estado.consolaEnPoder && ahora.isAfter(fechaEsperadaDevolucion);

  Duration diasDesdeEntrega(DateTime ahora) => ahora.difference(fechaInicio);

  // ── Copia ───────────────────────────────────────────────────────────────

  Alquiler copyWith({
    String? consolaId,
    Cliente? cliente,
    DateTime? fechaEsperadaDevolucion,
    EstadoAlquiler? estado,
    String? notas,
  }) => Alquiler(
    id: id, // la identidad no se copia con cambios
    consolaId: consolaId ?? this.consolaId,
    tipoConsola: tipoConsola,
    cliente: cliente ?? this.cliente,
    fechaInicio: fechaInicio, // el inicio tampoco cambia con la copia
    fechaEsperadaDevolucion:
        fechaEsperadaDevolucion ?? this.fechaEsperadaDevolucion,
    estado: estado ?? this.estado,
    notas: notas ?? this.notas,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Alquiler &&
          other.id == id &&
          other.consolaId == consolaId &&
          other.tipoConsola == tipoConsola &&
          other.cliente == cliente &&
          other.fechaInicio == fechaInicio &&
          other.fechaEsperadaDevolucion == fechaEsperadaDevolucion &&
          other.estado == estado &&
          other.notas == notas;

  @override
  int get hashCode => Object.hash(
    id,
    consolaId,
    tipoConsola,
    cliente,
    fechaInicio,
    fechaEsperadaDevolucion,
    estado,
    notas,
  );

  @override
  String toString() => 'Alquiler($id, $consolaId, ${estado.etiqueta})';
}
