local UILibrary = {}

-- Função auxiliar para criar instâncias
local function Create(instance, properties)
    local obj = Instance.new(instance)
    for prop, value in pairs(properties) do
        obj[prop] = value
    end
    return obj
end

-- Criar janela principal
function UILibrary:CreateWindow(title)
    local ScreenGui = Create("ScreenGui", { Parent = game.Players.LocalPlayer.PlayerGui, Name = "UILibrary" })

    local Main = Create("Frame", {
        Size = UDim2.new(0, 550, 0, 400),
        Position = UDim2.new(0.5, -275, 0.5, -200),
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        BorderSizePixel = 0,
        Parent = ScreenGui
    })

    -- Variável de controle de drag
    local CanDrag = true

    -- Sistema de Drag atualizado
    local function MakeDraggable(frame)
        local dragging, dragInput, dragStart, startPos

        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and CanDrag then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
            if dragging and input == dragInput then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    MakeDraggable(Main)

    local Title = Create("TextLabel", {
        Size = UDim2.new(1,0,0,40),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamSemibold,
        TextSize = 24,
        TextColor3 = Color3.new(1,1,1),
        Parent = Main
    })

    local TabHolder = Create("Frame", {
        Size = UDim2.new(0,140,1,-40),
        Position = UDim2.new(0,0,0,40),
        BackgroundColor3 = Color3.fromRGB(25,25,25),
        Parent = Main
    })

    local UIList = Create("UIListLayout", { Parent = TabHolder, Padding = UDim.new(0,5) })

    local PageHolder = Create("Frame", {
        Size = UDim2.new(1,-140,1,-40),
        Position = UDim2.new(0,140,0,40),
        BackgroundTransparency = 1,
        Parent = Main
    })

    local window = { Tabs = {}, PageHolder = PageHolder }

    function window:AddTab(name)
        local Button = Create("TextButton", {
            Size = UDim2.new(1,-10,0,30),
            BackgroundColor3 = Color3.fromRGB(50,50,50),
            TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.Gotham,
            TextSize = 16,
            Text = name,
            Parent = TabHolder
        })

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1,0,1,0),
            CanvasSize = UDim2.new(0,0,0,0),
            ScrollBarThickness = 5,
            Visible = false,
            BackgroundTransparency = 1,
            Parent = PageHolder
        })

        local Layout = Create("UIListLayout", { Parent = Page, Padding = UDim.new(0,5) })

        Button.MouseButton1Click:Connect(function()
            for _, tab in pairs(window.Tabs) do
                tab.Page.Visible = false
            end
            Page.Visible = true
        end)

        local tab = {}

        function tab:AddButton(options)
            local Button = Create("TextButton", {
                Size = UDim2.new(1, -10, 0, 30),
                BackgroundColor3 = Color3.fromRGB(70, 70, 70),
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                Text = options.Title,
                Parent = Page
            })

            Button.MouseButton1Click:Connect(function()
                if options.Callback then options.Callback() end
            end)
        end

        function tab:AddToggle(name, options)
            local state = options.Default or false

            local Frame = Create("Frame", {
                Size = UDim2.new(1, -10, 0, 30),
                BackgroundTransparency = 1,
                Parent = Page
            })

            local Box = Create("TextButton", {
                Size = UDim2.new(0, 30, 0, 30),
                BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100),
                Parent = Frame,
                Text = ""
            })

            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 40, 0, 0),
                Text = options.Title,
                TextColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                Parent = Frame
            })

            Box.MouseButton1Click:Connect(function()
                state = not state
                Box.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100)
                if options.Callback then options.Callback(state) end
            end)
        end

        function tab:AddSlider(name, options)
            local min, max = options.Min, options.Max
            local value = options.Default or min

            local Frame = Create("Frame", {
                Size = UDim2.new(1, -10, 0, 50),
                BackgroundTransparency = 1,
                Parent = Page
            })

            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                Text = options.Title .. ": " .. tostring(value),
                TextColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                Parent = Frame
            })

            local Bar = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 10),
                Position = UDim2.new(0, 10, 0, 30),
                BackgroundColor3 = Color3.fromRGB(70, 70, 70),
                Parent = Frame
            })

            local Fill = Create("Frame", {
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(0, 170, 255),
                Parent = Bar
            })

            local UIS = game:GetService("UserInputService")
            local dragging = false

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    CanDrag = false
                end
            end)

            UIS.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local scale = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    value = min + (max - min) * scale
                    if options.Rounding then
                        value = math.floor(value * (1 / options.Rounding) + 0.5) / (1 / options.Rounding)
                    end
                    Fill.Size = UDim2.new(scale, 0, 1, 0)
                    Label.Text = options.Title .. ": " .. tostring(value)
                    if options.Callback then options.Callback(value) end
                end
            end)

            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    CanDrag = true
                end
            end)
        end

        function tab:AddDropdown(name, options)
            local selected = options.Values[options.Default or 1]

            local Frame = Create("Frame", {
                Size = UDim2.new(1, -10, 0, 30),
                BackgroundColor3 = Color3.fromRGB(70, 70, 70),
                Parent = Page
            })

            local Label = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                Text = options.Title .. ": " .. selected,
                TextColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                Parent = Frame
            })

            local function update(new)
                selected = new
                Label.Text = options.Title .. ": " .. selected
                if options.Callback then options.Callback(selected) end
            end

            Label.MouseButton1Click:Connect(function()
                local menu = Instance.new("Frame", Frame)
                menu.Position = UDim2.new(0, 0, 1, 0)
                menu.Size = UDim2.new(1, 0, 0, #options.Values * 25)
                menu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                for i, opt in ipairs(options.Values) do
                    local btn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 25),
                        Position = UDim2.new(0, 0, 0, (i-1)*25),
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

        table.insert(window.Tabs, { Button = Button, Page = Page })
        if #window.Tabs == 1 then Page.Visible = true end
        return tab
    end

    return window
end

function UILibrary:Notify(options)
    local notification = Create("TextLabel", {
        Size = UDim2.new(0, 300, 0, 50),
        Position = UDim2.new(0.5, -150, 0, 50),
        BackgroundColor3 = Color3.fromRGB(0, 170, 255),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Text = options.Title.."\n"..options.Content,
        Parent = game.Players.LocalPlayer.PlayerGui.UILibrary
    })
    task.wait(options.Duration or 3)
    notification:Destroy()
end

return UILibrary
