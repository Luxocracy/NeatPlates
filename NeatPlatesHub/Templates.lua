local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")
local AceSerializer = LibStub("AceSerializer-3.0")
--local LocalVars = NeatPlatesHubDefaults

local font = NeatPlatesLocalizedFont or "Interface\\Addons\\NeatPlates\\Media\\DefaultFont.ttf"
local divider = "Interface\\Addons\\NeatPlatesHub\\shared\\ThinBlackLine"

local PanelHelpers = NeatPlatesUtility.PanelHelpers 		-- PanelTools
local DropdownFrame = CreateFrame("Frame", "NeatPlatesHubCategoryFrame", UIParent, "UIDropDownMenuTemplate" )
local OnMouseWheelScrollFrame

local CopyTable = NeatPlatesUtility.copyTable
local yellow, blue, red, orange = "|cffffff00", "|cFF3782D1", "|cFFFF1100", "|cFFFF6906"

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
			columnFrame:Callback()
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

	--local function CreateQuickEditbox(name, width, height, ...)
	--	local columnFrame = ...
	--	local frame = CreateFrame("ScrollFrame", name, columnFrame, "UIPanelScrollFrameTemplate")
	--	frame.BorderFrame = CreateFrame("Frame", nil, frame )
	--	local EditBox = CreateFrame("EditBox", nil, frame)
	--	-- Margins	-- Bottom/Left are supposed to be negative
	--	frame.Margins = {Left = 4, Right = 24, Top = 8, Bottom = 8, }
	--	width, height = width or 150, height or 100

	--	-- Frame Size
	--	frame:SetWidth(width+15)
	--	frame:SetHeight(height+25)
	--	-- Border
	--	frame.BorderFrame:SetPoint("TOPLEFT", 0, 5)
	--	frame.BorderFrame:SetPoint("BOTTOMRIGHT", 3, -5)
	--	frame.BorderFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	--										edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	--										tile = true, tileSize = 16, edgeSize = 16,
	--										insets = { left = 4, right = 4, top = 4, bottom = 4 }
	--										});
	--	frame.BorderFrame:SetBackdropColor(0.05, 0.05, 0.05, 0)
	--	frame.BorderFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	--	-- Text

	--	EditBox:SetPoint("TOPLEFT")
	--	EditBox:SetPoint("BOTTOMLEFT")
	--	EditBox:SetHeight(height)
	--	EditBox:SetWidth(width)
	--	EditBox:SetMultiLine(true)

	--	EditBox:SetFrameLevel(frame:GetFrameLevel()-1)
	--	EditBox:SetFont(NeatPlatesLocalizedInputFont or "Fonts\\FRIZQT__.TTF", 11, "NONE")
	--	--EditBox:SetText("Empty")
	--	EditBox:SetText("")
	--	EditBox:SetAutoFocus(false)
	--	EditBox:SetTextInsets(9, 6, 2, 2)
	--	frame:SetScrollChild(EditBox)
	--	frame.EditBox = EditBox
	--	--EditBox:SetIndentedWordWrap(true)
	--	--print(name, EditBox:GetFrameLevel(), frame:GetFrameLevel(), EditBox:GetFrameStrata(), frame:GetFrameStrata())
	--	-- Functions
	--	--function frame:GetValue() return SplitToTable(strsplit("\n", EditBox:GetText() )) end
	--	--function frame:SetValue(value) EditBox:SetText(TableToString(value)) end
	--	function frame:GetValue() return EditBox:GetText() end
	--	function frame:SetValue(value) EditBox:SetText(value) end
	--	frame._SetWidth = frame.SetWidth
	--	function frame:SetWidth(value) frame:_SetWidth(value); EditBox:SetWidth(value) end
	--	-- Set Positions
	--	QuickSetPoints(frame, ...)
	--	-- Set Feedback Function
	--	--frame.OnValueChanged = columnFrame.OnFeedback
	--	return frame, frame
	--end

	local CreateQuickEditbox = NeatPlatesUtility.PanelHelpers.CreateEditBox

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

	local function OptionsList_ClearSelection(listFrame, buttons)
		for _, button in pairs(buttons) do
			button.highlight:SetVertexColor(.196, .388, .8);
			button:UnlockHighlight();
		end

		listFrame.selection = nil;
	end

	local function OptionsList_SelectButton(listFrame, button)
		button.highlight:SetVertexColor(1, 1, 0);
		button:LockHighlight()

		listFrame.selection = button;
	end

	local function CreateQuickScrollList(parent, name, lists, buttonFunc)
		-- Create scroll frame
		local frame = CreateFrame("ScrollFrame", name.."_Scrollframe", parent, 'UIPanelScrollFrameTemplate')
		local child = CreateFrame("Frame", name.."_ScrollList")
		frame.listFrame = child
		frame:SetWidth(160)
		frame:SetHeight(260)
		child:SetWidth(160)
		child:SetHeight(100)

		-- Populate with list
		local lastItem
		for k,list in pairs(lists) do
			-- Create Label
			if list.label then
				local label = child:CreateFontString(nil, "OVERLAY")
				label:SetFont(NeatPlatesLocalizedFont or "Interface\\Addons\\NeatPlates\\Media\\DefaultFont.ttf", 18)
				label:SetTextColor(255/255, 105/255, 6/255)
				label:SetText(list.label)

				-- attach below previous item
				if lastItem then
					label:SetPoint("TOPLEFT", lastItem, "BOTTOMLEFT", 0, -8)
				else
					label:SetPoint("TOPLEFT", 0, 0)
				end
				lastItem = label
			end

			-- Create Buttons
			for i,item in pairs(list.list) do
				if item.text and item.value then
					-- create button
					local button = CreateFrame("Button", item.value.."_Button", child, 'NeatPlatesOptionsListButtonTemplate')
					button.value = item.value
					button.tooltipText = item.tooltip
					button.category = list.value
					button.options = item.options or {}
					button.highlight = button:GetHighlightTexture()

					button:SetText(item.text)
					button:SetScript("OnClick", function(self)
						OptionsList_ClearSelection(child, {child:GetChildren()})
						OptionsList_SelectButton(child, self)

						buttonFunc(self)
					end)

					-- attach below previous item
					if lastItem then
						button:SetPoint("TOPLEFT", lastItem, "BOTTOMLEFT", 0, 0)
					else
						button:SetPoint("TOPLEFT", 0, 0)
					end
					lastItem = button
				end
			end
		end
		

		frame:SetScrollChild(child)
		frame:SetScript("OnMouseWheel", OnMouseWheelScrollFrame)

		return frame
	end

	local CustomizationPanel
	local function CreateQuickCustomizationPanel(frame, parent, profile)
		-- Things to add:
		-- Sort the order of options to make more sense.
			 -- See if it's possible to combine some options (Might not be doable since were not changing the values with a multiplier but rather adding to them)
		-- 	Advanced Button(edit code directly)

		local list = {
			{ label = L["Main"], value = "main", list = NeatPlatesHubMenus.StyleOptions },
			{ label = L["Widgets"], value = "widgets", list = NeatPlatesHubMenus.WidgetOptions },
			{ label = L["Configuration"], value = "config", list = {
					{
						text = L["Import"],
						value = "import",
						tooltip = L["Import_tooltip"],
					},
					{
						text = L["Export"],
						value = "export",
						tooltip = L["Export_tooltip"],
					},
					{
						text = L["Reset All"],
						value = "reset",
						tooltip = L["ResetAll_tooltip"],
					},
			} }
		}

		local listCallback = {}

		-- Buttons states
		local options = {
  		StyleDropdown = function(self, option) return self.category == "main" end,
  		EnableCheckbox = function(self, option) return (option.enabled ~= nil or (self.category == "main" and option.enabled ~= false)) end,
  		AnchorOptions = function(self, option) return option.anchor ~= nil end,
  		AlignOptions = function(self, option) return option.align ~= nil end,
  		FontSize = function(self, option) return option.size ~= nil end,
  		OffsetX = function(self, option) return option.x ~= nil end,
  		OffsetY = function(self, option) return option.y ~= nil end,
  		OffsetWidth = function(self, option) return option.width ~= nil or option.w ~= nil end,
  		OffsetHeight = function(self, option) return option.height ~= nil or option.h ~= nil end,
  		ImportExport = function(self, option) return self.value == "import" or self.value == "export" end,
  		ImportButton = function(self, option) return self.value == "import" end,
  		ResetPrompt = function(self, option) return self.value == "reset" end,
  		ResetButton = function(self, option) return self.category and self.category ~= "config" end,
		}

		-- Update Panel Values
		local function updatePanelValues(self)
			if not self and not CustomizationPanel.activeFrame then return end
			if not self then self = CustomizationPanel.activeFrame end
	  	local theme = NeatPlates:GetTheme()
	  	local category = "WidgetConfig"
			if self.category == "main" then
				category = CustomizationPanel.StyleDropdown:GetValue()
	  	end
	  	local current = NeatPlatesHubFunctions.GetCustomizationOption(CustomizationPanel.profile, category, self.value) or {}
	  	local default = theme[category.."Backup"][self.value] or {}

	  	local getObjectName = function(item)
	  		local objectName = item.objectName
	  		if type(objectName) == "table" then
	  			for i=1, #objectName, 1 do
	  				if default[objectName[i]] then
	  					objectName = objectName[i]
	  					break
	  				end
	  			end
	  		end
	  		return objectName
	  	end

	  	local getOptionValue = function(item, defaultValue)
	  		local objectName = getObjectName(item)
	  		local value = current[objectName]
	  		if type(value) == "table" and value.value ~= nil then value = value.value end

	  		if value == nil and defaultValue ~= nil then value = defaultValue
				elseif value == nil then value = default[objectName] end

	  		return value
	  	end

	  	-- If not empty
	  	if next(self) then
		  	CustomizationPanel.activeFrame = self
		  	CustomizationPanel.activeOption = self.value
		  	CustomizationPanel.activeCategory = category

		  	-- Button OnClick
		  	CustomizationPanel.Title:SetText(L["Theme Customization"].." ("..self:GetText()..")") -- Set Title Text
		  else
		  	CustomizationPanel.Title:SetText(L["Theme Customization"]) -- Set Title Text
		  end
	  	-- Set Customization Values & Show/Hide Elements
	  	for k,option in pairs(options) do
	  		local item = CustomizationPanel[k]
	  		item.fetching = true -- Prevents 'OnValueChanged' from triggering while setting values.
	  		if self and option(self, default) then
	  			local itemType = type(default[getObjectName(item)])
	  			item:Show()
	  			item.enabled = true
					
	  			if itemType == "boolean" then
	  				item:SetChecked(getOptionValue(item))
					elseif itemType == "number" then
	  				-- For Offsets default value to zero instead of actaul value
	  				if item.objectType == "offset" then
							item:updateValues(getOptionValue(item, 0))
	  				else
							item:updateValues(getOptionValue(item))
	  				end
					elseif item.objectName then
						item:SetValue(getOptionValue(item))
					elseif self.value == "import" then
						if item.SetValue then item:SetValue("") end
					elseif self.value == "export" then
						item:SetValue(AceSerializer:Serialize(NeatPlatesHubFunctions.GetCustomizationOption(CustomizationPanel.profile)))
					end
	  		else
	  			item:Hide()
	  			item.enabled = false
	  		end
	  		item.fetching = false
	  	end

	  	-- Custom Callback
	  	if listCallback[self.value] and type(listCallback[self.value]) == "function" then listCallback[self.value]() end
	  end


		if not CustomizationPanel then
			-- Build the actual panel
			CustomizationPanel = CreateFrame("Frame", "NeatPlatesCustomizationPanel", UIParent, "UIPanelDialogTemplate");
			CustomizationPanel:Hide()
		  CustomizationPanel:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 2, right = 2, top = 2, bottom = 2 },})
		  CustomizationPanel:SetBackdropColor(0.06, 0.06, 0.06, .7)
		  CustomizationPanel:SetWidth(600)
		  CustomizationPanel:SetHeight(300)
		  CustomizationPanel:SetPoint("CENTER", UIParent, "CENTER", 0, 0 )
		  CustomizationPanel:SetFrameStrata("DIALOG")

		  CustomizationPanel:SetMovable(true)
		  CustomizationPanel:EnableMouse(true)
		  CustomizationPanel:RegisterForDrag("LeftButton", "RightButton")
		  CustomizationPanel:SetScript("OnMouseDown", function(self,arg1)
		    self:StartMoving()
		  end)
		  CustomizationPanel:SetScript("OnMouseUp", function(self,arg1)
		    self:StopMovingOrSizing()
		  end)

		  -- Create List Items
		  CustomizationPanel.List = CreateQuickScrollList(CustomizationPanel, "NeatPlatesCustomizationList", list, updatePanelValues)
		  CustomizationPanel.List:SetWidth(170)
		  CustomizationPanel.List:SetPoint("TOPLEFT", 15, -29)

		  local StyleOptions = {
		  	{ text = L["Default/Healthbar"], value = "Default"  },
				{ text = L["Headline/Text-Only"], value = "NameOnly"  },
		  }

		  local AnchorOptions = {
				{ text = L["CENTER"], value = "CENTER"  },
				{ text = L["TOP"], value = "TOP"  },
				{ text = L["LEFT"], value = "LEFT"  },
				{ text = L["RIGHT"], value = "RIGHT"  },
				{ text = L["BOTTOM"], value = "BOTTOM"  },
				{ text = L["TOPLEFT"], value = "TOPLEFT"  },
				{ text = L["TOPRIGHT"], value = "TOPRIGHT"  },
				{ text = L["BOTTOMLEFT"], value = "BOTTOMLEFT"  },
				{ text = L["BOTTOMRIGHT"], value = "BOTTOMRIGHT"  },
			}

		  local AlignOptions = {
				{ text = L["LEFT"], value = "LEFT" },
				{ text = L["CENTER"], value = "CENTER" },
				{ text = L["RIGHT"], value = "RIGHT" },
			}

		  -- Create Options
		  CustomizationPanel.StyleDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesCustomizationPanel_StyleDropdown", CustomizationPanel, StyleOptions, "Default", L["Style Mode"], true)
			CustomizationPanel.StyleDropdown:SetPoint("TOPRIGHT", CustomizationPanel, "TOPRIGHT", -45, -54)
			CustomizationPanel.StyleDropdown.OnValueChanged = function() updatePanelValues() end
			CustomizationPanel.EnableCheckbox = PanelHelpers:CreateCheckButton("NeatPlatesOptions_EnableCheckbox", CustomizationPanel, L["Element Enabled"])
			CustomizationPanel.EnableCheckbox:SetPoint("TOPLEFT", CustomizationPanel.StyleDropdown, "BOTTOMLEFT", 16, 4)
			CustomizationPanel.EnableCheckbox.objectName = "enabled"
			CustomizationPanel.EnableCheckbox:SetScript("OnClick", function(self) CustomizationPanel.OnValueChanged(self) end)

			CustomizationPanel.AnchorOptions = PanelHelpers:CreateDropdownFrame("NeatPlatesCustomizationPanel_AnchorOptions", CustomizationPanel, AnchorOptions, "CENTER", L["Frame Anchor"], true)
			CustomizationPanel.AnchorOptions:SetPoint("TOPLEFT", CustomizationPanel.List, "TOPRIGHT", 20, -20)
			CustomizationPanel.AnchorOptions.objectName = "anchor"
			CustomizationPanel.AlignOptions = PanelHelpers:CreateDropdownFrame("NeatPlatesCustomizationPanel_AlignOptions", CustomizationPanel, AlignOptions, "LEFT", L["Text Align"], true)
			CustomizationPanel.AlignOptions:SetPoint("TOPLEFT", CustomizationPanel.AnchorOptions, "BOTTOMLEFT", 0, -20)
			CustomizationPanel.AlignOptions.objectName = "align"

			CustomizationPanel.FontSize = PanelHelpers:CreateSliderFrame("NeatPlatesCustomizationPanel_FontSize", CustomizationPanel, L["Font Size"], 0, 1, 50, 1, "ACTUAL", 160, false)
			CustomizationPanel.FontSize:SetPoint("TOPRIGHT", CustomizationPanel.StyleDropdown, "BOTTOMRIGHT", 20, -42)
			CustomizationPanel.FontSize.objectName = "size"
			CustomizationPanel.OffsetX = PanelHelpers:CreateSliderFrame("NeatPlatesCustomizationPanel_OffsetX", CustomizationPanel, L["Offset X"], 0, -50, 50, 1, "ACTUAL", 160, true)
			CustomizationPanel.OffsetX:SetPoint("TOPRIGHT", CustomizationPanel.StyleDropdown, "BOTTOMRIGHT", 20, -84)
			CustomizationPanel.OffsetX.objectName = "x"
			CustomizationPanel.OffsetX.objectType = 'offset'
			CustomizationPanel.OffsetY = PanelHelpers:CreateSliderFrame("NeatPlatesCustomizationPanel_OffsetY", CustomizationPanel, L["Offset Y"], 0, -50, 50, 1, "ACTUAL", 160, true)
			CustomizationPanel.OffsetY:SetPoint("TOPLEFT", CustomizationPanel.OffsetX, "TOPLEFT", 0, -45)
			CustomizationPanel.OffsetY.objectName = "y"
			CustomizationPanel.OffsetY.objectType = 'offset'
			CustomizationPanel.OffsetWidth = PanelHelpers:CreateSliderFrame("NeatPlatesCustomizationPanel_OffsetWidth", CustomizationPanel, L["Offset Width"], 0, -50, 50, 1, "ACTUAL", 160, true)
			CustomizationPanel.OffsetWidth:SetPoint("RIGHT", CustomizationPanel.OffsetX, "LEFT", -30, 0)
			CustomizationPanel.OffsetWidth.objectName = {"width", "w"}
			CustomizationPanel.OffsetWidth.objectType = 'offset'
			CustomizationPanel.OffsetHeight = PanelHelpers:CreateSliderFrame("NeatPlatesCustomizationPanel_OffsetHeight", CustomizationPanel, L["Offset Height"], 0, -50, 50, 1, "ACTUAL", 160, true)
			CustomizationPanel.OffsetHeight:SetPoint("TOPLEFT", CustomizationPanel.OffsetWidth, "TOPLEFT", 0, -45)
			CustomizationPanel.OffsetHeight.objectName = {"height", "h"}
			CustomizationPanel.OffsetHeight.objectType = 'offset'

			CustomizationPanel.ImportExport = PanelHelpers.CreateEditBox("NeatPlatesCustomizationPanel_ImportExport", 340, 190, CustomizationPanel, "TOPLEFT", CustomizationPanel.List, "TOPRIGHT", 30, -10)

			CustomizationPanel.ResetPrompt = CreateFrame("Frame", 'NeatPlatesCustomizationPanel_ResetPromp', CustomizationPanel, "NeatPlatesPromptTemplate")
			CustomizationPanel.ResetPrompt:SetPoint("LEFT", CustomizationPanel.List, "RIGHT", 60, 20)
			CustomizationPanel.ResetPrompt.text:SetText(L["Are you sure you want to reset all Theme Customizations?"])

			-- Create Buttons
			CustomizationPanel.CancelButton = CreateFrame("Button", "NeatPlatesCustomizationCancelButton", CustomizationPanel, "NeatPlatesPanelButtonTemplate")
			CustomizationPanel.CancelButton:SetPoint("BOTTOMRIGHT", -12, 12)
			CustomizationPanel.CancelButton:SetWidth(80)
			CustomizationPanel.CancelButton:SetText(CANCEL)

			CustomizationPanel.CancelButton:SetScript("OnClick", function(self) CustomizationPanel:Hide() end)

			CustomizationPanel.OkayButton = CreateFrame("Button", "NeatPlatesCustomizationOkayButton", CustomizationPanel, "NeatPlatesPanelButtonTemplate")
			CustomizationPanel.OkayButton:SetPoint("RIGHT", CustomizationPanel.CancelButton, "LEFT", -6, 0)
			CustomizationPanel.OkayButton:SetWidth(80)
			CustomizationPanel.OkayButton:SetText(OKAY)

			CustomizationPanel.OkayButton:SetScript("OnClick", function(self) CustomizationPanel.oldValues = nil; CustomizationPanel:Hide() end)

			CustomizationPanel.ResetButton = CreateFrame("Button", "NeatPlatesCustomizationResetButton", CustomizationPanel, "NeatPlatesPanelButtonTemplate")
			CustomizationPanel.ResetButton:SetPoint("BOTTOMLEFT", CustomizationPanel.List, "BOTTOMRIGHT", 36, 1)
			CustomizationPanel.ResetButton:SetWidth(80)
			CustomizationPanel.ResetButton:SetText(L["Reset"])

			CustomizationPanel.ImportButton = CreateFrame("Button", "NeatPlatesCustomizationImportButton", CustomizationPanel, "NeatPlatesPanelButtonTemplate")
			CustomizationPanel.ImportButton:SetPoint("BOTTOMLEFT", CustomizationPanel.List, "BOTTOMRIGHT", 36, 1)
			CustomizationPanel.ImportButton:SetWidth(80)
			CustomizationPanel.ImportButton:SetText(L["Import"])

			-- Scripts
			-- Clear selected option
			CustomizationPanel.ClearSelections = function(self)
				OptionsList_ClearSelection(self.List.listFrame, {self.List.listFrame:GetChildren()}) -- Clear Selected item
			end

			-- Reset Prompt Buttons
			CustomizationPanel.ResetPrompt.button1.Callback = function()
				NeatPlatesHubFunctions.SetCustomizationOption(CustomizationPanel.profile, {
					Default = {},
					NameOnly = {},
					WidgetConfig = {}
				})
				--CustomizationPanel.oldValues = nil
				updatePanelValues({})
				CustomizationPanel:ClearSelections() -- Clear Selected item

				NeatPlatesHubHelpers.CallForStyleUpdate()
				print(orange.."NeatPlates: "..blue..L["All Theme Customizations have been reset."])
			end
			CustomizationPanel.ResetPrompt.button2.Callback = function()
				updatePanelValues({})
				CustomizationPanel:ClearSelections() -- Clear Selected item
			end

			-- On reset button clicked
			CustomizationPanel.ResetButton:SetScript("OnClick", function(self)
				local activeOption = CustomizationPanel.activeOption
				local category = CustomizationPanel.activeCategory
				if activeOption then
					NeatPlatesHubFunctions.SetCustomizationOption(CustomizationPanel.profile, category, activeOption)
					updatePanelValues()
					NeatPlatesHubHelpers.CallForStyleUpdate()
				end
			end)

			-- On Import button clicked
			CustomizationPanel.ImportButton:SetScript("OnClick", function(self)
				local _success, deserialized = AceSerializer:Deserialize(CustomizationPanel.ImportExport:GetValue())
				if(not _success) then
					print(orange.."NeatPlates: "..red..deserialized)
					error(deserialized)
					return
				end

				NeatPlatesHubFunctions.SetCustomizationOption(CustomizationPanel.profile, deserialized)
				updatePanelValues({})
				CustomizationPanel:ClearSelections() -- Clear Selected item

				NeatPlatesHubHelpers.CallForStyleUpdate()
				print(orange.."NeatPlates: "..blue..L["Imported Theme Customizations."])
			end)

			-- On panel hide
			CustomizationPanel:SetScript("OnHide", function(self)
				NeatPlates._TestMode = false 
				CustomizationPanel:ClearSelections() -- Clear Selected item

				-- Restore old values if user didn't hit Okay button
				if CustomizationPanel.oldValues then
					NeatPlatesHubFunctions.SetCustomizationOption(CustomizationPanel.profile, CustomizationPanel.oldValues)
					CustomizationPanel.oldValues = nil
				end

				-- Style Update
				NeatPlatesHubHelpers.CallForStyleUpdate()
			end)

			-- On panel show
			CustomizationPanel:SetScript("OnShow", function(self)
				NeatPlates._TestMode = true
				CustomizationPanel:ClearSelections() -- Clear Selected to set highlight color properly the first time
				self.oldValues = CopyTable(NeatPlatesHubFunctions.GetCustomizationOption(CustomizationPanel.profile) or {})
				-- Hide Settings sliders etc.
				for k,_ in pairs(options) do
		  		self[k]:Hide()
		  		self[k].enabled = false
		  	end
			end)

			-- On category value changed
			CustomizationPanel.OnValueChanged = function(self)
				if self.fetching then return end
				local activeOption = CustomizationPanel.activeOption
				local category = CustomizationPanel.activeCategory
		  	if activeOption then
					for k,v in pairs(CustomizationPanel) do
						if type(v) == "table" and v.enabled and v.objectName then
							local valueFunc = v.GetChecked or v.GetValue
							if not v.objectType then v.objectType = 'actual' end

							NeatPlatesHubFunctions.SetCustomizationOption(CustomizationPanel.profile, category, activeOption, v.objectName, {type = v.objectType, value = valueFunc(v)})
						end
					end
				end

				-- Style Update
				NeatPlatesHubHelpers.CallForStyleUpdate()
			end
		end

		CustomizationPanel.Title:SetText(L["Theme Customization"])
		CustomizationPanel:Hide()	-- Needs to be before setting the new profile
		CustomizationPanel.profile = profile

		return CustomizationPanel
	end

	local function CreateQuickCustomization(objectName, parent, ...)
		local frame = CreateFrame("Button", objectName, parent, "NeatPlatesPanelButtonTemplate")
	
		frame:SetPoint(...)
		frame:SetText(L["Theme Customization"])
		frame:SetWidth(frame:GetTextWidth()+32)

		frame:SetScript("OnClick", function(self)
			local panel = CreateQuickCustomizationPanel(self, parent, objectName:gsub("CustomizationButton", ""))
			panel:Show()
		end)

		return frame, frame
	end

	local ScalePanel
	local function CreateQuickScalePanel(frame, parent, name, label, options)
		local oldValues = frame.values
		local function onChange()
			frame.values = {
				x = ScalePanel.ScaleX:GetValue(),
				y = ScalePanel.ScaleY:GetValue(),
				offset = {
					x = ScalePanel.OffsetX:GetValue(),
					y = ScalePanel.OffsetY:GetValue(),
				}
			}
			parent.Callback()
		end

		if not ScalePanel then
			-- Build the actual panel
			ScalePanel = CreateFrame("Frame", "NeatPlatesScalePanel", UIParent, "UIPanelDialogTemplate");

			--local panel = CreateFrame( "Frame", "OffsetAndScale_InterfaceOptionsPanel", UIParent);
		
			--panel.MainFrame = CreateFrame("Frame")
			--panel.MainFrame:SetWidth(412)
			--panel.MainFrame:SetHeight(2760) 		-- This can be set VERY long since we've got it in a scrollable window.

			---- Scrollable Panel Window
			--------------------------------
			--panel.ScrollFrame = CreateFrame("ScrollFrame","OffsetAndScale_Scrollframe", panel, "UIPanelScrollFrameTemplate")
			--panel.ScrollFrame:SetPoint("LEFT", 16 )
			--panel.ScrollFrame:SetPoint("TOP", panel.MainLabel, "BOTTOM", 0, -8 )
			--panel.ScrollFrame:SetPoint("BOTTOMRIGHT", -32 , 16 )
			--panel.ScrollFrame:SetScrollChild(panel.MainFrame)
			--panel.ScrollFrame:SetScript("OnMouseWheel", OnMouseWheelScrollFrame)
			
			ScalePanel:Hide()
		  ScalePanel:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 2, right = 2, top = 2, bottom = 2 },})
		  ScalePanel:SetBackdropColor(0.06, 0.06, 0.06, .7)
		  ScalePanel:SetWidth(390)
		  ScalePanel:SetHeight(180)
		  ScalePanel:SetPoint("CENTER", UIParent, "CENTER", 0, 0 )
		  ScalePanel:SetFrameStrata("DIALOG")

		  ScalePanel:SetMovable(true)
		  ScalePanel:EnableMouse(true)
		  ScalePanel:RegisterForDrag("LeftButton", "RightButton")
		  ScalePanel:SetScript("OnMouseDown", function(self,arg1)
		    self:StartMoving()
		  end)
		  ScalePanel:SetScript("OnMouseUp", function(self,arg1)
		    self:StopMovingOrSizing()
		  end)

		  -- Create SLiders
		  ScalePanel.ScaleX = PanelHelpers:CreateSliderFrame("NeatPlatesScalePanel_ScaleX", ScalePanel, L["Scale X"], 1, .1, 3, .01, nil, 160)
			ScalePanel.ScaleX:SetPoint("TOPLEFT", ScalePanel, "TOPLEFT", 20, -54)
			ScalePanel.ScaleY = PanelHelpers:CreateSliderFrame("NeatPlatesScalePanel_ScaleY", ScalePanel, L["Scale Y"], 1, .1, 3, .01, nil, 160)
			ScalePanel.ScaleY:SetPoint("TOPLEFT", ScalePanel.ScaleX, "TOPLEFT", 0, -45)
			ScalePanel.OffsetX = PanelHelpers:CreateSliderFrame("NeatPlatesScalePanel_OffsetX", ScalePanel, L["Offset X"], 0, -50, 50, 1, "ACTUAL", 160, true)
			ScalePanel.OffsetX:SetPoint("TOPRIGHT", ScalePanel, "TOPRIGHT", -20, -54)
			ScalePanel.OffsetY = PanelHelpers:CreateSliderFrame("NeatPlatesScalePanel_OffsetY", ScalePanel, L["Offset Y"], 0, -50, 50, 1, "ACTUAL", 160, true)
			ScalePanel.OffsetY:SetPoint("TOPLEFT", ScalePanel.OffsetX, "TOPLEFT", 0, -45)

			-- Create Buttons
			ScalePanel.CancelButton = CreateFrame("Button", "NeatPlatesScaleCancelButton", ScalePanel, "NeatPlatesPanelButtonTemplate")
			ScalePanel.CancelButton:SetPoint("BOTTOMRIGHT", -12, 12)
			ScalePanel.CancelButton:SetWidth(80)
			ScalePanel.CancelButton:SetText(CANCEL)

			ScalePanel.CancelButton:SetScript("OnClick", function(self) ScalePanel:Hide() end)

			ScalePanel.OkayButton = CreateFrame("Button", "NeatPlatesScaleOkayButton", ScalePanel, "NeatPlatesPanelButtonTemplate")
			ScalePanel.OkayButton:SetPoint("RIGHT", ScalePanel.CancelButton, "LEFT", -6, 0)
			ScalePanel.OkayButton:SetWidth(80)
			ScalePanel.OkayButton:SetText(OKAY)
		end

		ScalePanel.Title:SetText(label)

		-- Create/Update functions
		ScalePanel.ScaleX.Callback = onChange
		ScalePanel.ScaleY.Callback = onChange
		ScalePanel.OffsetX.Callback = onChange
		ScalePanel.OffsetY.Callback = onChange

		ScalePanel.OkayButton:SetScript("OnClick", function(self)
			ScalePanel:SetScript("OnHide", nil)
			ScalePanel:Hide()
		end)

		ScalePanel:SetScript("OnHide", function(self)
			frame.values = oldValues
			parent.Callback()
		end)

		ScalePanel:SetScript("OnShow", function(self)
			self.ScaleX:updateValues()
			self.ScaleY:updateValues()
			self.OffsetX:updateValues()
			self.OffsetY:updateValues()
		end)

		-- Restore values
		local scale = frame.values
		--table.foreach(values, print)

		ScalePanel.ScaleX:Show()
		ScalePanel.ScaleY:Show()
		ScalePanel.OffsetX:Show()
		ScalePanel.OffsetY:Show()
		ScalePanel.ScaleX:SetValue(scale.x or 1)
		ScalePanel.ScaleY:SetValue(scale.y or 1)
		ScalePanel.OffsetX:SetValue(scale.offset.x or 0)
		ScalePanel.OffsetY:SetValue(scale.offset.y or 0)

		if options and (options.noScale or options.noPos) then ScalePanel:SetWidth(200) else ScalePanel:SetWidth(390) end
		if options and options.noScale then
			ScalePanel.ScaleX:Hide()
			ScalePanel.ScaleY:Hide()
		elseif options and options.noPos then
			ScalePanel.OffsetX:Hide()
			ScalePanel.OffsetY:Hide()
		end

		return ScalePanel
	end

	local function CreateQuickScale(objectName, name, label, onOkay, options, parent, ...)
		local frame = CreateFrame("Button", objectName, parent, "NeatPlatesPanelButtonTemplate")
	
		frame:SetWidth(22)
		frame:SetHeight(22)
		frame:SetPoint(...)
		if not options or (options and not options.label) then
			frame.Texture = frame:CreateTexture(nil, "ARTWORK")
			frame.Texture:SetTexture("Interface\\Addons\\NeatPlatesHub\\shared\\Scale-Icon")
			frame.Texture:SetPoint("CENTER", frame, "CENTER")
			frame.Texture:SetWidth(14)
			frame.Texture:SetHeight(14)
			frame.Texture:SetBlendMode("ADD")
		else
			frame:SetText(options.label)
			frame:SetWidth(frame:GetTextWidth()+16)
		end
		
		if not (options and options.label) then frame.tooltipText = L["Display Scale Options"] end

		-- Create Value handlers
		frame.SetValue = function(self, values)
			frame.values = values or {} 
		end
		frame.GetValue = function() return frame.values end

		frame:SetScript("OnClick", function(self)
			local panel = CreateQuickScalePanel(self, parent, name, label, options)
			panel:Show()
		end)

		return frame, frame
	end

	local EditboxPopup
	local function CreateQuickEditboxPopup(label, onOkay, highlight)
		if not EditboxPopup then
			-- Build the actual panel
			panel = CreateFrame("Frame", "NeatPlatesEditboxPopup", UIParent, "UIPanelDialogTemplate");
			panel:Hide()
		  panel:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 2, right = 2, top = 2, bottom = 2 },})
		  panel:SetBackdropColor(0.06, 0.06, 0.06, .7)
		  panel:SetWidth(410)
		  panel:SetHeight(300)
		  panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0 )
		  panel:SetFrameStrata("DIALOG")

		  panel:SetMovable(true)
		  panel:EnableMouse(true)
		  panel:RegisterForDrag("LeftButton", "RightButton")
		  panel:SetScript("OnMouseDown", function(self,arg1)
		    self:StartMoving()
		  end)
		  panel:SetScript("OnMouseUp", function(self,arg1)
		    self:StopMovingOrSizing()
		  end)

		  panel.EditBox = PanelHelpers.CreateEditBox("NeatPlatesEditboxPopupEditbox", 340, 190, panel, "TOPLEFT", 20, -40)
		  panel.EditBox.EditBox:SetScript("OnEditFocusGained", function()
				if panel.HighlightText then
					panel.EditBox.EditBox:HighlightText()
				end
			end)
			
			-- Fix editbox not focusing as expected
			panel.EditBox.BorderFrame:SetScript("OnMouseUp", function()
				panel.EditBox.EditBox:SetFocus()
			end)

		  -- Buttons
		  panel.CancelButton = CreateFrame("Button", "NeatPlatesEditboxPopupCancelButton", panel, "NeatPlatesPanelButtonTemplate")
			panel.CancelButton:SetPoint("BOTTOMRIGHT", -12, 12)
			panel.CancelButton:SetWidth(80)
			panel.CancelButton:SetText(CANCEL)

			panel.OkayButton = CreateFrame("Button", "NeatPlatesEditboxPopupOkayButton", panel, "NeatPlatesPanelButtonTemplate")
			panel.OkayButton:SetPoint("RIGHT", panel.CancelButton, "LEFT", -6, 0)
			panel.OkayButton:SetWidth(80)
			panel.OkayButton:SetText(OKAY)

			EditboxPopup = panel
		end

		EditboxPopup.Title:SetText(label)
		EditboxPopup.HighlightText = highlight

		-- Button Scripts
		EditboxPopup.CancelButton:SetScript("OnClick", function(self) EditboxPopup.EditBox:SetValue(""); EditboxPopup:Hide() end)
		EditboxPopup.OkayButton:SetScript("OnClick", function(self) if not onOkay or onOkay(EditboxPopup) then EditboxPopup.EditBox:SetValue(""); EditboxPopup:Hide() end end)

		EditboxPopup:Show()

		return EditboxPopup
	end

OnMouseWheelScrollFrame = function (frame, value, name)
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
NeatPlatesHubRapidPanel.CreateQuickScale = CreateQuickScale
NeatPlatesHubRapidPanel.CreateQuickCustomization = CreateQuickCustomization
NeatPlatesHubRapidPanel.CreateOffsetAndScalePanel = CreateOffsetAndScalePanel
NeatPlatesHubRapidPanel.CreateQuickEditboxPopup = CreateQuickEditboxPopup
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

local GetPanelValues = NeatPlatesHubHelpers.GetPanelValues
local SetPanelValues = NeatPlatesHubHelpers.SetPanelValues
local ListToTable = NeatPlatesHubHelpers.ListToTable
--local ConvertStringToTable = NeatPlatesHubHelpers.ConvertStringToTable
--local ConvertAuraListTable = NeatPlatesHubHelpers.ConvertAuraListTable

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
	LocalVars = GetVariableSet(panel)
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
            InterfaceOptionsFrame_OpenToCategory("NeatPlates")
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
