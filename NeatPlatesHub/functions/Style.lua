
local AddonName, HubData = ...;
local LocalVars = NeatPlatesHubDefaults

------------------------------------------------------------------------------
-- References
------------------------------------------------------------------------------

local InCombatLockdown = InCombatLockdown
local GetFriendlyThreat = NeatPlatesUtility.GetFriendlyThreat
local IsOffTanked = NeatPlatesHubFunctions.IsOffTanked
local IsTankingAuraActive = NeatPlatesWidgets.IsPlayerTank
local IsHealer = NeatPlatesUtility.IsHealer
local IsAuraShown = NeatPlatesWidgets.IsAuraShown


local function IsUnitActive(unit)
	local unitid = unit.unitid

	if unit.type == "NPC" then
		--(unit.threatValue > 1)
		--if ((not unit.isTapped) and UnitExists(unitid.."target")) or unit.isMarked then
		if ((not unit.isTapped) and unit.isInCombat) or unit.isMarked then
			return true
		end
	else	-- unit.type == "PLAYER"
		if (unit.health < unit.healthmax) then
			return true
		end
	end

end


------------------------------------------------------------------------------------
-- Style
------------------------------------------------------------------------------------

local BARMODE, HEADLINEMODE = 1, 2

-- Bar Always
local function StyleBarAlways(unit)
		return BARMODE
end

-- Headline Always
local function StyleHeadlineAlways(unit)
	return HEADLINEMODE
end

-- Bars during combat
local function StyleBarsInCombat(unit)
	if InCombatLockdown() then
		return BARMODE
	else return HEADLINEMODE end
end

-- Bars when unit is active or damaged
local function StyleBarsOnActive(unit)
	if (unit.health < unit.healthmax) or (unit.threatValue > 1) or unit.isMarked then 	--or unit.isInCombat
		return BARMODE
	end
	return HEADLINEMODE
end

-- player chars
local function StyleBarsOnPlayers(unit)

	if unit.type == "PLAYER" then
		return BARMODE
	else return HEADLINEMODE end
end

-- Current Target
local function StyleBarsOnTarget(unit)
	if (unit.isTarget or (LocalVars.FocusAsTarget and unit.isFocus)) == true then
		return BARMODE
	else return HEADLINEMODE end
end

-- low threat
local function StyleBarsOnLowThreat(unit)
	if InCombatLockdown() and unit.reaction ~= "FRIENDLY" then
		if IsOffTanked(unit) then return HEADLINEMODE end
		if unit.threatValue < 2 and unit.health > 0 then return BARMODE end
	elseif LocalVars.ColorShowPartyAggro and unit.reaction == "FRIENDLY" then
		if GetFriendlyThreat(unit.unitid) == true then return BARMODE end
	end
	return HEADLINEMODE
end

--[[
local AddHubFunction = NeatPlatesHubHelpers.AddHubFunction

local StyleModeFunctions = {}

NeatPlatesHubDefaults.StyleEnemyMode = "ALLBARS"			-- Sets the default function
NeatPlatesHubDefaults.StyleFriendlyMode = "BARSPLAYERS"			-- Sets the default function

AddHubFunction(StyleModeFunctions, NeatPlatesHubMenus.StyleModes, StyleBarAlways, "Default Bars", "ALLBARS")
AddHubFunction(StyleModeFunctions, NeatPlatesHubMenus.StyleModes, StyleHeadlineAlways, "Headline Always (No Health Bar)", "ALLHEADLINE")
AddHubFunction(StyleModeFunctions, NeatPlatesHubMenus.StyleModes, StyleBarsInCombat, "Out-of-Combat - Health Bars during Combat", "BARSCOMBAT")
AddHubFunction(StyleModeFunctions, NeatPlatesHubMenus.StyleModes, StyleBarsOnActive, "On Idle units - Health Bars on Active/Damaged/Marked Units", "BARSACTIVE")
AddHubFunction(StyleModeFunctions, NeatPlatesHubMenus.StyleModes, StyleBarsOnPlayers, "On NPCs - Health Bars on Players", "BARSPLAYERS")
AddHubFunction(StyleModeFunctions, NeatPlatesHubMenus.StyleModes, StyleBarsOnTarget, "On Non-Targets - Health Bar on Current Target", "BARSTARGET")
AddHubFunction(StyleModeFunctions, NeatPlatesHubMenus.StyleModes, StyleBarsOnLowThreat, "On Aggroed units - Health Bars on Low Threat (Tank Mode)", "BARSLOWTHREAT")
--]]




local function StyleIndexDelegate(unit)
	local func
	--if unit.reaction == "FRIENDLY" then func = StyleModeFunctions[LocalVars.StyleFriendlyMode or 0] or StyleBarAlways
	--else func = StyleModeFunctions[LocalVars.StyleEnemyMode or 0] or StyleBarAlways end

	return func(unit)
end


------------------------------------------------------------------------------------
-- Binary Plate Styles
------------------------------------------------------------------------------------

	--[[
	-- Low Threat
	if InCombatLockdown() and unit.reaction ~= "FRIENDLY" then
		if IsOffTanked(unit) then return "NameOnly" end
		if unit.threatValue < 2 and unit.health > 0 then return "Default" end
	elseif LocalVars.ColorShowPartyAggro and unit.reaction == "FRIENDLY" then
		if GetFriendlyThreat(unit.unitid) == true then return "Default" end
	end
	return "NameOnly"
	--]]

