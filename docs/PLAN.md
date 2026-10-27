# VennskApp: Prototype Plan

## Context
VennskApp turns home bookshelves into a shared, neighborhood-scale library. The tone is warm and family-like: other users are **neighbors (komşu)**, and nothing is bought or sold. The project folder `C:\Users\ridvn\Projects\VennskApp` is empty, so this is a new project.

**Decisions from the Q&A:**
- **Goal:** a $0 **demo/prototype** that makes the idea concrete and testable. It is not a production app. Work is part-time.
- **Core flow only:** add books to your library → set visibility → search who has a book → request/lend → loan duration based on reading speed.
- **Platforms:** Android + responsive web for the MVP. iOS and desktop come later from the same codebase.
- **Hosting:** run locally first, then move to free cloud tiers so friends can try it.
- **Background:** beginner, with some exposure to Dart/Flutter, JS/TS and C#.
- **Backend:** Supabase.
- **Location:** a map pin, snapped to a coarse area.
- **Trust & safety:** minimal for the prototype.
- **Launch country:** not decided, so the design must work anywhere (GDPR and KVKK both in mind).

---

## 1. Product summary & personas
**One-liner:** "Your neighbors' bookshelves, one shared library."

| Persona | Need | What they do in the MVP |
|---|---|---|
| **Ayşe, the collector** (45, 600 books) | Her books are sitting unread; she'd love them to be read, but only by trustworthy people nearby | Bulk-scans her shelf, sets "Friends + neighborhood", lends with auto-calculated durations |
| **Jonas, the reader** (28, reads 3 books/month, small flat) | Wants books without buying them | Searches a title, sees "2 neighbors have it", requests, logs reading sessions |
| **Mehmet, the cautious one** (60) | Privacy first | Keeps the library "Friends only" and lends only to friends |

---

## 2. Feature split

### Prototype MVP (what we build now)
- Email/password sign-in (Supabase Auth). Profile: display name, avatar (optional), language, coarse home area.
- **Add books** three ways:
  - search via Open Library, with Google Books as fallback
  - ISBN barcode scan on Android, with a "keep scanning" mode for bulk adds
  - manual entry
- **Library item fields:**
  - owned
  - status: `unread` / `reading` / `read`
  - short review + 1–5 rating
  - `lendable` toggle
  - per-book visibility override
- **Visibility levels:** Only me / Friends / Friends + neighborhood / Public. You set a profile default and can override it per book.
- **Friends:** send, accept and remove requests. Friends are found by username or invite link.
- **Discovery:** search a book and see holders grouped as Friends / Neighbors (~distance) / Public, only those who are allowed and lendable.
- **Lending:**
  - request (with optional message)
  - owner accepts (manual or auto duration) or declines
  - both confirm the handover; the due date starts then
  - return confirmed by the owner
  - one extension request, which the owner can accept or decline
  - overdue state
- **Reading log:** sessions (pages, minutes, date, optional book) and finished books (start/finish date). A simple stats card shows pages/hour, pages/day and books this year.
- **Auto loan duration** from the borrower's personal reading speed (Section 6).
- **In-app notifications:** loan events, friend requests, plus a daily reminder job for "due in 2 days" and "overdue".
- **Minimal trust:**
  - block user
  - report user (stored for manual review)
  - 👍/👎 after a completed loan, shown as a count
- **i18n:** English complete. All strings live in ARB files from day one. Turkish is added in the polish milestone.

### v1.1 (after the demo works with friends)
- Push notifications via FCM, which is free.
- Norwegian (Bokmål) translation, reviewed by a native speaker before launch.
- iOS build.
- Waitlist/queue for a book.
- Reading goals ("24 books in 2027").
- Fuller ratings with written feedback. Damaged/not-returned report flow with an outcome record.
- Data export (JSON) in settings.
- Offline read-only cache of "my library".

### Later
- Recommendations: "neighbors who liked X also liked Y" and genre-based suggestions.
- Desktop builds.
- Phone verification or ID-light verification.
- Book clubs and neighborhood "little library" events.
- Genre/difficulty-aware durations.
- Moderation dashboard.
- Multi-copy items.
- Import from Goodreads CSV.

---

## 3. Tech stack

