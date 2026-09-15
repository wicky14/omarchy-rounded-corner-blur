# Rounded Corner Blur

Adjust your windows' corner rounding, transparency, and background blur from a
top-bar dropdown — without touching any config file while you tweak.

## Features

- **Bar-widget dropdown** — click the sliders icon in the top bar panel.
- **Corner rounding** — 0–30 px.
- **Opacity** — active and inactive window opacity, 50–100%.
- **Blur** — toggle plus size (0–32) and passes (1–6).
- **Presets** — Default, Rounded, Glass, Frosted, Minimal (one click). The
  active preset stays highlighted; adjusting a slider deselects it.
- **Apply & restart shell** — one button that writes the current settings,
  reloads Hyprland, and restarts the bar. No terminal needed.
- **Auto-revert** — after a preset click or slider drag the change is applied
  live on the window, but a 15-second countdown starts; unless you press
  **Apply**, the panel restores the previous state automatically.
- **Reset to default** — removes the stored state, reloads Hyprland, and
  restarts the bar, returning to Omarchy's own defaults (the active theme
  wins).
- **Keyboard friendly** — arrows adjust, Enter toggles/activates, Tab cycles,
  Esc closes. Fully mouse-friendly too.

| Preset  | Rounding | Active | Inactive | Blur     |
| ------- | -------: | -----: | -------: | :------- |
| Default | 0        | 100%   | 100%     | off      |
| Rounded | 14       | 100%   | 100%     | off      |
| Glass   | 14       | 88%    | 80%      | 8 / 2    |
| Frosted | 10       | 90%    | 85%      | 12 / 3   |
| Minimal | 6        | 92%    | 85%      | 6 / 2    |

## Install

```bash
omarchy plugin add https://github.com/wicky14/omarchy-rounded-corner-blur.git --enable --yes
```

No manual config setup needed — the plugin wires itself up on first launch: it
copies `appearance.lua` to `~/.config/hypr/` and adds
`require("hypr.appearance")` to `~/.config/hypr/hyprland.lua` automatically, then
reloads Hyprland.

## Usage

Click the sliders icon (right side of the bar by default) to open the panel.
Drag a slider or use the arrows / +/- keys. Hitting a preset applies it
immediately and highlights the active preset. A 15-second countdown then
starts: the change is live on your windows, and if you do **not** press
**Apply & restart shell** in time, the previous state is restored automatically.
**Apply & restart shell** locks the change in and restarts the bar (handy after
a plugin update). **Reset to default** clears the stored state and restarts the
bar, so Hyprland falls back to the values Omarchy / your theme set.

## How it works

- On open, the widget reads your current Hyprland values (`hyprctl getoption`),
  so the sliders always start where your setup actually is.
- Presets, sliders, and the blur toggle change live on the window and start the
  15-second auto-revert countdown (`~/.local/state/omarchy/appearance.lua` is
  written instantly, then `hyprctl reload`).
- If the countdown runs out, the previous state is written back and reloaded;
  **Apply & restart shell** cancels the countdown, keeps the new values, and
  restarts the bar.
- `~/.config/hypr/appearance.lua` (auto-installed on first launch) applies that
  state via `hl.config({ decoration = ... })`.
- **Reset** deletes the state file, reloads, and restarts the bar — no leftover
  state, your theme defaults win again.

The plugin never edits `looknfeel.lua` or theme files. On first launch it adds a
single `require("hypr.appearance")` line to `hyprland.lua` and an
`appearance.lua` module.

## Uninstall

```bash
omarchy plugin remove custom.rounded-corner-blur --yes \
  && sed -i 's|^require("hypr.appearance")|-- require("hypr.appearance")|' ~/.config/hypr/hyprland.lua \
  && hyprctl reload
```

The `require` line is commented out (not deleted) so the state file is never
touched again after uninstall — no leftover state, your theme defaults win
again.

## License

MIT — see [LICENSE](LICENSE).