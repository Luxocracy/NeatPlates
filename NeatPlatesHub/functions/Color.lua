
local AddonName, HubData = ...;
local LocalVars = NeatPlatesHubDefaults
local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")


------------------------------------------------------------------
-- Color Definitions
------------------------------------------------------------------
local RaidIconColors = {
	["STAR"] = {r = 251/255, g = 240/255, b = 85/255,},
	["MOON"] = {r = 100/255, g = 180/255, b = 255/255,},
	["CIRCLE"] = {r = 230/255, g = 116/255, b = 11/255,},
	["SQUARE"] = {r = 0, g = 174/255, b = 1,},
	["DIAMOND"] = {r = 207/255, g = 49/255, b = 225/255,},
	--["CROSS"] = {r = 195/255, g = 38/255, b = 23/255,},
	["CROSS"] = {r = 255/255, g = 130/255, b = 100/255,},
	["TRIANGLE"] = {r = 31/255, g = 194/255, b = 27/255,},
	["SKULL"] = {r = 244/255, g = 242/255, b = 240/255,},
}

local RaidClassColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local ReactionColors = HubData.Colors.ReactionColors
local NameReactionColors = HubData.Colors.NameReactionColors

------------------------------------------------------------------
-- References
------------------------------------------------------------------
local GetFriendlyThreat = NeatPlatesUtility.GetFriendlyThreat
local IsFriend = NeatPlatesUtility.IsFriend
local IsHealer = NeatPlatesUtility.IsHealer
local IsGuildmate = NeatPlatesUtility.IsGuildmate
local IsPartyMember = NeatPlatesUtility.IsPartyMember
local HexToRGB = NeatPlatesUtility.HexToRGB

local IsOffTanked = NeatPlatesHubFunctions.IsOffTanked
local ThreatExceptions = NeatPlatesHubFunctions.ThreatExceptions
local IsTankingAuraActive = NeatPlatesWidgets.IsPlayerTank
local InCombatLockdown = InCombatLockdown
local StyleDelegate = NeatPlatesHubFunctions.SetStyleNamed
local AddHubFunction = NeatPlatesHubHelpers.AddHubFunction

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Health Bar Color
------------------------------------------------------------------------------
------------------------------------------------------------------------------
local tempColor = {}
local function DummyFunction() return end

-- By Low Health
local function ColorFunctionByHealth(unit)
	local health = unit.health/unit.healthmax
	if health > LocalVars.HighHealthThreshold then return LocalVars.ColorHighHealth
	elseif health > LocalVars.LowHealthThreshold then return LocalVars.ColorMediumHealth
	else return LocalVars.ColorLowHealth end
end

HubData.Functions.ColorFunctionByHealth = ColorFunctionByHealth



local function ColorFunctionBlack()
	return HubData.Colors.Black
end


--[[
unit.threatValue
	0 - Unit has less than 100% raw threat (default UI shows no indicator)
	1 - Unit has 100% or higher raw threat but isn't mobUnit's primary target (default UI shows yellow indicator)
	2 - Unit is mobUnit's primary target, and another unit has 100% or higher raw threat (default UI shows orange indicator)
	3 - Unit is mobUnit's primary target, and no other unit has 100% or higher raw threat (default UI shows red indicator)

	ColorThreatWarning		Warning
	ColorThreatTransition	Transition
	ColorThreatSafe	Safe
--]]

local function ColorFunctionByReaction(unit)
	if unit.unitid and unit.reaction == "FRIENDLY" and unit.type == "PLAYER" then
		if IsGuildmate(unit.unitid) then return LocalVars.ColorGuildMember
		elseif IsFriend(unit.unitid) then return LocalVars.ColorGuildMember 
		elseif IsPartyMember(unit.unitid) then return LocalVars.ColorPartyMember end
	end

	return ReactionColors[unit.reaction][unit.type]
end

--"By Class"
local function ColorFunctionByClass(unit)
	local classColor = RaidClassColors[unit.class]
	--print(unit.name, unit.class, classColor.r)
	if classColor then

		return classColor
	else
		return ColorFunctionByReaction(unit)
	end
end

--[[
0 - Unit has less than 100% raw threat (default UI shows no indicator)
1 - Unit has 100% or higher raw threat but isn't mobUnit's primary target (default UI shows yellow indicator)
2 - Unit is mobUnit's primary target, and another unit has 100% or higher raw threat (default UI shows orange indicator)
3 - Unit is mobUnit's primary target, and no other unit has 100% or higher raw threat (default UI shows red indicator)
--]]

