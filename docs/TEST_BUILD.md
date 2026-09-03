# VANTA BAY — Vertical Slice Test Build

This branch is intended to be playable from the first spawn through the end of Story Arc One.

## Controls

- WASD — move / drive
- Shift — sprint
- Space — jump / handbrake
- Mouse — camera
- RMB — aim
- LMB — fire
- R — reload
- 1 / 2 / 3 — pistol / SMG / rifle
- E — interact / enter / exit vehicle / confirm dialogue choice
- P — VANTA OS phone
- K — restart current mission from the latest autosave/checkpoint

## Test flow

1. FIRST RUN — leave Jace's apartment, reach Mateo's garage, make the Port Vanta delivery.
2. NO QUESTIONS — take the vehicle to the workshop.
3. AFTER MIDNIGHT — meet the Old Bay contact, survive the robbery, deliver to Marina.
4. WRONG PLACE — survive the deal, lose police, return to Old Bay.
5. BLACK GLASS — steal the target vehicle, evade police, deliver it and inspect the encrypted device.
6. LOSE THEM — return to Jace's apartment.
7. CLEAN SLATE — take the vehicle to Port Vanta, repaint it, change plates, clear vehicle heat, leave the workshop.
8. THE INTRODUCTION — meet Adrian Vale and make a dialogue choice that changes his trust.
9. TERMS & CONDITIONS — complete either the standard or trusted Adrian route.
10. OVERHEAD — reach the rooftop, survive the final ambush, escape to Port Vanta and finish the vertical slice.

## Save behavior

The active story slot autosaves during mission progression. Relaunching the game automatically resumes the active save. K reloads the latest autosave/checkpoint.

## Expected completion state

The HUD displays `STORY ARC COMPLETE — TEST BUILD FINISHED` and the save contains `vertical_slice_complete = true`.

## Automated build

GitHub Actions workflow `VANTA BAY Test Build` runs a headless Godot project import/parse and exports the `Web Test Build` preset. A successful workflow uploads the artifact `VANTA-BAY-Web-Test-Build`.
