# Buster UI - Example

Simple and clean UI library for Roblox executors.

## Basic Setup

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
```

## Toggle

```lua
Panel:CreateToggle({
    Name = "Toggle Example",
    Default = false,
    Callback = function(value)
        print("Toggle:", value)
    end
})
```

## Button

```lua
Panel:CreateButton({
    Name = "Button Example",
    Callback = function()
        print("Button clicked")
    end
})
```

## Slider

```lua
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
```

## Keybind

```lua
Panel:CreateKeybind({
    Name = "Keybind Example",
    Default = Enum.KeyCode.E,
    Callback = function(key)
        print("Keybind:", key.Name)
    end
})
```

## Dropdown

```lua
Panel:CreateDropdown({
    Name = "Dropdown Example",
    List = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Callback = function(value)
        print("Dropdown:", value)
    end
})
```

## Label

```lua
Panel:CreateLabel({ 
    Text = "Label Example", 
    Size = 11 
})
```
