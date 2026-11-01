--!strict
-- Free UI Pack kit. Clones the pack's own buttons, so each keeps its original LocalScript
-- (hover, press, bubbles or bursts, sounds), and models the parts the pack lacks in the same style.
-- Lives in ReplicatedStorage.FreeUIPack with a Templates child.
local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Pack = {}
local templates = script:WaitForChild("Templates")

Pack.DefaultWide = Vector2.new(160, 72)
Pack.DefaultIcon = Vector2.new(72, 72)
Pack.DefaultFrame = Vector2.new(180, 215)

Pack.Images = {
	Coin = "rbxassetid://81781760189273",
	Shoe = "rbxassetid://87329254837497",
	Magnet = "rbxassetid://131659960050691",
	Sunburst = "rbxassetid://130563114903838",
}

local OUTLINE = Color3.fromRGB(10, 9, 24)
local CLICK_SOUND = "rbxassetid://122835655736085"

local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

-- Top, bottom, lip and text outline of a modeled button or banner.
local THEMES: { [string]: { Top: Color3, Bottom: Color3, Lip: Color3, Stroke: Color3 } } = {
	Green = { Top = rgb(140, 245, 70), Bottom = rgb(26, 176, 40), Lip = rgb(10, 96, 26), Stroke = rgb(6, 56, 16) },
	Blue = { Top = rgb(92, 214, 255), Bottom = rgb(20, 112, 240), Lip = rgb(10, 56, 150), Stroke = rgb(6, 30, 92) },
	Purple = { Top = rgb(206, 110, 255), Bottom = rgb(122, 34, 232), Lip = rgb(70, 14, 150), Stroke = rgb(40, 6, 92) },
	Yellow = { Top = rgb(255, 234, 60), Bottom = rgb(255, 150, 16), Lip = rgb(176, 84, 6), Stroke = rgb(100, 44, 0) },
	Red = { Top = rgb(255, 104, 96), Bottom = rgb(214, 20, 36), Lip = rgb(128, 8, 22), Stroke = rgb(76, 4, 12) },
	Gray = { Top = rgb(176, 180, 196), Bottom = rgb(112, 116, 136), Lip = rgb(66, 68, 84), Stroke = rgb(36, 38, 50) },
}

export type Options = {
	Name: string?,
	Size: Vector2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	ZIndex: number?,
	LayoutOrder: number?,
	OnClick: (() -> ())?,
}

local function clone(key: string, default: Vector2, parent: Instance, options: Options?): any
	local template = templates:FindFirstChild(key)
	assert(template, "FreeUIPack: unknown asset " .. key)
	local opts: Options = options or {}
	local item = template:Clone() :: any
	local size = opts.Size or default
	item.Name = opts.Name or key
	item.Size = UDim2.fromOffset(size.X, size.Y)
	-- The button scripts read Position once when they start: it must be final before parenting.
	item.Position = opts.Position or UDim2.fromScale(0.5, 0.5)
	item.AnchorPoint = opts.AnchorPoint or Vector2.new(0.5, 0.5)
	item.ZIndex = opts.ZIndex or item.ZIndex
	item.LayoutOrder = opts.LayoutOrder or 0
	if opts.OnClick then item.Activated:Connect(opts.OnClick) end
	item.Parent = parent
	return item
end

--- ScreenGui with Sibling layering. Modeled parts rely on it: under Global layering their faces hide behind their lips.
function Pack.ScreenGui(parent: Instance, name: string): ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parent
	return gui
end

--- Wide button with a baked word: Back, Bag Pack, Code's, Correct, Delete, Forward, Gem's, Gift, Inventory, Luck,
--- Money, Pet's, Rebirth, Robux, Setting's, Shop, Super Gem's, Trade, Update Log, What's Added, WheelSpin.
function Pack.Wide(parent: Instance, name: string, options: Options?): ImageButton
	return clone("Wide_" .. name, Pack.DefaultWide, parent, options)
end

