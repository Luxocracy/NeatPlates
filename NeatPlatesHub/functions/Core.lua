
------------------------------------------------------------------------------------
-- NeatPlates Hub
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

local EMPTY_TEXTURE = "Interface\\Addons\\NeatPlates\\Media\\Empty"

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
		
		local targetIsTank = UnitIsUnit(targetOf, "pet") or targetIsGuardian or IsEnemyTanked(unit)

		--if LocalVars.EnableOffTankHighlight and IsEnemyTanked(unit) then
		if LocalVars.EnableOffTankHighlight and targetIsTank then
			return true
		end
	end
end

local function ThreatExceptions(unit, isTank, noSafeColor)
	if not unit or not unit.unitid then return end
	local unitGUID = UnitGUID(unit.unitid)
	if not unitGUID then return end
	unitGUID = select(6, strsplit("-", unitGUID))
	-- Mobs from Reaping affix
	local souls = {
		["148893"] = true,
		["148894"] = true,
		["148716"] = true,
	}

	-- Classic temporary fix, if enemy unit is in combat & the player is either in a party or has a pet.
	local playerIsTarget = unit.fixate or UnitIsUnit(unit.unitid.."target", "player")
	local showClassicThreat = (unit.reaction ~= "FRIENDLY" and unit.type == "NPC" and playerIsTarget and (UnitInParty("player") or UnitExists("pet")))

	-- Special case dealing with mobs from Reaping affix and units that fixate
	if showClassicThreat or souls[unitGUID] or unit.fixate then
		if (playerIsTarget and isTank) or (not playerIsTarget and not isTank) then
				return noSafeColor or LocalVars.ColorThreatSafe
		else
			return LocalVars.ColorThreatWarning
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
	if LocalVars.WidgetDebuffStyle == 2 then NeatPlatesWidgets.UseSquareDebuffIcon(LocalVars.AuraScale) else NeatPlatesWidgets.UseWideDebuffIcon(LocalVars.AuraScale)end
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

local function GetCustomizationOption(profile, category, option)
	local ProfileVars = NeatPlatesHubSettings[profile]
	if not category then return ProfileVars.Customization end
	return ProfileVars.Customization[category][option]
end

local function SetCustomizationOption(profile, category, option, key, value)
	local ProfileVars = NeatPlatesHubSettings[profile]
	if type(category) == "table" then ProfileVars.Customization = CopyTable(category); return end
	ProfileVars.Customization[category] = ProfileVars.Customization[category] or {}
	if type(option) == "table" then ProfileVars.Customization[category] = CopyTable(option); return end
	ProfileVars.Customization[category][option] = ProfileVars.Customization[category][option] or {}
	if not key then ProfileVars.Customization[category][option] = {}; return end
	if type(key) == "table" then
		-- Loop over keys. (Because width/height is sometimes defined fully as 'width' or just the first character 'w')
		for _,k in pairs(key) do
			ProfileVars.Customization[category][option][k] = value
		end
	 else
	 	ProfileVars.Customization[category][option][key] = value
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
		style.subtext.typeface = STANDARD_TEXT_FONT
		style.level.typeface = STANDARD_TEXT_FONT
		style.spelltext.typeface = STANDARD_TEXT_FONT
		style.spelltarget.typeface = STANDARD_TEXT_FONT
		style.customtext.typeface = STANDARD_TEXT_FONT
	else
		style.name.typeface = defaults.name.typeface
		style.subtext.typeface = defaults.subtext.typeface
		style.level.typeface = defaults.level.typeface
		style.spelltext.typeface = defaults.spelltext.typeface
		style.spelltarget.typeface = defaults.spelltarget.typeface
		style.customtext.typeface = defaults.customtext.typeface
	end


end

local function ApplyScaleOptions(widget, default, scale)
	if not widget then return widget end
	if widget.width then widget.width = default.width * (scale.x or 1) end
	if widget.height then widget.height = default.height * (scale.y or 1) end
	if widget.x then widget.x = default.x + (scale.offset.x or 0) end
	if widget.y then widget.y = default.y + (scale.offset.y or 0) end

	return widget
end

