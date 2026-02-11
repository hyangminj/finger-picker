# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Chwazi-like finger picker web app for random selection. Multiple people place fingers on a touch screen, and after a countdown, one finger is randomly chosen with visual effects.

## Running Locally

Open directly in a browser:
```bash
open index.html
```

Or serve with a local server:
```bash
npx serve .
```

## Architecture

**Single-file application**: All HTML, CSS, and JavaScript are contained in `index.html`. There are no dependencies, no build step, and no external libraries.

### Key Components

- **Touch/Mouse Event System**: Handles multi-touch input (up to 16 simultaneous touches) with mouse fallback for desktop testing
- **State Machine**: `idle` → `touching` → `countdown` → `selected` states control the application flow
- **Visual Effects System**:
  - Canvas background for ambient floating particles
  - DOM elements for finger circles with 3D gradient effects
  - Particle burst, expanding rings, and pulse animations for winner
  - SVG countdown ring in top-right corner
- **Countdown Mechanism**: 2-second timer that resets when new fingers join, using `requestAnimationFrame` for smooth progress updates

### State Flow

1. **idle**: No fingers on screen, prompt visible
2. **touching**: 1 finger detected, prompt hidden
3. **countdown**: 2+ fingers detected, countdown ring appears and animates
4. **selected**: Winner chosen, losers fade out, winner pulses with effects

### Mobile Optimizations

The app uses extensive touch handling and gesture prevention for reliable mobile behavior:
- `touch-action: none` prevents default browser gestures
- `user-scalable=no` prevents pinch-to-zoom
- Explicit `preventDefault()` on touch events
- `gesturestart/change/end` event prevention for iOS Safari
- Pull-to-refresh and overscroll prevention

### Color System

16 predefined colors in the `COLORS` array are cycled through for each finger. Colors are used for:
- Finger circle gradients (with programmatic lightening/darkening)
- Glow effects and shadows
- Particle effects
- Winner label

### Performance Considerations

- Background particles limited to 30 concurrent
- `devicePixelRatio` used for crisp canvas rendering on high-DPI screens
- `will-change` CSS property on finger elements
- `requestAnimationFrame` for all animations
- Efficient particle cleanup via reverse iteration
