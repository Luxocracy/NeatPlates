
local AddonName, HubData = ...;
local LocalVars = TidyPlatesHubDefaults



-- Widget Helpers
local WidgetLib = TidyPlatesWidgets

local CreateThreatLineWidget = WidgetLib.CreateThreatLineWidget
local CreateAuraWidget = WidgetLib.CreateAuraWidget
local CreateClassWidget = WidgetLib.CreateClassWidget
local CreateRangeWidget = WidgetLib.CreateRangeWidget
local CreateComboPointWidget = WidgetLib.CreateComboPointWidget
local CreateTotemIconWidget = WidgetLib.CreateTotemIconWidget

TidyPlatesHubDefaults.WidgetsRangeMode = 1
TidyPlatesHubMenus.RangeModes = {
				{ text = "9 yards"} ,
				{ text = "15 yards" } ,
				{ text = "28 yards" } ,
				{ text = "40 yards" } ,
			}

TidyPlatesHubDefaults.WidgetsDebuffStyle = 1
TidyPlatesHubMenus.DebuffStyles = {
				{ text = "Wide",  } ,
				{ text = "Compact (May require UI reload to take effect)",  } ,
			}

------------------------------------------------------------------------------
-- Aura Widget
------------------------------------------------------------------------------
TidyPlatesHubPrefixList = {
	-- ALL
	["ALL"] = 1,
	["All"] = 1,
	["all"] = 1,

	-- MY
	["MY"] = 2,
	["My"] = 2,
	["my"] = 2,

	-- OTHER
	["OTHER"] = 3,
	["Other"] = 3,
	["other"] = 3,

	-- CC
	["CC"] = 4,
	["cc"] = 4,
	["Cc"] = 4,

	-- NOT
	["NOT"] = 5,
	["Not"] = 5,
	["not"] = 5,
}

--[[
* Debuffs are color coded, with poison debuffs having a green border,
magic debuffs a blue border, physical debuffs a red border, diseases a
brown border, and curses a purple border

Information from Widget:
aura.spellid, aura.name, aura.expiration, aura.stacks,
aura.caster, aura.duration, aura.texture,
aura.type, aura.reaction
--]]

local AURA_TYPE_DEBUFF = 6
local AURA_TYPE_BUFF = 1

local AURA_TARGET_HOSTILE = 1
local AURA_TARGET_FRIENDLY = 2

local AURA_TYPE = { "Buff", "Curse", "Disease", "Magic", "Poison", "Debuff", }
local AURA_TYPE_COLORS = { nil, {1,0,1}, {.5, .2, 0}, {0,.4,1}, {0,1,0}, nil, }



local function GetPrefixPriority(aura)
	local spellid = tostring(aura.spellid)
	local name = aura.name
	-- Lookup using the Prefix & Priority Lists
	local prefix = LocalVars.WidgetsDebuffLookup[spellid] or LocalVars.WidgetsDebuffLookup[name]
	local priority = LocalVars.WidgetsDebuffPriority[spellid] or LocalVars.WidgetsDebuffPriority[name]

	return prefix, priority
end

local function GetAuraColor(aura)
	local color = AURA_TYPE_COLORS[aura.type]
	if color then return unpack(color) end
end

local DebuffPrefixModes = {
	-- All
	function(aura)
		return true
	end,
	-- My
	function(aura)
		if aura.caster == "player" or aura.caster == "pet" then return true end
	end,
	-- Other
	function(aura)
		--print(aura.caster, aura.name)
		if (aura.caster ~= "player" or aura.caster ~= "pet") then return true end
	end,
	-- CC
	function(aura)
		--return true, .5, .4, 0
		return true, 1, 1, 0
	end,
	-- NOT
	function(aura)
		return false
	end
}

local function SmartFilterMode(aura)
	local ShowThisAura = false
	local AuraPriority = 20


	-- My own Buffs and Debuffs
	if (aura.caster == "player" or aura.caster == "pet") and aura.duration and aura.duration < 150 then
		if LocalVars.WidgetsMyBuff and aura.effect == "HELPFUL" then
			ShowThisAura = true
		elseif LocalVars.WidgetsMyDebuff and aura.effect == "HARMFUL" then
			ShowThisAura = true
		end
	end


	-- Evaluate for further filtering
	local prefix, priority = GetPrefixPriority(aura)
	-- If the aura is mentioned in the list, evaluate the instruction...
	if prefix then
		local show = DebuffPrefixModes[prefix](aura)

		--print(aura.name, show, prefix, priority)
		if show == true then
			return true, 20 + (priority or 0)		-- , r, g, b
		else
			return false
		end
	--- When no prefix is mentioned, return the aura.
	else
		return ShowThisAura, 20		-- , r, g, b
	end

end




local DispelTypeHandlers = {
	-- Curse
	["Curse"] = function()
		return LocalVars.WidgetAuraTrackCurse
	end,
	-- Disease
	["Disease"] = function()
		return LocalVars.WidgetAuraTrackDisease
	end,
	-- Magic
	["Magic"] = function()
		return LocalVars.WidgetAuraTrackMagic
	end,
	-- Poison
	["Poison"] = function()
		return LocalVars.WidgetAuraTrackPoison
	end,
	}

