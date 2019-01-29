
local AddonName, HubData = ...;
local LocalVars = NeatPlatesHubDefaults
local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")


-- Widget Helpers
local WidgetLib = NeatPlatesWidgets

local CreateThreatLineWidget = WidgetLib.CreateThreatLineWidget
local CreateAuraWidget = WidgetLib.CreateAuraWidget
local CreateClassWidget = WidgetLib.CreateClassWidget
local CreateRangeWidget = WidgetLib.CreateRangeWidget
local CreateComboPointWidget = WidgetLib.CreateComboPointWidget
local CreateTotemIconWidget = WidgetLib.CreateTotemIconWidget
local CreateAbsorbWidget = WidgetLib.CreateAbsorbWidget
local CreateQuestWidget = WidgetLib.CreateQuestWidget
local CreateThreatPercentageWidget = WidgetLib.CreateThreatPercentageWidget

NeatPlatesHubDefaults.WidgetRangeMode = 1
NeatPlatesHubMenus.RangeModes = {
				{ text = "9 "..L["yards"]} ,
				{ text = "15 "..L["yards"]} ,
				{ text = "28 "..L["yards"]} ,
				{ text = "40 "..L["yards"]} ,
			}

NeatPlatesHubDefaults.WidgetAbsorbMode = 1
NeatPlatesHubMenus.AbsorbModes = {
				{ text = L["Blizzlike"]} ,
				{ text = L["Overlay"]} ,
			}

NeatPlatesHubDefaults.WidgetAbsorbUnits = 1
NeatPlatesHubMenus.AbsorbUnits = {
				{ text = L["Target Only"]} ,
				{ text = L["All Units"]} ,
			}

NeatPlatesHubDefaults.WidgetDebuffStyle = 1
NeatPlatesHubMenus.DebuffStyles = {
				{ text = L["Wide"],  } ,
				{ text = L["Compact (May require UI reload to take effect)"],  } ,
			}

NeatPlatesHubDefaults.WidgetComboPointsStyle = 2
NeatPlatesHubMenus.ComboPointsStyles = {
				{ text = L["Blizzlike"],  } ,
				{ text = L["NeatPlates"],  } ,
				{ text = L["NeatPlatesTraditional"],  } ,
			}

NeatPlatesHubDefaults.BorderPandemic = 1
NeatPlatesHubDefaults.BorderBuffPurgeable = 1
NeatPlatesHubDefaults.BorderBuffEnrage = 1
NeatPlatesHubMenus.BorderTypes = {
				{ text = L["Border Color"],  },
				{ text = L["Glow"],  },
			}