local function ColorFunctionDamage(unit, glow)
	--if IsOffTanked(unit) and not glow then return LocalVars.ColorAttackingOtherTank end

	if unit.threatValue > 1 then return LocalVars.ColorThreatWarning				-- When player is unit's target		-- Warning
	elseif unit.threatValue == 1 then return LocalVars.ColorThreatTransition											-- Transition
	else return LocalVars.ColorThreatSafe end																	-- Safe
end

local function ColorFunctionRawTank(unit, glow)
	if unit.threatValue > 2 then
		return LocalVars.ColorThreatWarning							-- When player is solid target, ie. Safe
	else
		if IsOffTanked(unit) and not glow then return LocalVars.ColorAttackingOtherTank		-- When unit is tanked by another

		elseif unit.threatValue == 2 then return LocalVars.ColorThreatTransition				-- Transition
		else return LocalVars.ColorThreatSafe end										-- Warning
	end
end

local function ColorFunctionTankSwapColors(unit, glow)
	if unit.threatValue > 2 then
		return LocalVars.ColorThreatSafe				-- When player is solid target		-- ColorThreatSafe = Safe Color... which means that a Tank would want it to be Safe
	else
		if IsOffTanked(unit) and not glow then return LocalVars.ColorAttackingOtherTank			-- When unit is tanked by another
		elseif unit.threatValue == 2 then return LocalVars.ColorThreatTransition					-- Transition
		else return LocalVars.ColorThreatWarning end												-- Warning
	end
end

--[[
Threat Value
0 - Unit has less than 100% raw threat (default UI shows no indicator)
1 - Unit has 100% or higher raw threat but isn't mobUnit's primary target (default UI shows yellow indicator)
2 - Unit is mobUnit's primary target, and another unit has 100% or higher raw threat (default UI shows orange indicator)
3 - Unit is mobUnit's primary target, and no other unit has 100% or higher raw threat (default UI shows red indicator)
--]]


local function ColorFunctionByThreat(unit)
	local classColor = RaidClassColors[unit.class]

	if classColor then
		return classColor
	elseif not UnitInParty("player") and not UnitExists("pet") and LocalVars.SafeColorSolo and InCombatLockdown() and unit.reaction ~= "FRIENDLY" and unit.type == "NPC" and (unit.isInCombat or UnitIsUnit(unit.unitid.."target", "player")) then
		return LocalVars.ColorThreatSafe
	elseif (LocalVars.ThreatSoloEnable or UnitInParty("player") or UnitExists("pet")) and InCombatLockdown() and unit.reaction ~= "FRIENDLY" and unit.type == "NPC" and (unit.isInCombat or UnitIsUnit(unit.unitid.."target", "player")) then
		local isTank = (LocalVars.ThreatWarningMode == "Tank") or (LocalVars.ThreatWarningMode == "Auto" and IsTankingAuraActive())
		local threatException = ThreatExceptions(unit, isTank)

		if threatException then return threatException end

		if unit.reaction == "NEUTRAL" and unit.threatValue < 2 and not IsOffTanked(unit) then return ReactionColors[unit.reaction][unit.type] end

		if isTank then
			return ColorFunctionTankSwapColors(unit)
		--elseif LocalVars.ThreatWarningMode == "Tank" then
		--	return ColorFunctionRawTank(unit)
		else return ColorFunctionDamage(unit) end

	else
		return ReactionColors[unit.reaction][unit.type]

	end

end


-- By Raid Icon
local function ColorFunctionByRaidIcon(unit)
	return RaidIconColors[unit.raidIcon]
end

-- By Level Color
local function ColorFunctionByLevelColor(unit)
	tempColor.r, tempColor.g, tempColor.b = unit.levelcolorRed, unit.levelcolorGreen, unit.levelcolorBlue
	return tempColor
end

--  Hub functions
local EnemyBarFunctions = {}
NeatPlatesHubDefaults.EnemyBarColorMode = "ByThreat"			-- Sets the default function