local function TrackDispelType(dispelType)
	if dispelType then
		local handlerfunction = DispelTypeHandlers[dispelType]
		if handlerfunction then return handlerfunction() end
	end
end

local function DebuffFilter(aura)
	if LocalVars.WidgetAuraTrackDispelFriendly and aura.reaction == AURA_TARGET_FRIENDLY then
		if aura.effect == "HARMFUL" and TrackDispelType(aura.type) then
		local r, g, b = GetAuraColor(aura)
		return true, 10, r, g, b end
	end

	return SmartFilterMode(aura)
end


---------------------------------------------------------------------------------------------------------
-- Widget Initializers
---------------------------------------------------------------------------------------------------------


local function AddClassIcon(plate, enable, config)
	if enable and config then
		if not plate.widgets.ClassIcon then
			local widget
			widget = CreateClassWidget(plate)
			widget:SetPoint(config.anchor or "TOP", plate, config.x or 0, config.y or 0) -- 0, 3)
			--widget:SetScale(1.2)
			plate.widgets.ClassIcon = widget
		end
	elseif plate.widgets.ClassIcon then
		plate.widgets.ClassIcon:Hide()
		plate.widgets.ClassIcon = nil
	end
end

local function AddTotemIcon(plate, enable, config)
	if enable and config then
		if not plate.widgets.TotemIcon then
			local widget
			widget = CreateTotemIconWidget(plate)
			widget:SetPoint(config.anchor or "TOP", plate, config.x or 0, config.y or 0) --0, 3)
			--widget:SetScale(1.2)
			plate.widgets.TotemIcon = widget
		end
	elseif plate.widgets.TotemIcon then
		plate.widgets.TotemIcon:Hide()
		plate.widgets.TotemIcon = nil
	end
end

local function AddComboPoints(plate, enable, config)
	if enable and config then
		if not plate.widgets.ComboWidget then
			local widget
			widget = CreateComboPointWidget(plate)
			widget:SetPoint(config.anchor or "TOP", plate, config.x or 0, config.y or 0) --0, 10)
			widget:SetFrameLevel(plate:GetFrameLevel()+2)
			plate.widgets.ComboWidget = widget
		end
	elseif plate.widgets.ComboWidget then
		plate.widgets.ComboWidget:Hide()
		plate.widgets.ComboWidget = nil
	end
end

local function AddThreatLineWidget(plate, enable, config)
	if enable and config then
		if not plate.widgets.ThreatLineWidget then
			local widget
			widget = CreateThreatLineWidget(plate)
			widget:SetPoint(config.anchor or "TOP", plate, config.x or 0, config.y or 0)
			widget:SetFrameLevel(plate:GetFrameLevel()+3)
			--widget._LowColor = LocalVars.TugWidgetLooseColor
			--widget._HighColor = LocalVars.TugWidgetAggroColor
			--widget._TankedColor = LocalVars.TugWidgetSafeColor
			plate.widgets.ThreatLineWidget = widget
		end
	elseif plate.widgets.ThreatLineWidget then
		plate.widgets.ThreatLineWidget:Hide()
		plate.widgets.ThreatLineWidget = nil
	end
end

local function AddThreatWheelWidget(plate, enable, config)
	if enable and config then
		if not plate.widgets.ThreatWheelWidget then
			local widget
			widget = WidgetLib.CreateThreatWheelWidget(plate)
			widget:SetPoint(config.anchor or "TOP", plate, config.x or 0, config.y or 0)
			widget:SetFrameLevel(plate:GetFrameLevel()+3)
			plate.widgets.ThreatWheelWidget = widget
		end
	elseif plate.widgets.ThreatWheelWidget then
		plate.widgets.ThreatWheelWidget:Hide()
		plate.widgets.ThreatWheelWidget = nil
	end
end

local RangeModeRef = { 9, 15, 28, 40 }
local function AddRangeWidget(plate, enable, config)
	if enable and config then
		if not plate.widgets.RangeWidget then
			local widget
			widget = CreateRangeWidget(plate)
			widget:SetPoint(config.anchor or "CENTER", config.x or 0, config.y or 0) --0, 0)
			plate.widgets.RangeWidget = widget
		end
	elseif plate.widgets.RangeWidget then
		plate.widgets.RangeWidget:Hide()
		plate.widgets.RangeWidget = nil
	end
end

local function AddDebuffWidget(plate, enable, config)
	if enable and config then
		if not plate.widgets.DebuffWidget then
			local widget
			widget =  CreateAuraWidget(plate)
			widget:SetPoint(config.anchor or "TOP", plate, config.x or 0, config.y or 0) --15, 20)
			widget:SetFrameLevel(plate:GetFrameLevel()+1)
			--widget.Filter = DebuffFilter		-- this method of defining the filter function will be deprecated in 6.9
			plate.widgets.DebuffWidget = widget
		end
	elseif plate.widgets.DebuffWidget then
		plate.widgets.DebuffWidget:Hide()
		plate.widgets.DebuffWidget = nil
	 end
end

