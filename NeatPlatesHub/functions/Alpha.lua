
local AddonName, HubData = ...;
local LocalVars = NeatPlatesHubDefaults
local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")


------------------------------------------------------------------------------
-- References
------------------------------------------------------------------------------
local InCombatLockdown = InCombatLockdown
local GetFriendlyThreat = NeatPlatesUtility.GetFriendlyThreat
local IsOffTanked = NeatPlatesHubFunctions.IsOffTanked
local IsTankingAuraActive = NeatPlatesWidgets.IsPlayerTank
local IsHealer = function() return false end
local IsAuraShown = function() return false end
local UnitFilter = NeatPlatesHubFunctions.UnitFilter
local IsPartyMember = NeatPlatesUtility.IsPartyMember
local function DummyFunction() end

------------------------------------------------------------------------------
-- Opacity / Alpha
------------------------------------------------------------------------------

-- By Low Health
local function AlphaFunctionByLowHealth(unit)
	if unit.health/unit.healthmax < LocalVars.LowHealthThreshold then return LocalVars.OpacitySpotlight end
end

-- By Threat (High)
local function AlphaFunctionByThreatHigh (unit)
	if InCombatLockdown() and unit.reaction ~= "FRIENDLY" then
		if unit.threatValue > 1 and unit.health > 0 then return LocalVars.OpacitySpotlight end
	elseif LocalVars.ColorShowPartyAggro and unit.reaction == "FRIENDLY" then
		if GetFriendlyThreat(unit.unitid) then return LocalVars.OpacitySpotlight end
	end
end

-- Tank Mode
local function AlphaFunctionByThreatLow (unit)
	if InCombatLockdown() and unit.reaction ~= "FRIENDLY" then
		if IsOffTanked(unit) then return end
		if unit.threatValue < 2 and unit.health > 0 then return LocalVars.OpacitySpotlight end
	elseif LocalVars.ColorShowPartyAggro and unit.reaction == "FRIENDLY" then
		if GetFriendlyThreat(unit.unitid) then return LocalVars.OpacitySpotlight end
	end
end

local function AlphaFunctionByMouseover(unit)
	if unit.isMouseover then return LocalVars.OpacitySpotlight end
end

local function AlphaFunctionByEnemy(unit)
	if unit.reaction ~= "FRIENDLY" then return LocalVars.OpacitySpotlight end
end

local function AlphaFunctionByNPC(unit)
	if unit.type == "NPC" then return LocalVars.OpacitySpotlight end
end

local function AlphaFunctionByRaidIcon(unit)
	if unit.isMarked then return LocalVars.OpacitySpotlight end
end

local function AlphaFunctionByActive(unit)
	if (unit.health < unit.healthmax) or (unit.threatValue > 1) or unit.isInCombat or unit.isMarked then return LocalVars.OpacitySpotlight end
end

local function AlphaFunctionByDamaged(unit)
	if (unit.health < unit.healthmax) or unit.isMarked then return LocalVars.OpacitySpotlight end
end

local function AlphaFunctionByActiveAuras(unit)
	local widget = unit.frame.widgets.DebuffWidget
	--local widget = NeatPlatesWidgets.GetAuraWidgetByGUID(unit.guid)
	if IsAuraShown(widget) then return LocalVars.OpacitySpotlight end
end

-- By Enemy Healer
local function AlphaFunctionByEnemyHealer(unit)
	if unit.reaction == "HOSTILE" and unit.type == "PLAYER" then
		--if NeatPlatesCache and NeatPlatesCache.HealerListByName[unit.rawName] then
		if IsHealer(unit.rawName) then
			return LocalVars.OpacitySpotlight
		end
	end
end

-- By Threat (Auto Detect)
local function AlphaFunctionByThreat(unit)
		if unit.reaction == "NEUTRAL" and unit.threatValue < 2 then return AlphaFunctionByThreatHigh(unit) end

		if (LocalVars.ThreatWarningMode == "Auto" and IsTankingAuraActive())
			or LocalVars.ThreatWarningMode == "Tank" then
				return AlphaFunctionByThreatLow(unit)	-- tank mode
		else return AlphaFunctionByThreatHigh(unit) end
end


local function AlphaFunctionGroupMembers(unit)
	if IsPartyMember(unit.unitid) then return LocalVars.OpacitySpotlight end
end


local function AlphaFunctionByPlayers(unit)
	if unit.type == "PLAYER" then return LocalVars.OpacitySpotlight end
end


--  Hub functions
local AddHubFunction = NeatPlatesHubHelpers.AddHubFunction

local AlphaFunctionsEnemy = {}

