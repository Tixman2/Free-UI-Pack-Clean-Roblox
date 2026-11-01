---
name: free-ui-pack-roblox
description: Build Roblox UI from the user's Free UI Pack (lft_productions): rainbow, purple, cyan, green, yellow, orange and red baked buttons, square icon buttons and five glass panels, each button with its own bubble or burst effect and sounds. Use whenever the user asks for a Roblox HUD, menu, shop, button or panel in a place that has Free_UI_Pack or ReplicatedStorage.FreeUIPack, or mentions "asset pack de ui" or this pack.
---

# Free UI Pack for Roblox

Look at `assets/pack-overview.jpg` first. That image is the whole style.

## What makes the style
- Every button is one image with its word baked in. Don't rebuild them with frames and don't put text on them.
- Colors carry meaning in the pack: rainbow = premium (Robux, Gift, Luck, Trade, WheelSpin), green = confirm or forward, red = back or delete, cyan = currencies and codes, yellow = Shop and Rebirth, orange = Inventory and Bag Pack, purple = Pet's, Setting's, Update Log.
- Each button already has its own LocalScript: hover, press, floating bubbles or a burst, and sounds. Cloning keeps them. Never add a second hover or press tween.

## Install once per place
Run `tools/install_in_studio.luau` through `execute_luau` in Edit mode, with `KIT_SOURCE` set to `src/FreeUIPack.luau`.

## Use it
```lua
local Pack = require(game.ReplicatedStorage.FreeUIPack)
Pack.Wide(parent, "Shop", { Position = UDim2.fromOffset(85, 40), OnClick = openShop })
Pack.Icon(parent, "Plus", { Position = UDim2.fromOffset(45, 270) })
local panel = Pack.Panel(gui, "Blue", { Size = Vector2.new(360, 430) })
Pack.Label(panel, "Daily Reward", { TextSize = 38, Position = UDim2.new(0.5, 0, 0, 50) })
Pack.BindScale(rootFrame)
local gui = Pack.ScreenGui(playerGui, "HUD")      -- always: modeled parts need Sibling layering
local gold = Pack.Counter(gui)                    -- coin pill that counts up with a bounce
gold.Set(1250)
local shop = Pack.Window(gui, { Title = "Shop", Color = "Blue", BannerTheme = "Yellow" })  -- shop.Body, shop.Close()
local card = Pack.Card(shop.Body, { Image = Pack.Images.Shoe, Size = UDim2.fromScale(0.48, 1), Position = UDim2.fromScale(0.25, 0.5) })
local buy = Pack.Chunky(card, { Theme = "Green", Icon = Pack.Images.Coin, Text = "100", OnClick = purchase })
buy.SetTheme("Gray")   buy.SetText("MAX")
Pack.Toast(gui, "Not enough gold!", { Color = Color3.fromRGB(255, 110, 110) })
```
Model the UI, don't just place images. Use a pack button only as a button, never as an icon or a currency display: a picture goes through `Pack.Picture` and `Pack.Images`. Anything needing its own text, such as a price, is a `Pack.Chunky`. Keep window content inside `Body`, which is fitted to the panel's inner frame.

Create a window when it opens: it destroys itself on close, so hidden buttons don't play idle sounds.
The full list of names is in the comments of `src/FreeUIPack.luau`. `examples/hud_demo.luau` is a tested starting point.

## Rules, with the reason
- Build on the client, from a LocalScript. The button scripts read `Position` once when they start, and a clone must keep running in PlayerGui.
- Place buttons by `Position`. Never put them directly under a UIListLayout or UIGridLayout: the scripts tween `Position` and fight the layout. Use one empty slot Frame per button if a layout is needed.
- `Pack.BindScale` goes on a root frame, never on a button: the scripts use the button's own UIScale.
- Wide words are limited to what is baked. For another word use `Pack.Chunky`.
- Panels are plain images, not 9-slice: stay close to the 180x215 ratio or the edges stretch.
- Game text stays in English.

## Before saying done
Screenshot in Play at the real size, hover and click one button of each kind, and read `get_console_output`.
