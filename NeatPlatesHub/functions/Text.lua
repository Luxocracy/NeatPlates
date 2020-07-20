
local AddonName, HubData = ...;
local LocalVars = NeatPlatesHubDefaults
local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")

------------------------------------------------------------------
-- References
------------------------------------------------------------------
local RaidClassColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

local GetFriendlyThreat = NeatPlatesUtility.GetFriendlyThreat

local IsFriend = NeatPlatesUtility.IsFriend
local IsGuildmate = NeatPlatesUtility.IsGuildmate

local IsOffTanked = NeatPlatesHubFunctions.IsOffTanked
local IsTankingAuraActive = NeatPlatesWidgets.IsPlayerTank
local InCombatLockdown = InCombatLockdown
local GetFriendlyClass = HubData.Functions.GetFriendlyClass
local GetEnemyClass = HubData.Functions.GetEnemyClass
local StyleDelegate = NeatPlatesHubFunctions.SetStyleNamed
local ColorFunctionByHealth = HubData.Functions.ColorFunctionByHealth
local CachedUnitDescription = NeatPlatesUtility.CachedUnitDescription

local GetUnitSubtitle = NeatPlatesUtility.GetUnitSubtitle
local GetUnitQuestInfo = NeatPlatesUtility.GetUnitQuestInfo
local round = NeatPlatesUtility.round


local AddHubFunction = NeatPlatesHubHelpers.AddHubFunction

local function DummyFunction() end

-- Colors
--local White = {r = 1, g = 1, b = 1}
--local WhiteColor = { r = 250/255, g = 250/255, b = 250/255, }


------------------------------------------------------------------------------
-- Optional/Health Text
------------------------------------------------------------------------------


local function GetLevelDescription(unit)
	local description = ""
	description = "Level "..unit.level
	if unit.isElite then description = description.." (Elite)" end
	return description
end



local function ShortenNumber(number)
	if not number then return "" end

	if LocalVars.AltShortening and number > 100000000 then
		return (ceil((number/10000000))/10).." "..L["SHORT_ONE_HUNDRED_MILLION"] --"亿"
	elseif not LocalVars.AltShortening and number > 1000000 then
		return (ceil((number/100000))/10).." "..L["SHORT_MILLION"]
	elseif LocalVars.AltShortening and number > 10000 then
		return (ceil((number/1000))/10).." "..L["SHORT_TEN_THOUSAND"]	--"万"
	elseif not LocalVars.AltShortening and number > 1000 then
		return (ceil((number/100))/10).." "..L["SHORT_THOUSAND"]
	else
		return number
	end
end

local function SepThousands(number)
	if not number then return "" end
	local n = tonumber(number)

	local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)')
	return left..(num:reverse():gsub('(%d%d%d)', '%1,'):reverse())..right
end


local function TextFunctionMana(unit)
	if (unit.isTarget or (LocalVars.FocusAsTarget and unit.isFocus)) then
		local power = ceil((UnitPower("target") / UnitPowerMax("target"))*100)
		--local r, g, b = UnitPowerType("target")
		--local powername = getglobal(select(2, UnitPowerType("target")))
		--if power and power > 0 then	return power.."% "..powername end
		local powertype = select(2,UnitPowerType("target"))
		local powercolor = PowerBarColor[powertype]
		local powername = getglobal(powertype)
		---print(power, powertype, powercolor, powercolor.r, powercolor.g, powercolor.b)
		if power and power > 0 then return power.."% "..powername, powercolor.r, powercolor.g, powercolor.b, 1 end
	end
end

local function GetHealth(unit)
	--if unit.healthmaxCached then
		return unit.health
	--else return nil end
end

local function GetHealthMax(unit)
	--if unit.healthmaxCached then
		return unit.healthmax
	--else return nil end
end

-- None
local function HealthFunctionNone() return "" end

-- Percent
local function TextHealthPercent(unit)
	return ceil(100*(unit.health/unit.healthmax)).."%"
end

local function TextHealthPercentColored(unit)
	local color = ColorFunctionByHealth(unit)
	return ceil(100*(unit.health/unit.healthmax)).."%", color.r, color.g, color.b, .7
end

local function HealthFunctionPercent(unit)
	if unit.health < unit.healthmax then
		return TextHealthPercent(unit)
	else return "" end
end

local function HealthFunctionPercentColored(unit)
	if unit.health < unit.healthmax then
		return TextHealthPercentColored(unit)
	else return "" end
end

-- Actual
local function HealthFunctionExact(unit)
	return SepThousands(GetHealth(unit))
