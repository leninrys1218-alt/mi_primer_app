import 'package:flutter/material.dart';
import 'package:mi_primer_proyecto_flutter/features/alquileres/data/alquileres_locales.dart';
import 'package:mi_primer_proyecto_flutter/features/alquileres/domain/alquiler.dart';

void main() => runApp(const MiApp());

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Alquiler PS5',
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    home: const PantallaAlquileres(),
  );
}

class PantallaAlquileres extends StatefulWidget {
  const PantallaAlquileres({super.key});

  @override
  State<PantallaAlquileres> createState() => _PantallaAlquileresState();
}

class _PantallaAlquileresState extends State<PantallaAlquileres> {
  // `late final` en el campo: el Future se crea UNA sola vez.
  // Crearlo dentro de build() lo relanza en cada reconstrucción.
  late final Future<List<Alquiler>> _alquileres = AlquileresLocales()
      .obtenerTodos();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Alquileres PS5')),
    body: FutureBuilder<List<Alquiler>>(
      future: _alquileres,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          // El mensaje de CampoInvalido dice el campo exacto que falló.
          return Center(child: Text('No se pudo leer:\n${snapshot.error}'));
        }

        final alquileres = snapshot.data ?? const <Alquiler>[];
        return ListView.separated(
          itemCount: alquileres.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final alquiler = alquileres[i];
            return ListTile(
              title: Text('${alquiler.consolaId} · ${alquiler.cliente.nombre}'),
              subtitle: Text(alquiler.estado.etiqueta),
              trailing: alquiler.consolaEnPoderDelCliente
                  ? const Icon(Icons.videogame_asset_outlined)
                  : null,
            );
          },
        );
      },
    ),
  );
}
