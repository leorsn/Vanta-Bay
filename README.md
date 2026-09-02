# VANTA BAY

VANTA BAY is an original mobile open-world game set in a sun-soaked coastal city. This repository now contains the first playable Godot 4 prototype rather than a static UI mock-up.

## Playable Phase 1

- Third-person character with camera collision
- Keyboard, mouse, and mobile touch controls
- Sprinting, jumping, procedural walk/run animation
- Walkable coastal district with collision
- Ocean Drive, connected streets, crosswalks, plaza, marina, beach, hotel, skyline, palms, parked cars, and street furniture
- Animated ocean surface
- Full dynamic day/night cycle with dawn, sunset, moonlight, fog, and automatic streetlights
- Responsive cinematic HUD for desktop and mobile
- Zero paid or copied assets: the prototype is generated from original code and primitive geometry

## Start the game

1. Install [Godot 4.3 or newer](https://godotengine.org/download/).
2. Clone or download this repository.
3. Open `project.godot` in Godot.
4. Press **F6** or the Play button.

### Desktop controls

| Action | Control |
|---|---|
| Move | WASD or arrow keys |
| Look | Mouse |
| Sprint | Shift |
| Jump | Space |
| Release mouse | Escape |

### Mobile controls

- Left thumb: virtual movement stick
- Drag on the right side: camera
- **RUN**: sprint
- **JUMP**: jump

The same project can be exported to iOS, Android, desktop, and Web from the Godot editor. An iOS export requires macOS, Xcode, and a configured Apple developer signing profile.

## Project structure

```text
scenes/main.tscn             Bootstrap scene
scripts/game.gd              Game composition and input bindings
scripts/world_builder.gd     Procedural city and environmental geometry
scripts/player_controller.gd Third-person controller and camera
scripts/mobile_hud.gd        Responsive HUD and touch input
scripts/day_night_cycle.gd   Lighting, sky, time, and streetlights
```

## Next milestones

1. Drivable vehicle, enter/exit interaction, and mobile driving controls
2. Traffic and pedestrian AI
3. First original story mission and two playable protagonists
4. Wanted system and police response
5. Shops, garage, apartments, character customization, and economy
6. Online lobby architecture for up to ten players
7. Production assets, animation, audio, optimization, and platform exports

VANTA BAY is its own IP. Development may borrow genre conventions from open-world crime games, but names, story, map, characters, code, art, audio, UI, and missions must remain original.

