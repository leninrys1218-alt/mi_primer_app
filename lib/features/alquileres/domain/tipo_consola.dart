/// Tipo de consola que se alquila.
///
/// Hoy solo hay PS5. Si el negocio agrega otra, se añade un valor aquí y
/// listo — nada más en el dominio se rompe.
enum TipoConsola {
  ps5;

  factory TipoConsola.fromJson(String valor) => switch (valor) {
    'ps5' => TipoConsola.ps5,
    _ => throw ArgumentError('Tipo de consola desconocido: $valor'),
  };

  String toJson() => name;
}
