local UserInputService = game:GetService("UserInputService")
local CoreGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

local infuz = {}
infuz.__index = infuz

local allWindows = {}
local isVisible = true

local function create(elementType, parent, properties)
	local element = Instance.new(elementType)

	if parent then
		element.Parent = parent
	end

	if properties then
		for key, value in pairs(properties) do
			local success, errorMessage = pcall(function()
				element[key] = value
			end)

			if not success then
				warn(string.format("Failed to set property '%s' on %s: %s", key, elementType, errorMessage))
			end
		end
	end

end

function infuz:MakeDraggable(frame, dragBar)
	local dragging = false
	local dragStart, startPos

	dragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function infuz:CreateSettingsModal(title)
	local modal = Instance.new("Frame")
	modal.Size = UDim2.new(0, 400, 0, 200)
	modal.Position = UDim2.new(0.5, -150, 0.5, -100)
	modal.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	modal.BorderSizePixel = 0
	modal.Visible = true
	modal.Parent = CoreGui
	modal.ZIndex = 999
	
	table.insert(allWindows, modal)

	local titleBar = Instance.new("TextLabel", modal)
	titleBar.Size = UDim2.new(1, 0, 0, 40)
	titleBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	titleBar.BorderSizePixel = 0
	titleBar.Text = title .. " Settings"
	titleBar.TextColor3 = Color3.new(1, 1, 1)
	titleBar.Font = Enum.Font.SourceSansBold
	titleBar.TextSize = 16
	titleBar.Name = "DragBar"
	titleBar.ZIndex = 1000

	local closeButton = Instance.new("TextButton", modal)
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -40, 0, 0)
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	closeButton.BorderSizePixel = 0
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.TextSize = 16
	closeButton.ZIndex = 1000
	closeButton.MouseButton1Click:Connect(function()
		modal:Destroy()
	end)
	
	self:MakeDraggable(modal, titleBar)

	return modal
end