AddHubFunction(EnemyBarFunctions, NeatPlatesHubMenus.EnemyBarModes, ColorFunctionByThreat, L["By Threat"], "ByThreat")
AddHubFunction(EnemyBarFunctions, NeatPlatesHubMenus.EnemyBarModes, ColorFunctionByReaction, L["By Reaction"], "ByReaction")
AddHubFunction(EnemyBarFunctions, NeatPlatesHubMenus.EnemyBarModes, ColorFunctionByClass, L["By Class"], "ByClass")
AddHubFunction(EnemyBarFunctions, NeatPlatesHubMenus.EnemyBarModes, ColorFunctionByHealth, L["By Health"], "ByHealth")


local FriendlyBarFunctions = {}
NeatPlatesHubDefaults.FriendlyBarColorMode = "ByReaction"			-- Sets the default function

AddHubFunction(FriendlyBarFunctions, NeatPlatesHubMenus.FriendlyBarModes, ColorFunctionByReaction, L["By Reaction"], "ByReaction")
AddHubFunction(FriendlyBarFunctions, NeatPlatesHubMenus.FriendlyBarModes, ColorFunctionByClass, L["By Class"], "ByClass")
AddHubFunction(FriendlyBarFunctions, NeatPlatesHubMenus.FriendlyBarModes, ColorFunctionByHealth, L["By Health"], "ByHealth")



------------------
local function CustomColorDelegate(unit)
	-- Functions is a bit messy because it attempts to use the order of items as a priority...
	local color, aura, threshold, current, lowest
	local health = (unit.health/unit.healthmax)*100

	if NeatPlatesWidgets.AuraCache then aura = NeatPlatesWidgets.AuraCache[unit.unitid] end

	local temp = {strsplit("\n", LocalVars.CustomColorList)}
	for index=1, #temp do
		local key = select(3, string.find(temp[index], "#%x+[%s%p]*(.*)"))
		
		if key then
			--Custom Color by Unit Name
			if not color and key == unit.name then
				color = HexToRGB(LocalVars.CustomColorLookup[unit.name]); break

		--Custom Color by Buff/Debuff
			elseif not color and aura and aura[key] then
				color = HexToRGB(LocalVars.CustomColorLookup[key]); break

		-- Custom Color by Unit Threshold
			else
				current = tonumber((strmatch(key, "(.*)(%%)")))
				if current and (not lowest or lowest > current) and health <= current then
					lowest = current
					threshold = key
				end
				if threshold then color = HexToRGB(LocalVars.CustomColorLookup[threshold]) end
			end
		end
	end

	return color
end


local function HealthColorDelegate(unit)

	local color, class

	-- Group Member Aggro Coloring
	if unit.reaction == "FRIENDLY" then
		if LocalVars.ColorShowPartyAggro and LocalVars.ColorPartyAggroBar then
			--if GetFriendlyThreat(unit.unitid) then color = LocalVars.ColorPartyAggro end
		end
	elseif unit.isTapped then
		color = LocalVars.ColorTapped -- Tapped Color Priority
	elseif (LocalVars.HighlightMouseoverMode == 2) and unit.isMouseover then
		color = LocalVars.ColorMouseover -- Mouseover Color
	elseif (LocalVars.HighlightTargetMode == 2) and unit.isTarget then
		color = LocalVars.ColorTarget -- Target Color
	elseif (LocalVars.HighlightFocusMode == 2) and unit.isFocus then
		color = LocalVars.ColorFocus -- Focus Color
	end

	-- Custom Color
	if not color then color = CustomColorDelegate(unit) end

	-- Color Mode / Color Spotlight
	if not color then
		local mode = 1
		local func

		if unit.reaction == "FRIENDLY" then
			func = FriendlyBarFunctions[LocalVars.FriendlyBarColorMode or 0] or DummyFunction
		else
			func = EnemyBarFunctions[LocalVars.EnemyBarColorMode or 0] or DummyFunction
		end

		--local func = ColorFunctions[mode] or DummyFunction
		color = func(unit)
	end


	--if LocalVars.UnitSpotlightBarEnable and LocalVars.UnitSpotlightLookup[unit.name] then
	--	color = LocalVars.UnitSpotlightColor
	--end

	if color then
		return color.r, color.g, color.b, 1	--, color.r/4, color.g/4, color.b/4, 1
	else return unit.red, unit.green, unit.blue end
end

