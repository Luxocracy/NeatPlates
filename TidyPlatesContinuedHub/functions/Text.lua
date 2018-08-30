
local AddonName, HubData = ...;
local LocalVars = TidyPlatesContHubDefaults


------------------------------------------------------------------
-- References
------------------------------------------------------------------
local RaidClassColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

local GetFriendlyThreat = TidyPlatesContUtility.GetFriendlyThreat

local IsFriend = TidyPlatesContUtility.IsFriend
local IsGuildmate = TidyPlatesContUtility.IsGuildmate

local IsOffTanked = TidyPlatesContHubFunctions.IsOffTanked
local IsTankingAuraActive = TidyPlatesContWidgets.IsPlayerTank
local InCombatLockdown = InCombatLockdown
local GetFriendlyClass = HubData.Functions.GetFriendlyClass
local GetEnemyClass = HubData.Functions.GetEnemyClass
local StyleDelegate = TidyPlatesContHubFunctions.SetStyleNamed
local ColorFunctionByHealth = HubData.Functions.ColorFunctionByHealth
local CachedUnitDescription = TidyPlatesContUtility.CachedUnitDescription

local GetUnitSubtitle = TidyPlatesContUtility.GetUnitSubtitle
local GetUnitQuestInfo = TidyPlatesContUtility.GetUnitQuestInfo


local AddHubFunction = TidyPlatesContHubHelpers.AddHubFunction

local function DummyFunction() end

-- Colors
local White = {r = 1, g = 1, b = 1}
local WhiteColor = { r = 250/255, g = 250/255, b = 250/255, }


------------------------------------------------------------------------------
-- Optional/Health Text
------------------------------------------------------------------------------


local function GetLevelDescription(unit)
	local description = ""
	description = "Level "..unit.level
	if unit.isElite then description = description.." (Elite)" end
	return description
end


local arenaUnitIDs = {"arena1", "arena2", "arena3", "arena4", "arena5"}

local function GetArenaIndex(unitname)
	-- Kinda hackish.  would be faster to cache the arena names using event handler.  later!
	if IsActiveBattlefieldArena() then
		local unitid, name
		for i = 1, #arenaUnitIDs do
			unitid = arenaUnitIDs[i]
			name = UnitName(unitid)
			if name and (name == unitname) then return i end
		end
	end
end


local function ShortenNumber(number)
	if not number then return "" end

	if number > 1000000 then
		return (ceil((number/100000))/10).." M"
	elseif number > 1000 then
		return (ceil((number/100))/10).." K"
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
local function TextHealthPercentColored(unit)
	local color = ColorFunctionByHealth(unit)
	return ceil(100*(unit.health/unit.healthmax)).."%", color.r, color.g, color.b, .7
end

local function HealthFunctionPercent(unit)
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
	--local color = White
	local health, healthmax = GetHealth(unit), GetHealthMax(unit)
	return ShortenNumber(health).."|cffffffff ("..ceil(100*(unit.health/unit.healthmax)).."%)", color.r, color.g, color.b
end
-- TargetOf
local function HealthFunctionTargetOf(unit)
	if unit.reaction ~= "FRIENDLY" and unit.isInCombat then
		return UnitName(unitid.."target")
	end
	--[[
	if (unit.isTarget or (LocalVars.FocusAsTarget and unit.isFocus)) then return UnitName("targettarget")
	elseif unit.isMouseover then return UnitName("mouseovertarget")
	else return "" end
	--]]
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


