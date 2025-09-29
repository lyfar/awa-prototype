# awa_01_spark

A web-first prototype built with Flutter.

## Prerequisites

- Flutter SDK installed with web support (run `flutter config --enable-web` once if web devices do not show up).
- Google Chrome installed.

## Run The Prototype In Chrome

1. From this `prototype` directory run `flutter devices` and confirm a `Chrome (web)` device is listed.
2. Launch the app with `flutter run -d chrome`. Flutter will build the web bundle and open a Chrome window that is wired up for hot reload/restart.
3. When you are done, press `q` (or `Ctrl+C`) in the terminal to stop the running session and close the debug Chrome instance.

If you only need a one-off run without keeping the process alive, add `--no-resident` (`flutter run -d chrome --no-resident`).
