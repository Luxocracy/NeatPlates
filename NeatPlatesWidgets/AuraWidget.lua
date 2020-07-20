
	--Spinning Cooldown Frame
	--[[
	frame.Cooldown = CreateFrame("Cooldown", nil, frame, "NeatPlatesAuraWidgetCooldown")
	frame.Cooldown:SetAllPoints(frame)
	frame.Cooldown:SetReverse(true)
	frame.Cooldown:SetHideCountdownNumbers(true)
	--]]

local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")
local LibClassicDurations = LibStub("LibClassicDurations", true)
local LCDUnitAura = function() end
if LibClassicDurations then
    LibClassicDurations:Register("NeatPlates")
    LCDUnitAura = LibClassicDurations.UnitAuraWithBuffs
end


NeatPlatesWidgets.DebuffWidgetBuild = 2

local PlayerGUID = UnitGUID("player")
local PlayerClass = select(2, UnitClass("player"))
local PolledHideIn = NeatPlatesWidgets.PolledHideIn
local FilterFunction = function() return 1 end
local AuraMonitor = CreateFrame("Frame")
local WatcherIsEnabled = false
local WidgetList, WidgetGUID = {}, {}

local UpdateWidget

local TargetOfGroupMembers = {}
local DebuffColumns = 3
local DebuffLimit = 6
local AuraLimit = 9
local inArena = false
local useWideIcons = true
local SpacerSlots = 0 -- math.min(15, DebuffColumns-1)

local PandemicEnabled = false
local PandemicColor = {}

local EmphasizedUnique = false
local MaxEmphasizedAuras = 1
local AuraWidth = 16.5
local AuraScale = 1
local AuraAlignment = "BOTTOMLEFT"
local ScaleOptions = {x = 1, y = 1, offset = {x = 0, y = 0}}
local PreciseAuraThreshold = 0

local function DummyFunction() end

local function DefaultPreFilterFunction() return true end
local function DefaultFilterFunction(aura, unit) if aura and aura.duration and (aura.duration < 30) then return true end end

local AuraFilterFunction = DefaultFilterFunction
local EmphasizedAuraFilterFunction = function() end
local AuraSortFunction = function() end
local AuraHookFunction
local AuraCache = {}
local AuraBaseDuration = {}
local AuraExpiration = {}

local AURA_TARGET_HOSTILE = 1
local AURA_TARGET_FRIENDLY = 2

local AURA_TYPE_BUFF = 1
local AURA_TYPE_DEBUFF = 6

local ComboPoints = 0

local ButtonGlow = LibStub("LibButtonGlow-1.0")
local ButtonGlowEnabled = {
		["Pandemic"] = false,
		["Magic"] = false,
		[""] = false, -- Enrage
	}

local HideCooldownSpiral = false
local HideAuraDuration = false
local HideAuraStacks = false

-- Get a clean version of the function...  Avoid OmniCC interference
local CooldownNative = CreateFrame("Cooldown", nil, WorldFrame)
local SetCooldown = CooldownNative.SetCooldown

local _

local AuraType_Index = {
	["Buff"] = 1,
	["Curse"] = 2,
	["Disease"] = 3,
	["Magic"] = 4,
	["Poison"] = 5,
	["Debuff"] = 6,
}

local function SetFilter(func)
	if func and type(func) == "function" then
		FilterFunction = func
	end
end

local function GetAuraWidgetByGUID(guid)
	if guid then return WidgetGUID[guid] end
end

local function IsAuraShown(widget, aura)
		if widget and widget:IsShown() then
			return true
		end
	return false
end


-----------------------------------------------------
-- Default Filter
-----------------------------------------------------
local function DefaultFilterFunction(debuff)
	if (debuff.duration < 600) then
		return true
	end
end


-----------------------------------------------------
-- General Events
-----------------------------------------------------


local function EventUnitAura(unitid)
	local frame

	if unitid then frame = WidgetList[unitid] end

	if frame then UpdateWidget(frame) end

end

-- Clear the AuraCache for the unitid
local function ClearAuraCache(unitid)
	if unitid then AuraCache[unitid] = nil end
end

---- Combat logging for aura applications in Classic
--local function EventCombatLog(...)
--	local _,event,_,sourceGUID,sourceName,sourceFlags,_,destGUID,destName,_,_,spellID,spellName = CombatLogGetCurrentEventInfo()
--	local points = 0