local function PowerColorDelegate(unit, powerType)
	if not unit.unitid then return 0,0,1,1 end -- Mana/blue

	local color
	if not powerType then powerType = UnitPowerType(unit.unitid) end

	color = PowerBarColor[powerType]	-- FrameXML/UnitFrame.lua

	return color.r, color.g, color.b, 1
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Cast Bar Color
------------------------------------------------------------------------------
------------------------------------------------------------------------------
local function CastBarDelegate(unit, school)
	local color, alpha
	local schoolColor = {
		[1] = LocalVars.ColorSchoolPhysical, -- Physical
		[2] = LocalVars.ColorSchoolHoly, -- Holy
		[4] = LocalVars.ColorSchoolFire, -- Fire
		[8] = LocalVars.ColorSchoolNature, -- Nature
		[16] = LocalVars.ColorSchoolFrost, -- Frost
		[32] = LocalVars.ColorSchoolShadow, -- Shadow
		[64] = LocalVars.ColorSchoolArcane, -- Arcane
	}


	if LocalVars.ColorCastBySchool and school then
		color = schoolColor[school]
	elseif unit.interrupted then
		color = LocalVars.ColorIntpellCast
	elseif unit.spellInterruptible then
		color = LocalVars.ColorNormalSpellCast
	else color = LocalVars.ColorUnIntpellCast end

	if (unit.reaction == "FRIENDLY" and not LocalVars.SpellCastEnableFriendly) or
		 (unit.reaction ~= "FRIENDLY" and not LocalVars.SpellCastEnableEnemy) then
		alpha = 0
	else alpha = 1 end

	--[[
	if unit.reaction ~= "FRIENDLY" or LocalVars.SpellCastEnableFriendly then alpha = 1
	else alpha = 0 end
--]]
	return color.r, color.g, color.b, alpha
end



------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Warning Border Color
------------------------------------------------------------------------------
------------------------------------------------------------------------------
local WarningColor = {}

-- Player Health (na)
local function WarningBorderFunctionByPlayerHealth(unit)
	local healthPct = UnitHealth("player")/UnitHealthMax("player")
	if healthPct < .3 then return HubData.Colors.DarkRed end
end

-- By Enemy Healer
local function WarningBorderFunctionByEnemyHealer(unit)
	if unit.reaction == "HOSTILE" and unit.type == "PLAYER" then
		--if NeatPlatesCache and NeatPlatesCache.HealerListByName[unit.rawName] then

		if IsHealer(unit.rawName) then
			return RaidClassColors[unit.class or ""] or ReactionColors[unit.reaction][unit.type]
		end
	end
end

---- "By Threat (High) Damage"
--local function WarningBorderFunctionByThreatDamage(unit)
--	if InCombatLockdown and unit.reaction ~= "FRIENDLY" and unit.type == "NPC" then
--		if unit.threatValue > 0 then
--			return ColorFunctionDamage(unit)
--		end
--	end
--end

---- "By Threat (Low) Tank"
--local function WarningBorderFunctionByThreatTank(unit)
--	if InCombatLockdown() and unit.reaction ~= "FRIENDLY" and unit.type == "NPC" then
--		if unit.threatValue < 3 then
--			if IsOffTanked(unit) then return else	return ColorFunctionRawTank(unit) end
--		end
--	end
--end


-- Warning Glow (Auto Detect)
local function WarningBorderFunctionByThreat(unit)
	if (LocalVars.ThreatSoloEnable or UnitInParty("player") or UnitExists("pet")) and InCombatLockdown() and unit.reaction ~= "FRIENDLY" and unit.type == "NPC" and (unit.isInCombat or UnitIsUnit(unit.unitid.."target", "player")) then
		local isTank = (LocalVars.ThreatWarningMode == "Tank") or (LocalVars.ThreatWarningMode == "Auto" and IsTankingAuraActive())
		local threatException = ThreatExceptions(unit, isTank, true)

		if threatException then
			if threatException == true then
				return
			else
				return threatException
			end
		end

		if unit.reaction == "NEUTRAL" and unit.threatValue < 2 then return end

		if isTank then
				if (not unit.isInCombat and not UnitIsUnit(unit.unitid.."target", "player")) or IsOffTanked(unit) then return
				elseif unit.threatValue == 2 then return LocalVars.ColorThreatTransition
				elseif unit.threatValue < 2 then return LocalVars.ColorThreatWarning	end
		elseif unit.threatValue > 0 then return ColorFunctionDamage(unit, true) end
	else
		-- Add healer tracking
		return WarningBorderFunctionByEnemyHealer(unit)

	end
