# Phase One

Flutter web dashboard for the Phase 1 Stabilization protocol. Installable as a
PWA on phone and laptop. All data is stored in the browser's local storage;
use Settings > Copy export / Paste import to move it between devices.

## Run locally

    C:\src\flutter\bin\flutter run -d chrome

## Build and serve the release bundle

    C:\src\flutter\bin\flutter build web --release
    python -m http.server 8787 --directory build/web

Then open http://localhost:8787 and use the browser's "Install app" option.

## Put it on your phone

Host `build/web` anywhere static (GitHub Pages, Netlify, Cloudflare Pages,
Firebase Hosting). Notifications and PWA install need HTTPS, which all of
those provide for free.

## What it does

- Today: daily floor habits with streaks, 15-minute Build timer, Pause Gate
  (delay + reason before any escape), 7-day grid, tomorrow's one line.
  After 10 PM it collapses to the one-line box only.
- Friction: one-time setup checklist with links to the blocking tools, and
  the gate log of walked-away vs went-through.
- Scripts: the three assertiveness frameworks, one-tap copy.
- Build: 6-week, 42-micro-action side-hustle roadmap with notes.
- Review: Sunday four questions, weekly weight, Phase 2 gate (4 weeks at 5/7).
- Settings: browser reminders (fire while the app is open or installed and
  running in the background), install instructions, export/import.
