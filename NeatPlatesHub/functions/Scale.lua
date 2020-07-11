

local AddonName, HubData = ...;
local LocalVars = NeatPlatesHubDefaults
local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")


------------------------------------------------------------------------------
-- References
------------------------------------------------------------------------------
local InCombatLockdown = InCombatLockdown
local GetFriendlyThreat = NeatPlatesUtility.GetFriendlyThreat
local IsOffTanked = NeatPlatesHubFunctions.IsOffTanked
local ThreatExceptions = NeatPlatesHubFunctions.ThreatExceptions
local IsTankingAuraActive = NeatPlatesWidgets.IsPlayerTank
local IsHealer = NeatPlatesUtility.IsHealer
local UnitFilter = NeatPlatesHubFunctions.UnitFilter
local IsAuraShown = NeatPlatesWidgets.IsAuraShown
local function DummyFunction() end

------------------------------------------------------------------------------
-- Scale
------------------------------------------------------------------------------

local MiniMobScale = .7

-- By Low Health
local function ScaleFunctionByLowHealth(unit)
	if unit.health/unit.healthmax < LocalVars.LowHealthThreshold then return LocalVars.ScaleSpotlight end
end

-- By Elite
local function ScaleFunctionByElite(unit)
	if unit.isElite then return LocalVars.ScaleSpotlight end
end

-- By Target
local function ScaleFunctionByTarget(unit)
	if (unit.isTarget or (LocalVars.FocusAsTarget and unit.isFocus)) then return LocalVars.ScaleSpotlight end
end

-- By Threat (High) DPS Mode
local function ScaleFunctionByThreatHigh(unit)
	if (UnitInParty("player") or UnitExists("pet")) and InCombatLockdown() and unit.reaction ~= "FRIENDLY" and (unit.isInCombat or UnitIsUnit(unit.unitid.."target", "player")) then
		if unit.type == "NPC" and unit.threatValue > 1 and unit.health > 2 then return LocalVars.ScaleSpotlight end
	elseif LocalVars.ColorShowPartyAggro and unit.reaction == "FRIENDLY" then
		if GetFriendlyThreat(unit.unitid) then return LocalVars.ScaleSpotlight end
	end
end

-- By Threat (Low) Tank Mode
local function ScaleFunctionByThreatLow(unit)
	if (UnitInParty("player") or UnitExists("pet")) and InCombatLockdown() and unit.reaction ~= "FRIENDLY" and (unit.isInCombat or UnitIsUnit(unit.unitid.."target", "player")) then
		if IsOffTanked(unit) then return end
		if unit.type == "NPC" and unit.health > 2 and unit.threatValue < 2 then return LocalVars.ScaleSpotlight end
	elseif LocalVars.ColorShowPartyAggro and unit.reaction == "FRIENDLY" then
		if GetFriendlyThreat(unit.unitid) then return LocalVars.ScaleSpotlight end
	end
end

-- By Debuff Widget
local function ScaleFunctionByActiveDebuffs(unit, frame)
	local widget = unit.frame.widgets.DebuffWidget
	--local widget = NeatPlatesWidgets.GetAuraWidgetByGUID(unit.guid)
	if IsAuraShown(widget) then return LocalVars.ScaleSpotlight end
end

-- By Enemy
local function ScaleFunctionByEnemy(unit)
	if unit.reaction ~= "FRIENDLY" then return LocalVars.ScaleSpotlight end
end

-- By NPC
local function ScaleFunctionByNPC(unit)
	if unit.type == "NPC" then return LocalVars.ScaleSpotlight end
end

-- By Raid Icon
local function ScaleFunctionByRaidIcon(unit)
	if unit.isMarked then return LocalVars.ScaleSpotlight end
end

-- By Enemy Healer
local function ScaleFunctionByEnemyHealer(unit)
	if unit.reaction == "HOSTILE" and unit.type == "PLAYER" then
		--if NeatPlatesCache and NeatPlatesCache.HealerListByName[unit.rawName] then
		if IsHealer(unit.rawName) then
			return LocalVars.ScaleSpotlight
		end
	end
end

-- By Boss
local function ScaleFunctionByBoss(unit)
	if unit.isBoss and unit.isElite then return LocalVars.ScaleSpotlight end
end

-- By Threat (Auto Detect)
local function ScaleFunctionByThreat(unit)
	if unit.reaction == "NEUTRAL" and unit.threatValue < 2 then return ScaleFunctionByThreatHigh(unit) end
	local isTank = (LocalVars.ThreatWarningMode == "Tank") or (LocalVars.ThreatWarningMode == "Auto" and IsTankingAuraActive())
	local threatException = ThreatExceptions(unit, isTank, true)

	if threatException then
		if threatException == true then
			return
		else
			return LocalVars.ScaleSpotlight
		end
	end

	if isTank then
			return ScaleFunctionByThreatLow(unit)	-- tank mode
	else return ScaleFunctionByThreatHigh(unit) end