end

--[[
local WarningBorderFunctionsUniversal = { DummyFunction, WarningBorderFunctionByThreat,
			WarningBorderFunctionByEnemyHealer }
			--]]

local function ThreatColorDelegate(unit)
	local color

	-- Friendly Unit Aggro
	if LocalVars.ColorShowPartyAggro and LocalVars.ColorPartyAggroGlow and unit.reaction == "FRIENDLY" then
		if GetFriendlyThreat(unit.unitid) then color = LocalVars.ColorPartyAggro end

	-- Enemy Units
	else

		-- NPCs
		if LocalVars.ThreatGlowEnable then
			color = WarningBorderFunctionByThreat(unit)
		end

		-- Players
		-- Check for Healer?  By Threat does this.
	end

	--[[
	if LocalVars.UnitSpotlightGlowEnable and LocalVars.UnitSpotlightLookup[unit.name] then
		color = LocalVars.UnitSpotlightColor
	end
	--]]

	if color then return color.r, color.g, color.b, 1
	else return 0, 0, 0, 0 end
end



------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Name Text Color
------------------------------------------------------------------------------
------------------------------------------------------------------------------

-- By Reaction
local function NameColorByReaction(unit)
	if unit.unitid then
		if IsGuildmate(unit.unitid) then return LocalVars.TextColorGuildMember
		elseif IsFriend(unit.unitid) then return LocalVars.TextColorGuildMember
		elseif IsPartyMember(unit.unitid) then return LocalVars.TextColorPartyMember end
	end

	return NameReactionColors[unit.reaction][unit.type]
end

-- By Significance
local function NameColorBySignificance(unit)
	-- [[
	if unit.reaction ~= "FRIENDLY" then
		if unit.isBoss then return LocalVars.TextColorBoss --HubData.Colors.BossGrey
		elseif unit.isElite then return LocalVars.TextColorElite --HubData.Colors.EliteGrey
		else return LocalVars.TextColorNormal end --HubData.Colors.NormalGrey
	else
		return NameColorByReaction(unit)
	end
	--]]
end

local function NameColorByClass(unit)
	--[[
	local class, color

	if unit.type == "PLAYER" then
		-- Determine Unit Class
		if unit.reaction == "FRIENDLY" then class = GetFriendlyClass(unit.name)
		else class = unit.class or GetEnemyClass(unit.name); end

		-- Return color
		if class and RaidClassColors[class] then
			return RaidClassColors[class] end
	end

--]]

	local class = unit.class

	if class then
		return RaidClassColors[unit.class]
	end

	-- For unit types with no Class info available, return reaction color
	return NameReactionColors[unit.reaction][unit.type]
end


local function NameColorByFriendlyClass(unit)
	local class, color

	if unit.type == "PLAYER" and unit.reaction == "FRIENDLY" then
		return RaidClassColors[unit.class]
	end

	-- For unit types with no Class info available, return reaction color
	return NameReactionColors[unit.reaction][unit.type]
end



local function NameColorByEnemyClass(unit)
	local class, color

	if unit.type == "PLAYER" and unit.reaction == "HOSTILE" then
		return RaidClassColors[unit.class]
	end

	-- For unit types with no Class info available, return reaction color
	return NameReactionColors[unit.reaction][unit.type]
end

local function NameColorByClass(unit)
	local color = RaidClassColors[unit.class]

	if color then
		return color
	else
		return NameColorByReaction(unit)
	end

end

local function NameColorByThreat(unit)
	if unit.reaction == "NEUTRAL" and unit.threatValue < 2 then return NameReactionColors[unit.reaction][unit.type]
	elseif InCombatLockdown() and (unit.isInCombat or UnitIsUnit(unit.unitid.."target", "player")) then return ColorFunctionByThreat(unit)
	else return RaidClassColors[unit.class or ""] or NameReactionColors[unit.reaction][unit.type] end
end

local SemiWhite = {r=1, g=1, b=1, a=.8}
local SemiWhiter = {r=1, g=1, b=1, a=.9}
local SemiYellow = {r=1, g=1, b=.8, a=1}
-- GoldColor, YellowColor
local function NameColorDefault(unit)
	return HubData.Colors.White
end