local function ApplyScaleOptionCustomization(widget, defaults, style, styleDefault)
	widget.DebuffWidget = ApplyScaleOptions(widget.DebuffWidget, defaults.DebuffWidget, LocalVars.WidgetAuraScaleOptions)
	widget.DebuffWidgetPlus = ApplyScaleOptions(widget.DebuffWidgetPlus, defaults.DebuffWidgetPlus, LocalVars.WidgetAuraScaleOptions)
end

local function ApplyCustomBarSize(style, defaults)
	defaults = style; -- Temporary test fix to this section overwriting 'Theme Customization'
	if defaults then
		-- Alter Widths
		-- Main Frame
		local frameMod = math.max((LocalVars.FrameBarWidth or 1), (LocalVars.CastBarWidth or 1))

		if defaults.frame.width then style.frame.width = defaults.frame.width * frameMod end
		if defaults.frame.x then style.frame.x = defaults.frame.x * frameMod end

		-- Healthbar
		local Healthbar = {"threatborder", "healthborder", "healthbar", "customtext", "level", "subtext", "name", "powerbar"}
		for k,v in pairs(Healthbar) do
			if defaults[v].width then style[v].width = defaults[v].width * (LocalVars.FrameBarWidth or 1) end
			if defaults[v].x then style[v].x = defaults[v].x * (LocalVars.FrameBarWidth or 1) end
		end

		-- Castbar
		local Castbar = {"castborder", "castnostop", "castbar", "spellicon", "spelltext", "spelltarget", "durationtext"}
		for k,v in pairs(Castbar) do
			if defaults[v].width then style[v].width = defaults[v].width * (LocalVars.CastBarWidth or 1) end
			if defaults[v].x then style[v].x = defaults[v].x * (LocalVars.CastBarWidth or 1) end
		end

		-- Things we don't want to apply width to
		style.eliteicon.x = defaults.eliteicon.x * (LocalVars.FrameBarWidth or 1)
		if style.eliteicon.width > 64 then style.eliteicon.width = defaults.eliteicon.width * (LocalVars.FrameBarWidth or 1) end
		
	
		-- Defined elsewhere so they need to be handled differently
		style.target.width = style.target.width * (LocalVars.FrameBarWidth or 1)
		style.focus.width = style.focus.width * (LocalVars.FrameBarWidth or 1)
		style.mouseover.width = style.mouseover.width * (LocalVars.FrameBarWidth or 1)

		-- Spelltext offset when durationtext is enabled
		if style.spelltext and style.spelltext.durationtext then
			local ref
			if LocalVars.CastbarDurationMode ~= "None" then
				ref = style.spelltext.durationtext	-- Override values
			else
				ref = defaults.spelltext -- Original values
			end
			for k,v in pairs(ref) do
				if k == "width" or k == "x" then
					v = v * (LocalVars.CastBarWidth or 1)
				end
				style.spelltext[k] = v
			end
		end
	end
end

local function ApplyThemeCustomization(theme)
	local categories = {"Default", "NameOnly", "WidgetConfig"}

	-- Restore theme to default settings
	theme["Default"] = CopyTable(theme["DefaultBackup"])
	theme["NameOnly"] = CopyTable(theme["NameOnlyBackup"])
	theme["WidgetConfig"] = CopyTable(theme["WidgetConfigBackup"])

	-- Highlighting customizations
	local indicators = {
		["target"] = {mode = LocalVars.HighlightTargetMode, scale = LocalVars.HighlightTargetScale},
		["focus"] = {mode = LocalVars.HighlightFocusMode, scale = LocalVars.HighlightFocusScale},
		["mouseover"] = {mode = LocalVars.HighlightMouseoverMode, scale = LocalVars.HighlightMouseoverScale}
	}

	local style = theme["Default"]
	for k,object in pairs(indicators) do
		style[k] = style[k] or {}
		local mode = object.mode
		--local scale = object.scale

		if mode then
			-- Set Indicator style, 1 = Disabled, 2 = Healthbar, 3 = Theme Default, 4 = Arrow Top, 5 = Arrow Sides, 6 = Arrow Right, 7 = Arrow Left
			if mode == 3 then
				style[k] = CopyTable(style.targetindicator)
			elseif mode == 4 then
				style[k] = CopyTable(style.targetindicator_arrowtop)
			elseif mode == 5 then
				style[k] = CopyTable(style.targetindicator_arrowsides)
			elseif mode == 6 then
				style[k] = CopyTable(style.targetindicator_arrowright)
			elseif mode == 7 then
				style[k] = CopyTable(style.targetindicator_arrowleft)
			end

			--style[k].height = style[k].height * scale.x
			--style[k].width = style[k].width * scale.y
			--style[k].x = style[k].x * scale.x + scale.offset.x
			--style[k].y = style[k].y * scale.y + scale.offset.y
		end
	end

	-- Apply customized style to each category
	for i,category in pairs(categories) do
		local style = theme[category]
		local modifications = LocalVars.Customization[category]

		-- Apply the customized style
		if modifications then
			for k,v in pairs(modifications) do
				if style[k] then
					for k2,v2 in pairs(v) do
						local objectType = nil
						local value = v2
						if type(v2) == "table" and v2.value ~= nil then
							objectType = v2.type
							value = v2.value
						end

						if objectType then
							if type(style[k][k2]) == "number" and objectType == "offset" then
								style[k][k2] = style[k][k2] + value
							else
								style[k][k2] = value
							end
						else
							-- Backwards compatability
							if type(style[k][k2]) == "number" then
								style[k][k2] = style[k][k2] + value
							else
								style[k][k2] = value
							end
						end
					end
				end
			end
		end
	end
