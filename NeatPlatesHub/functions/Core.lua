
------------------------------------------------------------------------------------
-- Neat Plates Hub
------------------------------------------------------------------------------------
local AddonName, HubData = ...;
local LocalVars = NeatPlatesHubDefaults
local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")
------------------------------------------------------------------------------------
HubData.Functions = {}
HubData.Colors = {}
NeatPlatesHubFunctions = {}
------------------------------------------------------------------------------------
local CallbackList = {}
function HubData.RegisterCallback(func) CallbackList[func] = true end
function HubData.UnRegisterCallback(func) CallbackList[func] = nil end

local CurrentProfileName = nil

local InCombatLockdown = InCombatLockdown

local CopyTable = NeatPlatesUtility.copyTable

local WidgetLib = NeatPlatesWidgets
local valueToString = NeatPlatesUtility.abbrevNumber

local MergeProfileValues = NeatPlatesHubHelpers.MergeProfileValues
local UpdateCVars = NeatPlatesHubHelpers.UpdateCVars

local EnableTankWatch = NeatPlatesWidgets.EnableTankWatch
local DisableTankWatch = NeatPlatesWidgets.DisableTankWatch
local EnableAggroWatch = NeatPlatesWidgets.EnableAggroWatch
local DisableAggroWatch = NeatPlatesWidgets.DisableAggroWatch

local GetFriendlyThreat = NeatPlatesUtility.GetFriendlyThreat
local IsTotem = NeatPlatesUtility.IsTotem
local IsAuraShown = NeatPlatesWidgets.IsAuraShown
local IsHealer = NeatPlatesUtility.IsHealer
local InstanceStatus = NeatPlatesUtility.InstanceStatus

local LastErrorMessage = 0


-- Combat
local IsEnemyTanked = NeatPlatesWidgets.IsEnemyTanked

local function IsOffTanked(unit)

	local unitid = unit.unitid
	if unitid then
		local targetOf = unitid.."target"	
		local targetGUID = UnitGUID(targetOf)
		local targetIsGuardian = false
		local guardians = {
			["61146"] = true, 	-- Black Ox Statue(61146)
			["103822"] = true,	-- Treant(103822)
			["61056"] = true, 	-- Primal Earth Elemental(61056)
			["95072"] = true, 	-- Greater Earth Elemental(95072)
		}

		if targetGUID then
			targetGUID = select(6, strsplit("-", UnitGUID(targetOf)))
			targetIsGuardian = guardians[targetGUID]
		end
		
		local targetIsTank = UnitIsUnit(targetOf, "pet") or targetIsGuardian or ("TANK" ==  UnitGroupRolesAssigned(targetOf))

		--if LocalVars.EnableOffTankHighlight and IsEnemyTanked(unit) then
		if LocalVars.EnableOffTankHighlight and targetIsTank then
			return true
		end
	end
end


-- General
local function DummyFunction() return end

-- Define the Menu for Threat Modes
NeatPlatesHubDefaults.ThreatWarningMode = "Auto"
NeatPlatesHubMenus.ThreatWarningModes = {
					{ text = L["Auto (Color Swap)"], value = "Auto",} ,
					{ text = L["Tank"], value = "Tank",} ,
					{ text = L["DPS/Healer"], value = "DPS",} ,
					}

HubData.Colors.NormalGrey = {r = .65, g = .65, b = .65, a = .4}
HubData.Colors.EliteGrey = {r = .9, g = .7, b = .3, a = .5}
HubData.Colors.BossGrey = {r = 1, g = .85, b = .1, a = .8}

-- Colors
HubData.Colors.BlueColor = {r = 60/255, g =  168/255, b = 255/255, }
HubData.Colors.GreenColor = { r = 96/255, g = 224/255, b = 37/255, }
HubData.Colors.RedColor = { r = 255/255, g = 51/255, b = 32/255, }
HubData.Colors.YellowColor = { r = 252/255, g = 220/255, b = 27/255, }
HubData.Colors.GoldColor = { r = 252/255, g = 140/255, b = 0, }
HubData.Colors.OrangeColor = { r = 255/255, g = 64/255, b = 0, }
HubData.Colors.WhiteColor = { r = 250/255, g = 250/255, b = 250/255, }