local EnemyNameColorFunctions = {}
NeatPlatesHubMenus.EnemyNameColorModes = {}
NeatPlatesHubDefaults.EnemyNameColorMode = "Default"

AddHubFunction(EnemyNameColorFunctions, NeatPlatesHubMenus.EnemyNameColorModes, NameColorDefault, L["White"], "Default")
AddHubFunction(EnemyNameColorFunctions, NeatPlatesHubMenus.EnemyNameColorModes, NameColorByClass, L["By Class"], "ByClass")
AddHubFunction(EnemyNameColorFunctions, NeatPlatesHubMenus.EnemyNameColorModes, NameColorByThreat, L["By Threat"], "ByThreat")
AddHubFunction(EnemyNameColorFunctions, NeatPlatesHubMenus.EnemyNameColorModes, NameColorByReaction, L["By Reaction"], "ByReaction")
AddHubFunction(EnemyNameColorFunctions, NeatPlatesHubMenus.EnemyNameColorModes, ColorFunctionByHealth, L["By Health"], "ByHealth")
AddHubFunction(EnemyNameColorFunctions, NeatPlatesHubMenus.EnemyNameColorModes, ColorFunctionByLevelColor, L["By Level Color"], "ByLevel")
AddHubFunction(EnemyNameColorFunctions, NeatPlatesHubMenus.EnemyNameColorModes, NameColorBySignificance, L["By Normal/Elite/Boss"], "ByElite")

local FriendlyNameColorFunctions = {}
NeatPlatesHubMenus.FriendlyNameColorModes = {}
NeatPlatesHubDefaults.FriendlyNameColorMode = "Default"

AddHubFunction(FriendlyNameColorFunctions, NeatPlatesHubMenus.FriendlyNameColorModes, NameColorDefault, L["White"], "Default")
AddHubFunction(FriendlyNameColorFunctions, NeatPlatesHubMenus.FriendlyNameColorModes, NameColorByClass, L["By Class"], "ByClass")
AddHubFunction(FriendlyNameColorFunctions, NeatPlatesHubMenus.FriendlyNameColorModes, NameColorByReaction, L["By Reaction"], "ByReaction")
AddHubFunction(FriendlyNameColorFunctions, NeatPlatesHubMenus.FriendlyNameColorModes, ColorFunctionByHealth, L["By Health"], "ByHealth")


NeatPlatesHubDefaults.FriendlyHeadlineColor = "ByReaction"
NeatPlatesHubDefaults.EnemyHeadlineColor = "ByReaction"


-- [[
local function SetNameColorDelegate(unit)
	local color, colorMode
	local alphaFade = 1
	local func
	local isFriendly = (unit.reaction == "FRIENDLY")

	-- Party Aggro Coloring, if enabled
	if isFriendly and LocalVars.ColorShowPartyAggro and LocalVars.ColorPartyAggroText then
		if GetFriendlyThreat(unit.unitid) then return LocalVars.ColorPartyAggro end
	end

	-- Headline Mode
	if StyleDelegate(unit) == "NameOnly" then

		if isFriendly then
			colorMode = LocalVars.FriendlyHeadlineColor
		else
			colorMode = LocalVars.EnemyHeadlineColor
		end
	-- Bar Mode
	else
		if isFriendly then
			colorMode = LocalVars.FriendlyNameColorMode
		else
			colorMode = LocalVars.EnemyNameColorMode
		end
	end

	-- Get color function
	if isFriendly then
		func = FriendlyNameColorFunctions[colorMode or 1] or NameColorDefault
	else
		func = EnemyNameColorFunctions[colorMode or 1] or NameColorDefault
	end

		-- Tapped Color Priority
	--if unit.isTapped then
	--	color = LocalVars.ColorTapped
	--else
		color = func(unit)
	--end


	if color then
		return color.r, color.g, color.b , ((color.a or 1) * alphaFade)
	else
		return 1, 1, 1, 1 * alphaFade
	end
end
--]]

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
NeatPlatesHubFunctions.SetHealthbarColor = HealthColorDelegate
NeatPlatesHubFunctions.SetPowerbarColor = PowerColorDelegate
NeatPlatesHubFunctions.SetCastbarColor = CastBarDelegate
NeatPlatesHubFunctions.SetThreatColor = ThreatColorDelegate
NeatPlatesHubFunctions.SetNameColor = SetNameColorDelegate