end
-- Approximate
local function HealthFunctionApprox(unit)
	return ShortenNumber(GetHealth(unit))
end
-- Approximate
local function HealthFunctionApproxAndPercent(unit)
	local color = ColorFunctionByHealth(unit)
	return HealthFunctionApprox(unit).."  ("..ceil(100*(unit.health/unit.healthmax)).."%)", color.r, color.g, color.b, .7
end
--Deficit
local function HealthFunctionDeficit(unit)
	local health, healthmax = GetHealth(unit), GetHealthMax(unit)
	if health and healthmax and (health ~= healthmax) then return "-"..SepThousands(healthmax - health) end
end
-- Total and Percent
local function HealthFunctionTotal(unit)
	local color = ColorFunctionByHealth(unit)
	--local color = HubData.Colors.White
	local health, healthmax = GetHealth(unit), GetHealthMax(unit)
	return ShortenNumber(health).."|cffffffff ("..ceil(100*(unit.health/unit.healthmax)).."%)", color.r, color.g, color.b
end
-- TargetOf
local function HealthFunctionTargetOf(unit)
	if unit.isInCombat then
		return UnitName(unit.unitid.."target")
	end
	--[[
	if (unit.isTarget or (LocalVars.FocusAsTarget and unit.isFocus)) then return UnitName("targettarget")
	elseif unit.isMouseover then return UnitName("mouseovertarget")
	else return "" end
	--]]
end
-- TargetOf(Class Color)
local function HealthFunctionTargetOfClass(unit)
	if unit.isInCombat then
		local targetof = unit.unitid.."target"
		local name = UnitName(targetof) or ""

		if UnitIsPlayer(targetof) then
			local targetclass = select(2, UnitClass(targetof))
			return ConvertRGBtoColorString(RaidClassColors[targetclass])..name
		else
			return name
		end	
	end
end
-- Level
local function HealthFunctionLevel(unit)
	local level = unit.level
	if unit.isElite then level = level.." (Elite)" end
	return level, unit.levelcolorRed, unit.levelcolorGreen, unit.levelcolorBlue, .9
end

-- Level and Health
local function HealthFunctionLevelHealth(unit)
	local level = unit.level
	if unit.isElite then level = level.."E" end
	return "("..level..") |cffffffff"..HealthFunctionApprox(unit), unit.levelcolorRed, unit.levelcolorGreen, unit.levelcolorBlue, .9
	--return "|cffffffff"..HealthFunctionApprox(unit).."  |r"..level, unit.levelcolorRed, unit.levelcolorGreen, unit.levelcolorBlue, .9
end


local HealthTextModesCustom = {}


--[[
local hexChars = {
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
}


local function intToHex(num)
	--local sig, sep
	--sig = fmod(num, 16)
	sep = num - sig*16
	return hexChars[sig]..hexChars[sep]
end

--]]


-- Custom
local function HealthFunctionCustom(unit)

	local LeftText, RightText, CenterText = "", "", ""

	--HealthTextModesCustom[LocalVars.StatusTextLeft]


	return LeftText, RightText, CenterText
	--if LocalVars.CustomHealthFunction then return LocalVars.CustomHealthFunction(unit) end

	--HealthTextModesCustom(mode, addColor)

	--[[
	FriendlyStatusTextMode
	FriendlyStatusTextModeCenter
	FriendlyStatusTextModeRight

	EnemyStatusTextMode
	EnemyStatusTextModeCenter
	EnemyStatusTextModeRight
	--]]


	--[[
	StatusTextLeft = 8,
	StatusTextCenter = 5,
	StatusTextRight = 7,

	StatusTextLeftColor = true,
	StatusTextCenterColor = true,
	StatusTextRightColor = true,

	--]]
end

local HealthTextModeFunctions = {}


NeatPlatesHubDefaults.FriendlyStatusTextMode = "HealthFunctionNone"
NeatPlatesHubDefaults.EnemyStatusTextMode = "HealthFunctionNone"

