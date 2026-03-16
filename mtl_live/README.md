# MTL Live — Montréal Live Events

Application mobile Flutter (iOS + Android) d'activités en temps réel à Montréal.

## Architecture

```
mtl_live/
├── lib/
│   ├── main.dart                    # Point d'entrée + AppShell (Bottom Nav)
│   ├── models/
│   │   ├── event_model.dart         # Modèle MtlEvent (unifie toutes les sources)
│   │   ├── filter_model.dart        # Modèle EventFilter (filtres persistants)
│   │   ├── weather_model.dart       # Modèle WeatherData (Open-Meteo)
│   │   └── user_model.dart          # Modèle AppUser (profil + favoris)
│   ├── providers/
│   │   └── providers.dart           # Tous les providers Riverpod
│   ├── screens/
│   │   ├── home_screen.dart         # Accueil (Hero + sections)
│   │   ├── explore_screen.dart      # Explorer / Découverte
│   │   ├── calendar_screen.dart     # Calendrier (mois/semaine/jour)
│   │   ├── live_screen.dart         # En direct maintenant
│   │   ├── free_screen.dart         # Gratuit & Pas cher
│   │   ├── favorites_screen.dart    # Mes plans / Favoris
│   │   ├── event_detail_screen.dart # Détail événement complet
│   │   └── auth_screen.dart         # Connexion (Google/Apple)
│   ├── services/
│   │   ├── firestore_service.dart   # Queries Firestore
│   │   ├── ticketmaster_service.dart# Client API Ticketmaster
│   │   ├── weather_service.dart     # Client Open-Meteo
│   │   ├── location_service.dart    # Géolocalisation
│   │   ├── auth_service.dart        # Authentification Firebase
│   │   ├── notification_service.dart# FCM + notifications locales
│   │   └── cache_service.dart       # Cache local Hive (7 jours offline)
│   ├── theme/
│   │   └── mtl_theme.dart           # Thème Montréal (dark/light)
│   ├── utils/
│   │   ├── constants.dart           # Constantes globales + URLs API
│   │   ├── date_helpers.dart        # Formatage dates en français QC
│   │   └── extensions.dart          # Extensions (couleurs, distance, etc.)
│   └── widgets/
│       ├── event_card.dart          # Carte d'événement (full + compact)
│       ├── hero_carousel.dart       # Hero Top 8 du mois
│       ├── filter_sheet.dart        # Bottom sheet filtres complets
│       ├── active_filters_bar.dart  # Chips des filtres actifs
│       ├── quick_filters.dart       # Filtres rapides horizontaux
│       ├── section_header.dart      # En-tête de section
│       ├── source_badge.dart        # Badge source de données
│       ├── status_badge.dart        # Badge statut disponibilité
│       └── weather_banner.dart      # Bannière météo intelligente
├── firebase/
│   ├── firebase.json                # Configuration Firebase
│   ├── firestore.rules              # Règles de sécurité Firestore
│   ├── firestore.indexes.json       # Index Firestore
│   └── functions/
│       └── src/
│           ├── index.ts             # Cloud Functions (crons + HTTP)
│           ├── ticketmaster.ts      # Refresh Ticketmaster (15 min)
│           ├── ville-montreal.ts    # Refresh Ville de Montréal (24h)
│           └── predicthq.ts         # Enrichissement PredictHQ (6h)
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── pubspec.yaml
└── README.md
```

## Tech Stack

| Composant | Technologie |
|-----------|-------------|
| Frontend | Flutter 3.24+ (Dart) |
| Backend | Firebase (Firestore, Auth, Functions, Messaging, Storage) |
| State Management | Riverpod 2.0+ |
| Cache local | Hive + Firestore offline persistence |
| Cartes | Google Maps Flutter |
| Notifications | Firebase Cloud Messaging + flutter_local_notifications |

## Sources de données

| Source | Fréquence de refresh | Type |
|--------|---------------------|------|
| Ticketmaster Discovery API | Toutes les 15 minutes | Prix live + événements |
| Ticketmaster Availability API | En temps réel (on-demand) | Places disponibles |
| Données ouvertes Ville de Montréal | Toutes les 24 heures | Événements publics gratuits |
| PredictHQ API | Toutes les 6 heures | Impact score + attendance |
| Open-Meteo | Toutes les heures | Météo (filtre intelligent) |

## Installation

### Prérequis

- Flutter 3.24+ (`flutter --version`)
- Dart SDK 3.5+
- Node.js 20+ (pour Cloud Functions)
- Firebase CLI (`npm install -g firebase-tools`)
- Compte Firebase avec projet créé

### 1. Clés API nécessaires

Créez un fichier `.env` à la racine :

```env
TICKETMASTER_API_KEY=votre_clé       # https://developer.ticketmaster.com/
PREDICTHQ_API_KEY=votre_clé          # https://www.predicthq.com/
GOOGLE_MAPS_API_KEY=votre_clé        # https://console.cloud.google.com/
```

### 2. Configuration Firebase

```bash
# Connexion Firebase
firebase login

# Initialisation du projet
firebase init

# Configuration FlutterFire
dart pub global activate flutterfire_cli
flutterfire configure
```

### 3. Installation des dépendances Flutter

```bash
cd mtl_live
flutter pub get
```

### 4. Déploiement Cloud Functions

```bash
cd firebase/functions
npm install
npm run build
firebase deploy --only functions
```

### 5. Lancement

```bash
# iOS (simulateur)
flutter run -d ios

# Android (émulateur)
flutter run -d android

# Avec émulateurs Firebase (développement local)
firebase emulators:start
flutter run
```

### 6. Polices

Téléchargez la police Montserrat depuis Google Fonts et placez les fichiers dans `assets/fonts/` :
- Montserrat-Regular.ttf
- Montserrat-Medium.ttf
- Montserrat-SemiBold.ttf
- Montserrat-Bold.ttf

## Fonctionnalités

- Hero section avec Top 8 événements du mois (PredictHQ impact score)
- 5 onglets : Accueil, Explorer, Calendrier, En direct, Mes plans
- Filtres avancés : date, catégorie, prix, localisation, quartier, météo, etc.
- Prix en temps réel avec source transparente et timestamp
- Bannière météo intelligente (recommande intérieur si mauvais temps)
- Mode offline (cache 7 jours via Hive)
- Authentification Google + Apple Sign-In
- Notifications push + rappels 1h avant
- Recherche full-text
- Dark mode par défaut (thème Montréal)
- Interface 100% en français québécois

## Thème

- Bleu Montréal : `#003399`
- Orange Montréal : `#FF6600`
- Background Dark : `#0D0D0D`
- Cards : `#1A1A2E` / `#16213E`

## Licence

Projet privé — Tous droits réservés.
