import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mi_primer_proyecto_flutter/core/json.dart';
import 'package:mi_primer_proyecto_flutter/features/alquileres/data/alquileres_locales.dart';

const _json = '''
[
  {
    "id": "alq-001",
    "consolaId": "PS5-01",
    "tipoConsola": "ps5",
    "cliente": { "nombre": "Carlos Mendoza", "cedula": "1065234789", "telefono": "3015678901" },
    "fechaInicio": "2026-08-10T14:00:00Z",
    "fechaEsperadaDevolucion": "2026-08-13T14:00:00Z",
    "estado": { "tipo": "reservado", "reservadoEn": "2026-08-09T18:30:00Z" }
  }
]
''';

void main() {
  test('lee la lista completa del archivo', () async {
    final repo = AlquileresLocales(lector: (_) async => _json);
    expect((await repo.obtenerTodos()).length, 1);
  });

  test('busca por id y devuelve null cuando no está', () async {
    final repo = AlquileresLocales(lector: (_) async => _json);

    expect((await repo.obtenerPorId('alq-001'))?.consolaId, 'PS5-01');
    expect(await repo.obtenerPorId('no-existe'), isNull);
  });

  test('un archivo que no es una lista se rechaza', () async {
    final repo = AlquileresLocales(lector: (_) async => '{"a": 1}');
    expect(repo.obtenerTodos(), throwsA(isA<CampoInvalido>()));
  });

  test(
    'el asset declarado en pubspec existe y el modelo lo entiende',
    () async {
      // Esta SÍ toca el bundle real: caza "olvidé el pubspec".
      TestWidgetsFlutterBinding.ensureInitialized();

      final repo = AlquileresLocales(lector: rootBundle.loadString);
      expect((await repo.obtenerTodos()).length, greaterThanOrEqualTo(3));
    },
  );
}
