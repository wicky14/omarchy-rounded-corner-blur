# Rounded Corner Blur

Adjust your windows' corner rounding, transparency, and background blur from a
top-bar dropdown — without touching any config file while you tweak.

## Features

- **Bar-widget dropdown** — click the sliders icon in the top bar panel.
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

No manual config setup needed — the plugin wires itself up on first launch: it
copies `appearance.lua` to `~/.config/hypr/` and adds
`require("hypr.appearance")` to `~/.config/hypr/hyprland.lua` automatically, then
reloads Hyprland.

A shell restart is required for the bar to pick up newly added widget files:

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
- `~/.config/hypr/appearance.lua` (auto-installed on first launch) applies that
  state via `hl.config({ decoration = ... })`.
- **Reset** deletes the state file and reloads — no leftover state, your theme
  defaults win again.

The plugin never edits `looknfeel.lua` or theme files. On first launch it adds a
single `require("hypr.appearance")` line to `hyprland.lua` and an
`appearance.lua` module; removing the plugin plus those two files fully restores
Omarchy.

## Uninstall

```bash
omarchy plugin remove custom.rounded-corner-blur --yes
rm ~/.config/hypr/appearance.lua
rm ~/.local/state/omarchy/appearance.lua
```

Then remove the `require("hypr.appearance")` line from
`~/.config/hypr/hyprland.lua`:

```bash
sed -i '/require("hypr.appearance")/d' ~/.config/hypr/hyprland.lua
```

Apply with:

```bash
hyprctl reload
```

## License

MIT — see [LICENSE](LICENSE).