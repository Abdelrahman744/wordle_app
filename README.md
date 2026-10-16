# Wordle

## Run in Chrome

Open a terminal in this folder (`wordle_app`) and run:

```powershell
flutter run -d chrome
```

The first run may take longer while Flutter builds the app. Leave the terminal
open while using the app. Press `r` in that terminal to hot reload changes, or
`q` to stop the app.

If dependencies have not been downloaded yet, run `flutter pub get` once before
the first launch.

## Project layout

```text
lib/
  main.dart                 App entry point
  app.dart                  App widget and theme setup
  screens/
    auth_screens.dart       Splash, sign-in, and sign-up
    main_shell.dart         Main navigation
    home_screen.dart        Home screen
    game_screen.dart        Wordle board
    stats_screen.dart       Statistics
    history_screen.dart     Past games
    profile_screen.dart     Profile and settings
    how_to_play_screen.dart Instructions
  theme/
    app_colors.dart         Shared colors
  widgets/
    shared_widgets.dart     Reusable widgets and navigation helper
test/
  widget_test.dart          App smoke test
```