NeatPlatesHubDefaults.EnemyAlphaSpotlightMode = "ByThreat"			-- Sets the default function
AddHubFunction(AlphaFunctionsEnemy, NeatPlatesHubMenus.EnemyOpacityModes, DummyFunction, L["None"], "None")
AddHubFunction(AlphaFunctionsEnemy, NeatPlatesHubMenus.EnemyOpacityModes, AlphaFunctionByThreat, L["By Threat"], "ByThreat")
AddHubFunction(AlphaFunctionsEnemy, NeatPlatesHubMenus.EnemyOpacityModes, AlphaFunctionByLowHealth, L["On Low-Health Units"], "OnLowHealth")
AddHubFunction(AlphaFunctionsEnemy, NeatPlatesHubMenus.EnemyOpacityModes, AlphaFunctionByNPC, L["On NPC"], "OnNPC")
--AddHubFunction(AlphaFunctionsEnemy, NeatPlatesHubMenus.EnemyOpacityModes, AlphaFunctionByActiveAuras, "On Active Auras", "OnActiveAura")
AddHubFunction(AlphaFunctionsEnemy, NeatPlatesHubMenus.EnemyOpacityModes, AlphaFunctionByEnemyHealer, L["On Enemy Healers"], "OnEnemyHealer")
AddHubFunction(AlphaFunctionsEnemy, NeatPlatesHubMenus.EnemyOpacityModes, AlphaFunctionByActive, L["On Active/Damaged Units"], "OnActiveUnits")


local AlphaFunctionsFriendly = {}

NeatPlatesHubDefaults.FriendlyAlphaSpotlightMode = "None"			-- Sets the default function
AddHubFunction(AlphaFunctionsFriendly, NeatPlatesHubMenus.FriendlyOpacityModes, DummyFunction, L["None"], "None")
AddHubFunction(AlphaFunctionsFriendly, NeatPlatesHubMenus.FriendlyOpacityModes, AlphaFunctionByLowHealth, L["On Low-Health Units"], "OnLowHealth")
AddHubFunction(AlphaFunctionsFriendly, NeatPlatesHubMenus.FriendlyOpacityModes, AlphaFunctionGroupMembers, L["On Party Members"], "OnGroupMembers")
AddHubFunction(AlphaFunctionsFriendly, NeatPlatesHubMenus.FriendlyOpacityModes, AlphaFunctionByPlayers, L["On Players"], "OnPlayers")
AddHubFunction(AlphaFunctionsFriendly, NeatPlatesHubMenus.FriendlyOpacityModes, AlphaFunctionByDamaged, L["On Damaged Units"], "OnActiveUnits")



-- Alpha Functions Listed by Role order: Damage, Tank, Heal
local AlphaFunctions = {AlphaFunctionsDamage, AlphaFunctionsTank}

local function Diminish(num)
	if num == 1 then return 1
	elseif num < .3 then return num*.60
	elseif num < .6 then return num*.70
	else return num * .80 end
end

local function AlphaDelegate(...)
	local unit = ...
	local alpha

	if not unit or not unit.unitid then return LocalVars.OpacitySpotlight end

	if LocalVars.UnitSpotlightOpacityEnable and LocalVars.UnitSpotlightLookup[unit.name] then
		return LocalVars.UnitSpotlightOpacity
	end

	if (unit.isTarget or (LocalVars.FocusAsTarget and unit.isFocus)) then return Diminish(LocalVars.OpacityTarget)
	--elseif unit.isCasting and unit.reaction == "HOSTILE" and LocalVars.OpacitySpotlightSpell then alpha = LocalVars.OpacitySpotlight
	elseif unit.isCasting and LocalVars.OpacitySpotlightSpell then alpha = LocalVars.OpacitySpotlight
	elseif unit.isMouseover and LocalVars.OpacitySpotlightMouseover then alpha = LocalVars.OpacitySpotlight
	elseif unit.isMarked and LocalVars.OpacitySpotlightRaidMarked then alpha = LocalVars.OpacitySpotlight

	else
		-- Filter
		if UnitFilter(unit) then
			alpha = LocalVars.OpacityFiltered
		-- Spotlight
		else
			local func = DummyFunction

			if unit.reaction == "FRIENDLY" then
				func = AlphaFunctionsFriendly[LocalVars.FriendlyAlphaSpotlightMode or NeatPlatesHubDefaults.FriendlyAlphaSpotlightMode] or func
			else
				func = AlphaFunctionsEnemy[LocalVars.EnemyAlphaSpotlightMode or NeatPlatesHubDefaults.EnemyAlphaSpotlightMode] or func
			end

			alpha = func(...)
		end
	end

	if not (alpha or UnitExists("target") ) and LocalVars.OpacityFullNoTarget then return Diminish(LocalVars.OpacityTarget) end

	--print("Alpha", alpha)
	if alpha then return Diminish(alpha)
	else return Diminish(LocalVars.OpacityNonTarget) end
end

------------------------------------------------------------------------------
-- Local Variable
------------------------------------------------------------------------------

local function OnVariableChange(vars) LocalVars = vars end
HubData.RegisterCallback(OnVariableChange)


------------------------------------------------------------------------------
-- Add References
------------------------------------------------------------------------------
NeatPlatesHubFunctions.SetAlpha = AlphaDelegate