### Comparison (scored for *this* project: beginner, solo, $0, Android + web first)
| | Flutter + backend | .NET MAUI + Blazor | React Native + Expo (web) | React PWA + Capacitor | Pure PWA |
|---|---|---|---|---|---|
| Single-codebase reach | Android, iOS, web, Windows, macOS, Linux | Android, iOS, Windows, macOS; web needs Blazor (partly separate UI) | Android, iOS, web; desktop weak | Web, Android, iOS (wrapped); desktop via Electron | Everything with a browser |
| Dev speed (solo) | High: hot reload, rich widgets, one UI language | Medium: MAUI tooling is still rough, more platform bugs | High if you know React | High if you know React | Highest at first |
| Performance | Very good (own rendering engine); web bundle is heavier | Good native; Blazor WASM loads slowly | Good native; web via RN-web is OK | Webview: OK for a book app | Webview/browser |
| Barcode/camera | `mobile_scanner`: excellent on Android/iOS, works on web | Plugins exist (ZXing.Net.Maui), less polished | `expo-camera`: excellent | Capacitor ML Kit plugin: good | Browser camera + JS decoder; flaky on iOS |
| Push | FCM via `firebase_messaging` | Possible, more DIY | Expo push: very easy | Capacitor push: good | Web Push; iOS only if installed to home screen |
| Offline | Good (local DB packages) | Good | Good | Good | Service worker: OK |
| Hosting cost | Web build is static hosting = free | Blazor Server needs a running server; WASM can be static | Static = free | Static = free | Static = free |
| Your learning curve | Dart is small and C#-like; you've touched it | C# known, but MAUI + Blazor = two UI models | JS/TS known; React + RN concepts to learn | Same as left | Lowest, but hits platform limits |

**Recommendation: Flutter + Supabase.**
- One Dart codebase covers Android + web now, and iOS + desktop later without a rewrite.
- `mobile_scanner` is the best barcode option of these choices.
- Dart reads like C#, and you've already touched it.
- Supabase removes most of the backend code a beginner would otherwise write: auth, Postgres + PostGIS, storage, realtime and row-level security.
- Supabase runs **entirely locally** (Supabase CLI + Docker) at $0, and the same migrations later deploy to the free cloud tier unchanged.

**Why not ASP.NET Core now:** it means more code (auth, API, hosting), and free .NET hosting is awkward. It remains a valid later choice if business logic outgrows SQL functions, because Postgres stays the same database.

### Full stack
| Concern | Choice | Cost |
|---|---|---|
| App | Flutter (stable), Riverpod (state), go_router (navigation), `flutter_localizations` + `intl` (i18n) | Free |
| Backend | Supabase: Postgres 15 + **PostGIS**; SQL functions (RPC) for business logic; **Row-Level Security** for privacy | Local: free; Cloud free tier (500 MB DB, 1 GB storage; pauses after 7 days idle) |
| Auth | Supabase Auth (email + password; email confirmation on cloud) | Free |
| Images | Supabase Storage for avatars only. Book covers are hot-linked from Open Library/Google Books URLs, not stored | Free |
| Scheduled jobs | `pg_cron` inside Postgres (daily reminder/overdue job) | Free |
| Realtime | Supabase Realtime on the `notifications` table, so the in-app bell updates live | Free |
| Book metadata | Open Library API (no key, CORS OK) first, Google Books API (free key) as fallback | Free |
| Map/pin | `flutter_map` + OpenStreetMap tiles (low traffic, attribution shown) | Free |
| Barcode | `mobile_scanner` | Free |
| Push (v1.1) | Firebase Cloud Messaging, sent from a Supabase Edge Function | Free |
| Web hosting (friends phase) | Cloudflare Pages or GitHub Pages (static Flutter web build) | Free |
| Android distribution (friends phase) | Signed APK shared directly, or Play Console internal testing later ($25 one-time, so deferred) | Free |
| Local tooling | Flutter SDK, Android Studio (emulator), Docker Desktop (free for personal use), Supabase CLI, VS Code | Free |

---

