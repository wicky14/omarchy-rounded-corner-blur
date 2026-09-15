# Rounded Corner Blur

Adjust your windows' corner rounding, transparency, and background blur from a
top-bar dropdown — without touching any config file while you tweak.

## Features

- **Bar-widget dropdown** — click the sliders icon in the top bar (like
  YouTube Music / other Omarchy bar widgets) to open the panel.
- **Corner rounding** — 0–30 px.
- **Opacity** — active and inactive window opacity, 50–100%.
- **Blur** — toggle plus size (0–32) and passes (1–6).
- **Presets** — Default, Rounded, Glass, Frosted, Minimal (one click).
- **Reset to default** — removes the stored state and returns to Omarchy's own
  defaults (the active theme wins).
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

One-time Hyprland setup so the plugin can apply changes:

```bash
cp ~/.config/omarchy/plugins/custom.rounded-corner-blur/appearance.lua ~/.config/hypr/appearance.lua
```

Then ensure `~/.config/hypr/hyprland.lua` loads that module (add near the top,
after any `require("hypr.looknfeel")`):

```lua
require("hypr.appearance")
```

Apply with:

```bash
hyprctl reload
```

Finally, if the icon does not show up in the bar yet:

```bash
omarchy restart shell
```

> A shell restart is required for the bar to pick up newly added widget files.

## Usage

Click the sliders icon (right side of the bar by default) to open the panel.
Drag a slider or use the arrows / +/- keys. Hitting a preset applies it
immediately. **Reset to default** removes the stored state and reloads, so
Hyprland falls back to the values Omarchy / your theme set.

## How it works

- On open, the widget reads your current Hyprland values (`hyprctl getoption`),
  so the sliders always start where your setup actually is.
- Adjusting a control writes `~/.local/state/omarchy/appearance.lua` and runs
  `hyprctl reload`.
- `~/.config/hypr/appearance.lua` (which you copied above) applies that state
  via `hl.config({ decoration = ... })`.
- **Reset** deletes the state file and reloads — no leftover state, your theme
  defaults win again.

The plugin never edits `looknfeel.lua`, `hyprland.lua`, or theme files. Removing
the plugin + the one-line `require` + `appearance.lua` fully restores Omarchy.

## Uninstall

```bash
omarchy plugin remove custom.rounded-corner-blur --yes
rm ~/.config/hypr/appearance.lua
rm ~/.local/state/omarchy/appearance.lua
hyprctl reload
```

## License

MIT — see [LICENSE](LICENSE).