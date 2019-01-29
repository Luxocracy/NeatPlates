local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")

local font = NeatPlatesLocalizedFont or "Interface\\Addons\\NeatPlates\\Media\\DefaultFont.ttf"
local divider = "Interface\\Addons\\NeatPlatesHub\\shared\\ThinBlackLine"

local PanelHelpers = NeatPlatesUtility.PanelHelpers 		-- PanelTools
local DropdownFrame = CreateFrame("Frame", "NeatPlatesHubCategoryFrame", UIParent, "UIDropDownMenuTemplate" )

-- Menu Templates
NeatPlatesHubMenus = NeatPlatesHubMenus or {}

NeatPlatesHubMenus.ScaleModes = {}
NeatPlatesHubMenus.EnemyOpacityModes = {}
NeatPlatesHubMenus.FriendlyOpacityModes = {}
NeatPlatesHubMenus.EnemyBarModes = {}
NeatPlatesHubMenus.FriendlyBarModes = {}
NeatPlatesHubMenus.StyleModes = {}
NeatPlatesHubMenus.TextModes = {}
NeatPlatesHubMenus.HeadlineEnemySubtexts = {}
NeatPlatesHubMenus.NameColorModes = {}

--NeatPlatesHubMenus.RangeModes = {}
--NeatPlatesHubMenus.DebuffStyles = {}
--NeatPlatesHubMenus.AuraWidgetModes = {}
--NeatPlatesHubMenus.ThreatWarningModes = {}


--[[
The basic concept of RapidPanel is that each UI widget will get attached to a 'rail' or alignment column.  This rail
provides access to a common update function.  Each widget gets attached as a stack, with widget definition tagging
the previous widget to anchor to.  Default and consistent anchor points also make for less work.

--]]


local function QuickSetPoints(frame, columnFrame, neighborFrame, xOffset, yOffset)
		local TopOffset = frame.Margins.Top + (yOffset or 0)
		local LeftOffset = frame.Margins.Left + (xOffset or 0)
		frame:ClearAllPoints()
		if neighborFrame then
			if neighborFrame.Margins then TopOffset = neighborFrame.Margins.Bottom + TopOffset + (yOffset or 0) end
			frame:SetPoint("TOP", neighborFrame, "BOTTOM", -(neighborFrame:GetWidth()/2), -TopOffset)
		else frame:SetPoint("TOP", columnFrame, "TOP", 0, -TopOffset) end
		frame:SetPoint("LEFT", columnFrame, "LEFT", LeftOffset, 0)
end

