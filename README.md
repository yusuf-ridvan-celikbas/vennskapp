# VennskApp

Your neighbors' bookshelves, one shared library. Lend and borrow books with friends and neighbors: no buying, no selling.

Prototype status: **M5 (reading log, reading pace, suggested loan length)**. See [docs/PLAN.md](docs/PLAN.md) for the full plan and milestones.

## Stack
- `app/` is the Flutter app (Android + web first). It uses Riverpod, go_router and `gen-l10n` (ARB files in `app/lib/l10n`).
- `supabase/` holds the Supabase project (Postgres + PostGIS, auth, RLS). It runs locally in Docker.

## Prerequisites (all free)
- Flutter SDK (stable) and Android Studio with an emulator.
- Docker Desktop.
- Node.js, used to run the Supabase CLI through `npx`.
- Windows only: turn on **Developer Mode** (`start ms-settings:developers`). Flutter needs it to build plugins.

## Run locally
```sh
# 1. Start the backend (first run downloads Docker images)
npx supabase@2 start
npx supabase@2 status          # shows the URLs and the publishable key

# 2. Configure the app
cd app
cp env/local.example.json env/local.json   # paste the publishable key into SUPABASE_ANON_KEY

# 3. Run
flutter run -d chrome  --dart-define-from-file=env/local.json
flutter run -d emulator-5554 --dart-define-from-file=env/local.json
```
Optional: put a free Google Books API key in `GOOGLE_BOOKS_API_KEY` (Google Cloud console → enable "Books API" → create an API key). It is only a fallback when Open Library doesn't know a book; without it, the fallback is skipped.

On the Android emulator, the host machine is reachable as `10.0.2.2`. Set `SUPABASE_URL` to `http://10.0.2.2:54321` in a separate env file, e.g. `env/android.json`.

Supabase Studio (database UI): http://127.0.0.1:54323 · Mailpit (local emails): http://127.0.0.1:54324

## Checks
```sh
cd app
flutter analyze
flutter test
```

## Translations
All UI text lives in `app/lib/l10n/app_<locale>.arb`, with English (`app_en.arb`) as the template. Never hard-code UI strings. `test/l10n_keys_test.dart` checks that every language file has the same keys.

## Database
- Migrations: `supabase/migrations/`. Apply them with `npx supabase@2 db reset`, which also wipes local data.
- Tests: `npx supabase@2 test db` (pgTAP files in `supabase/tests/`).
- Exact locations are never stored. `set_home_location` snaps the pin to a ~1 km grid cell and saves it in `profile_locations`, which no user can read directly.

## Demo data
`supabase/seed.sql` creates 12 fake people with books: 5 neighbors around Küçükçekmece, 3 elsewhere in Istanbul, and 4 in Oslo/Bergen, with mixed visibility settings and a few friendships between them. It runs automatically after `db reset`. To add it without wiping your own account, run:
```sh
docker exec -i supabase_db_vennskapp psql -U postgres < supabase/seed.sql
```
Demo accounts sign in as `<username>@demo.vennskapp.test`, for example `ayse@demo.vennskapp.test`. The shared local test password is in `seed.sql`.

To apply new migrations without losing data, use `npx supabase@2 migration up` instead of `db reset`.