--- Square icon button: Back, Code's, Correct, Delete, Forward, Gem's, Gift, Luck, Minus, Money, Mouse, Pet's, Plus,
--- Rebirth, Robux, Setting's, Shop, Super Gem's, Trade, WheelSpin. These are buttons: never use them as a plain icon.
function Pack.Icon(parent: Instance, name: string, options: Options?): ImageButton
	return clone("Icon_" .. name, Pack.DefaultIcon, parent, options)
end

--- Panel: White, Blue, Red, Orange, Green. It is a plain image, so keep close to its 180x215 ratio.
function Pack.Panel(parent: Instance, color: string, options: Options?): ImageLabel
	return clone("Panel_" .. color, Pack.DefaultFrame, parent, options)
end

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

--- Text matching the rounded lettering baked into the buttons, for words the pack doesn't have.
function Pack.Label(parent: Instance, text: string, options: { [string]: any }?): TextLabel
	local opts = options or {}
	local label = Instance.new("TextLabel")
	label.Name = opts.Name or "Label"
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.Text = text
	label.TextColor3 = opts.Color or Color3.new(1, 1, 1)
	label.TextSize = opts.TextSize or 32
	label.TextXAlignment = opts.AlignX or Enum.TextXAlignment.Center
	label.Size = opts.Size or UDim2.fromOffset(240, 48)
	label.Position = opts.Position or UDim2.fromScale(0.5, 0.5)
	label.AnchorPoint = opts.AnchorPoint or Vector2.new(0.5, 0.5)
	label.ZIndex = opts.ZIndex or 5
	local stroke = Instance.new("UIStroke")
	stroke.Color = opts.StrokeColor or OUTLINE
	stroke.Thickness = opts.StrokeThickness or 3
	stroke.Parent = label
	label.Parent = parent
	return label
end

--- Plain picture without a button script. image is an asset address, e.g. Pack.Images.Coin.
function Pack.Picture(parent: Instance, image: string, options: { [string]: any }?): ImageLabel
	local opts = options or {}
	local picture = Instance.new("ImageLabel")
	picture.Name = opts.Name or "Picture"
	picture.BackgroundTransparency = 1
	picture.Image = image
	picture.ScaleType = Enum.ScaleType.Fit
	picture.ImageColor3 = opts.Color or Color3.new(1, 1, 1)
	picture.ImageTransparency = opts.Transparency or 0
	picture.Size = opts.Size or UDim2.fromOffset(64, 64)
	picture.Position = opts.Position or UDim2.fromScale(0.5, 0.5)
	picture.AnchorPoint = opts.AnchorPoint or Vector2.new(0.5, 0.5)
	picture.Rotation = opts.Rotation or 0
	picture.ZIndex = opts.ZIndex or 4
	picture.Parent = parent
	return picture
end

-- Gives a frame the pack's look: dark outline, thick lip, bright gradient face and two hard glass streaks.
local function chunk(frame: GuiObject, themeName: string, radius: number): Frame
	local theme = THEMES[themeName]
	frame.BackgroundColor3 = theme.Lip
	frame.BackgroundTransparency = 0
	corner(frame, radius)
	local outline = Instance.new("UIStroke")
	outline.Name = "Outline"
	outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	outline.Color = OUTLINE
	outline.Thickness = 3
	outline.Parent = frame

	local face = Instance.new("Frame")
	face.Name = "Face"
	face.BackgroundColor3 = Color3.new(1, 1, 1)
	face.BorderSizePixel = 0
	face.Size = UDim2.new(1, 0, 1, -6)
	face.Parent = frame
	corner(face, radius)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(theme.Top, theme.Bottom)
	gradient.Rotation = 90
	gradient.Parent = face

	local streaks = Instance.new("Frame")
	streaks.Name = "Streaks"
	streaks.BackgroundColor3 = Color3.new(1, 1, 1)
	streaks.BorderSizePixel = 0
	streaks.Size = UDim2.fromScale(1, 1)
	streaks.Parent = face
	corner(streaks, radius)
	local bands = Instance.new("UIGradient")
	bands.Rotation = 25
	bands.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.16, 1),
		NumberSequenceKeypoint.new(0.161, 0.72), NumberSequenceKeypoint.new(0.3, 0.72),
		NumberSequenceKeypoint.new(0.301, 1), NumberSequenceKeypoint.new(0.38, 1),
		NumberSequenceKeypoint.new(0.381, 0.84), NumberSequenceKeypoint.new(0.44, 0.84),
		NumberSequenceKeypoint.new(0.441, 1), NumberSequenceKeypoint.new(1, 1),
	})
	bands.Parent = streaks
	return face