--	-- Tracking Aura Durations
--	if event == "SPELL_CAST_SUCCESS" then ComboPoints = GetComboPoints("player", "target") end

--	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
--		--if ComboPoints > GetComboPoints("player", "target") then points = ComboPoints end
--		spellID = select(7, GetSpellInfo(spellName))
--		--local desc = GetSpellDescription(spellID)
--		local duration, expiration

--		-- Lib workaround until NPC abilities get properly implemented
--		local spell = LibClassicDurations.spells[spellID]
--		if not spell then
--			spell = LibClassicDurations.npc_spells[spellID]
--			if spell then spell = {duration = spell} end
--		end
--		if spell then
--			duration = spell.duration
--		end

--		if duration and type(duration) ~= "function" and duration > 0 then
--			expiration = GetTime()+duration

--			AuraExpiration[destGUID] = AuraExpiration[destGUID] or {}
--			AuraExpiration[destGUID][sourceGUID] = AuraExpiration[destGUID][sourceGUID] or {}
--			AuraExpiration[destGUID][sourceGUID][spellID] = {expiration = expiration, duration = duration}
--		end
		
--	end
--end

-----------------------------------------------------
-- Function Reference Lists
-----------------------------------------------------

local AuraEvents = {
	--["UNIT_TARGET"] = EventUnitTarget,
	["UNIT_AURA"] = EventUnitAura,
	["NAME_PLATE_UNIT_REMOVED"] = ClearAuraCache, 
	--["COMBAT_LOG_EVENT_UNFILTERED"]  = EventCombatLog,
}

local function AuraEventHandler(frame, event, ...)
	local unitid = ...

	if event then
		local eventFunction = AuraEvents[event]
		eventFunction(...)
	end

end



-------------------------------------------------------------
-- Widget Object Functions
-------------------------------------------------------------

local function UpdateWidgetTime(frame, expiration)
	if expiration <= 0 or HideAuraDuration then
		frame.TimeLeft:SetText("")
	else
		local timeleft = expiration-GetTime()
		if timeleft > 60 then
			frame.TimeLeft:SetText(floor(timeleft/60).."m")
		else
			if timeleft < PreciseAuraThreshold then
				frame.TimeLeft:SetText((("%%.%df"):format(1)):format(timeleft))
			else
				frame.TimeLeft:SetText(floor(timeleft))
			end
			--frame.TimeLeft:SetText(floor(timeleft*10)/10)
		end
	end
end

local function UpdateAuraHighlighting(frame, aura)
		local r, g, b, a = aura.r, aura.g, aura.b, aura.a
		if r then
			frame.BorderHighlight:SetVertexColor(r, g or 1, b or 1, a or 1)
			frame.BorderHighlight:Show()
			frame.Border:Hide()
		else frame.BorderHighlight:Hide(); frame.Border:Show() end
end

local function UpdateIcon(frame, aura)
	if frame and aura and aura.texture and aura.expiration then
		-- Icon
		frame.Icon:SetTexture(aura.texture)

		-- Stacks
		if not HideAuraStacks and aura.stacks and aura.stacks > 1 then frame.Stacks:SetText(aura.stacks)
		else frame.Stacks:SetText("") end

		-- Hightlighting
		UpdateAuraHighlighting(frame, aura)

		-- [[ Cooldown
		frame.Cooldown.noCooldownCount = not HideAuraDuration -- Disable OmniCC interaction
		if aura.duration and aura.duration > 0 and aura.expiration and aura.expiration > 0 then
			--SetCooldown(frame.Cooldown, aura.expiration-aura.duration, aura.duration+.25)	-- (Clean Version)
			frame.Cooldown:SetCooldown(aura.expiration-aura.duration, aura.duration+.25)

			frame.Cooldown:SetDrawSwipe(not HideCooldownSpiral)
			frame.Cooldown:SetDrawEdge(not HideCooldownSpiral)
			
		else
			--SetCooldown(frame.Cooldown, 0, 0)	-- Clear Cooldown (Clean Version)
			frame.Cooldown:SetCooldown(0, 0)
		end
		--]]

		-- Expiration
		UpdateWidgetTime(frame, aura.expiration)
		frame:Show()
		--if aura.expiration ~= 0 then PolledHideIn(frame, aura.expiration) end
		PolledHideIn(frame, aura.expiration, "UpdateIcon")
	elseif frame then
		PolledHideIn(frame, 0)
	end