## 4. Architecture
```
┌───────────────────────────── Flutter app (Android / Web) ─────────────────────────────┐
│ features/: auth · library · add_book(scan/search/manual) · discover · loans · reading │
│            social · notifications · settings          core/: router, theme, l10n      │
│ Riverpod providers ──> repositories ──> supabase_flutter client                       │
└───────────┬────────────────────────────────────┬──────────────────────────────────────┘
            │ HTTPS (PostgREST, RPC, Auth, RT)   │ HTTPS
            ▼                                    ▼
┌─────────── Supabase (local Docker → cloud free) ───────────┐   ┌──────────────────────┐
│ Postgres + PostGIS                                          │   │ Open Library API     │
│  • tables (Section 5) • RLS policies (Section 7)            │   │ Google Books API     │
│  • RPCs: search_book_holders, request_loan, respond_loan,   │   └──────────────────────┘
│    confirm_handover, confirm_return, suggest_loan_days ...  │
│  • triggers → notifications rows   • pg_cron daily job      │
│ Auth · Storage (avatars) · Realtime (notifications)         │
└─────────────────────────────────────────────────────────────┘
```
**Principle:** the client is untrusted. Every privacy rule and every loan state transition is enforced in Postgres through RLS and `security definer` RPCs that validate the caller and the current state. The app only calls them.

**Repo layout**
```
VennskApp/
  app/                      Flutter project
    lib/core/…  lib/features/<feature>/{data,ui,providers}
    lib/l10n/app_en.arb  app_tr.arb  app_nb.arb
    l10n.yaml
  supabase/
    config.toml
    migrations/0001_init.sql, 0002_rls.sql, 0003_rpc_loans.sql, …
    seed.sql                fake neighbors + books for local testing
    tests/*.sql             pgTAP tests (visibility + loan transitions + duration)
  docs/                     this plan, privacy notes
```

---

## 5. Data model
All tables use `uuid` primary keys and have `created_at` / `updated_at`.

