# Fermah Quiz Hub (Flutter)

A community quiz and games site for the Fermafia, built with Flutter web.
Unofficial community project, not affiliated with, endorsed by, or
sponsored by Fermah.

## What it is

- 6 quizzes, 45 questions with explainers (Fermah Basics, ZK Zero to Hero,
  Proof Systems Arena, Kernel and ULTRAMINT, True or False Blitz,
  Fermafia Community). Each question has a 30 second timer, streaks and
  a time bonus.
- 4 mini games: Proof Pairs, Proof Rush, ZK Scramble, Fermah Says.
- Shared leaderboard, saved permanently in the project database.
- Share card maker: type your name, upload your profile picture, download
  the card as a PNG and post it on X or Discord with a gFermah caption.
- Learn Fermah cheat sheet with links to the official site, X, Discord
  and ULTRAMINT.
- Finn the dolphin mascot, drawn in Flutter.

Fermah has not confirmed any token. Never trust anyone promising a
Fermah token or airdrop.

## Leaderboard

The leaderboard lives in `api/leaderboard.js`, a Vercel serverless function
that stores scores in a Vercel KV store (Upstash Redis) through its REST
API. The board is live: scores are saved to the shared leaderboard and
stay saved permanently. On a local run the board shows a "not active yet"
note, which is expected, because the KV store is only linked on Vercel.

## Deploy on Vercel

1. Push this folder to a GitHub repository.
2. In Vercel, import the repository as a new project.
3. Build command: `flutter build web --release --no-web-resources-cdn`
   (the `--no-web-resources-cdn` flag bundles CanvasKit locally so the
   site does not depend on the Google CDN at runtime)
4. Output directory: `build/web`
5. Create a Vercel KV store and link it to the project, so
   `KV_REST_API_URL` and `KV_REST_API_TOKEN` are injected as
   environment variables.
6. Deploy. Open the site, play a quiz, save a score, and check that
   the leaderboard shows it.

## Run locally

```sh
flutter pub get
flutter run -d chrome
```

The leaderboard API is not available on a local run, so the board shows
its "not active yet" note there. That is expected. The board only works
on the deployed site with the KV store linked.
