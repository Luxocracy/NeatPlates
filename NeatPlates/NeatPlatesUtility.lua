NeatPlatesUtility = {}

-------------------------------------------------------------------------------------
--  General Helpers
-------------------------------------------------------------------------------------
local _
local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")

local copytable         -- Allows self-reference
copytable = function(original)
	local duplicate = {}
	for key, value in pairs(original) do
		if type(value) == "table" then duplicate[key] = copytable(value)
		else duplicate[key] = value end
	end
	return duplicate
end


NeatPlatesUtility.IsFriend = function(...) end
--NeatPlatesUtility.IsHealer =
--NeatPlatesUtility.IsGuildmate = function(...) end
--NeatPlatesUtility.IsPartyMember = function(...) end
NeatPlatesUtility.IsGuildmate = UnitIsInMyGuild
NeatPlatesUtility.IsPartyMember = function(unitid) if not  unitid then return false end; return UnitInParty(unitid) or UnitInRaid(unitid) end

local function RaidMemberCount()
	if UnitInRaid("player") then
		return GetNumGroupMembers()
	end
end

local function PartyMemberCount()
	if UnitInParty("player") then
		return GetNumGroupMembers()
	end
end

local function GetSpec()
	return GetActiveSpecGroup()
end

NeatPlatesUtility.GetNumRaidMembers = RaidMemberCount
NeatPlatesUtility.GetNumPartyMembers = PartyMemberCount
NeatPlatesUtility.GetSpec = GetSpec

local function GetGroupInfo()
	local groupType, groupCount

	if UnitInRaid("player") then groupType = "raid"
		groupCount = GetNumGroupMembers()
			-- Unitids for raid groups go from raid1..to..raid40.  No errors.
	elseif UnitInParty("player") then groupType = "party"
		groupCount = GetNumGroupMembers() - 1
			-- WHY?  Because the range for unitids are party1..to..party4.  GetNumGroupMembers() includes the Player, causing errors.
	else return end

	return groupType, groupCount
end

NeatPlatesUtility.GetGroupInfo = GetGroupInfo


local function mergetable(master, mate)
	local merged = {}
	local matedata
	for key, value in pairs(master) do
		if type(value) == "table" then
			matedata = mate[key]
			if type(matedata) == "table" then merged[key] = mergetable(value, matedata)
			else merged[key] = copytable(value) end
		else
			matedata = mate[key]
			if matedata == nil then merged[key] = master[key]
			else merged[key] = matedata end
		end
	end
	return merged
end

local function updatetable(original, added)
	-- Check for exist
	if not (original or added) then return original end
	if not (type(original) == 'table' and type(added) == 'table' ) then return original end
	local originalval

	for index, var in pairs(original) do
		if type(var) == "table" then original[index] = updatetable(var, added[index]) or var
		else
			--original[index] = added[index] or original[index]
			if added[index] ~= nil then
				original[index] = added[index]
			else original[index] = original[index] end

		end
	end
	return original
end

local function valueToString(value)
    if value ~= nil then
        if value >= 1000000 then return format('%.1fm', value / 1000000)
        elseif value >= 1000 then return format('%.1fk', value / 1000)
        else return value end
    end
end

-- Hex conversion functions
local function HexToRGB(hex)
    hex = hex:gsub("#","")
		
		-- Incase of shorthand hex
    if string.len(hex) == 3 then
    	str = "";
    	for i=1,3 do str = str..hex:sub(i,i)..hex:sub(i,i) end
    	hex = str
    end

    return {
    	r = tonumber("0x"..hex:sub(1,2))/255,
    	g = tonumber("0x"..hex:sub(3,4))/255,
    	b = tonumber("0x"..hex:sub(5,6))/255
    }
end

local function RGBToHex(r,g,b)
	local hexadecimal = '#'
	local rgb = {r*255,g*255,b*255}

	for key, value in pairs(rgb) do
		local hex = ''

		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex			
		end

		if(string.len(hex) == 0)then
			hex = '00'

		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	return hexadecimal
end


-- Round to x decimals
local function round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end

-- Fade frame function
local function fade(intervals, duration, delay, onUpdate, onDone, timer, stop)
	if not timer then timer = 0 end

	local interval = duration/intervals
	timer = timer+interval

	if duration > timer then
		if timer > delay then onUpdate() end
		C_Timer.After(interval, function() fade(intervals, duration, delay, onUpdate, onDone, timer) end)
	else onDone() end
end

-- Split guid
local function ParseGUID(guid)
	if guid then return strsplit("-", guid) end
	return
end


NeatPlatesUtility.abbrevNumber = valueToString
NeatPlatesUtility.copyTable = copytable
NeatPlatesUtility.mergeTable = mergetable
NeatPlatesUtility.updateTable = updatetable
NeatPlatesUtility.HexToRGB = HexToRGB
NeatPlatesUtility.RGBToHex = RGBToHex
NeatPlatesUtility.round = round
NeatPlatesUtility.fade = fade
NeatPlatesUtility.ParseGUID = ParseGUID

------------------------------------------
-- GameTooltipScanner
------------------------------------------
local ScannerName = "NeatPlatesScanningTooltip"
local TooltipScanner = CreateFrame( "GameTooltip", ScannerName , nil, "GameTooltipTemplate" ); -- Tooltip name cannot be nil
TooltipScanner:SetOwner( WorldFrame, "ANCHOR_NONE" );

