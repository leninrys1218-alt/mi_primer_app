import 'package:mi_primer_proyecto_flutter/core/json.dart';

/// Quién alquila la consola.
///
/// Es un **objeto de valor**: dos clientes con los mismos datos son el mismo
/// cliente, así que no lleva `id` y se compara por contenido.
class Cliente {
  const Cliente({
    required this.nombre,
    required this.cedula,
    required this.telefono,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    nombre: leerTexto(json, 'nombre'),
    cedula: leerTexto(json, 'cedula'),
    telefono: leerTexto(json, 'telefono'),
  );

  final String nombre;
  final String cedula;
  final String telefono;

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'cedula': cedula,
    'telefono': telefono,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cliente &&
          other.nombre == nombre &&
          other.cedula == cedula &&
          other.telefono == telefono;

  @override
  int get hashCode => Object.hash(nombre, cedula, telefono);

  @override
  String toString() => 'Cliente($nombre, $cedula)';
}
