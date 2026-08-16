import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primer_proyecto_flutter/core/json.dart';
import 'package:mi_primer_proyecto_flutter/features/alquileres/domain/alquiler.dart';
import 'package:mi_primer_proyecto_flutter/features/alquileres/domain/cliente.dart';
import 'package:mi_primer_proyecto_flutter/features/alquileres/domain/estado_alquiler.dart';
import 'package:mi_primer_proyecto_flutter/features/alquileres/domain/tipo_consola.dart';

Alquiler ejemplo({EstadoAlquiler? estado, String? notas}) => Alquiler(
  id: 'alq-001',
  consolaId: 'PS5-01',
  tipoConsola: TipoConsola.ps5,
  cliente: const Cliente(
    nombre: 'Carlos Mendoza',
    cedula: '1065234789',
    telefono: '3015678901',
  ),
  fechaInicio: DateTime.utc(2026, 8, 10, 14),
  fechaEsperadaDevolucion: DateTime.utc(2026, 8, 13, 14),
  estado: estado ?? Reservado(DateTime.utc(2026, 8, 9, 18, 30)),
  notas: notas,
);

void main() {
  group('serialización', () {
    test('un alquiler sobrevive la ida y vuelta a JSON sin perder nada', () {
      final original = ejemplo(
        estado: Entregado(DateTime.utc(2026, 8, 10, 14, 10), 150000),
        notas: 'Cliente pidió un control extra',
      );

      final texto = jsonEncode(original.toJson());
      final vuelta = Alquiler.fromJson(
        jsonDecode(texto) as Map<String, dynamic>,
      );

      expect(vuelta, equals(original));
    });

    test('un alquiler sin la clave notas se lee con notas null', () {
      final json = ejemplo().toJson()..remove('notas');
      expect(Alquiler.fromJson(json).notas, isNull);
    });

    test('un alquiler sin id dice QUÉ campo falló, no solo que falló', () {
      final json = ejemplo().toJson()..remove('id');

      expect(
        () => Alquiler.fromJson(json),
        throwsA(isA<CampoInvalido>().having((e) => e.campo, 'campo', 'id')),
      );
    });

    test('una fecha que no es ISO 8601 se rechaza', () {
      final json = ejemplo().toJson()..['fechaInicio'] = '10 de agosto';
      expect(() => Alquiler.fromJson(json), throwsA(isA<CampoInvalido>()));
    });

    test('la hora se conserva en UTC y no se corre cinco horas', () {
      final json = ejemplo().toJson();
      expect(json['fechaInicio'], '2026-08-10T14:00:00.000Z');
    });
  });

  group('igualdad', () {
    test('dos alquileres con los mismos datos son iguales', () {
      expect(ejemplo(), equals(ejemplo()));
    });

    test('dos alquileres con los mismos datos comparten hashCode', () {
      expect(ejemplo().hashCode, equals(ejemplo().hashCode));
      expect({ejemplo(), ejemplo()}.length, 1);
    });

    test('dos alquileres con clientes distintos NO son iguales', () {
      final otro = ejemplo().copyWith(
        cliente: const Cliente(
          nombre: 'Laura Pérez',
          cedula: '1073456123',
          telefono: '3126789012',
        ),
      );
      expect(ejemplo(), isNot(equals(otro)));
    });

    test('copyWith cambia solo lo que se le pasa', () {
      final original = ejemplo();
      final copia = original.copyWith(notas: 'Nueva nota');

      expect(copia.notas, 'Nueva nota');
      expect(copia.id, original.id);
      expect(copia.fechaInicio, original.fechaInicio);
    });
  });

  group('reglas de negocio', () {
    test('un alquiler entregado tiene la consola en poder del cliente', () {
      final alquiler = ejemplo(
        estado: Entregado(DateTime.utc(2026, 8, 10, 14, 10), 150000),
      );
      expect(alquiler.consolaEnPoderDelCliente, isTrue);
    });

    test('un alquiler devuelto NO tiene la consola en poder del cliente', () {
      final alquiler = ejemplo(
        estado: Devuelto(DateTime.utc(2026, 8, 13, 10), true),
      );
      expect(alquiler.consolaEnPoderDelCliente, isFalse);
    });

    test('un alquiler entregado que pasó su fecha esperada está vencido', () {
      final alquiler = ejemplo(
        estado: Entregado(DateTime.utc(2026, 8, 10, 14, 10), 150000),
      );
      final ahora = DateTime.utc(2026, 8, 20);
      expect(alquiler.estaVencido(ahora), isTrue);
    });

    test('la etiqueta de un atraso incluye los días', () {
      expect(const Atrasado(5, true).etiqueta, contains('5 día'));
    });
  });
}