------------------------------------------
-- Unit Subtitles/NPC Roles
------------------------------------------
local UnitSubtitles = {}
local function GetUnitSubtitle(unit)
	local unitid = unit.unitid
	local colorblindMode = GetCVar("colorblindMode") == "1" -- Color blind mode seems to shift this down one row.

	-- Bypass caching while in an instance
	--if inInstance or (not UnitExists(unitid)) then return end
	if ( UnitIsPlayer(unitid) or UnitPlayerControlled(unitid) or (not UnitExists(unitid))) then return end

	--local guid = UnitGUID(unitid)
	local name = unit.name
	local subTitle = UnitSubtitles[name]

	if not subTitle then
		TooltipScanner:ClearLines()
 		TooltipScanner:SetUnit(unitid)

 		local TooltipTextLeft1 = _G[ScannerName.."TextLeft1"]
 		local TooltipTextLeft2 = _G[ScannerName.."TextLeft2"]
 		local TooltipTextLeft3 = _G[ScannerName.."TextLeft3"]
 		local TooltipTextLeft4 = _G[ScannerName.."TextLeft4"]

 		name = TooltipTextLeft1:GetText()

		if name then name = gsub( gsub( (name), "|c........", "" ), "|r", "" ) else return end	-- Strip color escape sequences: "|c"
		if name ~= UnitName(unitid) then return end	-- Avoid caching information for the wrong unit


		-- Tooltip Format Priority:  Faction, Description, Level
		local toolTipText
		if colorblindMode then 
			toolTipText = TooltipTextLeft3:GetText() or "UNKNOWN"
		else
			toolTipText = TooltipTextLeft2:GetText() or "UNKNOWN"
		end

		if string.match(toolTipText, UNIT_LEVEL_TEMPLATE) then
			subTitle = ""
		else
			subTitle = toolTipText
		end

		UnitSubtitles[name] = subTitle
	end

	-- Maintaining a cache allows us to avoid the hit
	if subTitle == "" then return nil
	else return subTitle end

end

local function GetPetOwner(petName)
	TooltipScanner:ClearLines()
	TooltipScanner:SetUnit(petName)
	local ownerText = _G[ScannerName.."TextLeft2"]:GetText()
	if not ownerText then return nil, nil end
	local owner, _ = string.split("'",ownerText)
	local ownerGUID = UnitGUID(string.split("-",owner))

	return ownerGUID, owner -- This is the pet's owner
end

NeatPlatesUtility.GetUnitSubtitle = GetUnitSubtitle
NeatPlatesUtility.GetPetOwner = GetPetOwner

------------------------------------------
-- Quest Info
------------------------------------------
local function GetTooltipLineText(lineNumber)
        local tooltipLine = _G[ScannerName .. "TextLeft" .. lineNumber]
        local tooltipText = tooltipLine:GetText()
        local r, g, b = tooltipLine:GetTextColor()

        return tooltipText, r, g, b
end

local function GetUnitQuestInfo(unit)
    local unitid = unit.unitid
    local questName
    local questProgress
    local questList = {}

    if not unitid then return end

    -- Tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    TooltipScanner:ClearLines()
    TooltipScanner:SetUnit(unitid)

    for line = 3, TooltipScanner:NumLines() do
        local tooltipText, r, g, b = GetTooltipLineText( line )

        -- If the Quest Name exists, the following tooltip lines list quest progress
        if questName then
            -- Strip out the name of the player that is on the quest.
            local playerName, questNote = string.match(tooltipText, "(%g*) ?%- (.*)")

            if (playerName == "") or (playerName == UnitName("player")) then
                questProgress = questNote
                table.insert(questList, {questName, questProgress})
                --break
            end

        elseif b == 0 and r > 0.99 and g > 0.82 then
            -- Note: Quest Name Heading is colored Yellow
            questName = tooltipText
        end
    end

    return questList
end


NeatPlatesUtility.GetUnitQuestInfo = GetUnitQuestInfo

------------------------
-- Threat Function
------------------------

-- /run print(UnitThreatSituation("party1"), UnitAffectingCombat("party1"))
--local function GetThreatCondition(name)
local function GetFriendlyThreat(unitid)

	if unitid then
		local isUnitInParty = UnitPlayerOrPetInParty(unit)
		local isUnitInRaid = UnitInRaid(unit)
		local isUnitPet = (unit == "pet")

		--if isUnitInParty then
			local unitaggro = UnitThreatSituation(unitid)
			if unitaggro and unitaggro > 1 then return true end
		--end
	end
end

NeatPlatesUtility.GetFriendlyThreat = GetFriendlyThreat

------------------------
-- Threat Function
------------------------