function infuz:CreateCategory(name, position)
    print('hi')
	local CategoryFrame = Instance.new("Frame")
	CategoryFrame.Size = UDim2.new(0, 180, 0, 40)
	CategoryFrame.Position = position or UDim2.new(0, 100, 0, 100)
	CategoryFrame.BackgroundColor3 = Color3.fromRGB(21, 28, 31)
	CategoryFrame.BorderSizePixel = 0
	CategoryFrame.Active = true
	CategoryFrame.Parent = CoreGui
	
	table.insert(allWindows, CategoryFrame)

	local DragBar = Instance.new("Frame", CategoryFrame)
	DragBar.Size = UDim2.new(1, 0, 0, 40)
	DragBar.BackgroundTransparency = 1
	create("UIListLayout", DragBar, {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})
	create("UIPadding", DragBar, {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	})
	local TitleContainer = Instance.new("Frame", DragBar)
	TitleContainer.BackgroundTransparency = 1
	TitleContainer.AutomaticSize = Enum.AutomaticSize.X
	TitleContainer.Size = UDim2.new(0, 0, 1, 0)
	create("UIListLayout", TitleContainer, {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})
	local CategoryImage = Instance.new("ImageLabel", TitleContainer)
	CategoryImage.Size = UDim2.new(0, 15, 0, 15)
	CategoryImage.BackgroundTransparency = 1
	CategoryImage.Image = "rbxassetid://0"
	CategoryImage.ScaleType = Enum.ScaleType.Fit
	local CategoryTitle = Instance.new("TextLabel", TitleContainer)
	CategoryTitle.Text = name
	CategoryTitle.BackgroundTransparency = 1
	CategoryTitle.AutomaticSize = Enum.AutomaticSize.X
	CategoryTitle.LayoutOrder = 1
	CategoryTitle.Size = UDim2.new(0, 50, 1, 0)
	CategoryTitle.FontFace = Font.fromId(12187372629, Enum.FontWeight.Regular)
	CategoryTitle.TextColor3 = Color3.new(255, 255, 255)
	CategoryTitle.TextSize = 15
	CategoryTitle.TextXAlignment = Enum.TextXAlignment.Left
	local Chevron = Instance.new("ImageLabel", DragBar)
	Chevron.BackgroundTransparency = 1
	Chevron.Size = UDim2.new(0, 10, 0, 10)
	Chevron.Image = "rbxassetid://114144456437057"
	Chevron.ScaleType = Enum.ScaleType.Fit

	local Container = Instance.new("Frame", CategoryFrame)
	Container.BackgroundTransparency = 1
	Container.Position = UDim2.new(0, 0, 0, 40)
	Container.Size = UDim2.new(1, 0, 0, 0)
	Container.ClipsDescendants = true

	local Layout = Instance.new("UIListLayout", Container)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder

	local toggled = false

	DragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			toggled = not toggled
			Container.Size = UDim2.new(1, 0, 0, toggled and (#Container:GetChildren() * 40) - 40 or 0)
			CategoryFrame.Size = UDim2.new(0, 180, 0, toggled and (#Container:GetChildren() * 40) or 40)
		end
	end)

	self:MakeDraggable(CategoryFrame, DragBar)

	local category = { ui = self }
	function category:AddToggle(text, callback)
		local Toggle = Instance.new("TextButton", Container)
		Toggle.Text = ""
		Toggle.AutoButtonColor = false
		Toggle.Size = UDim2.new(1, 0, 0, 40)
		Toggle.BackgroundColor3 = Color3.fromRGB(21, 28, 31)
		Toggle.BorderSizePixel = 0
		create("UIListLayout", Toggle, {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		create("UIPadding", Toggle, {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		})
		local Config = Instance.new("ImageButton", Toggle)
		Config.BackgroundTransparency = 1
		Config.Size = UDim2.new(0, 15, 0, 15)
		Config.ZIndex = 2
		Config.Image = "rbxassetid://97984177563283"
		Config.ScaleType = Enum.ScaleType.Fit
		Config.AutoButtonColor = false
		Config.LayoutOrder = 1
		local Label = Instance.new("TextLabel", Toggle)
		Label.AutomaticSize = Enum.AutomaticSize.XY
		Label.BackgroundTransparency = 1
		Label.FontFace = Font.fromId(12187372629, Enum.FontWeight.Regular)
		Label.Text = text
		Label.TextColor3 = Color3.new(255, 255, 255)
		Label.TextSize = 15
		Label.TextXAlignment = Enum.TextXAlignment.Left

		local active = false
		Toggle.MouseButton1Click:Connect(function()
			active = not active
			Toggle.BackgroundColor3 = active and Color3.fromRGB(0, 119, 182) or Color3.fromRGB(21, 28, 31)
			pcall(callback, active)
		end)

		Config.MouseButton1Click:Connect(function()
			category.ui:CreateSettingsModal(text)
		end)

		if toggled then
			Container.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
		end
	end
	
	--function category:AddButton(text, callback)
	--	local Button = Instance.new("TextButton", Container)
	--	Button.Size = UDim2.new(1, 0, 0, 40)
	--	Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	--	Button.Text = text
	--	Button.Font = Enum.Font.SourceSans
	--	Button.BorderSizePixel = 0
	--	Button.TextColor3 = Color3.new(1, 1, 1)
	--	Button.TextSize = 16

	--	Button.MouseButton1Click:Connect(function()
	--		pcall(callback)
	--	end)

	--	if toggled then
	--		Container.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
	--	end
	--end

	function category:AddSlider(text, min, max, callback)
		local Slider = Instance.new("TextButton", Container)
		Slider.Size = UDim2.new(1, 0, 0, 40)
		Slider.BackgroundColor3 = Color3.fromRGB(21, 28, 31)
		Slider.BorderSizePixel = 0
		Slider.AutoButtonColor = false
		Slider.Text = ""
		
		local Info = Instance.new("Frame", Slider)
		Info.BackgroundTransparency = 1
		Info.Size = UDim2.new(1, 0, 1, 0)
		create("UIPadding", Info, {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		})
		create("UIListLayout", Info, {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		local Label = Instance.new("TextLabel", Info)
		Label.Size = UDim2.new(0, 0, 0, 0)
		Label.AutomaticSize = Enum.AutomaticSize.XY
		Label.BackgroundTransparency = 1
		Label.BorderSizePixel = 0
		Label.Text = text
		Label.TextColor3 = Color3.new(1, 1, 1)
		Label.FontFace = Font.fromId(12187372629, Enum.FontWeight.Regular)
		Label.TextSize = 15
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.ZIndex = 2
		Label.Position = UDim2.new(0, 0, 0.5, 0)
		Label.AnchorPoint = Vector2.new(0, 0.5)
		Label.LayoutOrder = 0
		local Value = Instance.new("TextLabel", Info)
		Value.Size = UDim2.new(0, 0, 0, 0)
		Value.AutomaticSize = Enum.AutomaticSize.XY
		Value.BackgroundTransparency = 1
		Value.BorderSizePixel = 0
		Value.Text = tostring(min)
		Value.TextColor3 = Color3.new(1, 1, 1)
		Value.FontFace = Font.fromId(12187372629, Enum.FontWeight.Light)
		Value.TextSize = 12
		Value.TextXAlignment = Enum.TextXAlignment.Left
		Value.ZIndex = 2
		Value.Position = UDim2.new(0, 0, 0.5, 0)
		Value.AnchorPoint = Vector2.new(0, 0.5)
		Value.LayoutOrder = 1
		local Config = Instance.new("ImageButton", Info)
		Config.BackgroundTransparency = 1
		Config.Size = UDim2.new(0, 15, 0, 15)
		Config.ZIndex = 2
		Config.Image = "rbxassetid://97984177563283"
		Config.ScaleType = Enum.ScaleType.Fit
		Config.AutoButtonColor = false
		Config.LayoutOrder = 1
		Config.LayoutOrder = 2
		

		local Fill = Instance.new("Frame", Slider)
		Fill.AnchorPoint = Vector2.new(0, 0.5)
		Fill.Position = UDim2.new(0, 0, 0.5, 0)
		Fill.Size = UDim2.new(0, 0, 1, 0)
		Fill.BackgroundColor3 = Color3.fromRGB(0, 119, 182)
		Fill.BorderSizePixel = 0
		Fill.ZIndex = 1

		local dragging = false

		local function update(input)
			local rel = (input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X
			rel = math.clamp(rel, 0, 1)
			Fill.Size = UDim2.new(rel, 0, 1, 0)
			local value = math.floor(min + (max - min) * rel)
			Value.Text = tostring(value)
			pcall(callback, value)
		end

		Slider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				update(input)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				update(input)
			end
		end)

		if toggled then
			Container.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
		end
	end

	return category
end

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.RightControl then
		isVisible = not isVisible
		for _, frame in ipairs(allWindows) do
			if frame and frame:IsA("GuiObject") then
				frame.Visible = isVisible
			end
		end
	end
end)

return infuz
