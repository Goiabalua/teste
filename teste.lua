local UILibrary = {}

local function Create(instance, props)
    local object = Instance.new(instance)
    for prop, value in pairs(props) do
        object[prop] = value
    end
    return object
end

local function MakeDraggable(frame)
    local dragging, offset
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            offset = input.Position - frame.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            frame.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function UILibrary:CreateWindow(title)
    local ScreenGui = Create("ScreenGui", { Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"), Name = "UILibrary" })

    local MainFrame = Create("Frame", {
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = ScreenGui
    })

    MakeDraggable(MainFrame)

    local TitleLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = title or "UILibrary",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamSemibold,
        TextSize = 24,
        Parent = MainFrame
    })

    local TabHolder = Create("Frame", {
        Size = UDim2.new(0, 120, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Parent = MainFrame
    })

    local PageHolder = Create("Frame", {
        Size = UDim2.new(1, -120, 1, -40),
        Position = UDim2.new(0, 120, 0, 40),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    local UIList = Create("UIListLayout", { Parent = TabHolder, Padding = UDim.new(0, 5) })

    local window = { Tabs = {}, PageHolder = PageHolder }

    function window:AddTab(name)
        local Button = Create("TextButton", {
            Size = UDim2.new(1, -10, 0, 30),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.Gotham,
            TextSize = 16,
            Text = name,
            Parent = TabHolder
        })

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 5,
            Visible = false,
            BackgroundTransparency = 1,
            Parent = PageHolder
        })

        local Layout = Create("UIListLayout", { Parent = Page, Padding = UDim.new(0, 5) })

        Button.MouseButton1Click:Connect(function()
            for _, tab in pairs(window.Tabs) do
                tab.Page.Visible = false
            end
            Page.Visible = true
        end)

        table.insert(window.Tabs, { Button = Button, Page = Page, Layout = Layout })

        return setmetatable({}, {
            __index = function(_, k)
                return function(_, ...)
                    return UILibrary[k](UILibrary, Page, ...)
                end
            end
        })
    end

    return window
end

-- COMPONENTES

function UILibrary:AddButton(parent, text, callback)
    local Button = Create("TextButton", {
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Text = text,
        Parent = parent
    })
    Button.MouseButton1Click:Connect(callback)
end

function UILibrary:AddToggle(parent, text, default, callback)
    local toggled = default or false

    local Frame = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local Box = Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100),
        Parent = Frame,
        Text = ""
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = Frame
    })

    Box.MouseButton1Click:Connect(function()
        toggled = not toggled
        Box.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100)
        callback(toggled)
    end)
end

function UILibrary:AddSlider(parent, text, min, max, default, callback)
    local value = default or min

    local Frame = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 50),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Text = text .. ": " .. tostring(value),
        TextColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = Frame
    })

    local SliderBar = Create("Frame", {
        Size = UDim2.new(1, -20, 0, 10),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        Parent = Frame
    })

    local SliderFill = Create("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 170, 255),
        Parent = SliderBar
    })

    local UIS = game:GetService("UserInputService")
    local dragging = false

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local scale = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * scale)
            SliderFill.Size = UDim2.new(scale, 0, 1, 0)
            Label.Text = text .. ": " .. tostring(value)
            callback(value)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function UILibrary:AddDropdown(parent, text, options, callback)
    local selected = options[1]

    local Frame = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        Parent = parent
    })

    local Label = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        Text = text .. ": " .. selected,
        TextColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = Frame
    })

    local function update(new)
        selected = new
        Label.Text = text .. ": " .. selected
        callback(selected)
    end

    Label.MouseButton1Click:Connect(function()
        local menu = Instance.new("Frame", Frame)
        menu.Position = UDim2.new(0, 0, 1, 0)
        menu.Size = UDim2.new(1, 0, 0, #options * 25)
        menu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        for i, opt in ipairs(options) do
            local btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 25),
                Position = UDim2.new(0, 0, 0, (i - 1) * 25),
                Text = opt,
                BackgroundColor3 = Color3.fromRGB(70, 70, 70),
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                Parent = menu
            })
            btn.MouseButton1Click:Connect(function()
                update(opt)
                menu:Destroy()
            end)
        end
    end)
end

function UILibrary:Notify(title, text, time)
    local notification = Create("TextLabel", {
        Size = UDim2.new(0, 300, 0, 50),
        Position = UDim2.new(0.5, -150, 0, 50),
        BackgroundColor3 = Color3.fromRGB(0, 170, 255),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Text = title .. "\n" .. text,
        Parent = game.Players.LocalPlayer.PlayerGui.UILibrary
    })
    task.wait(time or 3)
    notification:Destroy()
end

return UILibrary
