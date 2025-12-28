# Buster UI - Example

Simple and clean UI library for Roblox executors.

## Usage

```lua
local Buster = loadstring(game:HttpGet("http://212.227.64.179:9172/raw/buster-ui-library"))()

local Window = Buster:CreateWindow({
    Name = "Buster UI",
    Subtitle = "Example Script",
    Footer = "The Bronx",
    BrandText = "B",
    Size = { Width = 860, Height = 480 },
    ToggleKey = Enum.KeyCode.RightShift
})

local Tab = Window:CreateTab({ 
    Name = "Main", 
    Icon = "rbxassetid://10734949856"
})

local Panel = Tab:CreatePanel({ 
    Column = "Left", 
    Title = "Main Features"
})

Panel:CreateToggle({
    Name = "Toggle Example",
    Default = false,
    Callback = function(value)
        print("Toggle:", value)
    end
})

Panel:CreateButton({
    Name = "Button Example",
    Callback = function()
        print("Button clicked")
    end
})

Panel:CreateSlider({
    Name = "Slider Example",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        print("Slider:", value)
    end
})

Panel:CreateKeybind({
    Name = "Keybind Example",
    Default = Enum.KeyCode.E,
    Callback = function(key)
        print("Keybind:", key.Name)
    end
})

Panel:CreateDropdown({
    Name = "Dropdown Example",
    List = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Callback = function(value)
        print("Dropdown:", value)
    end
})

Panel:CreateLabel({ 
    Text = "Label Example", 
    Size = 11 
})
```

## Features

- CreateWindow
- CreateTab
- CreatePanel
- CreateToggle
- CreateButton
- CreateSlider
- CreateKeybind
- CreateDropdown
- CreateLabel
