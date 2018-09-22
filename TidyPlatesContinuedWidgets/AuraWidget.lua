
	--Spinning Cooldown Frame
	--[[
	frame.Cooldown = CreateFrame("Cooldown", nil, frame, "TidyPlatesContAuraWidgetCooldown")
	frame.Cooldown:SetAllPoints(frame)
	frame.Cooldown:SetReverse(true)
	frame.Cooldown:SetHideCountdownNumbers(true)
	--]]


TidyPlatesContWidgets.DebuffWidgetBuild = 2

local PlayerGUID = UnitGUID("player")
local PolledHideIn = TidyPlatesContWidgets.PolledHideIn
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

local function DummyFunction() end

local function DefaultPreFilterFunction() return true end
local function DefaultFilterFunction(aura, unit) if aura and aura.duration and (aura.duration < 30) then return true end end

local AuraFilterFunction = DefaultFilterFunction
local AuraHookFunction

local AURA_TARGET_HOSTILE = 1
local AURA_TARGET_FRIENDLY = 2

local AURA_TYPE_BUFF = 1
local AURA_TYPE_DEBUFF = 6

local ButtonGlow = LibStub("LibButtonGlow-1.0")
local ButtonGlowEnabled = {
		["Pandemic"] = false,
		["Magic"] = false,
		[""] = false, -- Enrage
	}

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



-----------------------------------------------------
-- Function Reference Lists
-----------------------------------------------------