-- Arena Vitals (ID, Mana, Health
local function HealthFunctionArenaID(unit)
	local localid
	local powercolor = White
	local powerstring = ""
	local arenastring = ""
	local arenaindex = GetArenaIndex(unit.rawName)

	--arenaindex = 2	-- Tester
	if unit.type == "PLAYER" then

		if arenaindex and arenaindex > 0 then
			arenastring = "|cffffcc00["..(tostring(arenaindex)).."]  |r"
		end


		if (unit.isTarget or (LocalVars.FocusAsTarget and unit.isFocus)) then localid = "target"
		elseif unit.isMouseover then localid = "mouseover"
		end


		if localid then
			local power = ceil((UnitPower(localid) / UnitPowerMax(localid))*100)
			local powerindex, powertype = UnitPowerType(localid)

			--local powername = getglobal(powertype)

			if power and power > 0 then
				powerstring = "  "..power.."%"		--..powername
				powercolor = PowerBarColor[powerindex] or White
			end
		end
	end

	local health = ShortenNumber(GetHealth(unit))
	local healthstring = "|cffffffff"..health.."|cff0088ff"

--[[
-- Test Strings
	powerstring = "  ".."43".."%"
	--arenastring = "|cffffcc00["..(tostring(2)).."]  |r"
	arenastring = "|cffffcc00#"..(tostring(2)).."  |r"
	powercolor = PowerBarColor[2]
--]]

	--	return '4'.."|r"..(powerstring or "")
	return arenastring..healthstring..powerstring, powercolor.r, powercolor.g, powercolor.b, 1

	--[[
	Arena ID, HealthFraction, ManaPercent
	#1  65%  75%

	Arena ID, HealthK, ManaFraction
	#2  300k  75%

	--]]
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


TidyPlatesContHubDefaults.FriendlyStatusTextMode = "HealthFunctionNone"
TidyPlatesContHubDefaults.EnemyStatusTextMode = "HealthFunctionNone"

AddHubFunction(HealthTextModeFunctions, TidyPlatesContHubMenus.TextModes, HealthFunctionNone, "None", "HealthFunctionNone")
AddHubFunction(HealthTextModeFunctions, TidyPlatesContHubMenus.TextModes, HealthFunctionPercent, "Percent Health", "HealthFunctionPercent")
AddHubFunction(HealthTextModeFunctions, TidyPlatesContHubMenus.TextModes, HealthFunctionExact, "Exact Health", "HealthFunctionExact")
AddHubFunction(HealthTextModeFunctions, TidyPlatesContHubMenus.TextModes, HealthFunctionApprox, "Approximate Health", "HealthFunctionApprox")
AddHubFunction(HealthTextModeFunctions, TidyPlatesContHubMenus.TextModes, HealthFunctionDeficit, "Health Deficit", "HealthFunctionDeficit")
AddHubFunction(HealthTextModeFunctions, TidyPlatesContHubMenus.TextModes, HealthFunctionTotal, "Health Total & Percent", "HealthFunctionTotal")
AddHubFunction(HealthTextModeFunctions, TidyPlatesContHubMenus.TextModes, HealthFunctionTargetOf, "Target Of", "HealthFunctionTargetOf")
AddHubFunction(HealthTextModeFunctions, TidyPlatesContHubMenus.TextModes, HealthFunctionLevel, "Level", "HealthFunctionLevel")
AddHubFunction(HealthTextModeFunctions, TidyPlatesContHubMenus.TextModes, HealthFunctionLevelHealth, "Level and Approx Health", "HealthFunctionLevelHealth")
AddHubFunction(HealthTextModeFunctions, TidyPlatesContHubMenus.TextModes, HealthFunctionArenaID, "Arena ID, Health, and Power", "HealthFunctionArenaID")


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
function TextAll(unit)
	-- local color = ColorFunctionByHealth(unit) --6.0
	local color = White
	if unit.health < unit.healthmax then
		return ceil(100*(unit.health/unit.healthmax)).."%", color.r, color.g, color.b, .7
	else
		--return GetLevelDescription(unit) , unit.levelcolorRed, unit.levelcolorGreen, unit.levelcolorBlue, .7
		return TextQuest(unit) or TextRoleGuildLevel(unit)
	end
end


local EnemyNameSubtextFunctions = {}
TidyPlatesContHubMenus.EnemyNameSubtextModes = {}
TidyPlatesContHubDefaults.HeadlineEnemySubtext = "RoleGuildLevel"
TidyPlatesContHubDefaults.HeadlineFriendlySubtext = "RoleGuildLevel"
AddHubFunction(EnemyNameSubtextFunctions, TidyPlatesContHubMenus.EnemyNameSubtextModes, DummyFunction, "None", "None")
AddHubFunction(EnemyNameSubtextFunctions, TidyPlatesContHubMenus.EnemyNameSubtextModes, TextHealthPercentColored, "Percent Health", "PercentHealth")
AddHubFunction(EnemyNameSubtextFunctions, TidyPlatesContHubMenus.EnemyNameSubtextModes, TextRoleGuildLevel, "NPC Role, Guild, or Level", "RoleGuildLevel")
AddHubFunction(EnemyNameSubtextFunctions, TidyPlatesContHubMenus.EnemyNameSubtextModes, TextRoleGuildQuest, "NPC Role, Guild, or Quest", "RoleGuildQuest")
AddHubFunction(EnemyNameSubtextFunctions, TidyPlatesContHubMenus.EnemyNameSubtextModes, TextRoleGuild, "NPC Role, Guild", "RoleGuild")
--AddHubFunction(EnemyNameSubtextFunctions, TidyPlatesContHubMenus.EnemyNameSubtextModes, TextRoleClass, "Role or Class", "RoleClass")
AddHubFunction(EnemyNameSubtextFunctions, TidyPlatesContHubMenus.EnemyNameSubtextModes, TextNPCRole, "NPC Role", "Role")
AddHubFunction(EnemyNameSubtextFunctions, TidyPlatesContHubMenus.EnemyNameSubtextModes, TextLevelColored, "Level", "Level")
AddHubFunction(EnemyNameSubtextFunctions, TidyPlatesContHubMenus.EnemyNameSubtextModes, TextQuest, "Quest", "Quest")
AddHubFunction(EnemyNameSubtextFunctions, TidyPlatesContHubMenus.EnemyNameSubtextModes, TextAll, "Everything", "RoleGuildLevelHealth")

--[[
local FriendlyNameSubtextFunctions = {}
TidyPlatesContHubMenus.FriendlyNameSubtextModes = {}
TidyPlatesContHubDefaults.HeadlineFriendlySubtext = "None"
AddHubFunction(FriendlyNameSubtextFunctions, TidyPlatesContHubMenus.FriendlyNameSubtextModes, DummyFunction, "None", "None")
AddHubFunction(FriendlyNameSubtextFunctions, TidyPlatesContHubMenus.FriendlyNameSubtextModes, TextHealthPercentColored, "Percent Health", "PercentHealth")
AddHubFunction(FriendlyNameSubtextFunctions, TidyPlatesContHubMenus.FriendlyNameSubtextModes, TextRoleGuildLevel, "Role, Guild or Level", "RoleGuildLevel")
AddHubFunction(FriendlyNameSubtextFunctions, TidyPlatesContHubMenus.FriendlyNameSubtextModes, TextRoleGuild, "Role or Guild", "RoleGuild")
AddHubFunction(FriendlyNameSubtextFunctions, TidyPlatesContHubMenus.FriendlyNameSubtextModes, TextNPCRole, "NPC Role", "Role")
AddHubFunction(FriendlyNameSubtextFunctions, TidyPlatesContHubMenus.FriendlyNameSubtextModes, TextLevelColored, "Level", "Level")
AddHubFunction(FriendlyNameSubtextFunctions, TidyPlatesContHubMenus.FriendlyNameSubtextModes, TextAll, "Role, Guild, Level or Health Percent", "RoleGuildLevelHealth")
--]]

local function CustomTextBinaryDelegate(unit)
	--if unit.style == "NameOnly" then

	if StyleDelegate(unit) == "NameOnly" then
		local func
		if unit.reaction == "FRIENDLY" then
			func = EnemyNameSubtextFunctions[LocalVars.HeadlineFriendlySubtext or 0] or DummyFunction
		else
			func = EnemyNameSubtextFunctions[LocalVars.HeadlineEnemySubtext or 0] or DummyFunction
		end

		return func(unit)
	end
	return HealthTextDelegate(unit)
end



------------------------------------------------------------------------------
-- Local Variable
------------------------------------------------------------------------------

local function OnVariableChange(vars) LocalVars = vars end
HubData.RegisterCallback(OnVariableChange)


------------------------------------------------------------------------------
-- Add References
------------------------------------------------------------------------------



TidyPlatesContHubFunctions.SetCustomText = HealthTextDelegate
TidyPlatesContHubFunctions.SetCustomTextBinary = CustomTextBinaryDelegate