| Entity | Key fields | Notes |
|---|---|---|
| **profiles** | `id` (= auth.users.id), `username` (unique), `display_name`, `avatar_path`, `locale` (`en`/`tr`/`nb`), `area_name` (e.g. "Grünerløkka", typed or reverse-geocoded), `home_cell geography(Point)` (**snapped**, see below), `default_visibility` (enum), `profile_visibility` (enum), `birth_year_confirmed_18` bool, `thumbs_up`, `thumbs_down` | No address and no raw coordinates are ever stored |
| **books** (shared catalog) | `isbn13` (unique, nullable), `isbn10`, `title`, `authors text[]`, `page_count` (nullable), `cover_url`, `language`, `published_year`, `source` (`openlibrary`/`google`/`manual`), `external_id`, `created_by` | One row per edition. Manual entries have no ISBN. Metadata is shown as-is, in any language |
| **library_items** (a user's copy) | `owner_id → profiles`, `book_id → books`, `owned` bool, `status` (`unread`/`reading`/`read`), `rating` 1–5, `review` (≤ 500 chars), `lendable` bool, `visibility` (enum, **nullable** = use profile default), `condition_note` | Unique (owner_id, book_id) |
| **reading_sessions** | `user_id`, `book_id` (nullable), `session_date`, `pages` (>0), `minutes` (>0) | Always private to the user |
| **finished_books** | `user_id`, `book_id`, `started_on`, `finished_on`, `pages_override` (nullable) | Main input for the speed model. Created when status → read (dates prompted) |
| **friendships** | `requester_id`, `addressee_id`, `status` (`pending`/`accepted`) | Unique unordered pair. "Friends" = accepted, either direction |
| **blocks** | `blocker_id`, `blocked_id` | Hides both users from each other everywhere |
| **reports** | `reporter_id`, `reported_id`, `loan_id` (nullable), `reason`, `details`, `status` | Manual review |
| **loans** | `library_item_id`, `owner_id`, `borrower_id`, `status` (enum below), `message`, `duration_days`, `duration_source` (`auto`/`manual`), `suggested_days`, `handover_at`, `due_at`, `returned_at`, `extension_days_requested`, `extension_status`, `owner_feedback` / `borrower_feedback` (`up`/`down`/null) | At most one *open* loan per item (partial unique index) |
| **loan_events** | `loan_id`, `actor_id`, `type`, `payload jsonb` | Audit trail / timeline UI |
| **notifications** | `user_id`, `type`, `payload jsonb` (ids + params, **not** translated text), `read_at` | The app renders text from ARB keys in the viewer's language |

**Enums**
- `visibility`: `private` < `friends` < `neighbors` < `public`. The order matters: each level includes the ones before it.
- `loan_status`: `requested` → `accepted` → `active` → `returned`. Side exits: `declined`, `cancelled` (by the borrower before handover). Overdue is **derived** (`active AND now() > due_at`), not stored.

**Coarse location:**
1. The pin the user drops is snapped on the server to the center of a ~1 km grid cell (round lat to 0.01°, lon to 0.01°/cos(lat)).
2. Only that snapped point is stored, in `geography` with a GiST index.
3. Distances shown to others are rounded: "same area" (< 1 km), "~2 km", "~4 km".
4. The neighborhood radius is **5 km**, a fixed constant for the prototype.

---

## 6. Reading-speed & loan-duration algorithm
The goal is to suggest how many **calendar days** this borrower needs for this book. The key quantity is **pages per calendar day (ppd)**: it includes days they don't read, so it reflects real life better than pages/hour.

### Inputs
- `P` = book pages: `books.page_count`, or 300 if unknown, and the UI asks the owner to confirm.
- Completed books from the last 12 months, each with rate `r_i = pages_i / max(1, finished_on − started_on + 1)`.
  - **Outliers are discarded:** r_i > 250, or a span > 365 days.
- Sessions: used when there are fewer than 2 completed books. Formula: `r_sess = pages read in the last 28 days / max(7, days since first session in that window)`.

### Estimate
```
p0 = 20 pages/day      # cold-start prior (≈ 30 min/day at ~40 pages/hour)
k  = 2                 # prior strength, in "books"

obs = weighted median of the last 5 r_i (weights 5,4,3,2,1, newest first)
n   = number of valid completed books (cap 10)
if n < 2 and session data exists:  obs = r_sess ; n = min(n + weeks_with_sessions/2, 2)
if no data at all:                 obs = p0     ; n = 0

ppd    = (k·p0 + n·obs) / (k + n)          # Bayesian shrinkage toward the prior
buffer = 1.20 + 0.30 · k/(k + n)           # 1.50 for a new user → ~1.25 with history
days   = ceil(P / ppd · buffer) + 2        # +2 days for handover/return logistics
days   = round up to a whole week if > 14  # friendlier due dates
days   = clamp(days, 7, 60)
```
- **How it improves:** each finished book adds evidence. The prior's weight falls from 100% to 50% (2 books) to ~17% (10 books), and the safety buffer shrinks with it. The median resists one-off binge or abandoned books.
- **Privacy:** `suggest_loan_days(borrower_id, book_id)` is a `security definer` SQL function. The owner sees **only the resulting number of days**, never the borrower's stats.
- **Owner control:** when accepting, the owner sees "Suggested: 28 days (based on their reading pace)". They can keep it (`auto`) or type any value from 3 to 90 (`manual`).

### Examples
| Borrower | History | Book | ppd | buffer | Calculation | Result |
|---|---|---|---|---|---|---|
| New user | none | 320 p | 20 | 1.50 | 320/20·1.5 = 24, +2 = 26 → week | **28 days** |
| Steady reader | 6 books, median 40 ppd | 320 p | (40+240)/8 = 35 | 1.275 | 9.14·1.275 = 11.7, +2 = 13.7 → 14 | **14 days** |
| Slow reader, long book | 4 books, median 10 ppd | 600 p | (40+40)/6 = 13.3 | 1.30 | 45·1.3 = 58.5, +2 = 60.5 → clamp | **60 days** |
| Quick novella | 6 books, 40 ppd | 120 p | 35 | 1.275 | 3.43·1.275 = 4.4, +2 = 6.4 → min | **7 days** |

**Later refinements:** a genre/difficulty factor; accounting for books currently on loan; per-user learned buffer from actual on-time returns.

---

## 7. Privacy & visibility rules
```
level(viewer, owner):
  if viewer = owner                          → OWNER
  if blocked either way                      → NONE   (also hides profile, search results, requests)
  if accepted friendship                     → FRIEND
  if both have home_cell and ST_DWithin(owner.home_cell, viewer.home_cell, 5 km) → NEIGHBOR
  if viewer is signed in                     → PUBLIC_USER
  else                                       → ANON   (prototype: anon sees nothing)

allowed(vis, rel):
  private   → OWNER
  friends   → OWNER, FRIEND
  neighbors → OWNER, FRIEND, NEIGHBOR
  public    → OWNER, FRIEND, NEIGHBOR, PUBLIC_USER

can_see_item(viewer, item)   = allowed(coalesce(item.visibility, owner.default_visibility), level(viewer, item.owner))
can_see_profile(viewer, p)   = allowed(p.profile_visibility, level(viewer, p))
                               OR viewer has an open/past loan with p   (so lenders/borrowers can recognise each other)
can_request_loan(viewer, item) = can_see_item AND item.lendable AND item.owned
                                 AND viewer ≠ owner AND no open loan on item AND not blocked
```
**Other rules:**
- **Per-book override wins.** A public book on a friends-only profile shows the owner's display name + area name, but not the rest of the profile. The UI warns about this when you set it.
- **What others see of location:** `area_name` and a rounded distance. Raw `home_cell` is never returned by any API: it is excluded from RLS-readable columns via a view, and only used inside functions.
- **Private data:** reading sessions, finished books and the speed estimate are always private to their owner.
- **Search order:** `search_book_holders(book_id)` returns rows the caller may see, grouped Friends → Neighbors (by distance) → Public. Only lendable copies show in the "can borrow" group; non-lendable visible copies show as "also on shelves of…".
- **Enforcement and tests:** RLS on every table, plus pgTAP tests for each row of the `allowed` table.

### Legal and privacy basics (prototype scope; full review before any public launch)
- **Age:** 18+ (self-declared checkbox), because users hand physical items to people they don't know. This is simpler than GDPR/KVKK parental-consent rules.
- **Data minimisation:** no address, no exact location, no phone number in the MVP.
- **Delete account:** cascades to all of the user's data. Loans are kept, anonymised, only while still open.
- **Export:** a JSON export comes in v1.1. For the prototype, document how to export manually.
- **Privacy notice:** a short screen in plain language, covering both GDPR and KVKK basics (purpose, data held, retention, rights).

---

## 8. i18n plan
- **Tooling:** Flutter `gen-l10n` with ARB files (`lib/l10n/app_en.arb` as the template; `app_tr.arb` and `app_nb.arb` added later), set up with `l10n.yaml` and `flutter_localizations`.
- **Rule:** no hard-coded UI strings. A lint check / PR habit enforces it. Keys are semantic, e.g. `loanRequestSentTitle`.
- **Plurals and gender:** ICU message syntax, e.g. `{count, plural, one{1 day left} other{{count} days left}}`. This handles Turkish (no plural inflection after numbers) and Norwegian correctly.
- **Dates and numbers:** `intl` `DateFormat.yMMMd(locale)` and `NumberFormat`, never manual string building. All dates are stored in UTC and shown in local time.
- **Locale selection:** device locale if supported, otherwise English. The user can override it in Settings, and it is saved in `profiles.locale`.
- **Notifications:** stored as `type + params` and rendered client-side in the viewer's language, so changing language re-translates old notifications.
- **Book metadata** is shown as-is.
- **Translation workflow:**
  1. English is written first.
  2. Turkish is AI-drafted, then reviewed by you (milestone M7).
  3. Norwegian is AI-drafted and marked "needs native review" before any public launch (v1.1).
- **Tone glossary:** neighbor = komşu = nabo; lend = ödünç vermek = låne ut; borrow = ödünç almak = låne. This keeps the warm wording consistent across languages.

---

## 9. Key MVP screens & flows
1. **Welcome → Sign up** (email, password, 18+ checkbox) → **Set up** (display name, username, drop pin on map → shows "You'll appear as *Grünerløkka*", default visibility picker with plain-language explanations).
2. **Home:** four tabs.
   - **My shelf:** grid of covers, filter by status, "+" button.
   - **Discover:** search box; results show "3 can lend: 1 friend, 2 neighbors".
   - **Loans:** Borrowing / Lending / Requests.
   - **Me:** stats, reading log, friends, settings.
3. **Add book:**
   - Choose Scan / Search / Manual.
   - Scan has a **bulk mode**: the camera stays open, and each ISBN is looked up and added with a toast and undo.
   - After adding, a quick sheet sets status / lendable / visibility, defaulting to the profile settings.
4. **Book detail (my copy):** status, rating, review, visibility override, lendable toggle, loan history.
5. **Discover result → Holder list → Request:** an optional warm message, e.g. "Hi neighbor! I'd love to read this."
6. **Owner request card:** Accept (suggested days + edit) / Decline (optional kind reason) → both see a chat-free "Arrange handover" hint (meet at a public place) → **Confirm handover** (both tap) → due date set.
7. **Active loan:** countdown, "Request extension", "Mark returned" (owner) → 👍/👎 feedback.
8. **Reading log:** quick "Log session" (pages, minutes, date) and "Finished!" with start/finish dates. Stats card.
9. **Notifications:** bell with live updates.
10. **Profile (other user):** area, 👍 count, their visible shelf, Add friend, Block/Report in the overflow menu.

**Accessibility and responsive design:**
- Material 3 with WCAG AA contrast, and every interactive element has a Semantics label.
- Text scales to 200%.
- Tap targets ≥ 48 dp; never rely on color alone (status = icon + text).
- Responsive breakpoints: <600 dp phone layout with bottom tabs; ≥600 dp navigation rail plus two-pane list/detail.

**Offline:** not in the prototype. The app shows a friendly "You're offline" banner. A cached read-only shelf comes in v1.1.

---

## 10. Milestones (solo, part-time, ~8–10 h/week; estimates are rough)
| # | Milestone | Concrete tasks | Done when |
|---|---|---|---|
| **M0** | Setup (1 wk) | Install Flutter, Android Studio, Docker Desktop, Supabase CLI. `git init` (branch `main`), add `.gitignore` (Flutter + Supabase `.env`/`.branches`/`.temp`), remote `origin` = `https://github.com/yusuf-ridvan-celikbas/VennskApp.git`, commit this plan as `docs/PLAN.md` and push. After that, commit at the end of each milestone. Create `app/` (`flutter create`), `supabase init` + `supabase start`. Add riverpod, go_router, supabase_flutter, flutter_localizations, intl. Set up `l10n.yaml` + `app_en.arb`. App shell with 4 tabs and a theme. | Empty app runs on the Android emulator and in Chrome against local Supabase; a string comes from ARB |
| **M1** | Auth & profile (1–2 wks) | Migration: `profiles`, enums. Sign up/in/out screens. Onboarding: name, username, map pin → `set_home_location(lat,lon)` RPC that snaps to the grid. Visibility defaults. | A new user can register, set an area, and see their profile |
| **M2** | Library (2–3 wks) | Migrations: `books`, `library_items`. Open Library search + ISBN lookup service (Google Books fallback). `upsert_book_from_isbn` logic. Manual entry form. `mobile_scanner` with bulk mode. Shelf grid, book detail, status/rating/review/lendable/visibility. | 20 real books scanned on the phone in under 5 minutes |
| **M3** | Friends, visibility & discovery (2 wks) | Migrations: `friendships`, `blocks`. RLS + `relationship_level()` + `can_see_item()`. `search_book_holders` RPC. **seed.sql** with ~15 fake users spread around a test city with varied visibility. Discover UI, other-user profile. **pgTAP tests** for every visibility/relationship combination. | Logged in as seeded users A/B/C, each sees exactly what the rules allow; tests are green |
| **M4** | Lending flow (2–3 wks) | Migrations: `loans`, `loan_events`. RPCs: `request_loan`, `respond_loan`, `cancel_loan`, `confirm_handover`, `request_extension`, `respond_extension`, `confirm_return`, each validating actor + state. Loans tab UI and timeline. Manual duration only at first. pgTAP for illegal transitions. | Full request → return cycle between two emulators/browsers |
| **M5** | Reading speed & auto duration (1–2 wks) | Migrations: `reading_sessions`, `finished_books`. Log UI, stats card. `suggest_loan_days` SQL function exactly as in Section 6. pgTAP tests using the 4 example rows. Show the suggestion in the accept dialog. | The owner sees the suggested days; the numbers match the examples table |
| **M6** | Notifications & minimal trust (1–2 wks) | `notifications` table, triggers on loan/friend events, Realtime bell. `pg_cron` daily job: due-in-2-days + overdue. Block/report. 👍/👎 after return. | Events show up live; overdue appears the day after the due date (test by moving the clock in SQL) |
| **M7** | Polish & friends demo (1–2 wks) | Turkish ARB (you review). Locale switch in settings. Empty states, warm copy pass, accessibility pass, responsive two-pane web. Privacy notice + delete account. Create the Supabase **cloud free** project, `supabase db push`. Deploy the Flutter web build to Cloudflare Pages. Build a signed APK. Invite 3–5 friends. | Friends can sign up from their phones/browsers and complete a loan |

Total ≈ 12–18 part-time weeks. Each milestone ends with something you can show.

---

## 11. Risks, open questions & assumptions
**Risks**
- **Free-tier limits:** the Supabase cloud project pauses after 7 days idle, so open the dashboard or app weekly during the demo. Open Library rate limits are fine at this scale; Google Books allows 1,000 requests/day.
- **Missing page counts in metadata:** fall back to 300 and ask the owner to confirm or edit. Users can correct `page_count` on their copy.
- **Barcode scanning in mobile web browsers** is less reliable than on Android. The Android app is the main path for scanning.
- **Cold start / empty neighborhood:** a demo with friends only works if they are near each other or friends in-app. Seed data covers local testing.
- **SQL-heavy logic is new territory for a beginner.** Mitigated by small RPCs, pgTAP tests, and keeping every rule in this document.
- **Physical-world safety:** keep the "meet in public" guidance; no exact addresses ever.

**Assumptions**
- Neighborhood = 5 km radius between snapped cells, fixed for now.
- One loan per item at a time.
- No in-app chat: users coordinate the handover outside the app via the optional message. This is a deliberate scope cut; simple chat could come in v1.1.
- 18+ only.
- English is required for the demo; Turkish comes in M7 and Norwegian in v1.1.

**Open questions for later**
- Launch city/country. This decides the legal review and Play Store listing.
- Should the neighborhood radius be user-adjustable (1–10 km)?
- Should lenders be able to require "friends of friends" only?
- Should there be a deposit or "trust level" system? No money is involved by design; reputation only.
- Who reviews reports once real strangers use the app?

---

## Verification (how we'll know the prototype works)
- **DB tests:** `supabase test db` (pgTAP) covers every visibility/relationship combination, every illegal loan transition, and `suggest_loan_days` against the 4 worked examples.
- **Flutter tests:**
  - widget tests for the add-book and accept-loan dialogs
  - a unit test that every ARB key exists in all present locales
  - `flutter analyze` clean
- **Manual end-to-end (local):**
  1. `supabase start` + seed.
  2. Run the app on the Android emulator as user A and in Chrome as user B.
  3. A scans books, sets one book to "neighbors" and one to "friends".
  4. B (a neighbor, not a friend) sees only the first in Discover.
  5. B requests it. A sees the suggested days and accepts. Both confirm the handover.
  6. Shift `due_at` into the past in SQL and run the cron job: overdue notification appears.
  7. A confirms the return, and 👍 feedback is recorded.
- **Friends phase:** repeat the flow above on the cloud deployment with real phones.

---

## Decision log (during implementation)
- 2026-10-27: Loans that are accepted but not handed over within **7 days** are cancelled automatically (hourly `pg_cron` job `expire-stale-loans`).
- 2026-10-27: Loan partners can see each other's basic profile while a loan is open and for **30 days** after it ends.
- 2026-10-27: Google Books fallback needs a free API key (`GOOGLE_BOOKS_API_KEY`); the anonymous quota is unusable.
- 2026-10-27: Loan reminders run daily at **07:00 UTC** (`loan-reminders`). "Due soon" (within 2 days) goes to the borrower; "overdue" goes to both people, once per due date (an extension earns a fresh reminder).
- 2026-10-27: Only the thumbs-up count is shown on profiles; thumbs-down is stored for review but never displayed.
- 2026-10-27: Reports can't be read through the API at all; review them in Supabase Studio (`public.reports`). A repeated report for the same person and reason updates the open one.
- Known follow-up: limit how often a user can move their home area, so distance labels can't be used to narrow down someone's grid cell.
