# Framed

*Ook beschikbaar in: [English](README.md) · [Español](README.es.md) · [Français](README.fr.md)*

*(Deze pagina is een vertaling van de Engelse README en is nog niet nagekeken door een native speaker.)*

Een lokaal, cirkelvormig moordspel dat je in het echt speelt: GPS-ondersteund, foto-gebaseerd. Twee spelmodi: meeste kiekjes wint (standaard) of laatste speler die overblijft.

**[IDEA.md](IDEA.md)** bevat het volledige spelontwerp (in het Engels).

## Hoe het werkt

Spelers verzamelen op een startpunt en verspreiden zich zodra de host het spel start. Na een verspreidingstimer krijgt iedereen een doelwit: een andere speler die ze moeten vinden en fotograferen met de camera in de app. Andere spelers vergelijken de foto met de referentieselfie van het doelwit, en bij een meerderheid van "ja"-stemmen sterft het doelwit. De moordenaar erft dan het doelwit van zijn slachtoffer, en de keten gaat verder. Het spel eindigt zodra er één speler overblijft. Standaard wint wie de meeste bevestigde kiekjes heeft, ook als die speler intussen dood is; de host kan in plaats daarvan kiezen voor "laatste speler overeind". GPS handhaaft continu een gedeeld speelgebied, en een speler die dat gebied verlaat of te lang stil blijft, sterft automatisch, gemarkeerd als vermist (MIA).

## Ontwikkeling

```sh
# Lokale backend (self-hosted Supabase + PostGIS)
cd backend && cp .env.example .env && docker compose up -d && cd ..

# App
flutter pub get
dart run build_runner build -d   # freezed- en slang-codegeneratie
flutter run                       # Android-emulator: voeg --dart-define=SUPABASE_URL=http://10.0.2.2:8000 toe
```

Checks: `dart format .` · `flutter analyze` · `flutter test`

## Structuur

- `lib/features/<feature>/{data,domain,presentation}` — clean architecture, feature-first
- `lib/core/` — thema (designsysteem), dependency injection, configuratie, cryptografie
- `backend/` — Supabase docker-compose voor lokale ontwikkeling ([backend/README.md](backend/README.md), in het Engels)

## Lokalisatie

`lib/i18n/<locale>.i18n.json`, één bestand per taal, met dezelfde sleutels als `en.i18n.json`
(basistaal) — `dart run build_runner build -d` faalt als er een sleutel ontbreekt, dus
de set kan niet uit elkaar lopen. Nieuwe talen hebben alleen een nieuw bestand nodig; geen
configuratiewijziging (`slang.yaml`).

Ondersteund: `en` (basis), `nl`, `es`, `fr`. `nl`/`es`/`fr` zijn machinaal vertaald
en hebben een controle door een native speaker nodig voordat de bewoordingen als definitief gelden
— dit is een publieke app, en juist de regeluitleg- en sociale teksten
(beschrijvingen van spelmodi, de "goed om te weten"-tekst, stemprompts) lezen
stroef zonder die controle. Houd de controle per taal bij in een issue tegen deze repo.