HubData.Colors.White = {r = 1, g = 1, b = 1}
HubData.Colors.Black = {r = 0, g = 0, b = 0}
HubData.Colors.BrightBlue =  {r = 0, g = 70/255, b = 240/255,} -- {r = 0, g = 75/255, b = 240/255,}
HubData.Colors.BrightBlueText = {r = 112/255, g = 219/255, b = 255/255,}
HubData.Colors.PaleBlue = {r = 0, g = 130/255, b = 225/255,}
HubData.Colors.PaleBlueText = {r = 194/255, g = 253/255, b = 1,}
HubData.Colors.DarkRed = {r = .9, g = 0.08, b = .08,}

local RaidClassColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

------------------------------------------------------------------------------------

local ReactionColors = {
	["FRIENDLY"] = {
		["PLAYER"] = {r = 0, g = 0, b = 1,},
		["NPC"] = {r = 0, g = 1, b = 0,},
	},
	["HOSTILE"] = {
		["PLAYER"] = {r = 1, g = 0, b = 0,},
		["NPC"] = {r = 1, g = 0, b = 0,},
	},
	["NEUTRAL"] = {
		["NPC"] = {r = 1, g = 1, b = 0,},
	},
	["TAPPED"] = {
		["NPC"] = {r = .45, g = .45, b = .45,},
	},
}



local NameReactionColors = {
	["FRIENDLY"] = {
		["PLAYER"] = {r = 60/255, g = 168/255, b = 255/255,},
		["NPC"] = {r = 96/255, g = 224/255, b = 37/255,},
	},
	["HOSTILE"] = {
		["PLAYER"] = {r = 255/255, g = 51/255, b = 32/255,},
		["NPC"] = {r = 255/255, g = 51/255, b = 32/255,},
	},
	["NEUTRAL"] = {
		["NPC"] = {r = 252/255, g = 180/255, b = 27/255,},
	},
	["TAPPED"] = {
		--["NPC"] = {r = .8, g = .8, b = 1,},
		["NPC"] = {r = .7, g = .7, b = .7,},
	},
}

HubData.Colors.ReactionColors = ReactionColors
HubData.Colors.NameReactionColors = NameReactionColors

------------------------------------------------------------------------------------
-- Helper Functions
------------------------------------------------------------------------------------

local function CallbackUpdate()
			for func in pairs(CallbackList) do
				func(LocalVars)
			end
end

local function EnableWatchers()
	if LocalVars.WidgetDebuffStyle == 2 then NeatPlatesWidgets.UseSquareDebuffIcon() else NeatPlatesWidgets.UseWideDebuffIcon()end
	--NeatPlatesUtility:EnableGroupWatcher()
	NeatPlatesUtility:EnableHealerTrack()
	--NeatPlatesWidgets:EnableTankWatch()

	CallbackUpdate()
end

local CreateVariableSet = NeatPlatesHubRapidPanel.CreateVariableSet


local function UseVariables(profileName)

	local suffix = profileName or L["Default"]
	if suffix then

		if CurrentProfileName ~= suffix then 	-- Stop repeat loading

			local objectName = "HubPanelProfile"..suffix

			LocalVars = NeatPlatesHubSettings[objectName] or CreateVariableSet(objectName)

			MergeProfileValues(LocalVars, NeatPlatesHubDefaults)		-- If the value doesn't exist in the settings, create it.

			CurrentProfileName = suffix

			CallbackUpdate()
		end

		return LocalVars
	end
end