end

-- Healthbar to Powerbar ratio
local function ApplyBarRatios(style, defaults)
	local ratio = 0.6
	local baseHeight = defaults.healthbar.height
	local anchorPoint = defaults.healthbar.anchor
	local offsetMultiplier = 1
	if anchorPoint == "CENTER" then offsetMultiplier = 0.5 end
	-- set height of bars
	style.healthbar.height = baseHeight * ratio
	style.powerbar.height = baseHeight * (1 - ratio)
	-- offset bars
	--style.powerbar.y =  defaults.powerbar.y - (style.healthbar.height * offsetMultiplier)
	style.powerbar.y =  defaults.powerbar.y - ((style.healthbar.height) * offsetMultiplier)
	style.healthbar.y =  defaults.healthbar.y + ((style.powerbar.height) * offsetMultiplier)
end

local function ApplyStyleCustomization(style, defaults, widget, widgetDefaults)
	if not style then return end
	style.level.show = (LocalVars.TextShowLevel == true)
	style.target.show = (LocalVars.HighlightTargetMode > 2)
	style.focus.show = (LocalVars.HighlightFocusMode > 2)
	style.mouseover.show = (LocalVars.HighlightMouseoverMode > 2)
	style.eliteicon.show = (LocalVars.WidgetEliteIndicator == true)
	style.spellicon.show = (style.spellicon.enabled and LocalVars.SpellIconEnable)
	style.spelltarget.show = (style.spelltarget.enabled and LocalVars.SpellTargetEnable)
	style.customtext.shadow = LocalVars.TextStatusForceShadow or defaults.customtext.shadow
	--style.rangeindicator.show = (LocalVars.WidgetRangeIndicator == true)

	if not style.spellicon.show and style.castborder.noicon ~= EMPTY_TEXTURE and style.castnostop.noicon ~= EMPTY_TEXTURE then
		style.castborder.texture = defaults.castborder.noicon
		style.castnostop.texture = defaults.castnostop.noicon
	else
		style.castborder.texture = defaults.castborder.texture
		style.castnostop.texture = defaults.castnostop.texture
	end

	--ApplyBarRatios(style, defaults)

	style.target.color = LocalVars.ColorTarget
	style.focus.color = LocalVars.ColorFocus
	style.mouseover.color = LocalVars.ColorMouseover

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
	ApplyThemeCustomization(theme)
	ApplyStyleCustomization(theme["Default"], theme["DefaultBackup"])
	ApplyFontCustomization(theme["NameOnly"], theme["NameOnlyBackup"])
	ApplyScaleOptionCustomization(theme["WidgetConfig"], theme["WidgetConfigBackup"], theme["Default"], theme["DefaultBackup"])

	-- Set Space Between Buffs & Debuffs
	NeatPlatesWidgets.SetSpacerSlots(math.ceil(LocalVars.SpacerSlots))
	NeatPlatesWidgets.SetEmphasizedSlots(math.ceil(LocalVars.EmphasizedSlots))

	-- Aura Update Interval
	local interval = 1
	if(LocalVars.PreciseAuraThreshold > 0) then interval = .1 end
	NeatPlatesWidgets.SetUpdateInterval(interval)

	-- There might be a better way to handle these settings, but this works for now.
	NeatPlates:SetCoreVariables(LocalVars)

	-- Manage ClickThrough option of nameplate bars.
	if ValidateCombatRestrictedSettings() then
		C_NamePlate.SetNamePlateFriendlyClickThrough(LocalVars.StyleFriendlyBarsClickThrough or false)
		C_NamePlate.SetNamePlateEnemyClickThrough(LocalVars.StyleEnemyBarsClickThrough or false)
	end

	NeatPlates.UpdateNameplateSize() -- Set/Update nameplate size

	NeatPlates:ForceUpdate()
	RaidClassColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