AddHubFunction(HealthTextModeFunctions, NeatPlatesHubMenus.TextModes, HealthFunctionNone, L["None"], "HealthFunctionNone")
AddHubFunction(HealthTextModeFunctions, NeatPlatesHubMenus.TextModes, HealthFunctionPercent, L["Percent Health"], "HealthFunctionPercent")
AddHubFunction(HealthTextModeFunctions, NeatPlatesHubMenus.TextModes, HealthFunctionPercentColored, L["Percent Health (Colored)"], "HealthFunctionPercentColored")
AddHubFunction(HealthTextModeFunctions, NeatPlatesHubMenus.TextModes, HealthFunctionExact, L["Exact Health"], "HealthFunctionExact")
AddHubFunction(HealthTextModeFunctions, NeatPlatesHubMenus.TextModes, HealthFunctionApprox, L["Approximate Health"], "HealthFunctionApprox")
AddHubFunction(HealthTextModeFunctions, NeatPlatesHubMenus.TextModes, HealthFunctionDeficit, L["Health Deficit"], "HealthFunctionDeficit")
AddHubFunction(HealthTextModeFunctions, NeatPlatesHubMenus.TextModes, HealthFunctionTotal, L["Health Total & Percent"], "HealthFunctionTotal")
AddHubFunction(HealthTextModeFunctions, NeatPlatesHubMenus.TextModes, HealthFunctionTargetOf, L["Target Of"], "HealthFunctionTargetOf")
AddHubFunction(HealthTextModeFunctions, NeatPlatesHubMenus.TextModes, HealthFunctionTargetOfClass, L["Target Of (Class Colored)"], "HealthFunctionTargetOfClass")
AddHubFunction(HealthTextModeFunctions, NeatPlatesHubMenus.TextModes, HealthFunctionLevel, L["Level"], "HealthFunctionLevel")
AddHubFunction(HealthTextModeFunctions, NeatPlatesHubMenus.TextModes, HealthFunctionLevelHealth, L["Level and Approx Health"], "HealthFunctionLevelHealth")


local function HealthTextDelegate(unit)

	local func
	local mode = 1
	local showText = not (LocalVars.TextShowOnlyOnTargets or LocalVars.TextShowOnlyOnActive)

	if unit.reaction == "FRIENDLY" then mode = LocalVars.FriendlyStatusTextMode
	else mode = LocalVars.EnemyStatusTextMode end

	func = HealthTextModeFunctions[mode] or DummyFunction

	if LocalVars.TextShowOnlyOnTargets then
		if ((unit.isTarget or (LocalVars.FocusAsTarget and unit.isFocus)) or unit.isMouseover or unit.isMarked) then showText = true end
	end

	if LocalVars.TextShowOnlyOnActive then
		if (unit.isMarked) or (unit.threatValue > 0) or (unit.health < unit.healthmax) then showText = true end
	end

	if showText then return func(unit) end
end



------------------------------------------------------------------------------------
-- Binary/Headline Text Styles
------------------------------------------------------------------------------------
local function RoleOrGuildText(unit)
	if unit.type == "NPC" then
		return (GetUnitSubtitle(unit) or GetLevelDescription(unit) or "") , 1, 1, 1, .70
	end
end

-- Role, Guild or Level
local function TextRoleGuildLevel(unit)
	local description
	local r, g, b = 1,1,1

	if unit.type == "NPC" then
		description = GetUnitSubtitle(unit)

		if not description then --  and unit.reaction ~= "FRIENDLY" then
			description =  GetLevelDescription(unit)
			r, g, b = .7, .7, .9
			--r, g, b = unit.levelcolorRed, unit.levelcolorGreen, unit.levelcolorBlue
		end

	elseif unit.type == "PLAYER" then
		description = GetGuildInfo(unit.unitid)
		r, g, b = .7, .7, .9
	end

	return description, r, g, b, .70
end



local function TextRoleGuild(unit)
	local description
	local r, g, b = 1,1,1

	if unit.type == "NPC" then
		description = GetUnitSubtitle(unit)

	elseif unit.type == "PLAYER" then
		description = GetGuildInfo(unit.unitid)
		--description = CachedUnitGuild(unit.name)
		r, g, b = .7, .7, .9
	end

	return description, r, g, b, .70
end

local function TextRoleClass(unit)
	local description, faction
	local r, g, b = 1,1,1

	if unit.type == "NPC" then
		description = GetUnitSubtitle(unit)
		if not description then
			faction, description = UnitFactionGroup(unit.unitid)
		end

	elseif unit.type == "PLAYER" then
		description = UnitClassBase(unit.unitid)
		local classColor = RaidClassColors[unit.class]
		r, g, b = classColor.r, classColor.g, classColor.b
	end

	return description, r, g, b, .70
end


-- NPC Role
local function TextNPCRole(unit)
	if unit.type == "NPC" then
		-- Prototype for displaying quest information on Nameplates
		--local questName, questObjective = GetUnitQuestInfo(unit)
		--return questObjective

		return GetUnitSubtitle(unit)
	end