local function MoveDebuffWidget(plate, config)
	local widget = plate.widgets.DebuffWidget
	if widget then
		widget:SetPoint(config.anchor or "TOP", plate, config.x or 0, config.y or 0) --15, 20)
	end
end

------------------------------------------------------------------------------
-- Widget Activation
------------------------------------------------------------------------------


-- testing HealerWidget
--CreateHealerWidget = TidyPlatesWidgets.CreateHealerWidget

local function OnInitializeWidgets(plate, configTable)
	AddClassIcon(plate, ((LocalVars.ClassEnemyIcon or LocalVars.ClassPartyIcon)) , configTable.ClassIcon)
	AddTotemIcon(plate,  LocalVars.WidgetsTotemIcon, configTable.TotemIcon)
	--AddThreatWheelWidget(plate, LocalVars.WidgetsThreatIndicator and (LocalVars.WidgetsThreatIndicatorMode == 2), configTable.ThreatWheelWidget)
	AddThreatLineWidget(plate, LocalVars.WidgetsThreatIndicator, configTable.ThreatLineWidget)		-- Tug-o-Threat
	AddComboPoints(plate, LocalVars.WidgetsComboPoints, configTable.ComboWidget )
	--AddRangeWidget(plate, LocalVars.WidgetsRangeIndicator, configTable.RangeWidget )
	if LocalVars.WidgetsComboPoints and configTable.DebuffWidgetPlus then -- If the combo widget is active, it often overlaps the debuff widget "DebuffWidgetPlus" will provide an alternative
		AddDebuffWidget(plate, LocalVars.WidgetsDebuff, configTable.DebuffWidgetPlus )
	else AddDebuffWidget(plate, LocalVars.WidgetsDebuff, configTable.DebuffWidget ) end


	if LocalVars.WidgetsEnableExternal and TidyPlatesGlobal_OnInitialize then TidyPlatesGlobal_OnInitialize(plate) end
end

local function OnContextUpdateDelegate(plate, unit)
	local Widgets = plate.widgets
	if LocalVars.WidgetsComboPoints and Widgets.ComboWidget then Widgets.ComboWidget:UpdateContext(plate, unit) end
	-- if (LocalVars.WidgetsThreatIndicatorMode == 1) and LocalVars.WidgetsThreatIndicator then Widgets.ThreatLineWidget:UpdateContext(unit) end		-- Tug-O-Threat
	if LocalVars.WidgetsThreatIndicator and Widgets.ThreatLineWidget then Widgets.ThreatLineWidget:UpdateContext(unit) end		-- Tug-O-Threat
	if LocalVars.WidgetsDebuff and Widgets.DebuffWidget then Widgets.DebuffWidget:UpdateContext(unit) end

	if LocalVars.WidgetsEnableExternal and TidyPlatesGlobal_OnContextUpdate then TidyPlatesGlobal_OnContextUpdate(plate, unit) end
end

local function OnUpdateDelegate(plate, unit)
	local Widgets = plate.widgets
	--if LocalVars.WidgetsRangeIndicator then Widgets.RangeWidget:Update(unit,RangeModeRef[LocalVars.RangeMode])  end
	if (LocalVars.ClassEnemyIcon and unit.reaction ~= "FRIENDLY") or (LocalVars.ClassPartyIcon and unit.reaction == "FRIENDLY") then Widgets.ClassIcon:Update(unit, LocalVars.ClassPartyIcon) end
	if LocalVars.WidgetsTotemIcon and Widgets.TotemIcon then Widgets.TotemIcon:Update(unit)  end
	--if (LocalVars.WidgetsThreatIndicatorMode == 2) and LocalVars.WidgetsThreatIndicator then plate.widgets.ThreatWheelWidget:Update(unit) end 		-- Threat Wheel

	if LocalVars.WidgetsEnableExternal and TidyPlatesGlobal_OnUpdate then TidyPlatesGlobal_OnUpdate(plate, unit) end
end


------------------------------------------------------------------------------
-- Local Variable
------------------------------------------------------------------------------

local function OnVariableChange(vars)

	LocalVars = vars

	if LocalVars.WidgetsDebuff then
		TidyPlatesWidgets:EnableAuraWatcher()
		TidyPlatesWidgets.SetAuraFilter(DebuffFilter)
	else TidyPlatesWidgets:DisableAuraWatcher() end

--[[
	if LocalVars.WidgetsAuraMode == 3 then
		TidyPlatesWidgets.SetAuraPrefilter(Prefilter)		-- Filter out some unecessary stuff
	else TidyPlatesWidgets.SetAuraPrefilter(nil) end
	--]]

	TidyPlatesWidgets.SetAuraPrefilter(nil)		-- Cache everything..
end
HubData.RegisterCallback(OnVariableChange)


------------------------------------------------------------------------------
-- Add References
------------------------------------------------------------------------------

TidyPlatesHubFunctions.OnUpdate = OnUpdateDelegate
TidyPlatesHubFunctions.OnInitializeWidgets = OnInitializeWidgets
TidyPlatesHubFunctions.OnContextUpdate = OnContextUpdateDelegate
TidyPlatesHubFunctions._WidgetDebuffFilter = DebuffFilter






