
local AddonName, HubData = ...;
local LocalVars = TidyPlatesContHubDefaults


------------------------------------------------------------------------------
-- References
------------------------------------------------------------------------------
local InCombatLockdown = InCombatLockdown
local GetFriendlyThreat = TidyPlatesContUtility.GetFriendlyThreat
local IsOffTanked = TidyPlatesContHubFunctions.IsOffTanked
local IsTankingAuraActive = TidyPlatesContWidgets.IsPlayerTank
local IsHealer = function() return false end
local IsAuraShown = function() return false end
local UnitFilter = TidyPlatesContHubFunctions.UnitFilter
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
	--local widget = TidyPlatesContWidgets.GetAuraWidgetByGUID(unit.guid)
	if IsAuraShown(widget) then return LocalVars.OpacitySpotlight end
end

-- By Enemy Healer
local function AlphaFunctionByEnemyHealer(unit)
	if unit.reaction == "HOSTILE" and unit.type == "PLAYER" then
		--if TidyPlatesContCache and TidyPlatesContCache.HealerListByName[unit.rawName] then
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
	local unitid = unit.unitid
	if UnitInParty(unitid) then return LocalVars.OpacitySpotlight end
end


local function AlphaFunctionByPlayers(unit)
	if unit.type == "PLAYER" then return LocalVars.OpacitySpotlight end
end


--  Hub functions
local AddHubFunction = TidyPlatesContHubHelpers.AddHubFunction

local AlphaFunctionsEnemy = {}

TidyPlatesContHubDefaults.EnemyAlphaSpotlightMode = "ByThreat"			-- Sets the default function
AddHubFunction(AlphaFunctionsEnemy, TidyPlatesContHubMenus.EnemyOpacityModes, DummyFunction, "None", "None")
AddHubFunction(AlphaFunctionsEnemy, TidyPlatesContHubMenus.EnemyOpacityModes, AlphaFunctionByThreat, "By Threat", "ByThreat")
AddHubFunction(AlphaFunctionsEnemy, TidyPlatesContHubMenus.EnemyOpacityModes, AlphaFunctionByLowHealth, "On Low-Health Units", "OnLowHealth")
AddHubFunction(AlphaFunctionsEnemy, TidyPlatesContHubMenus.EnemyOpacityModes, AlphaFunctionByNPC, "On NPC", "OnNPC")
--AddHubFunction(AlphaFunctionsEnemy, TidyPlatesContHubMenus.EnemyOpacityModes, AlphaFunctionByActiveAuras, "On Active Auras", "OnActiveAura")
AddHubFunction(AlphaFunctionsEnemy, TidyPlatesContHubMenus.EnemyOpacityModes, AlphaFunctionByEnemyHealer, "On Enemy Healers", "OnEnemyHealer")
AddHubFunction(AlphaFunctionsEnemy, TidyPlatesContHubMenus.EnemyOpacityModes, AlphaFunctionByActive, "On Active/Damaged Units", "OnActiveUnits")


local AlphaFunctionsFriendly = {}

TidyPlatesContHubDefaults.FriendlyAlphaSpotlightMode = "None"			-- Sets the default function
AddHubFunction(AlphaFunctionsFriendly, TidyPlatesContHubMenus.FriendlyOpacityModes, DummyFunction, "None", "None")
AddHubFunction(AlphaFunctionsFriendly, TidyPlatesContHubMenus.FriendlyOpacityModes, AlphaFunctionByLowHealth, "On Low-Health Units", "OnLowHealth")
AddHubFunction(AlphaFunctionsFriendly, TidyPlatesContHubMenus.FriendlyOpacityModes, AlphaFunctionGroupMembers, "On Party Members", "OnGroupMembers")
AddHubFunction(AlphaFunctionsFriendly, TidyPlatesContHubMenus.FriendlyOpacityModes, AlphaFunctionByPlayers, "On Players", "OnPlayers")
AddHubFunction(AlphaFunctionsFriendly, TidyPlatesContHubMenus.FriendlyOpacityModes, AlphaFunctionByDamaged, "On Damaged Units", "OnActiveUnits")



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
				func = AlphaFunctionsFriendly[LocalVars.FriendlyAlphaSpotlightMode or TidyPlatesContHubDefaults.FriendlyAlphaSpotlightMode] or func
			else
				func = AlphaFunctionsEnemy[LocalVars.EnemyAlphaSpotlightMode or TidyPlatesContHubDefaults.EnemyAlphaSpotlightMode] or func
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
TidyPlatesContHubFunctions.SetAlpha = AlphaDelegate

