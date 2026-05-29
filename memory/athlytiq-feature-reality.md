---
name: athlytiq-feature-reality
description: Which Athlytiq features actually work vs. UI-only shells (per app owner)
metadata:
  type: project
---

Per the app owner (2026-05-29): **most of Athlytiq's features do NOT actually work — they are UI shells with no working backend/data flow.**

- ✅ **Workout / exercise tracking works** — this is the one solid, functional foundation (ActiveWorkoutScreen, CompletedWorkout in sqflite, exercise library).
- ⚠️ **AI workout recommendation is INCOMPLETE** and does **not integrate** with the current workout & exercise selection (the Gemini workout generator exists but produces standalone plans, not wired into the real exercise library / selection flow).
- ❌ **Nutrition** (food logging, meal plans), and **other services** (community, marketplace, trainer, messaging) are **UI-only — no working features / no real persisted data**, despite tables/screens existing.

**Why this matters:** the `food_logs` sqflite table + `NutritionNotifier.addFoodLog` exist in code but in practice there is little/no real nutrition data. Any feature assuming real nutrition data (e.g. a nutrition↔performance AI bridge) is premature.

**How to apply:** build new work on the ONE working pillar — workout/exercise tracking — and prefer completing/integrating the half-done AI workout recommendation over features that depend on non-functional data sources. Verify a feature actually persists/loads real data before building on top of it. See [[athlytiq-architecture]].
