---
name: athlytiq-architecture
description: Athlytiq (fitnation) Flutter app architecture, stack, and feature layout
metadata:
  type: project
---

Athlytiq = monorepo: `fitnation/` (Flutter app) + `backend/` (FastAPI) + Supabase (Postgres/auth). Root `README.md`. Main branch `master`; active branch `messaging`.

**Flutter app (`fitnation/lib/`)** — NOT clean-architecture/BLoC. Layout: `api/`, `core/{components,themes}`, `helpers/`, `models/` (+ `models/trainer/`), `pages/`, `providers/`, `Screens/{Activities,Auth,Community,nutrition,Run,Trainer}`, `services/`, `widgets/{Activities,common,community,home}`.

**State mgmt:** flutter_riverpod + hooks_riverpod + provider (mixed). **Stack (pubspec):** dio, supabase_flutter, mapbox_maps_flutter (run tracking), web_socket_channel (realtime chat), flutter_chat_ui + flutter_chat_types, sqflite (offline), shared_preferences, flutter_secure_storage, syncfusion_flutter_charts + (no fl_chart), awesome_notifications + flutter_local_notifications + firebase_messaging, barcode_scan2 (nutrition scan), image_picker/file_picker, freezed_annotation + json_annotation (codegen), flutter_dotenv, go_fonts. NO bloc, NO get_it/injectable, NO go_router, NO retrofit, NO google_generative_ai yet.

**Existing screens:** Auth (login/signup/otp/forgot), Activities (list/detail), Community (feed/create_post/post_detail), nutrition, Run (run/active_run via Mapbox), Trainer (list/detail/chat). The `messaging` branch's last commit added generated chat models (serialization) — chat/messaging is the active WIP.

**Backend (`backend/app/`):** FastAPI — `api/v1/`, `crud/`, `models/`, `schemas/`, `core/`, `middleware/`, `websocket/`, `database/` (+ `workout_dataset/`), `alembic/versions/`. Docker. Supabase Postgres.

**Strategy doc** = `athlytiq_strategy.html` (root, 640 lines): positions app as "anti-fragmentation fitness layer" — AI nutrition↔performance bridge, social moat (workout completion cards, gym squads, leaderboards, streaks, verified coach badges), equipment-bundle marketplace, creator economy, Free/Pro/Elite tiers, GDPR data dashboard. See [[athlytiq-strategy-priorities]].

**Caveat:** codebase mid-refactor — stray `.bak`/`.disabled` model files exist. Reading `athlytiq_strategy.html` triggers noisy claude-mem PreToolUse hooks; tool results in this repo sometimes return with latency/duplication.
