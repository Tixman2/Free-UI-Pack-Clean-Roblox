-- Run once with execute_luau in Edit mode, with KIT_SOURCE set to the text of src/FreeUIPack.luau.
-- Moves the pack out of StarterGui (where it covers the screen) and into ReplicatedStorage.FreeUIPack.Templates.
-- Nothing is deleted: the rest of the pack goes to ServerStorage.FreeUIPackOriginal.
local KIT_SOURCE = nil

local RS = game:GetService("ReplicatedStorage")
local pack = game.StarterGui:FindFirstChild("Free_UI_Pack")
assert(pack, "Free_UI_Pack not found in StarterGui")

local module = RS:FindFirstChild("FreeUIPack")
if not module then
	assert(KIT_SOURCE, "set KIT_SOURCE")
	module = Instance.new("ModuleScript")
	module.Name = "FreeUIPack"
	module.Source = KIT_SOURCE
	module.Parent = RS
end
local templates = module:FindFirstChild("Templates") or Instance.new("Folder")
templates.Name = "Templates"
templates.Parent = module

local panelColors = { Frame1 = "White", Frame2 = "Blue", Frame3 = "Red", Frame4 = "Orange", Frame5 = "Green" }
local moved = 0
for _, item in pack.MegaPack:GetChildren() do
	if item:IsA("ImageLabel") and panelColors[item.Name] then
		item.Name = "Panel_" .. panelColors[item.Name]
	elseif item:IsA("ImageButton") then
		item.Name = (item.Size.X.Scale > 0.1 and "Wide_" or "Icon_") .. item.Name
	else
		continue
	end
	item.Parent = templates
	moved += 1
end
pack.Parent = game.ServerStorage
pack.Name = "FreeUIPackOriginal"
return "moved " .. moved .. " templates"
