# Finger Picker

A Chwazi-like finger picker web app. Multiple people place their fingers on the screen, and after a moment one finger is randomly chosen.

## How to Use

1. Open `index.html` on a touch-enabled device (or serve it locally)
2. Have everyone place a finger on the screen
3. Wait for the countdown ring (top-right) to complete (~2 seconds)
4. One finger is randomly selected with a glow effect
5. Tap anywhere to reset and go again

## Features

- Multi-touch support for up to 16 simultaneous fingers
- Each finger gets a unique colored circle with a 3D gradient
- 2-second countdown after all fingers are placed (resets if new finger joins)
- Winner selection with particle burst, expanding rings, and pulse animation
- Losers gracefully fade out
- Ambient floating background particles
- Dark theme with polished animations
- Works on iOS Safari, Android Chrome, and desktop browsers (mouse fallback)

## Running Locally

Just open the file directly:

```
open index.html
```

Or serve it:

```
npx serve .
```

## Technical Notes

- Single-file app: all HTML, CSS, and JS in one file
- No dependencies or build step
- Uses `touch-action: none` and gesture prevention for reliable mobile behavior
- Canvas background for ambient particles, DOM elements for finger circles
- CSS transitions and keyframe animations for smooth effects

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