------------------------------------------------------------------------------
-- Aura Widget
------------------------------------------------------------------------------
NeatPlatesHubPrefixList = {
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
-- local AURA_TYPE_COLORS = { nil, {1,0,1}, {.5, .2, 0}, {0,.4,1}, {0,1,0}, nil, }
local AURA_TYPE_COLORS = {
	["Buff"] = nil,
	["Curse"] = {1,0,1},
	["Disease"] = {.5, .2, 0},
	["Magic"] = {0,.4,1},
	["Poison"] = {0,1,0},
	["Debuff"] = nil,
}




local function GetPrefixPriority(aura)
	local spellid = tostring(aura.spellid)
	local name = aura.name

	-- Lookup using the Prefix & Priority Lists
	local prefix = LocalVars.WidgetDebuffLookup[spellid] or LocalVars.WidgetDebuffLookup[name] or NeatPlatesSettings.GlobalAuraLookup[spellid] or NeatPlatesSettings.GlobalAuraLookup[name]
	local priority = LocalVars.WidgetDebuffPriority[spellid] or LocalVars.WidgetDebuffPriority[name] or NeatPlatesSettings.GlobalAuraPriority[spellid] or NeatPlatesSettings.GlobalAuraPriority[name]

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
		if LocalVars.WidgetMyBuff and aura.effect == "HELPFUL" then
			ShowThisAura = true
		elseif LocalVars.WidgetMyDebuff and aura.effect == "HARMFUL" then
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
	-- Purgeable Buff
	if LocalVars.WidgetBuffPurgeable and aura.effect == "HELPFUL" and aura.type == "Magic" and aura.reaction == 1 then
		local color = LocalVars.ColorBuffPurgeable
		return true, 10, color.r, color.g, color.b, color.a
	end
	-- Sootheable Enrage Buff
	if LocalVars.WidgetBuffEnrage and aura.effect == "HELPFUL" and aura.type == "" and aura.reaction == 1 then
		local color = LocalVars.ColorBuffEnrage
		return true, 10, color.r, color.g, color.b, color.a
	end
	-- Dispellable Debuff
	if (LocalVars.WidgetAuraTrackDispelFriendly and aura.reaction == AURA_TARGET_FRIENDLY) then
		if (aura.effect == "HARMFUL" and TrackDispelType(aura.type)) then
			local r, g, b = GetAuraColor(aura)
			return true, 10, r, g, b, a
		end
	end

	return SmartFilterMode(aura)
end

local function EmphasizedFilter(aura)
	local spellid = tostring(aura.spellid)
	local name = aura.name
	local r, g, b = GetAuraColor(aura)

	-- Lookup using the Prefix & Priority Lists
	local prefix = LocalVars.EmphasizedAuraLookup[spellid] or LocalVars.EmphasizedAuraLookup[name] or NeatPlatesSettings.GlobalEmphasizedAuraLookup[spellid] or NeatPlatesSettings.GlobalEmphasizedAuraLookup[name]
	local priority = LocalVars.EmphasizedAuraPriority[spellid] or LocalVars.EmphasizedAuraPriority[name] or NeatPlatesSettings.GlobalEmphasizedAuraPriority[spellid] or NeatPlatesSettings.GlobalEmphasizedAuraPriority[name]

	if prefix and priority then
		local show = DebuffPrefixModes[prefix](aura)
		if show == true then
			return true, priority, r, g, b
		end
	elseif priority then
		return true, priority, r, g, b
	end

	return false -- Return false if aura isn't one to be emphasized
end

---------------------------------------------------------------------------------------------------------
-- Widget Initializers
---------------------------------------------------------------------------------------------------------

local function InitWidget( widgetName, extended, config, createFunction, enabled)
	local widget = extended.widgets[widgetName]

	if enabled and createFunction and config then
		--[[ Data from Themes passed to parent ]] --
		if config.h ~= nil then extended.widgetParent._height = config.h end
		if config.h ~= nil then extended.widgetParent._width = config.w end
		if config.o ~= nil then extended.widgetParent._orientation = config.o else extended.widgetParent._orientation = "HORIZONTAL" end

		if widget then
			if widget.UpdateConfig then widget:UpdateConfig() end
		else
			widget = createFunction(extended.widgetParent)
			extended.widgets[widgetName] = widget
		end

		widget:ClearAllPoints()
		widget:SetPoint(config.anchor or "TOP", extended, config.anchorRel or config.anchor or "TOP", config.x or 0, config.y or 0)

	elseif widget and widget.Hide then
		widget:Hide()
	end

end



------------------------------------------------------------------------------
-- Widget Activation
------------------------------------------------------------------------------
local function OnInitializeWidgets(extended, configTable)

	local EnableClassWidget = (LocalVars.ClassEnemyIcon or LocalVars.ClassPartyIcon)
	local EnableTotemWidget = LocalVars.WidgetTotemIcon
	local EnableComboWidget = LocalVars.WidgetComboPoints
	local EnableThreatWidget = LocalVars.WidgetThreatIndicator
	local EnableAuraWidget = LocalVars.WidgetDebuff
	local EnableAbsorbWidget = LocalVars.WidgetAbsorbIndicator
	local EnableQuestWidget = LocalVars.WidgetQuestIcon
	local EnableThreatPercentageWidget = LocalVars.WidgetThreatPercentage

	InitWidget( "ClassWidgetHub", extended, configTable.ClassIcon, CreateClassWidget, EnableClassWidget)
	InitWidget( "TotemWidgetHub", extended, configTable.TotemIcon, CreateTotemIconWidget, EnableTotemWidget)
	InitWidget( "ComboWidgetHub", extended, configTable.ComboWidget, CreateComboPointWidget, EnableComboWidget)
	InitWidget( "ThreatWidgetHub", extended, configTable.ThreatLineWidget, CreateThreatLineWidget, EnableThreatWidget)
	InitWidget( "AbsorbWidgetHub", extended, configTable.AbsorbWidget, CreateAbsorbWidget, EnableAbsorbWidget)
	InitWidget( "QuestWidgetHub", extended, configTable.QuestWidget, CreateQuestWidget, EnableQuestWidget)
	InitWidget( "ThreatPercentageWidgetHub", extended, configTable.ThreatPercentageWidget, CreateThreatPercentageWidget, EnableThreatPercentageWidget)

	if EnableComboWidget and configTable.DebuffWidgetPlus then
		InitWidget( "AuraWidgetHub", extended, configTable.DebuffWidgetPlus, CreateAuraWidget, EnableAuraWidget)
	else
		InitWidget( "AuraWidgetHub", extended, configTable.DebuffWidget, CreateAuraWidget, EnableAuraWidget)
	end

end

local function OnContextUpdateDelegate(extended, unit)
	local widgets = extended.widgets

	if LocalVars.WidgetComboPoints and widgets.ComboWidgetHub then
		widgets.ComboWidgetHub:UpdateContext(unit) end

	if LocalVars.WidgetThreatIndicator and widgets.ThreatWidgetHub then
		widgets.ThreatWidgetHub:UpdateContext(unit) end		-- Tug-O-Threat

	if LocalVars.WidgetDebuff and widgets.AuraWidgetHub then
		widgets.AuraWidgetHub:UpdateContext(unit) end

	if LocalVars.WidgetDebuff and widgets.AuraWidget then
		widgets.AuraWidget:UpdateContext(unit) end
	
	if LocalVars.WidgetAbsorbIndicator and widgets.AbsorbWidgetHub then
		widgets.AbsorbWidgetHub:UpdateContext(unit) end

	if LocalVars.WidgetThreatPercentage and widgets.ThreatPercentageWidgetHub then
		widgets.ThreatPercentageWidgetHub:UpdateContext(unit) end
end

local function OnUpdateDelegate(extended, unit)
	local widgets = extended.widgets

	if widgets.ClassWidgetHub and ( (LocalVars.ClassEnemyIcon and unit.reaction ~= "FRIENDLY") or (LocalVars.ClassPartyIcon and unit.reaction == "FRIENDLY")) then
		widgets.ClassWidgetHub:Update(unit, LocalVars.ClassPartyIcon)
	end

	if widgets.QuestWidgetHub and LocalVars.WidgetQuestIcon then
		widgets.QuestWidgetHub:Update(unit)
	end

	if LocalVars.WidgetTotemIcon and widgets.TotemWidgetHub then
		widgets.TotemWidgetHub:Update(unit)
	end
end


------------------------------------------------------------------------------
-- Local Variable
------------------------------------------------------------------------------

local function OnVariableChange(vars)

	LocalVars = vars

	if LocalVars.WidgetDebuff then
		NeatPlatesWidgets:EnableAuraWatcher()
		NeatPlatesWidgets.SetAuraFilter(DebuffFilter)
	else NeatPlatesWidgets:DisableAuraWatcher() end

	if true then
		NeatPlatesWidgets.SetEmphasizedAuraFilter(EmphasizedFilter, LocalVars.EmphasizedUnique)
	end
	
	if LocalVars.WidgetAbsorbIndicator then
		NeatPlatesWidgets.SetAbsorbType(LocalVars.WidgetAbsorbMode, LocalVars.WidgetAbsorbUnits)
	end

	if LocalVars.WidgetComboPoints then
		NeatPlatesWidgets.SetComboPointsStyle(LocalVars.WidgetComboPointsStyle);
	end

	if LocalVars.WidgetPandemic then
		NeatPlatesWidgets.SetPandemic(LocalVars.WidgetPandemic, LocalVars.ColorPandemic)
	end

	if LocalVars.WidgetPandemic or LocalVars.WidgetBuffPurgeable or LocalVars.WidgetBuffEnrage then
		NeatPlatesWidgets.SetBorderTypes(LocalVars.BorderPandemic, LocalVars.BorderBuffPurgeable, LocalVars.BorderBuffEnrage)
	end
end
HubData.RegisterCallback(OnVariableChange)


------------------------------------------------------------------------------
-- Add References
------------------------------------------------------------------------------

NeatPlatesHubFunctions.OnUpdate = OnUpdateDelegate
NeatPlatesHubFunctions.OnInitializeWidgets = OnInitializeWidgets
NeatPlatesHubFunctions.OnContextUpdate = OnContextUpdateDelegate
NeatPlatesHubFunctions._WidgetDebuffFilter = DebuffFilter