end


local function TextUnitTitle(unit)
	local color = HubData.Colors.White
	if unit.pvpname and unit.name then
		return string.gsub(unit.pvpname, '%s*'..unit.name, ''), color.r, color.g, color.b, .7
	end
end

local function TextQuest(unit)
	if unit.type == "NPC" then

		-- Prototype for displaying quest information on Nameplates
		local questName, questObjective = GetUnitQuestInfo(unit)
		return questObjective
	end
end

-- Role or Guild
local function TextRoleGuildQuest(unit)
	local r, g, b = 1, .9, .7
	return TextQuest(unit) or TextRoleGuild(unit), r, g, b, .70
end


-- Level
local function TextLevelColored(unit)
	--return GetLevelDescription(unit) , 1, 1, 1, .70
	return GetLevelDescription(unit) , unit.levelcolorRed, unit.levelcolorGreen, unit.levelcolorBlue, .70
end

-- Guild, Role, Level, Health
local function TextAll(unit)
	-- local color = ColorFunctionByHealth(unit) --6.0
	local color = HubData.Colors.White
	if unit.health < unit.healthmax then
		return ceil(100*(unit.health/unit.healthmax)).."%", color.r, color.g, color.b, .7
	else
		--return GetLevelDescription(unit) , unit.levelcolorRed, unit.levelcolorGreen, unit.levelcolorBlue, .7
		return TextQuest(unit) or TextRoleGuildLevel(unit)
	end
end


local EnemyNameSubtextFunctions = {}
NeatPlatesHubMenus.EnemyNameSubtextModes = {}
NeatPlatesHubDefaults.HeadlineEnemySubtext = "RoleGuildLevel"
NeatPlatesHubDefaults.HeadlineFriendlySubtext = "RoleGuildLevel"
NeatPlatesHubDefaults.EnemySubtext = "None"
NeatPlatesHubDefaults.FriendlySubtext = "None"
AddHubFunction(EnemyNameSubtextFunctions, NeatPlatesHubMenus.EnemyNameSubtextModes, DummyFunction, L["None"], "None")
AddHubFunction(EnemyNameSubtextFunctions, NeatPlatesHubMenus.EnemyNameSubtextModes, TextHealthPercentColored, L["Percent Health (Colored)"], "PercentHealthColored")
AddHubFunction(EnemyNameSubtextFunctions, NeatPlatesHubMenus.EnemyNameSubtextModes, TextHealthPercent, L["Percent Health"], "PercentHealth")
AddHubFunction(EnemyNameSubtextFunctions, NeatPlatesHubMenus.EnemyNameSubtextModes, TextRoleGuildLevel, L["NPC Role, Guild, or Level"], "RoleGuildLevel")
AddHubFunction(EnemyNameSubtextFunctions, NeatPlatesHubMenus.EnemyNameSubtextModes, TextRoleGuildQuest, L["NPC Role, Guild, or Quest"], "RoleGuildQuest")
AddHubFunction(EnemyNameSubtextFunctions, NeatPlatesHubMenus.EnemyNameSubtextModes, TextRoleGuild, L["NPC Role, Guild"], "RoleGuild")
--AddHubFunction(EnemyNameSubtextFunctions, NeatPlatesHubMenus.EnemyNameSubtextModes, TextRoleClass, "Role or Class", "RoleClass")
AddHubFunction(EnemyNameSubtextFunctions, NeatPlatesHubMenus.EnemyNameSubtextModes, TextNPCRole, L["NPC Role"], "Role")
AddHubFunction(EnemyNameSubtextFunctions, NeatPlatesHubMenus.EnemyNameSubtextModes, TextUnitTitle, L["Unit Title"], "UnitTitle")
AddHubFunction(EnemyNameSubtextFunctions, NeatPlatesHubMenus.EnemyNameSubtextModes, TextLevelColored, L["Level"], "Level")
AddHubFunction(EnemyNameSubtextFunctions, NeatPlatesHubMenus.EnemyNameSubtextModes, TextQuest, L["Quest"], "Quest")
AddHubFunction(EnemyNameSubtextFunctions, NeatPlatesHubMenus.EnemyNameSubtextModes, TextAll, L["Everything"], "RoleGuildLevelHealth")