do

	-- local function GetRelativeThreat(enemyUnitid)		-- 'enemyUnitid' is a target/enemy
	-- 	if not UnitExists(enemyUnitid) then return end

	-- 	local allyUnitid, allyThreat = nil, 0
	-- 	local playerIsTanking, playerSituation, playerThreat = UnitDetailedThreatSituation("player", enemyUnitid)
	-- 	if not playerThreat then return end

	-- 	-- Get Group Type
	-- 	local evalUnitid, evalIndex, evalThreat
	-- 	local groupType, size, startAt = nil, nil, 1
	-- 	if UnitInRaid("player") then
	-- 		groupType = "raid"
	-- 		groupSize = NeatPlatesUtility:GetNumRaidMembers()
	-- 		startAt = 2
	-- 	elseif UnitInParty("player") then
	-- 		groupType = "party"
	-- 		groupSize = NeatPlatesUtility:GetNumPartyMembers()
	-- 	else groupType = nil end

	-- 	-- Cycle through Group, picking highest threat holder
	-- 	if groupType then
	-- 		for allyIndex = startAt, groupSize do
	-- 			evalUnitid = groupType..allyIndex
	-- 			evalThreat = select(3, UnitDetailedThreatSituation(evalUnitid, enemyUnitid))
	-- 			if evalThreat and evalThreat > allyThreat then
	-- 				allyThreat = evalThreat
	-- 				allyUnitid = evalUnitid
	-- 			end
	-- 		end
	-- 	end

	-- 	-- Request Pet Threat (if possible)
	-- 	if HasPetUI() and UnitExists("pet") then
	-- 		evalThreat = select(3, UnitDetailedThreatSituation("pet", enemyUnitid)) or 0
	-- 		if evalThreat > allyThreat then
	-- 			allyThreat = evalThreat
	-- 			allyUnitid = "pet"
	-- 		end
	-- 	end

	-- 	--[[
	-- 	if playerIsTanking and allyThreat then
	-- 		return 100 - tonumber(allyThreat or 0), true
	-- 	elseif allyThreat and allyUnitid then
	-- 		return 100 - playerThreat, false
	-- 	end
	-- 	--]]
	-- 	-- [[
	-- 	-- Return the appropriate value
	-- 	if playerThreat and allyThreat and allyUnitid then
	-- 		if playerThreat >= 100 then 	-- The enemy is attacking you. You are tanking. 	Returns: 1. Your threat, plus your lead over the next highest person, 2. Your Unitid (since you're tanking)
	-- 			return tonumber(playerThreat + (100-allyThreat)), "player"
	-- 		else 	-- The enemy is not attacking you.  Returns: 1. Your scaled threat percent, 2. Who is On Top
	-- 			return tonumber(playerThreat), allyUnitid
	-- 		end
	-- 	end
	-- 	--]]
	-- end

	local function GetGroupThreatLeader(enemyUnitid)
		-- tempUnitid, tempThreat
		local friendlyUnitid, friendlyThreatval = nil, 0
		local tempUnitid, tempThreat
		local groupType, groupSize, startAt = nil, nil, 1

		-- Get Group Type
		if UnitInRaid("player") then
			groupType = "raid"
			groupSize = NeatPlatesUtility:GetNumRaidMembers()
			startAt = 2
		elseif UnitInParty("player") then
			groupType = "party"
			groupSize = NeatPlatesUtility:GetNumPartyMembers()
		else
			groupType = nil
		end

		-- Cycle through Party/Raid, picking highest threat holder
		if groupType then
			for allyIndex = startAt, groupSize do
				tempUnitid = groupType..allyIndex
				tempThreat = select(3, UnitDetailedThreatSituation(tempUnitid, enemyUnitid))
				if tempThreat and tempThreat > friendlyThreatval then
					friendlyThreatval = tempThreat
					friendlyUnitid = tempUnitid
				end
			end
		end

		-- Request Pet Threat (if possible)
		if HasPetUI() and UnitExists("pet") then
			tempThreat = select(3, UnitDetailedThreatSituation("pet", enemyUnitid)) or 0
			if tempThreat > friendlyThreatval then
				friendlyThreatval = tempThreat
				friendlyUnitid = "pet"
			end
		end

		return friendlyUnitid, friendlyThreatval

	end

	local function GetRelativeThreat(enemyUnitid)		-- 'enemyUnitid' is a target/enemy
		if not UnitExists(enemyUnitid) then return end
		
		local playerIsTanking, playerSituation, playerThreat = UnitDetailedThreatSituation("player", enemyUnitid)
		if not playerThreat then return end

		local friendlyUnitid, friendlyThreat = GetGroupThreatLeader(enemyUnitid)

		-- Return the appropriate value
		if playerThreat and friendlyThreat and friendlyUnitid then
			if playerThreat >= 100 then 	-- The enemy is attacking you. You are tanking. 	Returns: 1. Your threat, plus your lead over the next highest person, 2. Your Unitid (since you're tanking)
				return tonumber(playerThreat + (100-friendlyThreat)), "player"
			else 	-- The enemy is not attacking you.  Returns: 1. Your scaled threat percent, 2. Who is On Top
				return tonumber(playerThreat), friendlyUnitid
			end
		end

	end

	NeatPlatesUtility.GetRelativeThreat = GetRelativeThreat
end
------------------------------------------------------------------
-- Panel Helpers (Used to create interface panels)
------------------------------------------------------------------

local function CreatePanelFrame(self, reference, listname, title)
	local panelframe = CreateFrame( "Frame", reference, UIParent);
	panelframe.name = listname
	panelframe.Label = panelframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	panelframe.Label:SetPoint("TOPLEFT", panelframe, "TOPLEFT", 16, -16)
	panelframe.Label:SetHeight(15)
	panelframe.Label:SetWidth(350)
	panelframe.Label:SetJustifyH("LEFT")
	panelframe.Label:SetJustifyV("TOP")
	panelframe.Label:SetText(title or listname)
	return panelframe
end
-- [[
local function CreateDescriptionFrame(self, reference, parent, title, text)
	local descframe = CreateFrame( "Frame", reference, parent);
	descframe:SetHeight(15)
	descframe:SetWidth(200)

	descframe.Label = descframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	descframe.Label:SetAllPoints()
	descframe.Label:SetJustifyH("LEFT")
	descframe.Label:SetText(title)

	descframe.Description = descframe:CreateFontString(nil, 'ARTWORK', 'GameFontWhiteSmall')
	descframe.Description:SetPoint("TOPLEFT")
	descframe.Description:SetPoint("BOTTOMRIGHT")
	descframe.Description:SetJustifyH("LEFT")
	descframe.Description:SetJustifyV("TOP")
	descframe.Description:SetText(text)
	--
	return descframe
end
--]]
local function CreateCheckButton(self, reference, parent, label)
	local checkbutton = CreateFrame( "CheckButton", reference, parent, "NeatPlatesCheckButtonTemplate" )
	checkbutton.Label = _G[reference.."Text"]
	checkbutton.Label:SetText(label)
	checkbutton.GetValue = function() if checkbutton:GetChecked() then return true else return false end end
	checkbutton.SetValue = checkbutton.SetChecked

	return checkbutton
end

local function CreateRadioButtons(self, reference, parent, numberOfButtons, defaultButton, spacing, list, label)
	local index
	local radioButtonSet = {}

	for index = 1, numberOfButtons do
		radioButtonSet[index] = CreateFrame( "CheckButton", reference..index, parent, "UIRadioButtonTemplate" )
		radioButtonSet[index].Label = _G[reference..index.."Text"]
		radioButtonSet[index].Label:SetText(list[index] or " ")
		radioButtonSet[index].Label:SetWidth(250)
		radioButtonSet[index].Label:SetJustifyH("LEFT")

		if index > 1 then
			radioButtonSet[index]:SetPoint("TOP", radioButtonSet[index-1], "BOTTOM", 0, -(spacing or 10))
		end

		radioButtonSet[index]:SetScript("OnClick", function (self)
			local button
			for button = 1, numberOfButtons do radioButtonSet[button]:SetChecked(false) end
			self:SetChecked(true)
		end)
	end

	radioButtonSet.GetChecked = function()
		local index
		for index = 1, numberOfButtons do
			if radioButtonSet[index]:GetChecked() then return index end
		end
	end

	radioButtonSet.SetChecked = function(self, number)
		local index
		for index = 1, numberOfButtons do radioButtonSet[index]:SetChecked(false) end
		radioButtonSet[number]:SetChecked(true)
	end

	--if label then
	--	dropdown.Label = dropdown:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	--	dropdown.Label:SetPoint("TOPLEFT", 18, 18)
	--	dropdown.Label:SetText(label)
	--end

	radioButtonSet[defaultButton]:SetChecked(true)
	radioButtonSet.GetValue = radioButtonSet.GetChecked
	radioButtonSet.SetValue = radioButtonSet.SetChecked

	return radioButtonSet
end

--local function CreateSliderFrame(self, reference, parent, label, val, minval, maxval, step, mode)
--	local slider = CreateFrame("Slider", reference, parent, 'OptionsSliderTemplate')
--	slider:SetWidth(100)
--	slider:SetHeight(15)
--	--
--	slider:SetMinMaxValues(minval or 0, maxval or 1)
--	slider:SetValueStep(step or .1)
--	slider:SetValue(val or .5)
--	slider:SetOrientation("HORIZONTAL")
--	slider:Enable()
--	-- Labels
--	slider.Label = slider:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
--	slider.Label:SetPoint("TOPLEFT", -5, 18)
--	slider.Low = _G[reference.."Low"]
--	slider.High = _G[reference.."High"]
--	slider.Label:SetText(label or "")

--	-- Value
--	slider.Value = slider:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
--	slider.Value:SetPoint("BOTTOM", 0, -10)
--	slider.Value:SetWidth(50)

--	--slider.Value
--	if mode and mode == "ACTUAL" then
--		slider.Value:SetText(tostring(ceil(val)))
--		slider:SetScript("OnValueChanged", function()
--			local v = tostring(ceil(slider:GetValue()-0.5))
--			slider.Value:SetText(v)
--		end)
--		slider.Low:SetText(ceil((minval or 0)-0.5))
--		slider.High:SetText(ceil((maxval or 1)-0.5))
--		slider.isActual = true
--	else
--		slider.Value:SetText(tostring(ceil(100*(val or .5)-0.5)))
--		slider:SetScript("OnValueChanged", function()
--			slider.Value:SetText(tostring(ceil(100*slider:GetValue()-0.5)).."%")
--		end)
--		slider.Low:SetText(ceil((minval or 0)*100-0.5).."%")
--		slider.High:SetText(ceil((maxval or 1)*100-0.5).."%")
--		slider.isActual = false
--	end

--	--slider.tooltipText = "Slider"
--	return slider
--end

local function CreateSliderFrame(self, reference, parent, label, val, minval, maxval, step, mode, width, infinite)
	local value, multiplier, minimum, maximum, current
	local slider = CreateFrame("Slider", reference, parent, 'OptionsSliderTemplate')
	local EditBox = CreateFrame("EditBox", reference, slider)
	slider.isActual = (mode and mode == "ACTUAL")

	slider:SetWidth(width or 100)
	slider:SetHeight(15)
	--
	slider:SetMinMaxValues(minval or 0, maxval or 1)
	slider:SetValueStep(step or .1)
	slider:SetValue(val or .5)
	slider:SetOrientation("HORIZONTAL")
	slider:SetObeyStepOnDrag(true)
	slider:Enable()
	-- Labels
	slider.Label = slider:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	slider.Label:SetPoint("TOPLEFT", -5, 18)
	slider.Low = _G[reference.."Low"]
	slider.High = _G[reference.."High"]
	slider.Label:SetText(label or "")

	slider:SetScript("OnMouseUp", function(self)
		slider:updateValues()
		if self.Callback then self:Callback() end
	end)

	-- Value
	--slider.Value = slider:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
	--slider.Value:SetPoint("BOTTOM", 0, -10)
	--slider.Value:SetWidth(50)
	EditBox:SetPoint("BOTTOM", 0, -10)
	EditBox:SetHeight(5)
	EditBox:SetWidth(50)
	EditBox:SetFont(NeatPlatesLocalizedInputFont or "Fonts\\FRIZQT__.TTF", 11, "NONE")
	EditBox:SetAutoFocus(false)
	EditBox:SetJustifyH("CENTER")
	EditBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
	EditBox:SetScript("OnEditFocusLost", function(self) self:HighlightText(0, 0) end)

	EditBox:SetScript("OnEnterPressed", function(self, val)
		if slider.isActual then val = self:GetNumber() else val = self:GetNumber()/100 end
		slider:updateValues(val)
		slider:SetValue(val)
		self:ClearFocus()

		if parent.Callback then
			parent:Callback()
		elseif slider.Callback then
			slider:Callback()
		end
	end)

	slider.Value = EditBox

	if slider.isActual then
		local multiplier = 1
		if step < 1 and step >= 0.1 then multiplier = 10 elseif step < 0.1 then multiplier = 100 end
		slider.ceil = function(v) return ceil(v*multiplier-.5)/multiplier end
		minimum = minval or 0
		maximum = maxval or 1
		current = val or .5
	else
		slider.ceil = function(v) return ceil(v*100-.5) end
		minimum = tostring((minval or 0)*100).."%"
		maximum = tostring((maxval or 1)*100).."%"
		current = tostring(slider.ceil((val or .5))).."%"
	end

	slider.Low:SetText(minimum)
	slider.High:SetText(maximum)
	slider.Value:SetText(current)
	slider.Value:SetCursorPosition(0)
	slider:SetScript("OnValueChanged", function()
		local value = slider.ceil(slider:GetValue())
		local ext = "%"
		if slider.isActual then ext = "" end
		slider.Value:SetText(tostring(value..ext))
	end)

	slider.updateValues = function(self, val)
		local value = val or self.ceil(self:GetValue(self))
		if infinite then
			NeatPlatesHubRapidPanel.SetSliderMechanics(self, value, minimum+value, maximum+value, step)
		elseif slider.isActual then
			NeatPlatesHubRapidPanel.SetSliderMechanics(self, value, minimum, maximum, step) -- Only breaks stuff?
		end
		if parent.OnValueChanged then parent.OnValueChanged(slider) end
		if slider.OnValueChanged then slider.OnValueChanged(slider) end
	end

	--slider.tooltipText = "Slider"
	return slider
end

------------------------------------------------
-- Alternative Dropdown Menu
------------------------------------------------

local DropDownMenuFrame = CreateFrame("Frame")
local MaxDropdownItems = 25

DropDownMenuFrame:SetSize(100, 100)
DropDownMenuFrame:SetFrameStrata("TOOLTIP");
DropDownMenuFrame:Hide()

local Border = CreateFrame("Frame", nil, DropDownMenuFrame)
Border:SetBackdrop(
		{	bgFile = "Interface/DialogFrame/UI-DialogBox-Background-Dark",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
Border:SetBackdropColor(0,0,0,1);
Border:SetPoint("TOPLEFT", DropDownMenuFrame, "TOPLEFT")

-- Create the Menu Item Buttons
for i = 1, MaxDropdownItems do
	local button = CreateFrame("Button", "NeatPlatesDropdownMenuButton"..i, DropDownMenuFrame)
	DropDownMenuFrame["Button"..i] = button

	button:SetHeight(15)
	button:SetPoint("RIGHT", DropDownMenuFrame, "RIGHT")
	button:SetText("Button")

	button.buttonIndex = i

	if i > 1 then
		button:SetPoint("TOPLEFT", DropDownMenuFrame["Button"..i-1], "BOTTOMLEFT")
	else
		-- Initial Corner Point
		button:SetPoint("TOPLEFT", DropDownMenuFrame, "TOPLEFT", 10, -8)
	end

	local region = select(1, button:GetRegions())
	region:SetJustifyH("LEFT")
	region:SetPoint("LEFT", button, "LEFT")
	region:SetPoint("RIGHT", button, "RIGHT")

	--button:SetFrameStrata("DIALOG")
	button:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight")
	button:SetNormalFontObject("GameFontHighlightSmallLeft")
	button:SetHighlightFontObject("GameFontNormalSmallLeft")
	button:Show()
end

--[[
local CloseDropdownButton = CreateFrame("Button", nil, DropDownMenuFrame, "UIPanelCloseButton")
CloseDropdownButton:SetPoint("TOPLEFT", DropDownMenuFrame, "TOPRIGHT", -4, 0)
CloseDropdownButton:SetFrameStrata("TOOLTIP");
CloseDropdownButton:Raise()
CloseDropdownButton:Show()
--]]


local function HideDropdownMenu()
	DropDownMenuFrame:Hide()
end

local function ShowDropdownMenu(sourceFrame, menu, clickScript)
	if DropDownMenuFrame:IsShown() and DropDownMenuFrame.SourceFrame == sourceFrame then
		HideDropdownMenu()
		return
	end

	local currentSelection

	DropDownMenuFrame.SourceFrame = sourceFrame
	if sourceFrame.GetValue then currentSelection = sourceFrame:GetValue() end

	local numOfItems = 0
	local maxWidth = 0
	for i = 1, MaxDropdownItems do
		local item = menu[i]

		local button = DropDownMenuFrame["Button"..i]

		if item then
			local itemText = item.text
			local tooltipText = sourceFrame["tooltipText"..i]
			local region1, region2 = button:GetRegions()
			--print(region1:GetObjectType(), region2:GetObjectType() )

			button.tooltipText = tooltipText
			if currentSelection == i or itemText == currentSelection then
				region1:SetTextColor(1, .8, 0)
				region1:SetFont(1, .8, 0)
			else
				region1:SetTextColor(1, 1, 1)
			end

			button:SetText(itemText)
			button.Value = item.value

			--button:SetText
			maxWidth = max(maxWidth, button:GetTextWidth())
			numOfItems = numOfItems + 1
			button:SetScript("OnClick", clickScript)
			button:SetScript("OnEnter", function(self)
				if(self.tooltipText ~= nil) then
					GameTooltip_AddNewbieTip(self, self.tooltipText, 1.0, 1.0, 1.0, self.newbieText);
				end
			end);
			button:SetScript("OnLeave", function(self)
				if(self.tooltipText ~= nil) then
					GameTooltip:Hide();
				end
			end)

			button:Show()
		else
			button:Hide()
		end

	end

	DropDownMenuFrame:SetWidth(maxWidth + 20)
	Border:SetPoint("BOTTOMRIGHT", DropDownMenuFrame["Button"..numOfItems], "BOTTOMRIGHT", 10, -12)
	DropDownMenuFrame:SetPoint("TOPLEFT", sourceFrame, "BOTTOM")
	DropDownMenuFrame:Show()
	DropDownMenuFrame:Raise()

	-- Make sure the menu stays visible when displayed
	local LowerBound = Border:GetBottom() or 0
	if 0 > LowerBound then DropDownMenuFrame:SetPoint("TOPLEFT", sourceFrame, "BOTTOM", 0, LowerBound * -1) end
end


------------------------------------------------
-- Creates the Dropdown Drawer object
------------------------------------------------


local function CreateDropdownFrame(helpertable, reference, parent, menu, default, label, valueMethod)
	local drawer = CreateFrame("Frame", reference, parent, "NeatPlatesDropdownDrawerTemplate" )

	drawer.Text = _G[reference.."Text"]
	drawer.Button = _G[reference.."Button"]
	drawer:SetWidth(120)

	if label then
		drawer.Label = drawer:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		drawer.Label:SetPoint("TOPLEFT", 18, 18)
		drawer.Label:SetText(label)
	end

	drawer.valueMethod = valueMethod


	drawer.Text:SetWidth(100)
	drawer.Value = default

	-- SetValue is used in the Hub and Panel functions; Very important
	------------------------------------
	drawer.SetValue = function (self, value)
		--if not value then return end

		local itemText

		-- Search for Numerical Index
		if menu[value] then
			itemText = menu[value].text
		else
			-- Search for Token
			for i,v in pairs(menu) do
				if v.value == value then
					itemText = v.text
					break
				end
			end
		end

		if value then
			drawer.Text:SetText(itemText)
			drawer.Value = value
		end
	end

	-- GetValue is used in the Hub and Panel functions; Very important
	------------------------------------
	drawer.GetValue = function (self)
		return self.Value
	end

	-- New Dropdown Method
	------------------------------------------------

	local function OnClickItem(self)
		drawer:SetValue(menu[self.buttonIndex].value or self.buttonIndex)
		--print(self.Value, menu[self.buttonIndex].value, drawer:GetValue())

		if parent.OnValueChanged then parent.OnValueChanged(drawer) end
		if drawer.OnValueChanged then drawer.OnValueChanged(drawer) end
		PlaySound(856);
		HideDropdownMenu()
	end

	local function OnClickDropdown()
		PlaySound(856);
		ShowDropdownMenu(drawer, menu, OnClickItem)
	end

	local function OnHideDropdown()
		HideDropdownMenu()
	end

	-- Override the default menu display scripts...
	local button = _G[reference.."Button"]
	button:SetScript("OnClick", OnClickDropdown)
	button:SetScript("OnHide", OnHideDropdown)

	-- Set the default value on itself
	drawer:SetValue(default)

	return drawer
end

-- [[ COLOR
local CreateColorBox
do

	local workingFrame
	local function ChangeColor(cancel)
		local a, r, g, b
		if cancel then
			--r,g,b,a = unpack(ColorPickerFrame.startingval )
			workingFrame:SetBackdropColor(unpack(ColorPickerFrame.startingval ))
		else
			a, r, g, b = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
			workingFrame:SetBackdropColor(r,g,b,1-a)
			if workingFrame.OnValueChanged then workingFrame:OnValueChanged() end
		end
	end

	local function ShowColorPicker(frame, onOkay)
		local r,g,b,a = frame:GetBackdropColor()
		workingFrame = frame
		ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = 	ChangeColor, function() if onOkay and not ColorPickerFrame:IsShown() then onOkay(RGBToHex(ColorPickerFrame:GetColorRGB())) end; ChangeColor() end, ChangeColor;
		ColorPickerFrame.startingval  = {r,g,b,a}
		ColorPickerFrame:SetColorRGB(r,g,b);
		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.opacity = 1 - a
		ColorPickerFrame:SetFrameStrata(frame:GetFrameStrata())
		ColorPickerFrame:SetFrameLevel(frame:GetFrameLevel()+1)
		ColorPickerFrame:Hide(); ColorPickerFrame:Show(); -- Need to activate the OnShow handler.
	end

	function CreateColorBox(self, reference, parent, label, onOkay, r, g, b, a)
		local colorbox = CreateFrame("Button", reference, parent)
		colorbox:SetWidth(24)
		colorbox:SetHeight(24)
		colorbox:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameColorSwatch",
												edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
												tile = false, tileSize = 16, edgeSize = 8,
												insets = { left = 1, right = 1, top = 1, bottom = 1 }});
		colorbox:SetBackdropColor(r, g, b, a);
		colorbox:SetScript("OnClick",function() ShowColorPicker(colorbox, onOkay) end)
		--
		colorbox.Label = colorbox:CreateFontString(nil, 'ARTWORK', 'GameFontWhiteSmall')
		colorbox.Label:SetPoint("TOPLEFT", colorbox, "TOPRIGHT", 4, -7)
		colorbox.Label:SetText(label)

		colorbox.GetValue = function() local color = {}; color.r, color.g, color.b, color.a = colorbox:GetBackdropColor(); return color end
		colorbox.SetValue = function(self, color) colorbox:SetBackdropColor(color.r, color.g, color.b, color.a); end
		--colorbox.tooltipText = "Colorbox"
		return colorbox
	end
end

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


local function CreateEditBox(name, width, height, parent, anchorFrame, ...)
	local frame = CreateFrame("ScrollFrame", name, parent, "UIPanelScrollFrameTemplate")
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
	frame.BorderFrame:SetFrameLevel(frame:GetFrameLevel())
	-- Text

	EditBox:SetPoint("TOPLEFT")
	EditBox:SetPoint("BOTTOMLEFT")
	EditBox:SetHeight(height)
	EditBox:SetWidth(width)
	EditBox:SetMultiLine(true)

	EditBox:SetFrameLevel(frame:GetFrameLevel()+1)
	EditBox:SetFont(NeatPlatesLocalizedInputFont or "Fonts\\FRIZQT__.TTF", 11, "NONE")

	EditBox:SetText("")
	EditBox:SetAutoFocus(false)
	EditBox:SetTextInsets(9, 6, 2, 2)

	frame:SetScrollChild(EditBox)
	frame.EditBox = EditBox

	-- Fix editbox not focusing as expected
	frame.BorderFrame:SetScript("OnMouseDown", function()
		if not frame.EditBox:HasFocus() then frame.EditBox:SetFocus() end
	end)

	function frame:GetValue() return EditBox:GetText() end
	function frame:SetValue(value) EditBox:SetText(value) end
	frame._SetWidth = frame.SetWidth
	function frame:SetWidth(value) frame:_SetWidth(value); EditBox:SetWidth(value) end
	-- Set Positions
	if type(anchorFrame) == "table" then
		QuickSetPoints(frame, parent, anchorFrame, ...)
	else
		frame:SetPoint(anchorFrame, ...)
	end

	return frame, frame
end

local function CreateEditBoxButton(frame, onOkay)
	frame.okayButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.okayButton:SetWidth(40)
	frame.okayButton:SetHeight(20)
	frame.okayButton:SetPoint("BOTTOMRIGHT", -2, 2)
	frame.okayButton:SetText(OKAY)
	frame.okayButton:Hide()

	frame.okayButton:SetFrameLevel(frame.EditBox:GetFrameLevel()+1)

	frame.okayButton:SetScript("OnClick", function()
		onOkay()
		frame.okayButton:Hide()
	end)
	frame.EditBox:SetScript("OnEditFocusLost", function()
		frame.EditBox:HighlightText(0,0)
		if frame.EditBox.oldValue == frame:GetValue() then 
			frame.okayButton:Hide()
		end
	end)
	frame.EditBox:SetScript("OnEditFocusGained", function()
		frame.EditBox.oldValue = frame:GetValue()
		frame.okayButton:Show()
	end)
end

local function CreateTipBox(self, name, text, parent, ...)
	local frame = CreateFrame("Frame", name, parent, "NeatPlatesPanelTipTemplate")
	
	frame.Text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	frame.Text:SetTextColor(255/255, 105/255, 6/255)
	frame.Text:SetAllPoints()
	frame.Text:SetFont(NeatPlatesLocalizedFont, 12)
	frame.Text:SetText(L["Tip"])

	frame.tooltipText = text

	frame:SetPoint(...)

	return frame, frame
end

local function CreateMultiStateOptions(self, name, labelArray, stateArray, width, parent, ...)
	local frame = CreateFrame("Frame", "NeatPlatesPanelMultiState"..name, parent)


	frame.states = stateArray;
	--local labelArray = {"Combat", "Dungeon", "Raid", "Battleground", "World"}
	local lastItem
	for i,label in pairs(labelArray) do
		local button = CreateFrame("Button", "Button_"..label, frame, "NeatPlatesTriStateButtonTemplate")
		button.tooltipText = tooltip
		button.Label = L[label]
		button:SetText(L[label])
		button:SetWidth(width)

		-- attach below previous item
		if lastItem then
			button:SetPoint("TOPLEFT", lastItem, "BOTTOMLEFT", 0, 0)
		else
			button:SetPoint("TOPLEFT", 0, 0)
		end
		lastItem = button

		frame["Button_"..label] = button
	end

	-- Border
	frame.BorderFrame = CreateFrame("Frame", nil, frame )
	frame.BorderFrame:SetPoint("TOPLEFT", 0, 5)
	frame.BorderFrame:SetPoint("BOTTOMRIGHT", 3, -5)
	frame.BorderFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
										edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
										tile = true, tileSize = 16, edgeSize = 16,
										insets = { left = 4, right = 4, top = 4, bottom = 4 }
										});
	frame.BorderFrame:SetBackdropColor(0.05, 0.05, 0.05, 0)
	frame.BorderFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

	frame:SetWidth(width)
	frame:SetHeight(18*#labelArray+3)

	-- Set & Get Values
	frame.GetValue = function(self)
		local values = {}
		for i,label in pairs(labelArray) do
			values[label] = self["Button_"..label].state
		end

		return values
	end

	frame.SetValue = function(self, values)
		for label,value in pairs(values) do
			self["Button_"..label]:UpdateState(value)
		end
	end

	return frame, frame
end

PanelHelpers = {}

PanelHelpers.CreatePanelFrame = CreatePanelFrame
PanelHelpers.CreateDescriptionFrame = CreateDescriptionFrame
PanelHelpers.CreateCheckButton = CreateCheckButton
PanelHelpers.CreateRadioButtons = CreateRadioButtons
PanelHelpers.CreateSliderFrame = CreateSliderFrame
PanelHelpers.CreateDropdownFrame = CreateDropdownFrame
PanelHelpers.CreateColorBox = CreateColorBox
PanelHelpers.CreateEditBox = CreateEditBox
PanelHelpers.CreateEditBoxButton = CreateEditBoxButton
PanelHelpers.CreateTipBox = CreateTipBox
PanelHelpers.ShowDropdownMenu = ShowDropdownMenu
PanelHelpers.HideDropdownMenu = HideDropdownMenu
PanelHelpers.CreateMultiStateOptions = CreateMultiStateOptions

NeatPlatesUtility.PanelHelpers = PanelHelpers



local function StartMovement(frame)
	-- Store Original Point to frame.OriginalAnchor
	frame:StartMoving()
	local OriginalAnchor = frame.OriginalAnchor

	if not OriginalAnchor.point then
		OriginalAnchor.point, OriginalAnchor.relativeTo, OriginalAnchor.relativePoint,
			OriginalAnchor.xOfs, OriginalAnchor.yOfs = frame:GetPoint(1)
		print("Starting Movement from, ", OriginalAnchor.xOfs,  OriginalAnchor.yOfs)
	end


	-- Store Current Screen-RelativePosition to frame.NewAnchor
end

local function FinishMovement(frame)
	-- Store New Screen-RelativePosition to frame.NewAnchor
	local NewAnchor = frame.NewAnchor
	local OriginalAnchor = frame.OriginalAnchor
	NewAnchor.point, NewAnchor.relativeTo, NewAnchor.relativePoint,
		NewAnchor.xOfs, NewAnchor.yOfs = frame:GetPoint(1)
	print(frame:GetName(), " has been moved, " , NewAnchor.xOfs - OriginalAnchor.xOfs, " , ", NewAnchor.yOfs - OriginalAnchor.yOfs)
	frame:StopMovingOrSizing()
	-- Process the
end

local function EnableFreePositioning(frame)
	-- http://www.wowwiki.com/API_Frame_StartMoving
	-- point, relativeTo, relativePoint, xOfs, yOfs = MyRegion:GetPoint(n)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", StartMovement)
	frame:SetScript("OnMouseUp", FinishMovement)
	frame.OriginalAnchor = {}
	frame.NewAnchor = {}
end

PanelHelpers.EnableFreePositioning = EnableFreePositioning



-- Custom target frame
local function CreateTargetFrame()
	local frame = CreateFrame("Frame", "NeatPlatesTarget", WorldFrame)
	NeatPlatesTarget:Show()
	NeatPlatesTarget:SetPoint("CENTER", UIParent, "CENTER", 0, 300)
	NeatPlatesTarget:SetWidth(200)
	NeatPlatesTarget:SetHeight(200)
	NeatPlatesTarget:SetClampedToScreen(true)
	return frame
end

NeatPlatesUtility.CreateTargetFrame = CreateTargetFrame

----------------------
-- Call In() - Registers a callback, which hides the specified frame in X seconds
----------------------
do
	local CallList = {}			-- Key = Frame, Value = Expiration Time
	local Watcherframe = CreateFrame("Frame")
	local WatcherframeActive = false
	local select = select
	local timeToUpdate = 0

	local function CheckWatchList(self)
		local curTime = GetTime()
		if curTime < timeToUpdate then return end
		local count = 0
		timeToUpdate = curTime + 1
		-- Cycle through the watchlist
		for func, expiration in pairs(CallList) do
			if expiration < curTime then
				CallList[func] = nil
				func()
			else count = count + 1 end
		end
		-- If no more frames to watch, unregister the OnUpdate script
		if count == 0 then Watcherframe:SetScript("OnUpdate", nil) end
	end

	local function CallIn(func, expiration)
		-- Register Frame
		CallList[ func] = expiration + GetTime()
		-- Init Watchframe
		if not WatcherframeActive then
			Watcherframe:SetScript("OnUpdate", CheckWatchList)
			WatcherframeActive = true
		end
	end

	NeatPlatesUtility.CallIn = CallIn

end



--------------------------------------------------------------------------------------------------
-- InterfaceOptionsFrame_OpenToCategory
-- Quick and dirty fix
--------------------------------------------------------------------------------------------------

do
	local fixed = false

	local function OpenInterfacePanel(panel)
		if not fixed then

			local panelName = panel.name
			if not panelName then return end

			local t = {}

			for i, p in pairs(INTERFACEOPTIONS_ADDONCATEGORIES) do
				if p.name == panelName then
					t.element = p
					InterfaceOptionsListButton_ToggleSubCategories(t)
				end
			end
			fixed = true
		end

		InterfaceOptionsFrame_OpenToCategory(panel)
	end

	NeatPlatesUtility.OpenInterfacePanel = OpenInterfacePanel
end

-- /run for i,v in pairs(INTERFACEOPTIONS_ADDONCATEGORIES) do print(i, v, v.name) end







