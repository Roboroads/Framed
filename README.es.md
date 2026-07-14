# Framed

*También disponible en: [English](README.md) · [Français](README.fr.md) · [Nederlands](README.nl.md)*

*(Esta página es una traducción del README en inglés y todavía no la ha revisado un hablante nativo.)*

Un juego de asesinato circular de área local que se juega en la vida real: asistido por GPS, basado en fotos. Dos modos de juego: más fotos capturadas gana (por defecto) o último jugador en pie.

**[IDEA.md](IDEA.md)** contiene el diseño completo del juego (en inglés).

## Cómo funciona

Framed es un juego de asesinatos en la vida real, jugado con el GPS y la cámara del móvil en vez de pistolas de juguete. Cada jugador recibe un objetivo secreto, y "matarlo" consiste en sacarle una foto sin que se dé cuenta. Si fotografías a tu objetivo, heredas a quien él estaba persiguiendo, así que la cadena sigue hasta que queda un solo jugador. Marca una zona de juego en la app, reúne a un grupo de 3 o más, y a jugar.

## Desarrollo

```sh
# Backend local (Supabase autoalojado + PostGIS)
cd backend && cp .env.example .env && docker compose up -d && cd ..

# App
flutter pub get
dart run build_runner build -d   # generación de código freezed + slang
flutter run                       # emulador Android: añade --dart-define=SUPABASE_URL=http://10.0.2.2:8000
```

Comprobaciones: `dart format .` · `flutter analyze` · `flutter test`

## Estructura

- `lib/features/<feature>/{data,domain,presentation}` — arquitectura limpia, organizada por funcionalidad
- `lib/core/` — tema (sistema de diseño), inyección de dependencias, configuración, criptografía
- `backend/` — docker-compose de Supabase para desarrollo local ([backend/README.md](backend/README.md), en inglés)

## Localización

`lib/i18n/<locale>.i18n.json`, un archivo por idioma, con las mismas claves que `en.i18n.json`
(idioma base) — `dart run build_runner build -d` falla si falta alguna clave, así que
el conjunto no puede desincronizarse. Los idiomas nuevos solo necesitan un archivo nuevo; no
requieren cambios de configuración (`slang.yaml`).

Idiomas soportados: `en` (base), `nl`, `es`, `fr`. `nl`/`es`/`fr` están traducidos automáticamente
y necesitan revisión de un hablante nativo antes de considerar su redacción definitiva
— esta es una app pública, y las cadenas de explicación de reglas y contenido social
(descripciones de los modos de juego, el texto de "bueno saber", las indicaciones de votación) son
precisamente las que suenan forzadas sin esa revisión. El seguimiento de la revisión por idioma se hace en un issue de este repositorio.