local AuraEvents = {
	--["UNIT_TARGET"] = EventUnitTarget,
	["UNIT_AURA"] = EventUnitAura,
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
	if expiration == 0 then
		frame.TimeLeft:SetText("")
	else
		local timeleft = expiration-GetTime()
		if timeleft > 60 then
			frame.TimeLeft:SetText(floor(timeleft/60).."m")
		else
			frame.TimeLeft:SetText(floor(timeleft))
			--frame.TimeLeft:SetText(floor(timeleft*10)/10)
		end
	end
end


local function UpdateIcon(frame, aura)
	if frame and aura and aura.texture and aura.expiration then
		local r, g, b, a = aura.r, aura.g, aura.b, aura.a
		local glowType = aura.type
		local pandemicThreshold = aura.duration and aura.expiration and aura.effect == "HARMFUL" and aura.expiration-GetTime() <= aura.duration*0.3
		local removeGlow = true

		-- Icon
		frame.Icon:SetTexture(aura.texture)

		-- Stacks
		if aura.stacks and aura.stacks > 1 then frame.Stacks:SetText(aura.stacks)
		else frame.Stacks:SetText("") end

		-- Pandemic and other Hightlighting
		if (aura.effect == "HELPFUL" and ButtonGlowEnabled[aura.type]) or (PandemicEnabled and pandemicThreshold and ButtonGlowEnabled["Pandemic"]) then
			removeGlow = false
			frame.BorderHighlight:Hide()
			frame.Border:Hide()
			ButtonGlow.ShowOverlayGlow(frame)
			frame.__LBGoverlay:SetFrameLevel(frame:GetFrameLevel() or 65)
		elseif PandemicEnabled and pandemicThreshold then
			frame.BorderHighlight:SetVertexColor(PandemicColor.r,PandemicColor.g,PandemicColor.b,PandemicColor.a)
			frame.BorderHighlight:Show()
			frame.Border:Hide()
		elseif r then
			frame.BorderHighlight:SetVertexColor(r, g or 1, b or 1, a or 1)
			frame.BorderHighlight:Show()
			frame.Border:Hide()
		else frame.BorderHighlight:Hide(); frame.Border:Show() end

		-- Remove ButtonGlow if appropriate
		if frame.__LBGoverlay and removeGlow then ButtonGlow.HideOverlayGlow(frame) end

		-- [[ Cooldown
		frame.Cooldown.noCooldownCount = true -- Disable OmniCC interaction
		if aura.duration and aura.duration > 0 and aura.expiration and aura.expiration > 0 then
			SetCooldown(frame.Cooldown, aura.expiration-aura.duration, aura.duration+.25)
			--frame.Cooldown:SetCooldown(aura.expiration-aura.duration, aura.duration+.25)
		else
			SetCooldown(frame.Cooldown, 0, 0)	-- Clear Cooldown
		end
		--]]

		-- Expiration
		UpdateWidgetTime(frame, aura.expiration)
		frame:Show()
		if aura.expiration ~= 0 then PolledHideIn(frame, aura.expiration) end

	elseif frame then
		PolledHideIn(frame, 0)
	end
end


local function AuraSortFunction(a,b)
	return a.priority < b.priority
end


local function UpdateIconGrid(frame, unitid)

		if not unitid then return end

		local unitReaction
		if UnitIsFriend("player", unitid) then unitReaction = AURA_TARGET_FRIENDLY
		else unitReaction = AURA_TARGET_HOSTILE end

		local AuraIconFrames = frame.AuraIconFrames
		local storedAuras = {}
		local storedAuraCount = 0

		-- Cache displayable auras
		------------------------------------------------------------------------------------------------------
		-- This block will go through the auras on the unit and make a list of those that should
		-- be displayed, listed by priority.
		local auraIndex = 0
		local moreAuras = true

		local searchedDebuffs, searchedBuffs = false, false
		local auraFilter = "HARMFUL"

		repeat

			auraIndex = auraIndex + 1

			local aura = {}

			do
				local name, icon, stacks, auraType, duration, expiration, caster, canStealOrPurge, nameplateShowPersonal, spellid = UnitAura(unitid, auraIndex, auraFilter)		-- UnitaAura

				aura.name = name
				aura.texture = icon
				aura.stacks = stacks
				aura.type = auraType
				aura.effect = auraFilter
				aura.duration = duration
				aura.reaction = unitReaction
				aura.expiration = expiration
				aura.caster = caster
				aura.spellid = spellid
				aura.unit = unitid 		-- unitid of the plate
			end

			-- Gnaw , false, icon, 0 stacks, nil type, duration 1, expiration 8850.436, caster pet, false, false, 91800

			-- Auras are evaluated by an external function
			-- Pre-filtering before the icon grid is populated
			if aura.name then
				local show, priority, r, g, b, a = AuraFilterFunction(aura)
				--print(aura.name, show, priority)
				--show = true
				-- Store Order/Priority
				if show then

					aura.priority = priority or 10
					aura.r, aura.g, aura.b, aura.a = r, g, b, a

					storedAuraCount = storedAuraCount + 1
					storedAuras[storedAuraCount] = aura
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

		--[[ Debug, add custom Buff
		storedAuraCount = storedAuraCount+1
		storedAuras[storedAuraCount] = {
			["type"] = "Magic",
			["effect"] = "HELPFUL",
			["duration"] = 10,
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
		--]]

		-- Display Auras
		------------------------------------------------------------------------------------------------------
		local DebuffSlotCount = 0
		local BuffSlotCount = 0
		local AuraSlots = {}
		local BuffAuras = {}
		local DebuffAuras = {}
		local DebuffCount = 0

		if storedAuraCount > 0 then
			frame:Show()
			sort(storedAuras, AuraSortFunction)

			for index = 1, storedAuraCount do
				if (DebuffSlotCount+BuffSlotCount) > AuraLimit then break end
				local aura = storedAuras[index]
				if aura.spellid and aura.expiration then

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
			local rowCount = (math.floor((DebuffSlotCount + BuffSlotCount - 1)/DebuffColumns)+1)
			-- print(DebuffColumns * rowCount - (DebuffSlotCount + BuffSlotCount))
			if DebuffColumns * rowCount - (DebuffSlotCount + BuffSlotCount) >= SpacerSlots then
				rowOffset = math.max(DebuffColumns * rowCount, DebuffColumns) -- Same Row with space between
			else
				rowOffset = DebuffColumns * (rowCount + 1)	-- Seperate Row
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

end

function UpdateWidget(frame)
		local unitid = frame.unitid

		UpdateIconGrid(frame, unitid)
end

-- Context Update (mouseover, target change)
local function UpdateWidgetContext(frame, unit)
	local unitid = unit.unitid
	frame.unitid = unitid

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
local WideArt = "Interface\\Addons\\TidyPlatesContinuedWidgets\\Aura\\AuraFrameWide"
local SquareArt = "Interface\\Addons\\TidyPlatesContinuedWidgets\\Aura\\AuraFrameSquare"
local WideHighlightArt = "Interface\\Addons\\TidyPlatesContinuedWidgets\\Aura\\AuraFrameHighlightWide"
local SquareHighlightArt = "Interface\\Addons\\TidyPlatesContinuedWidgets\\Aura\\AuraFrameHighlightSquare"
local AuraFont = "FONTS\\ARIALN.TTF"

local function Enable()
	AuraMonitor:SetScript("OnEvent", AuraEventHandler)

	for event in pairs(AuraEvents) do AuraMonitor:RegisterEvent(event) end

	--TidyPlatesContUtility:EnableGroupWatcher()
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
end

local function TransformSquareAura(frame)
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
end

-- Create a Wide Aura Icon
local function CreateAuraIcon(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame.unit = nil
	frame.Parent = parent

	frame.Icon = frame:CreateTexture(nil, "BACKGROUND")
	frame.Border = frame:CreateTexture(nil, "ARTWORK")
	frame.BorderHighlight = frame:CreateTexture(nil, "ARTWORK")
	frame.Cooldown = CreateFrame("Cooldown", nil, frame, "TidyPlatesContAuraWidgetCooldown")

	frame.Cooldown:SetAllPoints(frame)
	frame.Cooldown:SetReverse(true)
	frame.Cooldown:SetHideCountdownNumbers(true)
	frame.Cooldown:SetDrawEdge(true)

	-- Text
	--frame.TimeLeft = frame:CreateFontString(nil, "OVERLAY")
	frame.TimeLeft = frame.Cooldown:CreateFontString(nil, "OVERLAY")
	frame.Stacks = frame:CreateFontString(nil, "OVERLAY")
	-- frame.Stacks = frame.Cooldown:CreateFontString(nil, "OVERLAY")

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
			local icon = iconTable[index] or CreateAuraIcon(frame)
			iconTable[index] = icon
			-- Apply Style
			if useWideIcons then TransformWideAura(icon) else TransformSquareAura(icon) end
		end

		-- -- Set Anchors
		-- iconTable[1]:ClearAllPoints()
		-- iconTable[1]:SetPoint("LEFT", frame)
		-- for index = 2, DebuffColumns do
		--   iconTable[index]:ClearAllPoints()
		--   iconTable[index]:SetPoint("LEFT", iconTable[index-1], "RIGHT", 5, 0)
		-- end

		-- iconTable[DebuffColumns+1]:ClearAllPoints()
		-- iconTable[DebuffColumns+1]:SetPoint("BOTTOMLEFT", iconTable[1], "TOPLEFT", 0, 8)
		-- for index = (DebuffColumns+2), AuraLimit do
		--   iconTable[index]:ClearAllPoints()
		--   iconTable[index]:SetPoint("LEFT", iconTable[index-1], "RIGHT", 5, 0)
		-- end

		-- Set Anchors
		local anchorIndex = 1
		for row = 1, AuraLimit/DebuffColumns do
			iconTable[anchorIndex]:ClearAllPoints()
			if row == 1 then
				iconTable[anchorIndex]:SetPoint("LEFT", frame)
			else
				iconTable[anchorIndex]:SetPoint("BOTTOMLEFT", iconTable[anchorIndex-DebuffColumns], "TOPLEFT", 0, 8)
			end
			for index = anchorIndex + 1, DebuffColumns * row do
			  iconTable[index]:ClearAllPoints()
			  iconTable[index]:SetPoint("LEFT", iconTable[index-1], "RIGHT", 5, 0)
			end
			anchorIndex = anchorIndex + DebuffColumns -- Set next anchor index
		end
	end
end

local function UpdateWidgetConfig(frame)
	UpdateIconConfig(frame)
end


-- Create the Main Widget Body and Icon Array
local function CreateAuraWidget(parent, style)

	-- Create Base frame
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(128); frame:SetHeight(32); frame:Show()
	--frame.PollFunction = UpdateWidgetTime

	-- Create Icon Grid
	frame.AuraIconFrames = {}
	UpdateIconConfig(frame)

	-- Functions
	frame._Hide = frame.Hide
	frame.Hide = function() ClearWidgetContext(frame); frame:_Hide() end

	frame.Filter = nil
	frame.UpdateContext = UpdateWidgetContext
	frame.Update = UpdateWidgetContext
	frame.UpdateConfig = UpdateWidgetConfig
	frame.UpdateTarget = UpdateWidgetTarget
	return frame
end

local function UseSquareDebuffIcon()
	useWideIcons = false
	DebuffColumns = 5
	DebuffLimit = DebuffColumns * 2
	AuraLimit = DebuffColumns * 3	-- Extra row for buffs
	TidyPlatesCont:ForceUpdate()
end

local function UseWideDebuffIcon()
	useWideIcons = true
	DebuffColumns = 3
	DebuffLimit = DebuffColumns * 2
	AuraLimit = DebuffColumns * 3	-- Extra row for buffs
	TidyPlatesCont:ForceUpdate()
end


local function SetAuraFilter(func)
	if func and type(func) == 'function' then
		AuraFilterFunction = func
	end
end

local function SetPandemic(enabled, color)
	PandemicEnabled = enabled
	PandemicColor = color
end

local function SetBorderTypes(pandemic, magic, enrage)
	if pandemic == 2 then pandemic = true else pandemic = false end
	if magic == 2 then magic = true else magic = false end
	if enrage == 2 then enrage = true else enrage = false end
	ButtonGlowEnabled = {
		["Pandemic"] = pandemic,
		["Magic"] = magic,
		[""] = enrage,
	}
end

local function SetSpacerSlots(amount)
	SpacerSlots = math.min(amount, DebuffColumns-1)
end


-----------------------------------------------------
-- External
-----------------------------------------------------
-- TidyPlatesContWidgets.GetAuraWidgetByGUID = GetAuraWidgetByGUID
TidyPlatesContWidgets.IsAuraShown = IsAuraShown

TidyPlatesContWidgets.UseSquareDebuffIcon = UseSquareDebuffIcon
TidyPlatesContWidgets.UseWideDebuffIcon = UseWideDebuffIcon

TidyPlatesContWidgets.SetAuraFilter = SetAuraFilter

TidyPlatesContWidgets.SetPandemic = SetPandemic
TidyPlatesContWidgets.SetBorderTypes = SetBorderTypes
TidyPlatesContWidgets.SetSpacerSlots = SetSpacerSlots

TidyPlatesContWidgets.CreateAuraWidget = CreateAuraWidget

TidyPlatesContWidgets.EnableAuraWatcher = Enable
TidyPlatesContWidgets.DisableAuraWatcher = Disable

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

TidyPlatesContWidgets.CanPlayerDispel = CanPlayerDispel


