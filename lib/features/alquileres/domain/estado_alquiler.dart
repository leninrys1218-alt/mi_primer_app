import 'package:mi_primer_proyecto_flutter/core/json.dart';

/// En qué punto de su ciclo de vida está un alquiler.
///
/// `sealed` significa dos cosas: nadie fuera de este archivo puede añadir un
/// estado, y el compilador conoce la lista completa. Eso permite que los
/// `switch` de abajo sean exhaustivos sin `default`.
sealed class EstadoAlquiler {
  const EstadoAlquiler();

  /// El ÚNICO sitio donde un texto del JSON se convierte en un tipo.
  factory EstadoAlquiler.fromJson(Map<String, dynamic> json) {
    final tipo = leerTexto(json, 'tipo');
    return switch (tipo) {
      'reservado' => Reservado(leerFecha(json, 'reservadoEn')),
      'entregado' => Entregado(
        leerFecha(json, 'entregadoEn'),
        leerDecimal(json, 'fianza'),
      ),
      'devuelto' => Devuelto(
        leerFecha(json, 'devueltoEn'),
        leerBooleano(json, 'buenEstado'),
      ),
      'atrasado' => Atrasado(
        leerEntero(json, 'diasAtraso'),
        leerBooleano(json, 'seAviso'),
      ),
      'cancelado' => Cancelado(leerTexto(json, 'motivo')),
      _ => throw CampoInvalido('estado.tipo', 'no es un estado conocido', tipo),
    };
  }

  /// Simétrico a fromJson: si añades un estado arriba y olvidas añadirlo
  /// aquí, esto no compila.
  Map<String, dynamic> toJson() => switch (this) {
    Reservado(:final reservadoEn) => {
      'tipo': 'reservado',
      'reservadoEn': reservadoEn.toIso8601String(),
    },
    Entregado(:final entregadoEn, :final fianza) => {
      'tipo': 'entregado',
      'entregadoEn': entregadoEn.toIso8601String(),
      'fianza': fianza,
    },
    Devuelto(:final devueltoEn, :final buenEstado) => {
      'tipo': 'devuelto',
      'devueltoEn': devueltoEn.toIso8601String(),
      'buenEstado': buenEstado,
    },
    Atrasado(:final diasAtraso, :final seAviso) => {
      'tipo': 'atrasado',
      'diasAtraso': diasAtraso,
      'seAviso': seAviso,
    },
    Cancelado(:final motivo) => {'tipo': 'cancelado', 'motivo': motivo},
  };

  /// Regla de negocio: ¿la consola sigue en manos del cliente?
  bool get consolaEnPoder => switch (this) {
    Entregado() || Atrasado() => true,
    Reservado() || Devuelto() || Cancelado() => false,
  };

  /// Texto para la pantalla.
  String get etiqueta => switch (this) {
    Reservado() => 'Reservado',
    Entregado(:final fianza) =>
      'Entregado · fianza \$${fianza.toStringAsFixed(0)}',
    Devuelto(:final buenEstado) =>
      buenEstado ? 'Devuelto en buen estado' : 'Devuelto con daño',
    Atrasado(:final diasAtraso) => 'Atrasado · $diasAtraso día(s)',
    Cancelado(:final motivo) => 'Cancelado: $motivo',
  };
}

final class Reservado extends EstadoAlquiler {
  const Reservado(this.reservadoEn);

  final DateTime reservadoEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reservado && other.reservadoEn == reservadoEn;

  @override
  int get hashCode => Object.hash(runtimeType, reservadoEn);

  @override
  String toString() => 'Reservado($reservadoEn)';
}

final class Entregado extends EstadoAlquiler {
  const Entregado(this.entregadoEn, this.fianza);

  final DateTime entregadoEn;
  final double fianza;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entregado &&
          other.entregadoEn == entregadoEn &&
          other.fianza == fianza;

  @override
  int get hashCode => Object.hash(runtimeType, entregadoEn, fianza);

  @override
  String toString() => 'Entregado($entregadoEn, \$$fianza)';
}

final class Devuelto extends EstadoAlquiler {
  const Devuelto(this.devueltoEn, this.buenEstado);

  final DateTime devueltoEn;
  final bool buenEstado;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Devuelto &&
          other.devueltoEn == devueltoEn &&
          other.buenEstado == buenEstado;

  @override
  int get hashCode => Object.hash(runtimeType, devueltoEn, buenEstado);

  @override
  String toString() => 'Devuelto($devueltoEn, buenEstado: $buenEstado)';
}

final class Atrasado extends EstadoAlquiler {
  // El assert documenta la regla en depuración; leerEntero ya la garantiza
  // en producción (no deja pasar un valor que no sea número).
  const Atrasado(this.diasAtraso, this.seAviso)
    : assert(diasAtraso > 0, 'atrasado exige al menos 1 día');

  final int diasAtraso;
  final bool seAviso;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Atrasado &&
          other.diasAtraso == diasAtraso &&
          other.seAviso == seAviso;

  @override
  int get hashCode => Object.hash(runtimeType, diasAtraso, seAviso);

  @override
  String toString() => 'Atrasado($diasAtraso días, avisado: $seAviso)';
}

final class Cancelado extends EstadoAlquiler {
  const Cancelado(this.motivo) : assert(motivo != '', 'cancelar exige motivo');

  final String motivo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Cancelado && other.motivo == motivo;

  @override
  int get hashCode => Object.hash(runtimeType, motivo);

  @override
  String toString() => 'Cancelado($motivo)';
}
