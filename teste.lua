local UILibrary = {}

function UILibrary:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomUILibrary"
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 50)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "My UI"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.TextSize = 24
    TitleLabel.Parent = MainFrame

    local TabFolder = Instance.new("Folder", MainFrame)

    local window = {
        MainFrame = MainFrame,
        TabFolder = TabFolder
    }

    setmetatable(window, {__index = self})
    return window
end

function UILibrary:AddTab(tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 100, 0, 30)
    TabButton.Position = UDim2.new(0, #self.TabFolder:GetChildren() * 110, 0, 50)
    TabButton.Text = tabName
    TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Parent = self.MainFrame

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 1, -80)
    TabFrame.Position = UDim2.new(0, 0, 0, 80)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.Parent = self.MainFrame
    TabFrame.Name = tabName

    TabButton.MouseButton1Click:Connect(function()
        for _, v in pairs(self.MainFrame:GetChildren()) do
            if v:IsA("Frame") and v ~= self.MainFrame then
                v.Visible = false
            end
        end
        TabFrame.Visible = true
    end)

    return {
        TabFrame = TabFrame
    }
end

function UILibrary:AddButton(tab, buttonName, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 200, 0, 40)
    Button.Position = UDim2.new(0, 20, 0, #tab.TabFrame:GetChildren() * 50)
    Button.Text = buttonName
    Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Parent = tab.TabFrame

    Button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
end

return UILibrary
