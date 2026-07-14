# Framed

*Également disponible en : [English](README.md) · [Español](README.es.md) · [Nederlands](README.nl.md)*

*(Cette page est une traduction du README en anglais et n'a pas encore été relue par un locuteur natif.)*

Un jeu d'assassinat circulaire en extérieur, joué en vrai : assisté par GPS, basé sur des photos. Deux modes de jeu : le plus de photos gagne (par défaut) ou dernier joueur en vie.

**[IDEA.md](IDEA.md)** contient la conception complète du jeu (en anglais).

## Comment ça marche

Framed est un jeu d'assassinat grandeur nature, joué avec le GPS et l'appareil photo du téléphone à la place de pistolets en mousse. Chaque joueur reçoit une cible secrète, et "l'éliminer" consiste simplement à la prendre en photo à son insu. Si vous photographiez votre cible, vous héritez de la personne qu'elle traquait, et la chaîne continue jusqu'à ce qu'il ne reste qu'un joueur. Délimitez une zone de jeu dans l'application, réunissez un groupe de 3 joueurs ou plus, et lancez-vous.

## Développement

```sh
# Backend local (Supabase auto-hébergé + PostGIS)
cd backend && cp .env.example .env && docker compose up -d && cd ..

# App
flutter pub get
dart run build_runner build -d   # génération de code freezed + slang
flutter run                       # émulateur Android : ajoutez --dart-define=SUPABASE_URL=http://10.0.2.2:8000
```

Vérifications : `dart format .` · `flutter analyze` · `flutter test`

## Structure

- `lib/features/<feature>/{data,domain,presentation}` — architecture propre, organisée par fonctionnalité
- `lib/core/` — thème (système de design), injection de dépendances, configuration, cryptographie
- `backend/` — docker-compose Supabase pour le développement local ([backend/README.md](backend/README.md), en anglais)

## Localisation

`lib/i18n/<locale>.i18n.json`, un fichier par langue, avec les mêmes clés que `en.i18n.json`
(langue de base) — `dart run build_runner build -d` échoue si une clé manque, donc
l'ensemble ne peut pas diverger. Une nouvelle langue n'a besoin que d'un nouveau fichier ; aucun
changement de configuration n'est nécessaire (`slang.yaml`).

Langues prises en charge : `en` (base), `nl`, `es`, `fr`. `nl`/`es`/`fr` sont traduites automatiquement
et ont besoin d'une relecture par un locuteur natif avant que leur formulation soit considérée définitive
— cette application est publique, et les chaînes d'explication des règles et de contenu social
(descriptions des modes de jeu, le texte "bon à savoir", les invites de vote) sont
justement celles qui sonnent artificiel sans cette relecture. Le suivi des relectures par langue se fait dans une issue de ce dépôt.
