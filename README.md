# Finger Picker

A Chwazi-like finger picker app for random selection. Multiple people place their fingers on the screen, and after a countdown, one finger is randomly chosen with visual effects.

Available as both a **web app** and a **Flutter mobile app**.

## Web Version (`web/`)

A single-file web app with no dependencies or build step.

### How to Use

1. Open `web/index.html` on a touch-enabled device (or serve it locally)
2. Have everyone place a finger on the screen
3. Wait for the countdown ring (top-right) to complete (~2 seconds)
4. One finger is randomly selected with a glow effect
5. Tap anywhere to reset and go again

### Running

```bash
open web/index.html
# or
npx serve web
```

### Features

- Multi-touch support for up to 16 simultaneous fingers
- Each finger gets a unique colored circle with a 3D gradient
- 2-second countdown after all fingers are placed (resets if new finger joins)
- Winner selection with particle burst, expanding rings, and pulse animation
- Ambient floating background particles
- Dark theme with polished animations
- Works on iOS Safari, Android Chrome, and desktop browsers (mouse fallback)

## Flutter Version (`flutter/`)

A native mobile app built with Flutter, with full Korean language support.

### Running

```bash
cd flutter
flutter pub get
flutter run
```

See [`flutter/INSTALLATION.md`](flutter/INSTALLATION.md) for detailed setup instructions and [`flutter/DEPLOYMENT_GUIDE.md`](flutter/DEPLOYMENT_GUIDE.md) for deployment.

## Project Structure

```
/
├── web/                ← Web version (single-file app)
│   └── index.html
├── flutter/            ← Flutter mobile app
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── ...
├── README.md
├── CLAUDE.md
└── LICENSE
```

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