local function CreateQuickSlider(name, label, mode, width, ... ) --, neighborFrame, xOffset, yOffset)
		local columnFrame = ...
		local frame = PanelHelpers:CreateSliderFrame(name, columnFrame, label, .5, 0, 1, .1, mode)
		frame:SetWidth(width or 250)
		--frame.Label:SetFont("FONTS/ARIALN.TTF", 14)
		-- Margins	-- Bottom/Left are negative
		frame.Margins = { Left = 12, Right = 8, Top = 20, Bottom = 13,}
		QuickSetPoints(frame, ...)
		-- Set Feedback Function
		frame:SetScript("OnMouseUp", function()
			--OnPanelItemChange()
			columnFrame.Callback()
			--if columnFrame.OnFeedback then columnFrame:OnFeedback() end
		end)
		return frame, frame
	end

	local function CreateQuickCheckbutton(name, label, ...)
		local columnFrame = ...
		local frame = PanelHelpers:CreateCheckButton(name, columnFrame, label)
		--frame.Label:SetFont("FONTS/ARIALN.TTF", 14)
		-- Margins	-- Bottom/Left are supposed to be negative
		frame.Margins = { Left = 2, Right = 100, Top = 0, Bottom = 0,}
		QuickSetPoints(frame, ...)
		-- Set Feedback Function
		frame:SetScript("OnClick", function()
			--OnPanelItemChange()
			columnFrame.Callback()
			--if columnFrame.OnFeedback then columnFrame:OnFeedback() end
		end)
		return frame, frame
	end

	local function SetSliderMechanics(slider, value, minimum, maximum, increment)
		slider:SetMinMaxValues(minimum, maximum)
		slider:SetValueStep(increment)
		slider:SetValue(value)

		if slider.isActual then
			local multiplier = 1
			if increment < 1 and increment >= .1 then multiplier = 10 elseif increment < .1 then multiplier = 100 end
			slider.ceil = function(v) return ceil(v*multiplier-.5)/multiplier end
			
			slider.Low:SetText(minimum)
			slider.High:SetText(maximum)
		else
			slider.Low:SetText(tostring(minimum*100).."%")
			slider.High:SetText(tostring(maximum*100).."%")
		end
	end

	local function CreateQuickEditbox(name, width, height, ...)
		local columnFrame = ...
		local frame = CreateFrame("ScrollFrame", name, columnFrame, "UIPanelScrollFrameTemplate")
		frame.BorderFrame = CreateFrame("Frame", nil, frame )
		local EditBox = CreateFrame("EditBox", nil, frame)
		-- Margins	-- Bottom/Left are supposed to be negative
		frame.Margins = {Left = 4, Right = 24, Top = 8, Bottom = 8, }
		width, height = width or 150, height or 100

		-- Frame Size
		frame:SetWidth(width+15)
		frame:SetHeight(height+25)
		-- Border
		frame.BorderFrame:SetPoint("TOPLEFT", 0, 5)
		frame.BorderFrame:SetPoint("BOTTOMRIGHT", 3, -5)
		frame.BorderFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
											edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
											tile = true, tileSize = 16, edgeSize = 16,
											insets = { left = 4, right = 4, top = 4, bottom = 4 }
											});
		frame.BorderFrame:SetBackdropColor(0.05, 0.05, 0.05, 0)
		frame.BorderFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
		-- Text

		EditBox:SetPoint("TOPLEFT")
		EditBox:SetPoint("BOTTOMLEFT")
		EditBox:SetHeight(height)
		EditBox:SetWidth(width)
		EditBox:SetMultiLine(true)

		EditBox:SetFrameLevel(frame:GetFrameLevel()-1)
		EditBox:SetFont(NeatPlatesLocalizedInputFont or "Fonts\\FRIZQT__.TTF", 11, "NONE")
		--EditBox:SetText("Empty")
		EditBox:SetText("")
		EditBox:SetAutoFocus(false)
		EditBox:SetTextInsets(9, 6, 2, 2)
		frame:SetScrollChild(EditBox)
		frame.EditBox = EditBox
		--EditBox:SetIndentedWordWrap(true)
		--print(name, EditBox:GetFrameLevel(), frame:GetFrameLevel(), EditBox:GetFrameStrata(), frame:GetFrameStrata())
		-- Functions
		--function frame:GetValue() return SplitToTable(strsplit("\n", EditBox:GetText() )) end
		--function frame:SetValue(value) EditBox:SetText(TableToString(value)) end
		function frame:GetValue() return EditBox:GetText() end
		function frame:SetValue(value) EditBox:SetText(value) end
		frame._SetWidth = frame.SetWidth
		function frame:SetWidth(value) frame:_SetWidth(value); EditBox:SetWidth(value) end
		-- Set Positions
		QuickSetPoints(frame, ...)
		-- Set Feedback Function
		--frame.OnValueChanged = columnFrame.OnFeedback
		return frame, frame
	end

	local function CreateQuickColorbox(name, label, onOkay, ...)
		local columnFrame = ...
		local frame = PanelHelpers:CreateColorBox(name, columnFrame, label, onOkay, 0, .5, 1, 1)
		-- Margins	-- Bottom/Left are supposed to be negative
		frame.Margins = { Left = 5, Right = 100, Top = 3, Bottom = 2,}
		-- Set Positions
		QuickSetPoints(frame, ...)
		-- Set Feedback Function
		frame.OnValueChanged = function() columnFrame.Callback() end
		--frame.OnValueChanged = columnFrame.OnFeedback
		return frame, frame
	end

	local function CreateQuickDropdown(name, label, dropdownTable, initialValue, ...)
		local columnFrame = ...

		local frame = PanelHelpers:CreateDropdownFrame(name, columnFrame, dropdownTable, initialValue, label)		--- ADD the new valueMethod  (2 for Token)
		-- Margins	-- Bottom/Left are supposed to be negative
		if label == "" then
			frame.Margins = { Left = -16, Right = 0, Top = 1, Bottom = 0,}
		else
			frame.Margins = { Left = -12, Right = 2, Top = 22, Bottom = 0,}
		end
		-- Set Positions
		QuickSetPoints(frame, ...)
		-- Set Feedback Function
		frame.OnValueChanged = function() columnFrame.Callback() end
		--frame.OnValueChanged = columnFrame.OnFeedback
		return frame, frame
	end

	local function CreateQuickHeadingLabel(name, label, ...)
		local columnFrame = ...
		local frame = CreateFrame("Frame", name, columnFrame)
		-- Heading Appearance
		frame:SetHeight(32)
		frame:SetWidth(500)
		frame.Text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		frame.Text:SetFont(font, 26)
		frame.Text:SetTextColor(255/255, 105/255, 6/255)
		frame.Text:SetAllPoints()
		frame.Text:SetText(label)
		frame.Text:SetJustifyH("LEFT")
		frame.Text:SetJustifyV("BOTTOM")
                -- Divider Line
                frame.DividerLine = frame:CreateTexture(nil, 'ARTWORK')
                frame.DividerLine:SetTexture(divider)
                frame.DividerLine:SetSize( 500, 12)
                frame.DividerLine:SetPoint("BOTTOMLEFT", frame.Text, "TOPLEFT", 0, 5)
		-- Margins
		frame.Margins = { Left = 6, Right = 2, Top = 12, Bottom = 2,}
		-- Set Positions
		QuickSetPoints(frame, ...)
		-- Bookmark
		local bookmark = CreateFrame("Frame", nil, columnFrame)
		bookmark:SetPoint("TOPLEFT", columnFrame, "TOPLEFT")
		bookmark:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
		columnFrame.Headings = columnFrame.Headings or {}
		columnFrame.Headings[(#columnFrame.Headings)+1] = label
		columnFrame.HeadingBookmarks = columnFrame.HeadingBookmarks or {}
		columnFrame.HeadingBookmarks[label] = bookmark
		-- Done!
		return frame, frame
	end

	local function CreateDrawer(name, label, ...)
		local columnFrame = ...
		local frame = CreateFrame("Frame", name, columnFrame)
		frame.AnchorButton = CreateFrame("Button", name.."Button", columnFrame)

		-- Heading Appearance
		frame:SetHeight(26)
		frame:SetWidth(500)
		-- Clicky Button

		--frame.Border = frame:CreateTexture(nil, "ARTWORK")

		frame.Text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		frame.Text:SetFont(font, 26)
		frame.Text:SetTextColor(255/255, 105/255, 6/255)
		frame.Text:SetAllPoints()
		frame.Text:SetText("Test Text")
		frame.Text:SetJustifyH("LEFT")
		frame.Text:SetJustifyV("BOTTOM")

		--frame.Button = CreateFrame("Button", name.."Button", frame)

		--local frame = CreateFrame("ScrollFrame", name, columnFrame, "UIPanelScrollFrameTemplate")
		--:SetScrollChild()

		-- Margins
		frame.Margins = { Left = 6, Right = 2, Top = 12, Bottom = 2,}
		-- Set Positions
		QuickSetPoints(frame.AnchorButton, ...)
		frame:SetPoint("TOPLEFT", frame.AnchorButton, "TOPLEFT", 0, 0)
		-- Done!
		return frame, frame
	end

	local function CreateQuickItemLabel(name, label, ...)
		local columnFrame = ...
		local frame = CreateFrame("Frame", name, columnFrame)
		frame:SetHeight(15)
		frame:SetWidth(500)
		frame.Text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		--frame.Text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		-- frame.Text:SetFont("Fonts\\FRIZQT__.TTF", 18 )
		-- frame.Text:SetFont("Fonts\\ARIALN.TTF", 18 )
		--frame.Text:SetFont(font, 22 )
		--frame.Text:SetTextColor(1, .7, 0)
		--frame.Text:SetTextColor(55/255, 173/255, 255/255)
		frame.Text:SetAllPoints()
		frame.Text:SetText(label)
		frame.Text:SetJustifyH("LEFT")
		frame.Text:SetJustifyV("BOTTOM")
		-- Margins	-- Bottom/Left are supposed to be negative
		frame.Margins = { Left = 6, Right = 2, Top = 2, Bottom = 2,}
		-- Set Positions
		QuickSetPoints(frame, ...)
		return frame, frame
	end

local function OnMouseWheelScrollFrame(frame, value, name)
	local scrollbar = _G[frame:GetName() .. "ScrollBar"];
	local currentPosition = scrollbar:GetValue()
	local increment = 50

	-- Spin Up
	if ( value > 0 ) then scrollbar:SetValue(currentPosition - increment);
	-- Spin Down
	else scrollbar:SetValue(currentPosition + increment); end
end


NeatPlatesHubRapidPanel = {}
NeatPlatesHubRapidPanel.CreateQuickSlider = CreateQuickSlider
NeatPlatesHubRapidPanel.CreateQuickCheckbutton = CreateQuickCheckbutton
NeatPlatesHubRapidPanel.SetSliderMechanics = SetSliderMechanics
NeatPlatesHubRapidPanel.CreateQuickEditbox = CreateQuickEditbox
NeatPlatesHubRapidPanel.CreateQuickColorbox = CreateQuickColorbox
NeatPlatesHubRapidPanel.CreateQuickDropdown = CreateQuickDropdown
NeatPlatesHubRapidPanel.CreateQuickHeadingLabel = CreateQuickHeadingLabel
NeatPlatesHubRapidPanel.CreateQuickItemLabel = CreateQuickItemLabel
NeatPlatesHubRapidPanel.OnMouseWheelScrollFrame = OnMouseWheelScrollFrame

--[[
local CreateQuickSlider = NeatPlatesHubRapidPanel.CreateQuickSlider
local CreateQuickCheckbutton = NeatPlatesHubRapidPanel.CreateQuickCheckbutton
local SetSliderMechanics = NeatPlatesHubRapidPanel.SetSliderMechanics
local CreateQuickEditbox = NeatPlatesHubRapidPanel.CreateQuickEditbox
local CreateQuickColorbox = NeatPlatesHubRapidPanel.CreateQuickColorbox
local CreateQuickDropdown = NeatPlatesHubRapidPanel.CreateQuickDropdown
local CreateQuickHeadingLabel = NeatPlatesHubRapidPanel.CreateQuickHeadingLabel
local CreateQuickItemLabel = NeatPlatesHubRapidPanel.CreateQuickItemLabel
local OnMouseWheelScrollFrame = NeatPlatesHubRapidPanel.OnMouseWheelScrollFrame
--]]


---------------
-- Helpers
---------------
local yellow, blue, red, orange = "|cffffff00", "|cFF3782D1", "|cFFFF1100", "|cFFFF6906"

local GetPanelValues = NeatPlatesHubHelpers.GetPanelValues
local SetPanelValues = NeatPlatesHubHelpers.SetPanelValues
local ListToTable = NeatPlatesHubHelpers.ListToTable
--local ConvertStringToTable = NeatPlatesHubHelpers.ConvertStringToTable
--local ConvertAuraListTable = NeatPlatesHubHelpers.ConvertAuraListTable
local CopyTable = NeatPlatesUtility.copyTable

--[[
local function GetGlobalSettings()

end

local function SetGlobalSettings()

end

--]]

local function CheckVariableIntegrity(objectName)
	for i,v in pairs(NeatPlatesHubDefaults) do
		if NeatPlatesHubSettings[objectName][i] == nil then NeatPlatesHubSettings[objectName][i] = v end
	end
end

local function CreateVariableSet(objectName, source)
	--print("CreateVariableSet", objectName)
	NeatPlatesHubSettings[objectName] = CopyTable(NeatPlatesHubSettings[source] or NeatPlatesHubDefaults)
	return NeatPlatesHubSettings[objectName]
end

local function GetVariableSet(panel)
	if panel then

		local objectName = panel.objectName

		local settings = NeatPlatesHubSettings[objectName]
		if not settings then

			settings = CreateVariableSet(objectName)
		end
		--print("GetVariableSet", panel, objectName, settings)
		return settings
	else
		--return NeatPlatesHubDefaults
	end
end

local function ClearVariableSet(panel)
	for i, v in pairs(NeatPlatesHubSettings[panel.objectName]) do NeatPlatesHubSettings[panel.objectName][i] = nil end
	NeatPlatesHubSettings[panel.objectName] = nil
	ReloadUI()
end

local function RemoveVariableSet(panel)
	if panel and panel.objectName then
		NeatPlatesHubSettings[panel.objectName] = nil
		NeatPlatesHubSettings.profiles[panel.objectName:gsub("HubPanelProfile", "")] = nil
	end
end

local function OnPanelItemChange(panel)
	local LocalVars = GetVariableSet(panel)
	GetPanelValues(panel, LocalVars)
	panel.RefreshSettings(LocalVars)
end

-- Colors
local yellow, blue, red, orange = "|cffffff00", "|cFF5599EE", "|cFFFF1100", "|cFFFF9920"

local function AddDropdownTitle(title)
	local DropdownTitle, DropdownSpacer = {}, {}

	-- Define Spacer
	DropdownSpacer.text = ""
	DropdownSpacer.notCheckable = 1
	DropdownSpacer.isTitle = 1

	-- Define Title
	DropdownTitle.text = title
	DropdownTitle.notCheckable = 1
	DropdownTitle.isTitle = 1
	DropdownTitle.padding = 16

	-- Add Menu Buttons
	UIDropDownMenu_AddButton(DropdownTitle)
	--UIDropDownMenu_AddButton(DropdownSpacer)
end


local function CreateInterfacePanel( objectName, panelTitle, parentFrameName)

	-- Variables
	------------------------------
	-- This can be created later...
	--CreateVariableSet(objectName)

	-- Panel
	------------------------------
	local panel = CreateFrame( "Frame", objectName.."_InterfaceOptionsPanel", UIParent);
	panel.objectName = objectName
	panel:SetBackdrop({	bgFile = "Interface/Tooltips/UI-Tooltip-Background", --bgFile = "Interface/FrameGeneral/UI-Background-Marble",
						edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
						edgeSize = 16,
						insets = { left = 4, right = 4, top = 4, bottom = 4 },})

	--panel:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 2, right = 2, top = 2, bottom = 2 },})
	panel:SetBackdropColor(.1, .1, .1, .6)
	panel:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
	--panel:SetBackdropColor(0.06, 0.06, 0.06, .5)

	if parentFrameName then
		panel.parent = parentFrameName
	end

	panel.name = panelTitle

	-- Heading
	------------------------------
	--panel.MainLabel = CreateQuickHeadingLabel(nil, panelTitle, panel, nil, 16, 16)
	panel.MainLabel = CreateQuickHeadingLabel(nil, panelTitle, panel, nil, 16, 8)

        -- Warnings
        ------------------------------
	panel.WarningFrame = CreateFrame("Frame", objectName.."WarningFrame", panel )
	panel.WarningFrame:SetPoint("LEFT", 16, 0 )
	panel.WarningFrame:SetPoint("TOP", panel.MainLabel, "BOTTOM", 0, -8 )
        panel.WarningFrame:SetPoint("RIGHT", -16 , 16 )
        panel.WarningFrame:SetHeight(50)
	panel.WarningFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
												edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
												--tile = true, tileSize = 16,
												edgeSize = 16,
												insets = { left = 4, right = 4, top = 4, bottom = 4 }
												});
	--panel.WarningFrame:SetBackdropColor(0.5, 0.5, 0.5, 1)
	panel.WarningFrame:SetBackdropColor(.9, 0.3, 0.2, 1)
	panel.WarningFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
	panel.WarningFrame:Hide()
        -- Description
        panel.Warnings = CreateQuickHeadingLabel(nil, "", panel.WarningFrame, nil, 8, -4)
        -- Button
	local WarningFixButton = CreateFrame("Button", objectName.."WarningFixButton", panel.WarningFrame, "NeatPlatesPanelButtonTemplate")
	WarningFixButton:SetPoint("RIGHT", -10, 0)
	WarningFixButton:SetWidth(150)
        WarningFixButton:SetText("Fix Problem...")


	-- Main Scrolled Frame
	------------------------------
	panel.MainFrame = CreateFrame("Frame")
	panel.MainFrame:SetWidth(412)
	panel.MainFrame:SetHeight(2760) 		-- This can be set VERY long since we've got it in a scrollable window.

	-- Scrollable Panel Window
	------------------------------
	panel.ScrollFrame = CreateFrame("ScrollFrame",objectName.."_Scrollframe", panel, "UIPanelScrollFrameTemplate")
	panel.ScrollFrame:SetPoint("LEFT", 16 )
	panel.ScrollFrame:SetPoint("TOP", panel.MainLabel, "BOTTOM", 0, -8 )
	panel.ScrollFrame:SetPoint("BOTTOMRIGHT", -32 , 16 )
	panel.ScrollFrame:SetScrollChild(panel.MainFrame)
	panel.ScrollFrame:SetScript("OnMouseWheel", OnMouseWheelScrollFrame)

	-- Scroll Frame Border
	------------------------------
	panel.ScrollFrameBorder = CreateFrame("Frame", objectName.."ScrollFrameBorder", panel.ScrollFrame )
	panel.ScrollFrameBorder:SetPoint("TOPLEFT", -4, 5)
	panel.ScrollFrameBorder:SetPoint("BOTTOMRIGHT", 3, -5)
	panel.ScrollFrameBorder:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
												edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
												--tile = true, tileSize = 16,
												edgeSize = 16,
												insets = { left = 4, right = 4, top = 4, bottom = 4 }
												});
	panel.ScrollFrameBorder:SetBackdropColor(0.05, 0.05, 0.05, 0)
	panel.ScrollFrameBorder:SetBackdropBorderColor(0.2, 0.2, 0.2, 0)

	-- Alignment Colum
	------------------------------
	panel.AlignmentColumn = CreateFrame("Frame", objectName.."_AlignmentColumn", panel.MainFrame)
	panel.AlignmentColumn:SetPoint("TOPLEFT", 12,0)
	panel.AlignmentColumn:SetPoint("BOTTOMRIGHT", panel.MainFrame, "BOTTOM")
	panel.AlignmentColumn.Callback = function() OnPanelItemChange(panel) end

	-----------------
	-- Panel Event Handler
	-----------------


	--panel:SetScript("OnEvent", function()
	panel:SetScript("OnShow", function()
		-- Check for Variable Set
		if not GetVariableSet(panel) then CreateVariableSet(objectName) end
		-- Verify Variable Integrity
		CheckVariableIntegrity(objectName)
		-- Refresh Panel based on loaded variables
		if panel.RefreshSettings then panel.RefreshSettings(GetVariableSet(panel)) end
	end)

	--panel:RegisterEvent("PLAYER_ENTERING_WORLD")

	panel.onEditboxOkay = function() OnPanelItemChange(panel) end


	-----------------
	-- Config Management Buttons
	-----------------

-- [[
	-- Bookmark/Table of Contents Button
	local BookmarkButton = CreateFrame("Button", objectName.."BookmarkButton", panel, "NeatPlatesPanelButtonTemplate")
	--BookmarkButton:SetPoint("TOPRIGHT", ReloadThemeDataButton, "TOPLEFT", -4, 0)
	BookmarkButton:SetPoint("TOPRIGHT", -40, -22)
	BookmarkButton:SetWidth(110)
	BookmarkButton:SetScale(.85)
	BookmarkButton:SetText(L["Categories"])


	local function OnClickBookmark(frame)
		local scrollTo = panel.AlignmentColumn.HeadingBookmarks[frame:GetText()]:GetHeight()
		--print(frame:GetText(), scrollTo)
		panel.ScrollFrame:SetVerticalScroll(ceil(scrollTo - 27))
		PanelHelpers.HideDropdownMenu()
	end

	local function OnClickBookmarkDrawer(frame)
		PlaySound(856)

		if not (panel.AlignmentColumn and panel.AlignmentColumn.Headings) then return end
		local BookmarkMenu = {}


		for index, name in pairs(panel.AlignmentColumn.Headings) do
			BookmarkMenu[index] = {}
			BookmarkMenu[index].text = name
		end

		PanelHelpers.ShowDropdownMenu(BookmarkButton, BookmarkMenu, OnClickBookmark)
	end


	BookmarkButton:SetScript("OnClick", OnClickBookmarkDrawer )

	-- Make Default Profile
	local DefaultProfileButton = CreateFrame("Button", objectName.."DefaultProfileButton", panel, "NeatPlatesPanelButtonTemplate")
	DefaultProfileButton:SetPoint("LEFT", BookmarkButton, -120, 0)
	DefaultProfileButton:SetWidth(110)
	DefaultProfileButton:SetScale(.85)
	DefaultProfileButton:SetText(L["Default Profile"])

	local function OnClickDefaultProfile(frame)
		PlaySound(856)
		local name = panel.objectName:gsub("HubPanelProfile", "")

		-- Set profile as the default profile.
		StaticPopupDialogs["NeatPlates_DefaultProfile"] = {
		  text = name:gsub(".+", L["Do you really want to make '%1' the default profile?"]),
		  button1 = YES,
		  button2 = NO,
		  OnAccept = function()
		  	local yellow, blue, red, orange = "|cffffff00", "|cFF3782D1", "|cFFFF1100", "|cFFFF6906"
		  	NeatPlatesSettings.DefaultProfile = name
		  	-- Update names of profiles
		  	NeatPlatesHubMenus.UpdateDefaultPanel(name)

		  	print(orange.."NeatPlates: "..blue..name:gsub(".+", L["The profile '%1' is now the Default profile."]))
		  end,
		  timeout = 0,
		  whileDead = true,
		  hideOnEscape = true,
		  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
		}
		StaticPopup_Show("NeatPlates_DefaultProfile")
	end


	DefaultProfileButton:SetScript("OnClick", OnClickDefaultProfile)
--]]

	local function SetMaximizeButtonTexture(frame)
		--frame:SetNormalTexture("Interface\\Buttons\\UI-Panel-BiggerButton-Up")
		frame:SetNormalTexture("Interface\\Buttons\\UI-Panel-SmallerButton-Up")
		--frame:SetPushedTexture("Interface\\Buttons\\UI-Panel-BiggerButton-Down")
		frame:SetPushedTexture("Interface\\Buttons\\UI-Panel-SmallerButton-Down")
	end

	-- Unlink - Detach -
	local ClosePanel, UnLinkPanel, EnableUnlink
	local UnlinkButton
	UnlinkButton = CreateFrame("Button", objectName.."UnlinkButton", panel, "UIPanelCloseButton")
	UnlinkButton:SetPoint("LEFT", PasteThemeDataButton, "RIGHT", 0, -0.5)
	UnlinkButton:SetScale(.95)
	SetMaximizeButtonTexture(UnlinkButton)



	EnableUnlink = function()
		UnlinkButton:SetScript("OnClick", UnLinkPanel)
		SetMaximizeButtonTexture(UnlinkButton)
		UnlinkButton:SetScript("OnClick", UnLinkPanel)

		--panel:SetScale(1)
		panel:SetMovable(false)
		panel:SetScript("OnDragStart",nil)
		panel:SetScript("OnDragStop",nil)
                panel:SetBackdropColor(.1, .1, .1, .6)
	end

	-- The Unlink feature will pop the config panel onto its own movable window frame
	UnLinkPanel = function (self)
		HideUIPanel(InterfaceOptionsFrame)		-- ShowUIPanel(InterfaceOptionsFrame);
		local height, width = panel:GetHeight(), panel:GetWidth()
		panel:SetParent(UIParent)
		panel:ClearAllPoints()
		panel:SetHeight(height - 40)
		panel:SetWidth(width - 60)
		panel:SetPoint("CENTER")
		--panel:SetScale(.95)
                panel:SetBackdropColor(.1, .1, .1, 1)

		--[[
		panel:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background",
											edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
											--edgeFile = "Interface/DialogFrame/UI-DialogBox-Gold-Border",
											--tile = true, tileSize = 16,
											edgeSize = 16,
											insets = { left = 4, right = 4, top = 4, bottom = 4 }
											});

		--panel:SetBackdropColor(0.05, 0.05, 0.05, .8)
		panel:SetBackdropColor(0.06, 0.06, 0.06, 1)
		panel:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
		--]]

		panel:SetClampedToScreen(true)
		panel:RegisterForDrag("LeftButton")
		panel:EnableMouse(true)
		panel:SetMovable(true)
		panel:SetScript("OnDragStart", function(self, button) panel:SetAlpha(.9); if button =="LeftButton" then panel:StartMoving() end end)
		panel:SetScript("OnDragStop", function(self, button) panel:SetAlpha(1); panel:StopMovingOrSizing() end)

		-- Repurpose button for Close
		self:SetScript("OnClick", ClosePanel)
		self:SetScale(.90)
		self:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
		self:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
	end

	ClosePanel = function(self)
		OnPanelItemChange(panel)
		EnableUnlink()
		panel:Hide()
	end

        local function OpenNeatPlatesConfig()
            InterfaceOptionsFrame_OpenToCategory("Neat Plates")
        end

        local RefreshPanel = function(self)
            SetPanelValues(panel, GetVariableSet(panel))
            EnableUnlink(UnlinkButton)

            local activeTheme = NeatPlates:GetTheme()

            if activeTheme.OnUpdate and (activeTheme.OnUpdate == NeatPlatesHubFunctions.OnUpdate) then
            	panel.WarningFrame:Hide()
                panel.ScrollFrame:SetPoint("TOP", panel.MainLabel, "BOTTOM", 0, -8 )        -- Default

     		else
				panel.ScrollFrame:SetPoint("TOP", panel.WarningFrame, "BOTTOM", 0, -8 )     -- Warning
                panel.WarningFrame:Show()
                panel.Warnings.Text:SetText("It appears that you're not using a Hub-compatible Theme.")
                panel.Warnings.Text:SetTextColor(1, 1, 1)
                panel.Warnings.Text:SetFont(font, 18)

                WarningFixButton:SetText("Change Theme...")
                WarningFixButton:SetScript("OnClick", OpenNeatPlatesConfig)
            end

            --[[
            -- On Warning...
            panel.ScrollFrame:SetPoint("TOP", panel.MainLabel, "BOTTOM", 0, -8       -- Default
            panel.ScrollFrame:SetPoint("TOP", panel.MainLabel, "BOTTOM", 0, -8       -- Default

            panel.ScrollFrame:SetPoint("TOP", panel.WarningFrame, "BOTTOM", 0, -8 )     -- Warning

            panel.WarningFrame:Hide()
        -- Description
        panel.Warnings
            --]]
            --Theme.ShowConfigPanel = ShowNeatPlatesHubDamagePanel
        end

	-----------------
	-- Button Handlers
	-----------------
	panel.okay = ClosePanel --function() OnPanelItemChange(panel) end
	panel.cancel = NeatPlates.Update
	panel.refresh = RefreshPanel
        panel:SetScript("OnShow", RefreshPanel)
	UnlinkButton:SetScript("OnClick", UnLinkPanel)

	InterfaceOptions_AddCategory(panel)
	----------------
	-- Return a pointer to the whole thingy
	----------------
	return panel
end


NeatPlatesHubRapidPanel.CreateInterfacePanel = CreateInterfacePanel
NeatPlatesHubRapidPanel.CreateVariableSet = CreateVariableSet
NeatPlatesHubRapidPanel.RemoveVariableSet = RemoveVariableSet