end


--local function AuraSortFunction(a,b)
--	return a.priority < b.priority
--end


local function UpdateIconGrid(frame, unitid)
		if not unitid then return end
		local unitGUID = UnitGUID(unitid)

		local unitReaction
		if UnitIsFriend("player", unitid) then unitReaction = AURA_TARGET_FRIENDLY
		else unitReaction = AURA_TARGET_HOSTILE end

		local AuraIconFrames = frame.AuraIconFrames
		local storedAuras = {}
		local storedAuraCount = 0
		local emphasizedAuras = {}

		-- Cache displayable auras
		------------------------------------------------------------------------------------------------------
		-- This block will go through the auras on the unit and make a list of those that should
		-- be displayed, listed by priority.
		local auraIndex = 0
		local moreAuras = true

		local searchedDebuffs, searchedBuffs = false, false
		local auraFilter = "HARMFUL"

		AuraCache[unitid] = {} -- Clear cache for unit

		repeat

			auraIndex = auraIndex + 1

			local aura = {}

			do
				local name, icon, stacks, auraType, duration, expiration, caster, canStealOrPurge, nameplateShowPersonal, spellid = LCDUnitAura(unitid, auraIndex, auraFilter)		-- UnitaAura
				local casterGUID

				aura.name = name
				aura.texture = icon
				aura.stacks = stacks
				aura.type = auraType
				aura.effect = auraFilter
				aura.reaction = unitReaction
				aura.caster = caster
				aura.spellid = spellid
				aura.unit = unitid 		-- unitid of the plate
				aura.expiration = expiration
				aura.duration = duration

				--if aura.duration == 0 and aura.expiration == 0 then
				--	if caster then casterGUID = UnitGUID(caster) end
				--	if AuraExpiration[unitGUID] and AuraExpiration[unitGUID][casterGUID] and AuraExpiration[unitGUID][casterGUID][spellid] then
				--		aura.duration = AuraExpiration[unitGUID][casterGUID][spellid].duration
				--		aura.expiration = AuraExpiration[unitGUID][casterGUID][spellid].expiration
				--	end
				--end

				-- Pandemic Base duration
				if spellid and caster == "player" then
					if not AuraBaseDuration[spellid] or AuraBaseDuration[spellid] > duration then
						AuraBaseDuration[spellid] = duration
					end
				end
				aura.baseduration = AuraBaseDuration[spellid] or duration
			end

			-- Gnaw , false, icon, 0 stacks, nil type, duration 1, expiration 8850.436, caster pet, false, false, 91800

			-- Auras are evaluated by an external function
			-- Pre-filtering before the icon grid is populated
			if aura.name then
				local show, priority, r, g, b, a = AuraFilterFunction(aura)
				local emphasized, ePriority = EmphasizedAuraFilterFunction(aura)
				--print(aura.name, show, priority)
				--show = true
				AuraCache[unitid][aura.name], AuraCache[unitid][tostring(aura.spellid)] = true, true -- Used by Custom Color Conditions
				-- Store Order/Priority
				if show then
					aura.priority = priority or 10
					aura.r, aura.g, aura.b, aura.a = r, g, b, a

					storedAuraCount = storedAuraCount + 1
					storedAuras[storedAuraCount] = aura
				end
				-- Add to Emphasized list
				if emphasized then
					aura.priority = ePriority or 10
					--emphasizedAuras[aura.name], emphasizedAuras[tostring(aura.spellid)] = aura, aura
					emphasizedAuras[#emphasizedAuras+1] = aura
				end
			else
				if auraFilter == "HARMFUL" then
					searchedDebuffs = true
					auraFilter = "HELPFUL"
					auraIndex = 0
				else
					searchedBuffs = true
				end
			end

		until (searchedDebuffs and searchedBuffs)

		NeatPlatesWidgets.AuraCache = AuraCache

		--[[ Debug, add custom Buff
		while storedAuraCount < AuraLimit do
			storedAuraCount = storedAuraCount+1
			storedAuras[storedAuraCount] = {
				["type"] = "Magic",
				["effect"] = "HELPFUL",
				["duration"] = 12,
				["stacks"] = 0,
				["reaction"] = 1,
				["name"] = "Debug",
				["expiration"] = 0,
				["priority"] = 20,
				["spellid"] = 234153,
				["texture"] = 136069,
				["r"] = 0.2,
				["g"] = 0,
				["b"] = 1,
			}
		end
		--]]
		

		-- Display Auras
		------------------------------------------------------------------------------------------------------
		local DebuffSlotCount = 0
		local BuffSlotCount = 0
		local AuraSlots = {}
		local BuffAuras = {}
		local DebuffAuras = {}
		local DebuffCount = 0
		local DisplayedRows = 0
		local EmphasizedAura
		local EmphasizedAuraCount = 0

		EmphasizedAura, EmphasizedAuraCount = frame.emphasized:SetAura(emphasizedAuras)	-- Display Emphasized Aura, returns displayed aura

		if not (HideInHeadlineMode and frame.style == "NameOnly") and (storedAuraCount > 0 or next(EmphasizedAura))  then frame:Show() end -- Show the parent frame
		if storedAuraCount > 0 then
			sort(storedAuras, AuraSortFunction)

			for index = 1, storedAuraCount do
				if (DebuffSlotCount+BuffSlotCount) > AuraLimit then break end
				local aura = storedAuras[index]

				if aura.spellid and aura.expiration and not(EmphasizedUnique and EmphasizedAura[tostring(aura.spellid)]) then
					-- Sort buffs and debuffs
					if aura.effect == "HELPFUL" then 
						table.insert(BuffAuras, aura)
						BuffSlotCount = BuffSlotCount + 1
					elseif DebuffSlotCount < DebuffLimit then
						table.insert(DebuffAuras, aura)
						DebuffSlotCount = DebuffSlotCount + 1
					end

					frame.currentAuraCount = index
				end
			end

			-- Loop through debuffs and call function to display them
			for k, aura in ipairs(DebuffAuras) do
				UpdateIcon(AuraIconFrames[k], aura)
				AuraSlots[k] = true
			end

			-- Calculate Buff Offset
			local rowOffset
			DisplayedRows = (math.floor((DebuffSlotCount + BuffSlotCount - 1)/DebuffColumns) + math.min(DebuffSlotCount, 1))
			
			 --print(DebuffColumns * DisplayedRows - (DebuffSlotCount + BuffSlotCount))
			if DebuffColumns * DisplayedRows - (DebuffSlotCount + BuffSlotCount) >= SpacerSlots then
				rowOffset = math.max(DebuffColumns * DisplayedRows, DebuffColumns) -- Same Row with space between
			elseif BuffSlotCount > 0 then
				rowOffset = DebuffColumns * (DisplayedRows + 1)	-- Seperate Row
				DisplayedRows = DisplayedRows+1
			end

			-- Loop through buffs and call function to display them
			for k, aura in ipairs(BuffAuras) do
				local index = rowOffset+1-k
				-- Make sure we aren't overwriting any debuffs and that we're not trying to apply buffs to slots that don't exist
				if index > DebuffCount and index > 0 then
						UpdateIcon(AuraIconFrames[index], aura)
						AuraSlots[index] = true
				end
			end

		end

		-- Clear Extra Slots
		for AuraSlotEmpty = 1, AuraLimit do
			if AuraSlots[AuraSlotEmpty] ~= true then UpdateIcon(AuraIconFrames[AuraSlotEmpty]) end
		end

		if AuraAlignment == "BOTTOM" then
			local offsetX = -(AuraWidth+5)*(math.min(storedAuraCount, DebuffColumns)-1)/2
			AuraIconFrames[1]:SetPoint(AuraAlignment, offsetX, 0)
		end

		DisplayedRows = math.max(0, DisplayedRows)
		EmphasizedAuraCount = math.max(1, EmphasizedAuraCount) -- Make sure we aren't setting 0 as this can detach the frame...

		-- Set Height/Width of Aura Frames
		frame:SetHeight(DisplayedRows*16 + (DisplayedRows-1)*8) -- Set Height of the parent for easier alignment of the Emphasized aura.
		frame.emphasized:SetWidth(EmphasizedAuraCount * AuraWidth)
end

function UpdateWidget(frame)
		local unitid = frame.unitid
		if(HideInHeadlineMode and frame.style == "NameOnly") then
			frame:Hide()
		else
			frame:Show()
		end
		UpdateIconGrid(frame, unitid)
end

-- Context Update (mouseover, target change)
local function UpdateWidgetContext(frame, unit)
	local unitid = unit.unitid
	frame.unitid = unitid
	frame.style = unit.style

	WidgetList[unitid] = frame

	UpdateWidget(frame)
end

local function ClearWidgetContext(frame)
	for unitid, widget in pairs(WidgetList) do
		if frame == widget then WidgetList[unitid] = nil end
	end
end

local function ExpireFunction(icon)
	UpdateWidget(icon.Parent)
end

-------------------------------------------------------------
-- Widget Frames
-------------------------------------------------------------
local WideArt = "Interface\\Addons\\NeatPlatesWidgets\\Aura\\AuraFrameWide"
local SquareArt = "Interface\\Addons\\NeatPlatesWidgets\\Aura\\AuraFrameSquare"
local WideHighlightArt = "Interface\\Addons\\NeatPlatesWidgets\\Aura\\AuraFrameHighlightWide"
local SquareHighlightArt = "Interface\\Addons\\NeatPlatesWidgets\\Aura\\AuraFrameHighlightSquare"
local AuraFont = "FONTS\\ARIALN.TTF"

local function Enable()
	AuraMonitor:SetScript("OnEvent", AuraEventHandler)

	for event in pairs(AuraEvents) do AuraMonitor:RegisterEvent(event) end

	--NeatPlatesUtility:EnableGroupWatcher()
	WatcherIsEnabled = true

end

local function Disable()
	AuraMonitor:SetScript("OnEvent", nil)
	AuraMonitor:UnregisterAllEvents()
	WatcherIsEnabled = false

	for unitid, widget in pairs(WidgetList) do
		if frame == widget then WidgetList[unitid] = nil end
	end

end


local function TransformWideAura(frame)
	frame.Parent:SetWidth(DebuffColumns*(26 + 5)*AuraScale)

	frame:SetWidth(26.5)
	frame:SetHeight(14.5)
	-- Icon
	frame.Icon:SetAllPoints(frame)
	frame.Icon:SetTexCoord(.07, 1-.07, .23, 1-.23)  -- obj:SetTexCoord(left,right,top,bottom)
	-- Border
	frame.Border:SetWidth(32); frame.Border:SetHeight(32)
	frame.Border:SetPoint("CENTER", 1, -2)
	frame.Border:SetTexture(WideArt)
	-- Highlight
	frame.BorderHighlight:SetAllPoints(frame.Border)
	frame.BorderHighlight:SetTexture(WideHighlightArt)
	--  Time Text
	frame.TimeLeft:SetFont(AuraFont ,9, "OUTLINE")
	frame.TimeLeft:SetShadowOffset(1, -1)
	frame.TimeLeft:SetShadowColor(0,0,0,1)
	frame.TimeLeft:SetPoint("RIGHT", 0, 8)
	frame.TimeLeft:SetWidth(26)
	frame.TimeLeft:SetHeight(16)
	frame.TimeLeft:SetJustifyH("RIGHT")
	--  Stacks
	frame.Stacks:SetFont(AuraFont,10, "OUTLINE")
	frame.Stacks:SetShadowOffset(1, -1)
	frame.Stacks:SetShadowColor(0,0,0,1)
	frame.Stacks:SetPoint("RIGHT", 0, -6)
	frame.Stacks:SetWidth(26)
	frame.Stacks:SetHeight(16)
	frame.Stacks:SetJustifyH("RIGHT")

	AuraWidth = frame:GetWidth()
end

local function TransformSquareAura(frame)
	frame.Parent:SetWidth(DebuffColumns*(16 + 5))

	frame:SetWidth(16.5)
	frame:SetHeight(14.5)
	-- Icon
	frame.Icon:SetAllPoints(frame)
	frame.Icon:SetTexCoord(.10, 1-.07, .12, 1-.12)  -- obj:SetTexCoord(left,right,top,bottom)
	-- Border
	frame.Border:SetWidth(32); frame.Border:SetHeight(32)
	frame.Border:SetPoint("CENTER", 0, -2)
	frame.Border:SetTexture(SquareArt)
	-- Highlight
	frame.BorderHighlight:SetAllPoints(frame.Border)
	frame.BorderHighlight:SetTexture(SquareHighlightArt)
	--  Time Text
	frame.TimeLeft:SetFont(AuraFont ,9, "OUTLINE")
	frame.TimeLeft:SetShadowOffset(1, -1)
	frame.TimeLeft:SetShadowColor(0,0,0,1)
	frame.TimeLeft:SetPoint("RIGHT", 0, 8)
	frame.TimeLeft:SetWidth(26)
	frame.TimeLeft:SetHeight(16)
	frame.TimeLeft:SetJustifyH("RIGHT")
	--  Stacks
	frame.Stacks:SetFont(AuraFont,10, "OUTLINE")
	frame.Stacks:SetShadowOffset(1, -1)
	frame.Stacks:SetShadowColor(0,0,0,1)
	frame.Stacks:SetPoint("RIGHT", 0, -6)
	frame.Stacks:SetWidth(26)
	frame.Stacks:SetHeight(16)
	frame.Stacks:SetJustifyH("RIGHT")

	AuraWidth = frame:GetWidth()
end

-- Create a Wide Aura Icon
local function CreateAuraIcon(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame.unit = nil
	frame.Parent = parent

	frame.Icon = frame:CreateTexture(nil, "BACKGROUND")
	frame.Border = frame:CreateTexture(nil, "ARTWORK")
	frame.BorderHighlight = frame:CreateTexture(nil, "ARTWORK")
	frame.Cooldown = CreateFrame("Cooldown", nil, frame, "NeatPlatesAuraWidgetCooldown")
	frame.Info = CreateFrame("Frame", nil, frame)

	frame.Cooldown:SetAllPoints(frame)
	frame.Cooldown:SetReverse(true)
	frame.Cooldown:SetHideCountdownNumbers(true)
	frame.Cooldown:SetDrawEdge(true)

	frame.Info:SetAllPoints(frame)

	-- Text
	frame.TimeLeft = frame.Info:CreateFontString(nil, "OVERLAY")
	frame.Stacks = frame.Info:CreateFontString(nil, "OVERLAY")

	-- Information about the currently displayed aura
	frame.AuraInfo = {
		Name = "",
		Icon = "",
		Stacks = 0,
		Expiration = 0,
		Type = "",
	}

	frame.Expire = ExpireFunction
	frame.Poll = UpdateWidgetTime
	frame:Hide()

	return frame
end

local function UpdateIconConfig(frame)
	local iconTable = frame.AuraIconFrames

	if iconTable then
		-- Create Icons
		for index = 1, AuraLimit do
			--if not iconTable[index] then print("Creating aura icon"); auraIconsCreated = (auraIconsCreated or 0) + 1; print(auraIconsCreated);end
			local icon = iconTable[index] or CreateAuraIcon(frame)
			iconTable[index] = icon
			icon:SetScale(AuraScale)
			-- Apply Style
			if useWideIcons then TransformWideAura(icon) else TransformSquareAura(icon) end
		end

		-- Set Anchors
		local anchorIndex = 1
		for row = 1, AuraLimit/DebuffColumns do
			iconTable[anchorIndex]:ClearAllPoints()
			if row == 1 then
				iconTable[anchorIndex]:SetPoint(AuraAlignment or "BOTTOMLEFT", frame)
			else
				iconTable[anchorIndex]:SetPoint("BOTTOMLEFT", iconTable[anchorIndex-DebuffColumns], "TOPLEFT", 0, 8)
			end
			for index = anchorIndex + 1, DebuffColumns * row do
			  iconTable[index]:ClearAllPoints()
			  if AuraAlignment == "BOTTOMRIGHT" then
			  	iconTable[index]:SetPoint("RIGHT", iconTable[index-1], "LEFT", -5, 0)
			  else
			  	iconTable[index]:SetPoint("LEFT", iconTable[index-1], "RIGHT", 5, 0)
			  end
			end
			anchorIndex = anchorIndex + DebuffColumns -- Set next anchor index
		end
	end
end

local function UpdateEmphasizedIconConfig(frame)
	local iconTable = frame.AuraIconFrames

	--local columns = 1
	local auraLimit = MaxEmphasizedAuras

	if iconTable then
		-- Create Icons
		for index = 1, auraLimit do
			local icon = iconTable[index] or CreateAuraIcon(frame)
			iconTable[index] = icon
			-- Apply Style
			if useWideIcons then TransformWideAura(icon) else TransformSquareAura(icon) end
		end

		-- Set Anchors
		iconTable[1]:ClearAllPoints()
		iconTable[1]:SetPoint("BOTTOMLEFT", frame)
		for index = 2, auraLimit do
		  iconTable[index]:ClearAllPoints()
		  iconTable[index]:SetPoint("LEFT", iconTable[index-1], "RIGHT", 5, 0)
		end
	end
end

local function UpdateWidgetConfig(frame)
	UpdateIconConfig(frame)
	UpdateEmphasizedIconConfig(frame.emphasized)
end

local function UpdateWidgetOffset(frame, x, y)
	local config = frame.lastConfig
	frame:ClearAllPoints()
	frame:SetPoint(config.anchor or "TOP", config.relFrame, config.anchorRel or config.anchor or "TOP", config.x or 0, (config.y or 0) + (y or 0))
end

local function SetCustomPoint(frame, anchor, relFrame, anchorRel, x, y)
	frame.lastConfig = {
		anchor = anchor,
		relFrame = relFrame,
		anchorRel = anchorRel,
		x = x,
		y = y
	}

	UpdateWidgetOffset(frame)
end

-- Create the Main Widget Body and Icon Array
local function CreateAuraWidget(parent, style)
	-- Create Base frame
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(128); frame:SetHeight(32); frame:Show()
	--frame.PollFunction = UpdateWidgetTime

	-- Create Emphasized Frame
	frame.emphasized = CreateFrame("Frame", nil, frame)
	frame.emphasized:SetWidth(32); frame.emphasized:SetHeight(32); frame.emphasized:SetPoint("BOTTOM", frame, "TOP", 0, 2); frame.emphasized:SetScale(2); frame.emphasized:Show()

	-- Create Icon Grid
	frame.AuraIconFrames = {}
	frame.emphasized.AuraIconFrames = {}
	UpdateIconConfig(frame)
	UpdateEmphasizedIconConfig(frame.emphasized)

	-- Functions
	frame._Hide = frame.Hide
	frame.Hide = function() ClearWidgetContext(frame); frame:_Hide() end

	frame.Filter = nil
	frame.UpdateContext = UpdateWidgetContext
	frame.Update = UpdateWidgetContext
	frame.UpdateConfig = UpdateWidgetConfig
	frame.UpdateTarget = UpdateWidgetTarget
	frame.SetCustomPoint = SetCustomPoint
	frame.UpdateOffset = UpdateWidgetOffset

	-- Emphasized Functions
	frame.emphasized.SetAura = function(frame, auras)
		local shown = 0
		local ids = {}
		local auraLimit = MaxEmphasizedAuras
		sort(auras, AuraSortFunction)


		for index = 1, #auras do
			if index > auraLimit then break end
			shown = shown+1
			ids[tostring(auras[index].spellid)] = true
			UpdateIcon(frame.AuraIconFrames[index], auras[index])
		end
		
		-- Cleanup empty aura slots
		for i=shown+1, #frame.AuraIconFrames do
			UpdateIcon(frame.AuraIconFrames[i])
		end


		return ids, shown
	end

	return frame
end

local function UseSquareDebuffIcon(scale)
	AuraScale = scale
	useWideIcons = false
	DebuffColumns = math.max(math.ceil(5/AuraScale), 5)
	DebuffLimit = DebuffColumns * 2
	AuraLimit = DebuffColumns * 3	-- Extra row for buffs
	NeatPlates:ForceUpdate()
end

local function UseWideDebuffIcon(scale)
	AuraScale = scale
	useWideIcons = true
	DebuffColumns = math.max(math.ceil(3/AuraScale), 3)
	DebuffLimit = DebuffColumns * 2
	AuraLimit = DebuffColumns * 3	-- Extra row for buffs
	NeatPlates:ForceUpdate()
end

local function SetAuraSortMode(func)
	if func and type(func) == 'function' then
		AuraSortFunction = func
	end
end

local function SetAuraFilter(func)
	if func and type(func) == 'function' then
		AuraFilterFunction = func
	end
end

local function SetEmphasizedAuraFilter(func, unique)
	if func and type(func) == 'function' then
		EmphasizedAuraFilterFunction = func
	end
	EmphasizedUnique = unique
end

local function SetAuraOptions(LocalVars)
	local Alignments ={
		"BOTTOMLEFT",
		"BOTTOM",
		"BOTTOMRIGHT",
	}

	HideCooldownSpiral = LocalVars.HideCooldownSpiral
	HideAuraDuration = LocalVars.HideAuraDuration
	HideAuraStacks = LocalVars.HideAuraStacks
	AuraScale = LocalVars.AuraScale
	AuraAlignment = Alignments[LocalVars.WidgetAuraAlignment]
	ScaleOptions = LocalVars.WidgetAuraScaleOptions
	HideInHeadlineMode = LocalVars.HideAuraInHeadline
	PreciseAuraThreshold = LocalVars.PreciseAuraThreshold
end

--local function SetPandemic(enabled, color)
--	PandemicEnabled = enabled
--	PandemicColor = color
--end

--local function SetBorderTypes(pandemic, magic, enrage)
--	if pandemic == 2 then pandemic = true else pandemic = false end
--	if magic == 2 then magic = true else magic = false end
--	if enrage == 2 then enrage = true else enrage = false end
--	ButtonGlowEnabled = {
--		["Pandemic"] = pandemic,
--		["Magic"] = magic,
--		[""] = enrage,
--	}
--end

local function SetSpacerSlots(amount)
	SpacerSlots = math.min(amount, DebuffColumns-1)
end

local function SetEmphasizedSlots(amount)
	MaxEmphasizedAuras = math.min(amount, DebuffColumns-1)
end

-----------------------------------------------------
-- External
-----------------------------------------------------
-- NeatPlatesWidgets.GetAuraWidgetByGUID = GetAuraWidgetByGUID
NeatPlatesWidgets.IsAuraShown = IsAuraShown

NeatPlatesWidgets.UseSquareDebuffIcon = UseSquareDebuffIcon
NeatPlatesWidgets.UseWideDebuffIcon = UseWideDebuffIcon

NeatPlatesWidgets.SetAuraSortMode = SetAuraSortMode
NeatPlatesWidgets.SetAuraFilter = SetAuraFilter
NeatPlatesWidgets.SetEmphasizedAuraFilter = SetEmphasizedAuraFilter
NeatPlatesWidgets.SetAuraOptions = SetAuraOptions

--NeatPlatesWidgets.SetPandemic = SetPandemic
--NeatPlatesWidgets.SetBorderTypes = SetBorderTypes
NeatPlatesWidgets.SetSpacerSlots = SetSpacerSlots
NeatPlatesWidgets.SetEmphasizedSlots = SetEmphasizedSlots

NeatPlatesWidgets.CreateAuraWidget = CreateAuraWidget

NeatPlatesWidgets.EnableAuraWatcher = Enable
NeatPlatesWidgets.DisableAuraWatcher = Disable

-----------------------------------------------------
-- Soon to be deprecated
-----------------------------------------------------

local PlayerDispelCapabilities = {
	["Curse"] = false,
	["Disease"] = false,
	["Magic"] = false,
	["Poison"] = false,
}

local function UpdatePlayerDispelTypes()
	PlayerDispelCapabilities["Curse"] = IsSpellKnown(51886) or IsSpellKnown(475) or IsSpellKnown(2782)
	PlayerDispelCapabilities["Poison"] = IsSpellKnown(2782) or IsSpellKnown(32375) or IsSpellKnown(4987) or (IsSpellKnown(527) and IsSpellKnown(33167))
	PlayerDispelCapabilities["Magic"] = (IsSpellKnown(4987) and IsSpellKnown(53551)) or (IsSpellKnown(2782) and IsSpellKnown(88423)) or (IsSpellKnown(527) and IsSpellKnown(33167)) or (IsSpellKnown(51886) and IsSpellKnown(77130)) or IsSpellKnown(32375)
	PlayerDispelCapabilities["Disease"] = IsSpellKnown(4987) or IsSpellKnown(528)
end

local function CanPlayerDispel(debuffType)
	return PlayerDispelCapabilities[debuffType or ""]
end

NeatPlatesWidgets.CanPlayerDispel = CanPlayerDispel


