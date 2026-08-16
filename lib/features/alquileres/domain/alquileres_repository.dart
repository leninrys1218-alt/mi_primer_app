import 'package:mi_primer_proyecto_flutter/features/alquileres/domain/alquiler.dart';

/// Lo que la aplicación necesita saber de los alquileres.
///
/// `abstract interface class` = solo contrato: nadie hereda de aquí, solo
/// lo implementa.
abstract interface class AlquileresRepository {
  Future<List<Alquiler>> obtenerTodos();

  Future<Alquiler?> obtenerPorId(String id);
}