--[[
Threat Value
0 - Unit has less than 100% raw threat (default UI shows no indicator)
1 - Unit has 100% or higher raw threat but isn't mobUnit's primary target (default UI shows yellow indicator)
2 - Unit is mobUnit's primary target, and another unit has 100% or higher raw threat (default UI shows orange indicator)
3 - Unit is mobUnit's primary target, and no other unit has 100% or higher raw threat (default UI shows red indicator)
--]]



local function StyleNameDelegate(unit)

	if LocalVars.StyleForceBarsOnTargets and (unit.isTarget or (LocalVars.FocusAsTarget and unit.isFocus)) then return "Default" end
	if LocalVars.StyleHeadlineOutOfCombat and (not InCombatLockdown()) then return "NameOnly" end
	if LocalVars.StyleHeadlineMiniMobs and unit.isMini then return "NameOnly" end

	-- Friendly and Hostile
	if unit.reaction == "FRIENDLY" then
		if IsUnitActive(unit) and LocalVars.StyleFriendlyBarsOnActive then return "Default"
		elseif unit.isElite and LocalVars.StyleFriendlyBarsOnElite then return "Default"
		elseif unit.type == "PLAYER" and LocalVars.StyleFriendlyBarsOnPlayers then
			if unit.isPVPFlagged and LocalVars.StyleFriendlyBarsOnPlayersExcludeFlagged then
				return "NameOnly"
			elseif LocalVars.StyleFriendlyBarsOnPlayersExcludeNonFlagged then
				return "NameOnly"
			end
			return "Default"
		elseif unit.type ~= "PLAYER" and LocalVars.StyleFriendlyBarsOnNPC then
			if LocalVars.StyleFriendlyBarsInstanceMode and IsInInstance() then return "NameOnly"
			elseif unit.isPet and LocalVars.StyleFriendlyBarsNoMinions then return "NameOnly"
			elseif unit.isTotem and LocalVars.StyleFriendlyBarsNoTotem then return "NameOnly"
			else return "Default" end
		end
	elseif unit.reaction == "NEUTRAL" then
		-- if IsUnitActive(unit) and LocalVars.StyleEnemyBarsOnActive then return "Default" end
		--if unit.threatValue > 1 then return "Default"
		if LocalVars.StyleHeadlineNeutral then return "NameOnly"
		elseif IsUnitActive(unit) and LocalVars.StyleEnemyBarsOnActive then return "Default"
		elseif LocalVars.StyleEnemyBarsOnNPC then return "Default"
		end
	else
		if IsUnitActive(unit) and LocalVars.StyleEnemyBarsOnActive then return "Default"
		elseif unit.isElite and LocalVars.StyleEnemyBarsOnElite then return "Default"
		elseif unit.type == "PLAYER" and LocalVars.StyleEnemyBarsOnPlayers then
			if unit.isPVPFlagged and LocalVars.StyleEnemyBarsOnPlayersExcludeFlagged then
				return "NameOnly"
			elseif LocalVars.StyleEnemyBarsOnPlayersExcludeNonFlagged then
				return "NameOnly"
			end
			return "Default"
		elseif unit.type ~= "PLAYER" and LocalVars.StyleEnemyBarsOnNPC then
			if LocalVars.StyleEnemyBarsInstanceMode and IsInInstance() then return "NameOnly"
			elseif unit.isPet and LocalVars.StyleEnemyBarsNoMinions then return "NameOnly"
			elseif unit.isTotem and LocalVars.StyleEnemyBarsNoTotem then return "NameOnly"
			else return "Default" end
		end
	end

	-- Otherwise...
	return "NameOnly"
end


--[[
------------------------------------------------------------------
-- Experimental Style Delegate
------------------------------------------------------------------

local function IsThereText(unit)
	local text = CustomTextBinaryDelegate(unit)
	if text and text ~= "" then return true end
end

local function SetStyleTrinaryDelegate(unit)
	local style = StyleDelegate(unit)
	local widget = unit.frame.widgets.DebuffWidget

	if style == 2 then
		if IsThereText(unit) then
			return "NameOnly"
		else
			return "NameOnly-NoDescription"
		end
	elseif IsAuraShown(widget) then
		return "Default"
	else
		return "Default-NoAura"
	end
end
--]]


------------------------------------------------------------------------------
-- Local Variable
------------------------------------------------------------------------------

local function OnVariableChange(vars) LocalVars = vars end
HubData.RegisterCallback(OnVariableChange)


------------------------------------------------------------------------------
-- Add References
------------------------------------------------------------------------------
NeatPlatesHubFunctions.SetMultistyle = StyleIndexDelegate
NeatPlatesHubFunctions.SetStyleBinary = StyleNameDelegate
NeatPlatesHubFunctions.SetStyleNamed = StyleNameDelegate
--NeatPlatesHubFunctions.SetStyleTrinary = SetStyleTrinaryDelegate