---------------
-- Apply customization
---------------
local function ApplyFontCustomization(style, defaults)
	if not style then return end
	style.frame.y = ((LocalVars.FrameVerticalPosition-.5)*50)-16

	if LocalVars.TextUseBlizzardFont then
		style.name.typeface = STANDARD_TEXT_FONT
		style.level.typeface = STANDARD_TEXT_FONT
		style.spelltext.typeface = STANDARD_TEXT_FONT
		style.customtext.typeface = STANDARD_TEXT_FONT
	else
		style.name.typeface = defaults.name.typeface
		style.level.typeface = defaults.level.typeface
		style.spelltext.typeface = defaults.spelltext.typeface
		style.customtext.typeface = defaults.customtext.typeface
	end


end

local function ApplyCustomBarSize(style, defaults)

	if defaults then
		-- Alter Widths
		style.threatborder.width = defaults.threatborder.width * (LocalVars.FrameBarWidth or 1)
		style.healthborder.width = defaults.healthborder.width * (LocalVars.FrameBarWidth or 1)
		style.target.width = defaults.target.width * (LocalVars.FrameBarWidth or 1)
		style.healthbar.width = defaults.healthbar.width * (LocalVars.FrameBarWidth or 1)
		style.frame.width = defaults.frame.width * (LocalVars.FrameBarWidth or 1)
		style.eliteicon.x = defaults.eliteicon.x * (LocalVars.FrameBarWidth or 1)
	end
end

local function ApplyStyleCustomization(style, defaults)
	if not style then return end
	style.level.show = (LocalVars.TextShowLevel == true)
	style.target.show = (LocalVars.WidgetTargetHighlight == true)
	style.eliteicon.show = (LocalVars.WidgetEliteIndicator == true)

 	ApplyCustomBarSize(style, defaults)
	ApplyFontCustomization(style, defaults)
end


local function ValidateCombatRestrictedSettings()
	local CombatLockdown = InCombatLockdown()
	local time = GetTime()
	local settings = {
		["StyleEnemyBarsClickThrough"] = C_NamePlate.GetNamePlateEnemyClickThrough(),
		["StyleFriendlyBarsClickThrough"] = C_NamePlate.GetNamePlateFriendlyClickThrough(),
	}

	if CombatLockdown then
		-- Loop through affected settings to see if any of them were change, if so trigger a warning that they weren't applied correctly
		for k, v in pairs(settings) do
			if LastErrorMessage+5 < time and LocalVars[k] ~= v then
				LastErrorMessage = time
				print("|cffff6906NeatPlates:|cffffdd00 Some settings could not be applied properly due to certain combat restrictions.")
			end
		end
	end

	return not CombatLockdown
end

local function ApplyProfileSettings(theme, source, ...)
	-- When nil is passed, the theme is being deactivated
	if not theme then return end

	ReactionColors.FRIENDLY.NPC = LocalVars.ColorFriendlyNPC
	ReactionColors.FRIENDLY.PLAYER = LocalVars.ColorFriendlyPlayer
	ReactionColors.HOSTILE.NPC = LocalVars.ColorHostileNPC
	ReactionColors.HOSTILE.PLAYER = LocalVars.ColorHostilePlayer
	ReactionColors.NEUTRAL.NPC = LocalVars.ColorNeutral

	NameReactionColors.FRIENDLY.NPC = LocalVars.TextColorFriendlyNPC
	NameReactionColors.FRIENDLY.PLAYER = LocalVars.TextColorFriendlyPlayer
	NameReactionColors.HOSTILE.NPC = LocalVars.TextColorHostileNPC
	NameReactionColors.HOSTILE.PLAYER = LocalVars.TextColorHostilePlayer
	NameReactionColors.NEUTRAL.NPC = LocalVars.TextColorNeutral

	EnableWatchers()
	ApplyStyleCustomization(theme["Default"], theme["DefaultBackup"])
	ApplyFontCustomization(theme["NameOnly"], theme["NameOnlyBackup"])

	-- Set Space Between Buffs & Debuffs
	NeatPlatesWidgets.SetSpacerSlots(math.ceil(LocalVars.SpacerSlots))
	NeatPlatesWidgets.SetEmphasizedSlots(math.ceil(LocalVars.EmphasizedSlots))

	NeatPlates:ToggleInterruptedCastbars(LocalVars.IntCastEnable, LocalVars.IntCastWhoEnable)	-- Toggle Interrupt Castbar

	-- Manage ClickThrough option of nameplate bars.
	if ValidateCombatRestrictedSettings() then
		C_NamePlate.SetNamePlateFriendlyClickThrough(LocalVars.StyleFriendlyBarsClickThrough or false)
		C_NamePlate.SetNamePlateEnemyClickThrough(LocalVars.StyleEnemyBarsClickThrough or false)
	end

	NeatPlates:ForceUpdate()
	RaidClassColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
