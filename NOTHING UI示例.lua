local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))();
local Windows = NothingLibrary.new({
	Title = "TY hub",
	Description = "TY HUB | Roblox Script",
	Keybind = Enum.KeyCode.LeftControl,
	Logo = 'http://www.roblox.com/asset/?id=18898582662'
})

local TabFrame = Windows:NewTab({
	Title = "Example",
	Description = "example tab",
	Icon = "rbxassetid://7733960981"
})

local Section = TabFrame:NewSection({
	Title = "Section",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})

local InfoSection = TabFrame:NewSection({
	Title = "Information",
	Icon = "rbxassetid://7733964719",
	Position = "Right"
})

Section:NewToggle({
	Title = "Toggle",
	Default = false,
	Callback = function(tr)
		print(tr)
	end,
})

Section:NewToggle({
	Title = "Auto Farm",
	Default = false,
	Callback = function(tr)
		print(tr)
	end,
})

Section:NewButton({
	Title = "Kill All",
	Callback = function()
		print('killed')
	end,
})

Section:NewButton({
	Title = "Teleport",
	Callback = function()
		print('tp')
	end,
})

Section:NewSlider({
	Title = "Slider",
	Min = 10,
	Max = 50,
	Default = 25,
	Callback = function(a)
		print(a)
	end,
})

Section:NewSlider({
	Title = "WalkSpeed",
	Min = 15,
	Max = 50,
	Default = 16,
	Callback = function(a)
		print(a)
	end,
})

Section:NewKeybind({
	Title = "Keybind",
	Default = Enum.KeyCode.RightAlt,
	Callback = function(a)
		print(a)
	end,
})

Section:NewKeybind({
	Title = "Auto Combo",
	Default = Enum.KeyCode.T,
	Callback = function(a)
		print(a)
	end,
})

Section:NewDropdown({
	Title = "Dropdown",
	Data = {1,2,3,4,5},
	Default = 1,
	Callback = function(a)
		print(a)
	end,
})

Section:NewDropdown({
	Title = "Method",
	Data = {'Teleport','Locker','Auto'},
	Default = 'Auto',
	Callback = function(a)
		print(a)
	end,
})

InfoSection:NewTitle('UI by CATSUS')
InfoSection:NewButton({
	
	Title = "复制QQ群",
	Callback = function()
		print('948082232')
	end,
})