end

local function pop(scale: UIScale, from: number, time: number)
	scale.Scale = from
	TweenService:Create(scale, TweenInfo.new(time, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

--- Modeled button for anything needing its own text, such as a price. Themes: Green, Blue, Purple, Yellow, Red, Gray.
--- Returns { Button, SetText(text), SetTheme(name) }.
function Pack.Chunky(parent: Instance, options: { [string]: any })
	local button = Instance.new("TextButton")
	button.Name = options.Name or "Chunky"
	button.Text = ""
	button.AutoButtonColor = false
	button.Size = options.Size or UDim2.fromOffset(200, 60)
	button.Position = options.Position or UDim2.fromScale(0.5, 0.5)
	button.AnchorPoint = options.AnchorPoint or Vector2.new(0.5, 0.5)
	button.ZIndex = options.ZIndex or 3
	local themeName = options.Theme or "Green"
	local face = chunk(button, themeName, options.Radius or 12)
	local label = Pack.Label(face, options.Text or "", { Name = "Text", TextSize = options.TextSize or 30, StrokeThickness = 3,
		StrokeColor = THEMES[themeName].Stroke, Size = UDim2.fromScale(1, 1) })
	if options.Icon then
		local iconSize = options.IconSize or 40
		Pack.Picture(face, options.Icon, { Name = "Icon", Size = UDim2.fromOffset(iconSize, iconSize), Position = UDim2.new(0, 10 + iconSize / 2, 0.5, 0), Rotation = -8 })
		label.Size = UDim2.new(1, -(iconSize + 14), 1, 0)
		label.Position = UDim2.new(1, 0, 0.5, 0)
		label.AnchorPoint = Vector2.new(1, 0.5)
	end
	local scale = Instance.new("UIScale")
	scale.Parent = button
	local click = Instance.new("Sound")
	click.SoundId = CLICK_SOUND
	click.Volume = 0.5
	click.Parent = button
	local function to(value: number, time: number, style: Enum.EasingStyle)
		TweenService:Create(scale, TweenInfo.new(time, style, Enum.EasingDirection.Out), { Scale = value }):Play()
	end
	button.MouseEnter:Connect(function() to(1.05, 0.18, Enum.EasingStyle.Quint) end)
	button.MouseLeave:Connect(function() to(1, 0.2, Enum.EasingStyle.Quint) end)
	button.MouseButton1Down:Connect(function() to(0.92, 0.06, Enum.EasingStyle.Quad) end)
	button.MouseButton1Up:Connect(function() to(1.05, 0.3, Enum.EasingStyle.Back) end)
	button.Activated:Connect(function()
		click:Play()
		if options.OnClick then options.OnClick() end
	end)
	button.Parent = parent

	local chunky = { Button = button }
	function chunky.SetText(text: string)
		label.Text = text
	end
	function chunky.SetTheme(name: string)
		local theme = THEMES[name]
		local gradient = face:FindFirstChildOfClass("UIGradient") :: UIGradient
		local stroke = label:FindFirstChildOfClass("UIStroke") :: UIStroke
		button.BackgroundColor3 = theme.Lip
		gradient.Color = ColorSequence.new(theme.Top, theme.Bottom)
		stroke.Color = theme.Stroke
	end
	return chunky
end

--- Scales a root frame for every screen. Client only. Put buttons under this frame, never give them this UIScale.
function Pack.BindScale(root: GuiObject, designSize: Vector2?)
	local design = designSize or Vector2.new(1050, 620)
	local scale = Instance.new("UIScale")
	scale.Name = "WindowScale"
	scale.Parent = root
	local camera = workspace.CurrentCamera
	local function update()
		local view = camera.ViewportSize
		scale.Scale = math.clamp(math.min(view.X / design.X, view.Y / design.Y), 0.52, 1.18)
	end
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
	update()
end

local function withCommas(value: number): string
	local text = tostring(math.floor(value))
	while true do
		local replaced, count = text:gsub("^(%d+)(%d%d%d)", "%1,%2")
		text = replaced
		if count == 0 then return text end
	end
end

--- Currency pill: dark capsule, coin overflowing on the left, number that counts up with a bounce.
--- Returns { Root, Set(value) }.
function Pack.Counter(parent: Instance, options: { [string]: any }?)
	local opts = options or {}
	local root = Instance.new("Frame")
	root.Name = opts.Name or "Counter"
	root.BackgroundColor3 = rgb(24, 22, 54)
	root.BackgroundTransparency = 0.08
	root.Size = opts.Size or UDim2.fromOffset(240, 52)
	root.Position = opts.Position or UDim2.new(0.5, 0, 0, 14)
	root.AnchorPoint = opts.AnchorPoint or Vector2.new(0.5, 0)
	corner(root, 26)
	local outline = Instance.new("UIStroke")
	outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	outline.Color = OUTLINE
	outline.Thickness = 3
	outline.Parent = root
	local icon = Pack.Picture(root, opts.Icon or Pack.Images.Coin, { Name = "Icon", Size = UDim2.fromOffset(74, 74), Position = UDim2.new(0, 16, 0.5, 0), Rotation = -10 })
	local iconScale = Instance.new("UIScale")
	iconScale.Parent = icon
	local label = Pack.Label(root, "0", { Name = "Amount", TextSize = opts.TextSize or 36, Color = opts.Color or rgb(255, 226, 90), StrokeThickness = 3,
		AlignX = Enum.TextXAlignment.Left, Size = UDim2.new(1, -66, 1, 0), Position = UDim2.new(0, 58, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
	local labelScale = Instance.new("UIScale")
	labelScale.Parent = label
	root.Parent = parent

	-- The capsule hugs the number so there's no empty space on its right.
	local function fit()
		root.Size = UDim2.fromOffset(math.max(120, 58 + label.TextBounds.X + 24), root.Size.Y.Offset)
	end
	label:GetPropertyChangedSignal("TextBounds"):Connect(fit)
	fit()

	local shown, target = 0, 0
	local running = false
	local counter = { Root = root }
	function counter.Set(value: number)
		local gained = value > target
		target = value
		if gained then
			pop(iconScale, 1.3, 0.3)
			pop(labelScale, 1.12, 0.25)
		end
		if running then return end
		running = true
		task.spawn(function()
			while shown ~= target do
				local step = (target - shown) * 0.2
				shown = if math.abs(step) < 1 then target else shown + step
				label.Text = withCommas(shown)
				RunService.Heartbeat:Wait()
			end
			running = false
		end)
	end
	return counter
end

--- Bouncy menu: pack panel, modeled title banner, close button, blurred world behind. Body is fitted to the panel's
--- inner rectangle, so content lines up with its frame. The window destroys itself on close, so its buttons' idle
--- sounds stop with it. Returns { Root, Panel, Body, Close() }.
function Pack.Window(gui: Instance, options: { [string]: any }?)
	local opts = options or {}
	local size: Vector2 = opts.Size or Vector2.new(580, 450)
	local root = Instance.new("Frame")
	root.Name = opts.Name or "Window"
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromOffset(size.X, size.Y)
	root.Position = UDim2.fromScale(0.5, 0.56)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.ZIndex = 20
	root.Parent = gui
	Pack.BindScale(root)
	local panel = Pack.Panel(root, opts.Color or "Blue", { Name = "Panel", Size = size, Position = UDim2.fromScale(0.5, 0.5) })
	local popScale = Instance.new("UIScale")
	popScale.Name = "Pop"
	popScale.Parent = panel

	local banner = Instance.new("Frame")
	banner.Name = "TitleBanner"
	banner.Size = UDim2.fromOffset(260, 68)
	banner.Position = UDim2.new(0.5, 0, 0, 6)
	banner.AnchorPoint = Vector2.new(0.5, 0.5)
	banner.Rotation = -2
	banner.ZIndex = 6
	local bannerTheme = opts.BannerTheme or "Purple"
	local face = chunk(banner, bannerTheme, 14)
	Pack.Label(face, opts.Title or "", { Name = "Title", TextSize = 42, StrokeThickness = 4, StrokeColor = THEMES[bannerTheme].Stroke, Size = UDim2.fromScale(1, 1) })
	banner.Parent = panel

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromScale(0.5, 0.56)
	body.AnchorPoint = Vector2.new(0.5, 0.5)
	body.Size = UDim2.fromScale(0.8, 0.72)
	body.ZIndex = 3
	body.Parent = panel

	local blur = Instance.new("BlurEffect")
	blur.Name = "PackWindowBlur"
	blur.Size = 0
	blur.Parent = Lighting
	TweenService:Create(blur, TweenInfo.new(0.25), { Size = 14 }):Play()
	pop(popScale, 0.72, 0.32)

	local window = { Root = root, Panel = panel, Body = body }
	local closed = false
	function window.Close()
		if closed then return end
		closed = true
		TweenService:Create(blur, TweenInfo.new(0.16), { Size = 0 }):Play()
		TweenService:Create(popScale, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0.72 }):Play()
		task.delay(0.17, function()
			blur:Destroy()
			root:Destroy()
		end)
	end
	Pack.Icon(panel, "Delete", { Name = "Close", Size = Vector2.new(66, 66), Position = UDim2.new(1, -8, 0, 8), ZIndex = 7, OnClick = window.Close })
	return window
end

--- Dark item card with a spinning sunburst behind a tilted picture. Returns the card frame; the spin stops with it.
function Pack.Card(parent: Instance, options: { [string]: any }): Frame
	local card = Instance.new("Frame")
	card.Name = options.Name or "Card"
	card.BackgroundColor3 = rgb(26, 24, 60)
	card.BackgroundTransparency = 0.06
	card.Size = options.Size or UDim2.fromOffset(220, 320)
	card.Position = options.Position or UDim2.fromScale(0.5, 0.5)
	card.AnchorPoint = options.AnchorPoint or Vector2.new(0.5, 0.5)
	corner(card, 16)
	local outline = Instance.new("UIStroke")
	outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	outline.Color = OUTLINE
	outline.Thickness = 3
	outline.Parent = card
	local imageY = options.ImageY or 110
	local burst = Pack.Picture(card, Pack.Images.Sunburst, { Name = "Sunburst", Size = UDim2.fromOffset(170, 170), Position = UDim2.new(0.5, 0, 0, imageY), Color = options.BurstColor or rgb(255, 214, 90), Transparency = 0.55, ZIndex = 2 })
	Pack.Picture(card, options.Image, { Name = "Image", Size = UDim2.fromOffset(96, 96), Position = UDim2.new(0.5, 0, 0, imageY), Rotation = -8, ZIndex = 3 })
	task.spawn(function()
		while burst.Parent do
			burst.Rotation = (burst.Rotation + RunService.Heartbeat:Wait() * 24) % 360
		end
	end)
	card.Parent = parent
	return card
end

--- Short message that bounces in and floats away.
function Pack.Toast(gui: Instance, text: string, options: { [string]: any }?)
	local opts = options or {}
	local label = Pack.Label(gui, text, { Name = "Toast", TextSize = opts.TextSize or 36, StrokeThickness = 4, Color = opts.Color,
		Size = UDim2.fromOffset(600, 50), Position = opts.Position or UDim2.fromScale(0.5, 0.17), ZIndex = 40 })
	local stroke = label:FindFirstChildOfClass("UIStroke") :: UIStroke
	local scale = Instance.new("UIScale")
	scale.Parent = label
	pop(scale, 0.5, 0.28)
	local leave = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.75)
	TweenService:Create(label, leave, { TextTransparency = 1, Position = label.Position - UDim2.fromOffset(0, 36) }):Play()
	TweenService:Create(stroke, leave, { Transparency = 1 }):Play()
	task.delay(1.3, function() label:Destroy() end)
end

--- Loads every template image up front so buttons don't pop in. Client only, yields.
function Pack.Preload()
	ContentProvider:PreloadAsync(templates:GetChildren())
end

return Pack