--[[
local FriendlyNameSubtextFunctions = {}
NeatPlatesHubMenus.FriendlyNameSubtextModes = {}
NeatPlatesHubDefaults.HeadlineFriendlySubtext = "None"
AddHubFunction(FriendlyNameSubtextFunctions, NeatPlatesHubMenus.FriendlyNameSubtextModes, DummyFunction, "None", "None")
AddHubFunction(FriendlyNameSubtextFunctions, NeatPlatesHubMenus.FriendlyNameSubtextModes, TextHealthPercentColored, "Percent Health", "PercentHealth")
AddHubFunction(FriendlyNameSubtextFunctions, NeatPlatesHubMenus.FriendlyNameSubtextModes, TextRoleGuildLevel, "Role, Guild or Level", "RoleGuildLevel")
AddHubFunction(FriendlyNameSubtextFunctions, NeatPlatesHubMenus.FriendlyNameSubtextModes, TextRoleGuild, "Role or Guild", "RoleGuild")
AddHubFunction(FriendlyNameSubtextFunctions, NeatPlatesHubMenus.FriendlyNameSubtextModes, TextNPCRole, "NPC Role", "Role")
AddHubFunction(FriendlyNameSubtextFunctions, NeatPlatesHubMenus.FriendlyNameSubtextModes, TextLevelColored, "Level", "Level")
AddHubFunction(FriendlyNameSubtextFunctions, NeatPlatesHubMenus.FriendlyNameSubtextModes, TextAll, "Role, Guild, Level or Health Percent", "RoleGuildLevelHealth")
--]]

local function SubTextDelegate(unit)
	--if unit.style == "NameOnly" then
	local func
	if StyleDelegate(unit) == "NameOnly" then
		if unit.reaction == "FRIENDLY" then
			func = EnemyNameSubtextFunctions[LocalVars.HeadlineFriendlySubtext or 0] or DummyFunction
		else
			func = EnemyNameSubtextFunctions[LocalVars.HeadlineEnemySubtext or 0] or DummyFunction
		end
	else
		if unit.reaction == "FRIENDLY" then
			func = EnemyNameSubtextFunctions[LocalVars.FriendlySubtext or 0] or DummyFunction
		else
			func = EnemyNameSubtextFunctions[LocalVars.EnemySubtext or 0] or DummyFunction
		end
	end
	return func(unit)
end

local function CastbarDurationRemaining(currentTime, startTime, endTime, isChannel)
	local text = tonumber(round((endTime - currentTime)/1000, 1))
	if text <= 0 then text = "" end
	return text
end

local function CastbarDurationElapsed(currentTime, startTime, endTime, isChannel)
	local maxCast = round((endTime - startTime)/1000, 1)
	return math.min(maxCast, round((currentTime - startTime)/1000, 1))
end

local function CastbarDurationCastTime(currentTime, startTime, endTime, isChannel)
	local text = ""
	local maxCast = round((endTime - startTime)/1000, 1)
	if isChannel then
		text = math.max(0, round((endTime - currentTime)/1000, 1)).."/"..maxCast
	else
		text = math.min(maxCast, round((currentTime - startTime)/1000, 1)).."/"..maxCast
	end
	return text
end

local CastbarDurationFunctions = {}
NeatPlatesHubMenus.CastbarDurationModes = {}
NeatPlatesHubDefaults.CastbarDurationMode = "None"
AddHubFunction(CastbarDurationFunctions, NeatPlatesHubMenus.CastbarDurationModes, DummyFunction, L["None"], "None")
AddHubFunction(CastbarDurationFunctions, NeatPlatesHubMenus.CastbarDurationModes, CastbarDurationRemaining, L["Time Remaining"], "TimeRemaining")
AddHubFunction(CastbarDurationFunctions, NeatPlatesHubMenus.CastbarDurationModes, CastbarDurationElapsed, L["Time Elapsed"], "TimeElapsed")
AddHubFunction(CastbarDurationFunctions, NeatPlatesHubMenus.CastbarDurationModes, CastbarDurationCastTime, L["Time Elapsed/Cast Time"], "TimeCastTime")

local function CastbarDurationDelegate(...)
	local func = CastbarDurationFunctions[LocalVars.CastbarDurationMode or 0] or DummyFunction
	return func(...)
end

------------------------------------------------------------------------------
-- Local Variable
------------------------------------------------------------------------------

local function OnVariableChange(vars) LocalVars = vars end
HubData.RegisterCallback(OnVariableChange)


------------------------------------------------------------------------------
-- Add References
------------------------------------------------------------------------------



NeatPlatesHubFunctions.SetCustomText = HealthTextDelegate
NeatPlatesHubFunctions.SetSubText = SubTextDelegate
NeatPlatesHubFunctions.SetCastbarDuration = CastbarDurationDelegate

