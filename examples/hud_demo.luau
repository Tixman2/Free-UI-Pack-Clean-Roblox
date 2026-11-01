-- LocalScript example, in StarterPlayerScripts: a coin pill, a side menu and a shop window with one item card.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Pack = require(RS.FreeUIPack)

local gui = Pack.ScreenGui(Players.LocalPlayer:WaitForChild("PlayerGui"), "HUD")

local counter = Pack.Counter(gui)
Pack.BindScale(counter.Root)
counter.Set(1250)

local function openShop()
	local window = Pack.Window(gui, { Title = "Shop", Color = "Blue", BannerTheme = "Yellow" })
	local card = Pack.Card(window.Body, { Image = Pack.Images.Shoe, ImageY = 112, Size = UDim2.fromScale(0.48, 1), Position = UDim2.fromScale(0.25, 0.5) })
	Pack.Label(card, "Speed", { TextSize = 32, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0.5, 0, 0, 30) })
	Pack.Chunky(card, { Theme = "Green", Icon = Pack.Images.Coin, IconSize = 42, Text = "100", TextSize = 28,
		Size = UDim2.new(1, -20, 0, 60), Position = UDim2.new(0.5, 0, 1, -44), OnClick = function()
			Pack.Toast(gui, "Bought!")
		end })
end

local menu = Instance.new("Frame")
menu.Name = "LeftMenu"
menu.BackgroundTransparency = 1
menu.Size = UDim2.fromOffset(170, 170)
menu.AnchorPoint = Vector2.new(0, 0.5)
menu.Position = UDim2.new(0, 12, 0.5, 0)
menu.Parent = gui
Pack.BindScale(menu)
Pack.Wide(menu, "Shop", { Position = UDim2.fromOffset(85, 40), OnClick = openShop })
Pack.Wide(menu, "Rebirth", { Position = UDim2.fromOffset(85, 124) })