end


-- From Neon.lua...
local LocalVars = NeatPlatesHubDamageVariables

local function OnInitialize(plate, theme)
	if theme and theme.WidgetConfig then
		NeatPlatesHubFunctions.OnInitializeWidgets(plate, theme.WidgetConfig)
	end
end

local function OnActivateTheme(theme)

	if not theme then
		NeatPlatesWidgets.DisableAuraWatcher()
	end
	-- This gets called when switching themes.
	-- Ideally, it should clear out old widget data when nil is reported.
end

local function OnChangeProfile(theme, profile)
	if profile then

		UseVariables(profile)

		local theme = NeatPlates:GetTheme()

		if theme then
			if theme.ApplyProfileSettings then
				ApplyProfileSettings(theme, "From OnChangeProfile")
				NeatPlates:ForceUpdate()
			end
		end
	end
end

-- Quickly add functions to a Theme
local function ApplyHubFunctions(theme)
	theme.SetNameColor = NeatPlatesHubFunctions.SetNameColor
	theme.SetScale = NeatPlatesHubFunctions.SetScale
	theme.GetClickableArea = NeatPlatesHubFunctions.GetClickableArea
	theme.SetAlpha = NeatPlatesHubFunctions.SetAlpha
	theme.SetHealthbarColor = NeatPlatesHubFunctions.SetHealthbarColor
	theme.SetThreatColor = NeatPlatesHubFunctions.SetThreatColor
	theme.SetCastbarColor = NeatPlatesHubFunctions.SetCastbarColor
	theme.OnUpdate = NeatPlatesHubFunctions.OnUpdate
	theme.OnContextUpdate = NeatPlatesHubFunctions.OnContextUpdate
	theme.ShowConfigPanel = ShowNeatPlatesHubDamagePanel
	theme.SetStyle = NeatPlatesHubFunctions.SetStyleBinary
	theme.SetCustomText = NeatPlatesHubFunctions.SetCustomTextBinary
	theme.OnInitialize = OnInitialize		-- Need to provide widget positions
	theme.OnActivateTheme = OnActivateTheme -- called by Neat Plates Core, Theme Loader
	theme.ApplyProfileSettings = ApplyProfileSettings
	theme.OnChangeProfile = OnChangeProfile

	-- Make Backup Copies of the default settings of the theme styles
	theme["DefaultBackup"] = CopyTable(theme["Default"])
	theme["NameOnlyBackup"] = CopyTable(theme["NameOnly"])

	if barStyle then
		backupStyle.threatborder.default_width = barStyle.threatborder.width
		backupStyle.healthborder.default_width = barStyle.healthborder.width
		backupStyle.target.default_width = barStyle.target.width
		backupStyle.healthbar.default_width = barStyle.healthbar.width
		backupStyle.eliteicon.default_x = barStyle.eliteicon.x
	end

	return theme
end

---------------------------------------------
-- Function List
---------------------------------------------
NeatPlatesHubFunctions.IsOffTanked = IsOffTanked
NeatPlatesHubFunctions.UseVariables = UseVariables
NeatPlatesHubFunctions.EnableWatchers = EnableWatchers
NeatPlatesHubFunctions.ApplyHubFunctions = ApplyHubFunctions