end

-- Function List

local ScaleFunctionsUniversal = {}

--[[
local ScaleFunctionsUniversal = { DummyFunction, ScaleFunctionByThreat, ScaleFunctionByElite,
		ScaleFunctionByEnemy,ScaleFunctionByNPC, ScaleFunctionByRaidIcon,
		ScaleFunctionByEnemyHealer, ScaleFunctionByLowHealth, ScaleFunctionByBoss}
--]]


local AddHubFunction = NeatPlatesHubHelpers.AddHubFunction

AddHubFunction(ScaleFunctionsUniversal, NeatPlatesHubMenus.ScaleModes, DummyFunction, L["None"], "None")
AddHubFunction(ScaleFunctionsUniversal, NeatPlatesHubMenus.ScaleModes, ScaleFunctionByThreat, L["By Threat"], "ByThreat")
AddHubFunction(ScaleFunctionsUniversal, NeatPlatesHubMenus.ScaleModes, ScaleFunctionByElite, L["On Elite Units"], "OnElite")
AddHubFunction(ScaleFunctionsUniversal, NeatPlatesHubMenus.ScaleModes, ScaleFunctionByEnemy, L["On Enemy Units"], "OnHostile")
AddHubFunction(ScaleFunctionsUniversal, NeatPlatesHubMenus.ScaleModes, ScaleFunctionByNPC, L["On NPCs"], "OnNPC")
AddHubFunction(ScaleFunctionsUniversal, NeatPlatesHubMenus.ScaleModes, ScaleFunctionByRaidIcon, L["On Raid Targets"], "OnMarked")
AddHubFunction(ScaleFunctionsUniversal, NeatPlatesHubMenus.ScaleModes, ScaleFunctionByEnemyHealer, L["On Enemy Healers"], "OnHealers")
AddHubFunction(ScaleFunctionsUniversal, NeatPlatesHubMenus.ScaleModes, ScaleFunctionByLowHealth, L["On Low-Health Units"], "OnLowHealth")
AddHubFunction(ScaleFunctionsUniversal, NeatPlatesHubMenus.ScaleModes, ScaleFunctionByBoss, L["On Bosses"], "OnBosses")
--NeatPlatesHubDefaults.ScaleFunctionMode = 2			-- Sets the default function
NeatPlatesHubDefaults.ScaleFunctionMode = "ByThreat"			-- Sets the default function


local function ScaleDelegate(...)

	local unit = ...
	local scale, filterScale;

	--if LocalVars.UnitSpotlightScaleEnable and LocalVars.UnitSpotlightLookup[unit.name] then
	--	return LocalVars.UnitSpotlightScale
	--end
	if not unit or not unit.unitid then return LocalVars.ScaleStandard end

	-- Get scale from scale function
	local func = ScaleFunctionsUniversal[LocalVars.ScaleFunctionMode] or DummyFunction
	if func then scale = func(...) end

	-- Filter
	if (LocalVars.FilterScaleLock or (not (unit.isTarget or (LocalVars.FocusAsTarget and unit.isFocus) ) ) ) and UnitFilter(unit) then
		filterScale = LocalVars.ScaleFiltered
	end

	if (LocalVars.ScaleTargetSpotlight and (unit.isTarget or (LocalVars.FocusAsTarget and unit.isFocus))) then scale = LocalVars.ScaleSpotlight
	elseif (LocalVars.ScaleMouseoverSpotlight and unit.isMouseover) then scale = LocalVars.ScaleSpotlight
	elseif LocalVars.ScaleIgnoreNonEliteUnits and (not unit.isElite) then scale = nil
	elseif LocalVars.ScaleIgnoreNeutralUnits and unit.reaction == "NEUTRAL" then scale = nil
	elseif LocalVars.ScaleIgnoreInactive and not ( (unit.health < unit.healthmax) or (unit.isInCombat or UnitIsUnit(unit.unitid.."target", "player") or unit.threatValue > 0) or (unit.isCasting == true) ) then scale = nil
	elseif LocalVars.ScaleCastingSpotlight and unit.reaction == "HOSTILE" and unit.isCasting then scale = LocalVars.ScaleSpotlight
	--elseif LocalVars.ScaleMiniMobs and unit.isMini then
	--	scale = MiniMobScale
	end

	if(filterScale and (LocalVars.FilterScaleLock or scale == nil)) then
		return filterScale
	else
		return scale or LocalVars.ScaleStandard
	end
end


------------------------------------------------------------------------------
-- Local Variable
------------------------------------------------------------------------------

local function OnVariableChange(vars)
	LocalVars = vars
end
HubData.RegisterCallback(OnVariableChange)


------------------------------------------------------------------------------
-- Add References
------------------------------------------------------------------------------
NeatPlatesHubFunctions.SetScale = ScaleDelegate

