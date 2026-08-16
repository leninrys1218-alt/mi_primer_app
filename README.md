# PlayRenta

Los locales de alquiler de PlayStation aún llevan el control
de manera manual. PlayRenta centraliza cada préstamo para
saber, de un vistazo, qué consola está afuera, con quién y desde cuándo.

## El dominio

- `Alquiler`   — entidad principal. Identidad: `id`.
- `Cliente`    — objeto de valor (nombre, cédula, teléfono).
- `EstadoAlquiler` — sellada: Reservado · Entregado · Devuelto · Atrasado · Cancelado.
- `TipoConsola` — enum, hoy solo `ps5`, pensado para crecer sin romper el resto.

## Decisión: modelo escrito a mano (sin freezed)

Sí intenté usar freezed (paso 11), pero me tropecé con varios errores
raros: un campo anidado que no se convertía bien a JSON, versiones de
paquetes que no cuadraban, y una anotación de más que terminó rompiendo
todo. Después de darle vueltas un rato, decidí no forzarlo y quedarme
con la versión a mano que ya tenía funcionando y que entiendo por
completo.

Además noté algo real: mi código a mano da errores que dicen qué campo
falló (`CampoInvalido: 'consolaId' debe ser un texto no vacío`), mientras
que freezed generado solo tira el típico error de Dart sin decir cuál
campo fue. Para una app donde los datos los llena el dueño del local a
mano, ese mensaje claro me parece más valioso que ahorrarme código.
Freezed lo estare probando de manera autonoma despues sin la presion de la entrega.

## Cómo correrlo

    flutter pub get

    flutter test

    flutter run