end

local function ApplyRequiredCVars(NeatPlatesOptions)
	if InCombatLockdown() then return end
	if NeatPlatesOptions.EnforceRequiredCVars then
		if not NeatPlatesOptions.BlizzardScaling then SetCVar("nameplateMinScale", 1) end  -- General requirement, prevents issues with 'hitbox' of nameplates and scaling
	end
end


-- From Neon.lua...
--local LocalVars = NeatPlatesHubDamageVariables

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
		if NeatPlatesCustomizationPanel then NeatPlatesCustomizationPanel:Hide() end -- Hide the theme customization frame. (Has to be done before we change the 'LocalVars' variable set)

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
	theme.SetPowerbarColor = NeatPlatesHubFunctions.SetPowerbarColor
	theme.SetThreatColor = NeatPlatesHubFunctions.SetThreatColor
	theme.SetCastbarColor = NeatPlatesHubFunctions.SetCastbarColor
	theme.OnUpdate = NeatPlatesHubFunctions.OnUpdate
	theme.OnContextUpdate = NeatPlatesHubFunctions.OnContextUpdate
	theme.ShowConfigPanel = ShowNeatPlatesHubDamagePanel
	theme.SetStyle = NeatPlatesHubFunctions.SetStyleBinary
	theme.SetCustomText = NeatPlatesHubFunctions.SetCustomText
	theme.SetSubText = NeatPlatesHubFunctions.SetSubText
	theme.SetCastbarDuration = NeatPlatesHubFunctions.SetCastbarDuration
	theme.OnInitialize = OnInitialize		-- Need to provide widget positions
	theme.OnActivateTheme = OnActivateTheme -- called by NeatPlates Core, Theme Loader
	theme.ApplyProfileSettings = ApplyProfileSettings
	theme.ApplyThemeCustomization = ApplyThemeCustomization
	theme.OnChangeProfile = OnChangeProfile

	-- Make Backup Copies of the default settings of the theme styles
	theme["DefaultBackup"] = CopyTable(theme["Default"])
	theme["NameOnlyBackup"] = CopyTable(theme["NameOnly"])
	theme["WidgetConfigBackup"] = CopyTable(theme["WidgetConfig"])

	if barStyle then
		backupStyle.threatborder.default_width = barStyle.threatborder.width
		backupStyle.healthborder.default_width = barStyle.healthborder.width
		backupStyle.target.default_width = barStyle.target.width
		backupStyle.focus.default_width = barStyle.target.width
		backupStyle.mouseover.default_width = barStyle.target.width
		backupStyle.healthbar.default_width = barStyle.healthbar.width
		backupStyle.eliteicon.default_x = barStyle.eliteicon.x
	end

	return theme
end

---------------------------------------------
-- Function List
---------------------------------------------
NeatPlatesHubFunctions.IsOffTanked = IsOffTanked
NeatPlatesHubFunctions.ThreatExceptions = ThreatExceptions
NeatPlatesHubFunctions.UseVariables = UseVariables
NeatPlatesHubFunctions.EnableWatchers = EnableWatchers
NeatPlatesHubFunctions.ApplyHubFunctions = ApplyHubFunctions
NeatPlatesHubFunctions.ApplyRequiredCVars = ApplyRequiredCVars
NeatPlatesHubFunctions.GetCustomizationOption = GetCustomizationOption
NeatPlatesHubFunctions.SetCustomizationOption = SetCustomizationOption




