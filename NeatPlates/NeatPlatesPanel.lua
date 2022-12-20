---------------------------------------------------------------------------------------------------------------------
-- NeatPlates Interface Panel
---------------------------------------------------------------------------------------------------------------------

local AddonName, NeatPlatesInternal = ...
NeatPlatesPanel = {}
NeatPlatesHubMenus = NeatPlatesHubMenus or {}

local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")

local SetTheme = NeatPlatesInternal.SetTheme	-- Use the protected version

local version = GetAddOnMetadata("NeatPlates", "version")
local versionString = "|cFF666666"..version

local PanelHelpers = NeatPlatesUtility.PanelHelpers
local NeatPlatesInterfacePanel = PanelHelpers:CreatePanelFrame( "NeatPlatesInterfacePanel", "NeatPlates", nil, NeatPlatesBackdrop)
-- Attach update functions (Has to be setup earlier because of Dragonflight)
NeatPlatesInterfacePanel.okay = OnOkay
NeatPlatesInterfacePanel.refresh = OnRefresh

NeatPlatesInterfacePanel.OnCommit = NeatPlatesInterfacePanel.okay;
NeatPlatesInterfacePanel.OnDefault = NeatPlatesInterfacePanel.default;
NeatPlatesInterfacePanel.OnRefresh = NeatPlatesInterfacePanel.refresh;
local category
if Settings and not NEATPLATES_IS_CLASSIC then
	-- TODO: Figure out why the new, proper, method isn't working with subcategories
	-- category = Settings.RegisterCanvasLayoutCategory(NeatPlatesInterfacePanel, NeatPlatesInterfacePanel.name, NeatPlatesInterfacePanel.name);
	-- Settings.RegisterAddOnCategory(category);
	category = InterfaceOptions_AddCategory(NeatPlatesInterfacePanel);
	category.expanded = true -- Open by default
else
	category = InterfaceOptions_AddCategory(NeatPlatesInterfacePanel);
end

local CallIn = NeatPlatesUtility.CallIn
local copytable = NeatPlatesUtility.copyTable
local RGBToHex = NeatPlatesUtility.RGBToHex

-- Localized fonts
if (LOCALE_koKR) then
	NeatPlatesLocalizedFont = "Fonts\\2002.TTF";
elseif (LOCALE_zhCN) then
	NeatPlatesLocalizedFont = "Fonts\\ARKai_T.ttf";
elseif (LOCALE_zhTW) then
	NeatPlatesLocalizedFont = "Fonts\\blei00d.TTF";
elseif (LOCALE_ruRU) then
	NeatPlatesLocalizedFont = "Fonts\\FRIZQT___CYR.TTF";
else
	NeatPlatesLocalizedFont = "Interface\\Addons\\NeatPlates\\Media\\DefaultFont.ttf";
	NeatPlatesLocalizedInputFont = "Fonts\\FRIZQT__.TTF"
	NeatPlatesLocalizedThreatFont = "FONTS\\arialn.ttf"
end

NeatPlatesLocalizedInputFont = NeatPlatesLocalizedInputFont or NeatPlatesLocalizedFont
NeatPlatesLocalizedThreatFont = NeatPlatesLocalizedThreatFont or NeatPlatesLocalizedFont

local font = NeatPlatesLocalizedFont or "Interface\\Addons\\NeatPlates\\Media\\DefaultFont.ttf"
local white, yellow, blue, red, orange, green = "|cFFFFFFFF", "|cffffff00", "|cFF3782D1", "|cFFFF1100", "|cFFFF6906", "|cFF60E025"

local function SetCastBars(enable)
	if enable then NeatPlates:EnableCastBars()
		else NeatPlates:DisableCastBars()
	end
end

local function ReplaceColorPatterns(text)
	text = text:gsub('%%yellow%%', yellow) -- Yellow
	text = text:gsub('%%blue%%', blue) -- BLue
	text = text:gsub('%%red%%', red) -- Red
	text = text:gsub('%%orange%%', orange) -- Orange
	return text
end

-------------------------------------------------------------------------------------
--  Default Options
-------------------------------------------------------------------------------------

local FirstTryTheme = "Neon"

local ActiveProfile = "None"

NeatPlatesSettings = {
	DefaultProfile = L["Default"],

	GlobalAdditonalAuras = {},
}

NeatPlatesOptions = {
	ActiveTheme = nil,

	FirstSpecProfile = NeatPlatesSettings.DefaultProfile,
	SecondSpecProfile = NeatPlatesSettings.DefaultProfile,
	ThirdSpecProfile = NeatPlatesSettings.DefaultProfile,
	FourthSpecProfile = NeatPlatesSettings.DefaultProfile,

	FriendlyAutomation = {},
	EnemyAutomation = {},
	EmulatedTargetPlate = false,
	DisableCastBars = false,
	ForceBlizzardFont = false,
	BlizzardScaling = false,
	BlizzardNameVisibility = false,
	BlizzardWidgets = true,
	OverrideOutline = 1,
	EnforceRequiredCVars = true,
	ForceHealthUpdates = false,

	NameplateClickableHeight = 1,
	NameplateClickableWidth = 1,
	WelcomeShown = false,
}

local NeatPlatesOptionsDefaults = copytable(NeatPlatesOptions)
local NeatPlatesSettingsDefaults = copytable(NeatPlatesSettings)
local NeatPlatesThemeNames = {}

local OutlineStyleItems = {
	{ text = L["Default"],  },
	{ text = L["None"],  },
	{ text = L["Thin Outline"],  },
	{ text = L["Thick Outline"],  },
}

local HubProfileList = {}


local function GetProfile()
	return ActiveProfile
end

NeatPlates.GetProfile = GetProfile


function NeatPlatesPanel.AddProfile(self, profileName)
	if profileName then
		HubProfileList[#HubProfileList+1] = { text = profileName, value = profileName }
	end
end

function NeatPlatesPanel.RemoveProfile(self, profileName)
	table.foreach(HubProfileList, function(i, profile)
		if profile.value == profileName then table.remove(HubProfileList, i) end
	end)
end

local function RemoveProfile(panel)
	if panel.objectName == "HubPanelProfile"..NeatPlatesSettings.DefaultProfile then print(orange.."NeatPlates: "..red..L["Sorry, can't delete the Default profile :("]); return false end

	panel:Hide()	-- Hide panel, as a frame cannot be deleted

	-- Remove interface category for profile
	if not Settings then
		table.foreach(INTERFACEOPTIONS_ADDONCATEGORIES, function(i, category)
			if category.name == panel.name then INTERFACEOPTIONS_ADDONCATEGORIES[i] = nil end
		end)
	else
		local category = Settings.GetCategory(panel.parent)
		table.foreach(category.subcategories, function(i, c)
			if c.name == panel.name then
				c:SetParentCategory(nil)
				table.remove(category.subcategories, i)
			end
		end)
	end

	NeatPlatesHubRapidPanel.RemoveVariableSet(panel)	-- Remove stored variables
	NeatPlatesPanel:RemoveProfile(panel.objectName:gsub("HubPanelProfile", "")) -- Object Name with prefix removed
	-- InterfaceAddOnsList_Update()	-- Update Interface Options to remove the profile
	return true
end

local function ValidateProfileName(name, callback)
	if not name or name == "" then
		-- Invalid Name
		print(orange.."NeatPlates: "..red..L["You need to specify a 'Profile Name'."])
	elseif NeatPlatesHubSettings.profiles[name] then
		-- Profile name alredy exists, ask permission to overwrite.
		StaticPopupDialogs["NeatPlates_OverwriteProfile"] = {
		  text = L["A profile with this name already exists, do you wish to overwrite it?"],
		  button1 = YES,
		  button2 = NO,
		  OnAccept = function()
		  	callback(true)	-- Profile name exists, but it is okay to overwrite it.
		  	print(orange.."NeatPlates: "..blue..name:gsub(".+", L["The profile '%1' was successfully overwritten."]))
		  end,
		  OnCancel = function() print(orange.."NeatPlates: "..yellow..name:gsub(".+", L["The profile '%1' already exists, try a different name."])) end,
		  timeout = 0,
		  whileDead = true,
		  hideOnEscape = true,
		  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
		}
		StaticPopup_Show("NeatPlates_OverwriteProfile")
	else
		callback(false) -- Profile name doesn't exist, create it.
	end
end

local function SetNameplateVisibility(cvar, options, event)
	local inCombat = UnitAffectingCombat("player")
	local inInstance, instanceType = IsInInstance()
	instanceType = instanceType or "scenario"
	local instanceOptions = (options.Dungeon or options.Raid or options.Battleground or options.Arena or options.Scenario)
	local instanceTypes = {party = options.Dungeon, raid = options.Raid, pvp = options.Battleground, arena = options.Arena, scenario = options.Scenario}
	local enable

	if event == "PLAYER_ENTERING_WORLD" then
		-- Instance Automation
		if instanceOptions and inInstance then
			if instanceTypes[instanceType] == "show" then
				enable = true
			elseif instanceTypes[instanceType] == "hide" then
				enable = false
			end
		end

		-- World Automation
		if options.World and not inInstance then enable = options.World == "show" end
	end

	if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
		-- Combat Automation
		if (enable or enable == nil) and options.Combat then enable = ((inCombat and options.Combat == "show") or (not inCombat and options.Combat == "hide")) end
	end

	-- Set CVars
	if enable == true then
		SetCVar(cvar, 1)
	elseif enable == false then
		SetCVar(cvar, 0)
	end
end

local function GetClickableArea()
	return NeatPlatesOptions.NameplateClickableWidth or 1, NeatPlatesOptions.NameplateClickableHeight or 1
end


--[[
function NeatPlates:ReloadTheme()
	SetTheme(NeatPlatesInternal.activeThemeName)
	NeatPlatesOptions.ActiveTheme = NeatPlatesInternal.activeThemeName
	NeatPlates:ForceUpdate()
end
--]]

NeatPlatesPanel.GetClickableArea = GetClickableArea

-------------------------------------------------------------------------------------
-- Panel
-------------------------------------------------------------------------------------
local ThemeDropdownMenuItems = {}

local function ApplyAutomationSettings()
	SetCastBars(not NeatPlatesOptions.DisableCastBars)
	NeatPlates.OverrideFonts(NeatPlatesOptions.ForceBlizzardFont)
	NeatPlates.ToggleHealthTicker(NeatPlatesOptions.ForceHealthUpdates)
	if NEATPLATES_IS_CLASSIC then
		NeatPlates:ToggleEmulatedTargetPlate(NeatPlatesOptions.EmulatedTargetPlate)
	end

	if NeatPlatesOptions._EnableMiniButton then
		NeatPlatesUtility:CreateMinimapButton()
		NeatPlatesUtility:ShowMinimapButton()
	end

	NeatPlates:ForceUpdate()
end

local function VerifyPanelSettings()
	-- Verify per-character settings
	for k, v in pairs(NeatPlatesOptionsDefaults) do
		if NeatPlatesOptions[k] == nil or type(NeatPlatesOptions[k]) ~= type(NeatPlatesOptionsDefaults[k]) then
			NeatPlatesOptions[k] = NeatPlatesOptionsDefaults[k]
		end
	end
	-- Verify global settings
	for k, v in pairs(NeatPlatesSettingsDefaults) do
		-- Temporary to move over per-character settings that are now global.
		if NeatPlatesOptions[k] and NeatPlatesSettings[k] == NeatPlatesSettingsDefaults[k] then
			NeatPlatesSettings[k] = NeatPlatesOptions[k]
			NeatPlatesOptions[k] = nil
		end
		if NeatPlatesSettings[k] == nil or type(NeatPlatesSettings[k]) ~= type(NeatPlatesSettingsDefaults[k]) then
			NeatPlatesSettings[k] = NeatPlatesSettingsDefaults[k]
		end
	end
end

local function VerifySpecSelections()
	if NeatPlatesHubSettings then
		if not NeatPlatesHubSettings.profiles[NeatPlatesOptions.FirstSpecProfile] then NeatPlatesOptions.FirstSpecProfile = nil end
		if not NeatPlatesHubSettings.profiles[NeatPlatesOptions.SecondSpecProfile] then NeatPlatesOptions.SecondSpecProfile = nil end
		if not NeatPlatesHubSettings.profiles[NeatPlatesOptions.ThirdSpecProfile] then NeatPlatesOptions.ThirdSpecProfile = nil end
		if not NeatPlatesHubSettings.profiles[NeatPlatesOptions.FourthSpecProfile] then NeatPlatesOptions.FourthSpecProfile = nil end
	end
end

local function ApplyPanelSettings()
	-- Theme
	SetTheme(NeatPlatesOptions.ActiveTheme or FirstTryTheme)

	-- This is here in case the theme couldn't be loaded, and the core falls back to defaults
	--NeatPlatesOptions.ActiveTheme = NeatPlatesInternal.activeThemeName
	--local theme = NeatPlatesThemeList[NeatPlatesInternal.activeThemeName]

	-- Global Aura Filter Lists
	-- if NeatPlatesSettings.GlobalAuraList and not NeatPlatesSettings.GlobalAdditonalAuras then NeatPlatesHubHelpers.ConvertAuraListTable(NeatPlatesSettings.GlobalAuraList, NeatPlatesSettings.GlobalAuraLookup, NeatPlatesSettings.GlobalAuraPriority) end
	-- if NeatPlatesSettings.GlobalEmphasizedAuraList and not NeatPlatesSettings.GlobalAdditonalAuras then NeatPlatesHubHelpers.ConvertAuraListTable(NeatPlatesSettings.GlobalEmphasizedAuraList, NeatPlatesSettings.GlobalEmphasizedAuraLookup, NeatPlatesSettings.GlobalEmphasizedAuraPriority) end

	-- Convert old aura lists to new format
	if NeatPlatesSettings.GlobalAuraLookup and NeatPlatesSettings.GlobalEmphasizedAuraLookup and NeatPlatesSettings.GlobalAdditonalAura then
		NeatPlatesUtility.ConvertOldAuraListToAuraTable(NeatPlatesSettings.GlobalAdditonalAuras, NeatPlatesSettings.GlobalAuraLookup, NeatPlatesSettings.GlobalEmphasizedAuraLookup)

		-- Cleanup old vars
		-- NeatPlatesSettings.GlobalAuraList = nil
		NeatPlatesSettings.GlobalAuraLookup = nil
		NeatPlatesSettings.GlobalAuraPriority = nil
		-- NeatPlatesSettings.GlobalEmphasizedAuraList = nil
		NeatPlatesSettings.GlobalEmphasizedAuraLookup = nil
		NeatPlatesSettings.GlobalEmphasizedAuraPriority = nil
	end

	-- Load Hub Profile
	ActiveProfile = NeatPlatesSettings.DefaultProfile

	local currentSpec = 1
	if not NEATPLATES_IS_CLASSIC then
		currentSpec = GetSpecialization()
	end

	if currentSpec == 4 then
		ActiveProfile = NeatPlatesOptions.FourthSpecProfile
	elseif currentSpec == 3 then
		ActiveProfile = NeatPlatesOptions.ThirdSpecProfile
	elseif currentSpec == 2 then
		ActiveProfile = NeatPlatesOptions.SecondSpecProfile
	else
		ActiveProfile = NeatPlatesOptions.FirstSpecProfile
	end


	local theme = NeatPlates:GetTheme()

	if theme and theme.OnChangeProfile then theme:OnChangeProfile(ActiveProfile) end

	NeatPlates.OverrideOutline(NeatPlatesOptions.OverrideOutline)	-- Set Outline Override

	-- Store it for external usage
	--NeatPlatesOptions.ActiveProfile = ActiveProfile
	-- ** Use NeatPlates:GetProfile()

	-- Reset Widgets
	NeatPlates:ResetWidgets()
	NeatPlates:ForceUpdate()
end

local function SetClassColors(panel)
	-- Class Colors
	table.foreach(NEATPLATES_CLASS_COLORS, function(class, color)
		local frameName = "ClassColor"..class
		local frame = panel[frameName]
		if frame then
			frame:SetValue(color)
		end
	end)
end

local function GetCVarValues(panel)
	-- Recursive until we get the values to make sure they exist
	local Values = {
		NameplateTargetClamp = (function() if GetCVar("nameplateTargetRadialPosition") == "1" then return true else return false end end)(),
		NameplateStacking = (function() if GetCVar("nameplateMotion") == "1" then return true else return false end end)(),
		NameplateFriendlyNPCs = (function() if GetCVar("nameplateShowFriendlyNPCs") == "1" then return true else return false end end)(),
		NameplateMaxDistance = GetCVar("nameplateMaxDistance"),
		NameplateOccludedAlphaMult = GetCVar("nameplateOccludedAlphaMult"),
		NameplateNotSelectedAlpha = GetCVar("nameplateNotSelectedAlpha"),
		NameplateMinAlpha = GetCVar("nameplateMinAlpha"),
		NameplateMaxAlpha = GetCVar("nameplateMaxAlpha"),
		NameplateMinAlphaDistance = GetCVar("nameplateMinAlphaDistance"),
		NameplateMaxAlphaDistance = GetCVar("nameplateMaxAlphaDistance"),
		NameplateOverlapH = GetCVar("nameplateOverlapH"),
		NameplateOverlapV = GetCVar("nameplateOverlapV"),
	}

	local setVars = function()
		for k,v in pairs(Values) do
			if v and v ~= "DONE" and panel[k].SetChecked then panel[k]:SetChecked(v); Values[k] = "DONE" end
			if v and v ~= "DONE" and panel[k].SetValue then panel[k]:SetValue(v); Values[k] = "DONE" end
		end
	end

	setVars();
	C_Timer.NewTicker(0.5, setVars, 10)
end

local function GetPanelValues(panel)
	NeatPlatesOptions.ActiveTheme = panel.ActiveThemeDropdown:GetValue()

	NeatPlatesOptions.FriendlyAutomation = panel.FriendlyAutomation:GetValue()
	NeatPlatesOptions.EnemyAutomation = panel.EnemyAutomation:GetValue()
	NeatPlatesOptions.DisableCastBars = panel.DisableCastBars:GetChecked()
	NeatPlatesOptions.ForceBlizzardFont = panel.ForceBlizzardFont:GetChecked()
	NeatPlatesOptions.BlizzardScaling = panel.BlizzardScaling:GetChecked()
	NeatPlatesOptions.BlizzardNameVisibility = panel.BlizzardNameVisibility:GetChecked()
	NeatPlatesOptions.BlizzardWidgets = panel.BlizzardWidgets:GetChecked()
	NeatPlatesOptions.OverrideOutline = panel.OverrideOutline:GetValue()
	NeatPlatesOptions.EnforceRequiredCVars = panel.EnforceRequiredCVars:GetChecked()
	NeatPlatesOptions.ForceHealthUpdates = panel.ForceHealthUpdates:GetChecked()
	NeatPlatesOptions.NameplateClickableWidth = panel.NameplateClickableWidth:GetValue()
	NeatPlatesOptions.NameplateClickableHeight = panel.NameplateClickableHeight:GetValue()
	--NeatPlatesOptions.PrimaryProfile = panel.FirstSpecDropdown:GetValue()

	NeatPlatesOptions.FirstSpecProfile = panel.FirstSpecDropdown:GetValue()
	if not NEATPLATES_IS_CLASSIC then
		NeatPlatesOptions.SecondSpecProfile = panel.SecondSpecDropdown:GetValue()
		NeatPlatesOptions.ThirdSpecProfile = panel.ThirdSpecDropdown:GetValue()
		NeatPlatesOptions.FourthSpecProfile = panel.FourthSpecDropdown:GetValue()
	else
		NeatPlatesOptions.EmulatedTargetPlate = panel.EmulatedTargetPlate:GetChecked()
	end

	-- NeatPlatesSettings.GlobalAuraList = panel.GlobalAuraEditBox:GetValue()
	-- NeatPlatesSettings.GlobalEmphasizedAuraList = panel.GlobalEmphasizedAuraEditBox:GetValue()
end


local function SetPanelValues(panel)
	panel.ActiveThemeDropdown:SetValue(NeatPlatesOptions.ActiveTheme)

	panel.FirstSpecDropdown:SetValue(NeatPlatesOptions.FirstSpecProfile)
	if not NEATPLATES_IS_CLASSIC then
		panel.SecondSpecDropdown:SetValue(NeatPlatesOptions.SecondSpecProfile)
		panel.ThirdSpecDropdown:SetValue(NeatPlatesOptions.ThirdSpecProfile)
		panel.FourthSpecDropdown:SetValue(NeatPlatesOptions.FourthSpecProfile)
	else
		panel.EmulatedTargetPlate:SetChecked(NeatPlatesOptions.EmulatedTargetPlate)
	end

	panel.DisableCastBars:SetChecked(NeatPlatesOptions.DisableCastBars)
	panel.ForceBlizzardFont:SetChecked(NeatPlatesOptions.ForceBlizzardFont)
	panel.BlizzardScaling:SetChecked(NeatPlatesOptions.BlizzardScaling)
	panel.BlizzardNameVisibility:SetChecked(NeatPlatesOptions.BlizzardNameVisibility)
	panel.BlizzardWidgets:SetChecked(NeatPlatesOptions.BlizzardWidgets)
	panel.OverrideOutline:SetValue(NeatPlatesOptions.OverrideOutline)
	panel.EnforceRequiredCVars:SetChecked(NeatPlatesOptions.EnforceRequiredCVars)
	panel.ForceHealthUpdates:SetChecked(NeatPlatesOptions.ForceHealthUpdates)
	panel.NameplateClickableWidth:SetValue(NeatPlatesOptions.NameplateClickableWidth)
	panel.NameplateClickableHeight:SetValue(NeatPlatesOptions.NameplateClickableHeight)
	panel.FriendlyAutomation:SetValue(NeatPlatesOptions.FriendlyAutomation)
	panel.EnemyAutomation:SetValue(NeatPlatesOptions.EnemyAutomation)

	-- panel.GlobalAuraEditBox:SetValue(NeatPlatesSettings.GlobalAuraList)
	-- panel.GlobalEmphasizedAuraEditBox:SetValue(NeatPlatesSettings.GlobalEmphasizedAuraList)

	panel.GlobalAdditonalAuras:SetValue(NeatPlatesSettings.GlobalAdditonalAuras)

	-- Class Colors
	SetClassColors(panel)

	-- CVars
	GetCVarValues(panel)
end



local function OnValueChange(self)
	local panel = self:GetParent()
	GetPanelValues(panel)
	ApplyPanelSettings()
end


local function OnOkay(panel)
	panel = panel.MainFrame
	GetPanelValues(panel)
	ApplyPanelSettings()
	ApplyAutomationSettings()
	NeatPlatesHubFunctions.ApplyRequiredCVars(NeatPlatesOptions)
end


-- Loads values from the saved vars, and preps for display of the panel
local function OnRefresh(panel)
	panel = panel.MainFrame
	if not panel then return end

	SetPanelValues(panel)

	if NEATPLATES_IS_CLASSIC then
		panel.FirstSpecLabel:SetText(L["Active Profile"])
	else
		------------------------
		-- Spec Notes
		------------------------
		local currentSpec = GetSpecialization()

		------------------------
		-- First Spec Details
		------------------------
		local id, name = GetSpecializationInfo(1)

		if name then
			if currentSpec == 1 then name = name.." ("..L["Active"]..")" end
			panel.FirstSpecLabel:SetText(name)
		end
		------------------------
		-- Second Spec Details
		------------------------
		local id, name = GetSpecializationInfo(2)

		if name then
			if currentSpec == 2 then name = name.." ("..L["Active"]..")" end
			panel.SecondSpecLabel:SetText(name)
		end
		------------------------
		-- Third Spec Details
		------------------------
		local id, name = GetSpecializationInfo(3)

		if name then
			if currentSpec == 3 then name = name.." ("..L["Active"]..")" end
			panel.ThirdSpecLabel:SetText(name)
			panel.ThirdSpecLabel:Show()
			panel.ThirdSpecDropdown:Show()
		end
		------------------------
		-- Fourth Spec Details
		------------------------
		local id, name = GetSpecializationInfo(4)

		if name then
			if currentSpec == 4 then name = name.." ("..L["Active"]..")" end
			panel.FourthSpecLabel:SetText(name)
			panel.FourthSpecLabel:Show()
			panel.FourthSpecDropdown:Show()
		end
	end

end





local function CreateMenuTables()
	-- Convert the Theme List into a Menu List
	local themecount = 1

	ThemeDropdownMenuItems = {{text = "           ",},}

	if type(NeatPlatesThemeList) == "table" then
		for themename, themepointer in pairs(NeatPlatesThemeList) do
			NeatPlatesThemeNames[themecount] = themename
			--NeatPlatesThemeIndexes[themename] = themecount
			themecount = themecount + 1
		end
		-- Theme Choices
		for index, name in pairs(NeatPlatesThemeNames) do ThemeDropdownMenuItems[index] = {text = name, value = name } end
	end
	sort(ThemeDropdownMenuItems, function (a,b)
	  return (a.text < b.text)
    end)

end

local function OnMouseWheelScrollFrame(frame, value, name)
	local scrollbar = _G[frame:GetName() .. "ScrollBar"];
	local currentPosition = scrollbar:GetValue()
	local increment = 50

	-- Spin Up
	if ( value > 0 ) then scrollbar:SetValue(currentPosition - increment);
	-- Spin Down
	else scrollbar:SetValue(currentPosition + increment); end
end

local function SetCVarValue(self, cvar, isBool)
	if not InCombatLockdown() then
		local value
		if isBool then
			value = self:GetChecked() and 1 or 0	-- Convert to int bool
		else
			value = self.ceil(self:GetValue())
		end
		C_CVar.SetCVar(cvar, value, cvar)
	else
		print(orange.."NeatPlates: "..red..L["CVars could not applied due to combat"])
	end
end

local function BuildInterfacePanel(panel)
	local _panel = panel
	panel:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 2, right = 2, top = 2, bottom = 2 },})
	panel:SetBackdropColor(0.06, 0.06, 0.06, .7)

	panel.Label:SetFont(font, 26, "")
	panel.Label:SetPoint("TOPLEFT", panel, "TOPLEFT", 16+6, -16-4)
	panel.Label:SetTextColor(255/255, 105/255, 6/255)

	panel.Version = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	panel.Version:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -16-4)
	panel.Version:SetHeight(15)
	panel.Version:SetWidth(350)
	panel.Version:SetJustifyH("RIGHT")
	panel.Version:SetJustifyV("TOP")
	panel.Version:SetText(versionString)
	panel.Version:SetFont(font, 18, "")

	panel.DividerLine = panel:CreateTexture(nil, 'ARTWORK')
	panel.DividerLine:SetTexture("Interface\\Addons\\NeatPlatesHub\\shared\\ThinBlackLine")
	panel.DividerLine:SetSize( 500, 12)
	panel.DividerLine:SetPoint("TOPLEFT", panel.Label, "BOTTOMLEFT", -6, -12)

	-- Main Scrolled Frame
	------------------------------
	panel.MainFrame = CreateFrame("Frame")
	panel.MainFrame:SetWidth(412)
	panel.MainFrame:SetHeight(100) 		-- If the items inside the frame overflow, it automatically adjusts the height.

	-- Scrollable Panel Window
	------------------------------
	panel.ScrollFrame = CreateFrame("ScrollFrame","NeatPlates_Scrollframe", panel, "UIPanelScrollFrameTemplate")
	panel.ScrollFrame:SetPoint("LEFT", 16 )
	panel.ScrollFrame:SetPoint("TOP", panel.DividerLine, "BOTTOM", 0, -8 )
	panel.ScrollFrame:SetPoint("BOTTOMRIGHT", -32 , 16 )
	panel.ScrollFrame:SetScrollChild(panel.MainFrame)
	panel.ScrollFrame:SetScript("OnMouseWheel", OnMouseWheelScrollFrame)

	-- Scroll Frame Border
	------------------------------
	panel.ScrollFrameBorder = CreateFrame("Frame", "NeatPlatesScrollFrameBorder", panel.ScrollFrame, NeatPlatesBackdrop)
	panel.ScrollFrameBorder:SetPoint("TOPLEFT", -4, 5)
	panel.ScrollFrameBorder:SetPoint("BOTTOMRIGHT", 3, -5)
	panel.ScrollFrameBorder:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
												edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
												--tile = true, tileSize = 16,
												edgeSize = 16,
												insets = { left = 4, right = 4, top = 4, bottom = 4 }
												});
	panel.ScrollFrameBorder:SetBackdropColor(0.05, 0.05, 0.05, 0)
	panel.ScrollFrameBorder:SetBackdropBorderColor(0.2, 0.2, 0.2, 0)

	panel = panel.MainFrame
	----------------------------------------------
	-- Theme
	----------------------------------------------
	panel.ThemeCategoryTitle = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.ThemeCategoryTitle:SetFont(font, 22, "")
	panel.ThemeCategoryTitle:SetText(L["Theme"])
	panel.ThemeCategoryTitle:SetPoint("TOPLEFT", 20, -10)
	panel.ThemeCategoryTitle:SetTextColor(255/255, 105/255, 6/255)

	-- Dropdown
	panel.ActiveThemeDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesChooserDropdown", panel, ThemeDropdownMenuItems, NeatPlatesDefaultThemeName, nil, true)
	panel.ActiveThemeDropdown:SetPoint("TOPLEFT", panel.ThemeCategoryTitle, "BOTTOMLEFT", -20, -8)

	----------------------------------------------
	-- Profiles
	----------------------------------------------
	panel.ProfileLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.ProfileLabel:SetFont(font, 22, "")
	panel.ProfileLabel:SetText(L["Profile Selection"])
	panel.ProfileLabel:SetPoint("TOPLEFT", panel.ActiveThemeDropdown, "BOTTOMLEFT", 20, -20)
	panel.ProfileLabel:SetTextColor(255/255, 105/255, 6/255)

	---------------
	-- Column 1
	---------------
-- Spec 1
	panel.FirstSpecLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.FirstSpecLabel:SetPoint("TOPLEFT", panel.ProfileLabel,"BOTTOMLEFT", 0, -8)
	panel.FirstSpecLabel:SetWidth(170)
	panel.FirstSpecLabel:SetJustifyH("LEFT")
	panel.FirstSpecLabel:SetText(L["First Spec"])

	panel.FirstSpecDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesFirstSpecDropdown", panel, HubProfileList, NeatPlatesSettings.DefaultProfile, nil, true)
	panel.FirstSpecDropdown:SetPoint("TOPLEFT", panel.FirstSpecLabel, "BOTTOMLEFT", -20, -2)

	if not NEATPLATES_IS_CLASSIC then
		-- Spec 3
		panel.ThirdSpecLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		panel.ThirdSpecLabel:SetPoint("TOPLEFT", panel.FirstSpecDropdown,"BOTTOMLEFT", 20, -8)
		panel.ThirdSpecLabel:SetWidth(170)
		panel.ThirdSpecLabel:SetJustifyH("LEFT")
		panel.ThirdSpecLabel:SetText(L["Third Spec"])
		panel.ThirdSpecLabel:Hide()

		panel.ThirdSpecDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesThirdSpecDropdown", panel, HubProfileList, NeatPlatesSettings.DefaultProfile, nil, true)
		panel.ThirdSpecDropdown:SetPoint("TOPLEFT", panel.ThirdSpecLabel, "BOTTOMLEFT", -20, -2)
		panel.ThirdSpecLabel:Hide()

		---------------
		-- Column 2
		---------------
		-- Spec 2
		panel.SecondSpecLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		panel.SecondSpecLabel:SetPoint("TOPLEFT", panel.FirstSpecLabel,"TOPLEFT", 150, 0)
		panel.SecondSpecLabel:SetWidth(170)
		panel.SecondSpecLabel:SetJustifyH("LEFT")
		panel.SecondSpecLabel:SetText(L["Second Spec"])

		panel.SecondSpecDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesSecondSpecDropdown", panel, HubProfileList, NeatPlatesSettings.DefaultProfile, nil, true)
		panel.SecondSpecDropdown:SetPoint("TOPLEFT",panel.SecondSpecLabel, "BOTTOMLEFT", -20, -2)

		-- Spec 4
		panel.FourthSpecLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		panel.FourthSpecLabel:SetPoint("TOPLEFT", panel.SecondSpecDropdown,"BOTTOMLEFT", 20, -8)
		panel.FourthSpecLabel:SetWidth(170)
		panel.FourthSpecLabel:SetJustifyH("LEFT")
		panel.FourthSpecLabel:SetText(L["Fourth Spec"])
		panel.FourthSpecLabel:Hide()

		panel.FourthSpecDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesFourthSpecDropdown", panel, HubProfileList, NeatPlatesSettings.DefaultProfile, nil, true)
		panel.FourthSpecDropdown:SetPoint("TOPLEFT",panel.FourthSpecLabel, "BOTTOMLEFT", -20, -2)
		panel.FourthSpecDropdown:Hide()
	end


	----------------------------------------------
	-- Profile Management
	----------------------------------------------

	panel.ProfileManagementLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.ProfileManagementLabel:SetFont(font, 22, "")
	panel.ProfileManagementLabel:SetText(L["Profile Management"])
	if NEATPLATES_IS_CLASSIC then
		panel.ProfileManagementLabel:SetPoint("TOPLEFT", panel.FirstSpecDropdown, "BOTTOMLEFT", 20, -20)
	else
		panel.ProfileManagementLabel:SetPoint("TOPLEFT", panel.ThirdSpecDropdown, "BOTTOMLEFT", 20, -20)
	end
	panel.ProfileManagementLabel:SetTextColor(255/255, 105/255, 6/255)

	-- Profile Name
	panel.ProfileName = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.ProfileName:SetPoint("TOPLEFT", panel.ProfileManagementLabel, "BOTTOMLEFT", 0, -8)
	panel.ProfileName:SetWidth(170)
	panel.ProfileName:SetJustifyH("LEFT")
	panel.ProfileName:SetText(L["Profile Name"])

	panel.ProfileNameEditBox = CreateFrame("EditBox", "NeatPlatesOptions_ProfileNameEditBox", panel, "InputBoxTemplate")
	panel.ProfileNameEditBox:SetWidth(124)
	panel.ProfileNameEditBox:SetHeight(25)
	panel.ProfileNameEditBox:SetPoint("TOPLEFT", panel.ProfileName, "BOTTOMLEFT", 4, 0)
	panel.ProfileNameEditBox:SetAutoFocus(false)
	panel.ProfileNameEditBox:SetFont(NeatPlatesLocalizedInputFont or "Fonts\\FRIZQT__.TTF", 11, "")
	panel.ProfileNameEditBox:SetFrameStrata("DIALOG")

	-- Profile Color picker
	panel.ProfileColorBox = PanelHelpers:CreateColorBox("ProfileColor", panel, "", nil, 0, .5, 1, 1)
	panel.ProfileColorBox:SetPoint("LEFT", panel.ProfileNameEditBox, "RIGHT")
	panel.ProfileColorBox:SetScale(0.85)

	-- Create Profile Button
	panel.CreateProfile = CreateFrame("Button", "NeatPlatesOptions_CreateProfile", panel, "NeatPlatesPanelButtonTemplate")
	panel.CreateProfile:SetPoint("LEFT", panel.ProfileColorBox, "RIGHT", 3, 0)
	panel.CreateProfile:SetWidth(100)
	panel.CreateProfile:SetText(L["Add Profile"])

	-- Import Profile Button
	panel.ImportProfile = CreateFrame("Button", "NeatPlatesOptions_ImportProfile", panel, "NeatPlatesPanelButtonTemplate")
	panel.ImportProfile:SetPoint("LEFT", panel.CreateProfile, "RIGHT", 3, 0)
	panel.ImportProfile:SetWidth(100)
	panel.ImportProfile:SetText(L["Import Profile"])

	-- Copy Profile Dropdown
	panel.CopyProfile = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.CopyProfile:SetPoint("TOPLEFT", panel.ProfileNameEditBox, "BOTTOMLEFT", -3, -8)
	panel.CopyProfile:SetWidth(170)
	panel.CopyProfile:SetJustifyH("LEFT")
	panel.CopyProfile:SetText(L["Copy Profile"])

	panel.CopyProfileDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesCopyProfileDropdown", panel, HubProfileList, nil, nil, true)
	panel.CopyProfileDropdown:SetPoint("TOPLEFT", panel.CopyProfile, "BOTTOMLEFT", -20, -2)

	-- Remove Profile Dropdown
	panel.RemoveProfile = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.RemoveProfile:SetPoint("TOPLEFT", panel.CopyProfile, "TOPLEFT", 140, 0)
	panel.RemoveProfile:SetWidth(170)
	panel.RemoveProfile:SetJustifyH("LEFT")
	panel.RemoveProfile:SetText(L["Remove Profile"])

	panel.RemoveProfileDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesRemoveProfileDropdown", panel, HubProfileList, nil, nil, true)
	panel.RemoveProfileDropdown:SetPoint("TOPLEFT", panel.RemoveProfile, "BOTTOMLEFT", -20, -2)

	-- Export Profile Dropdown
	panel.ExportProfile = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.ExportProfile:SetPoint("TOPLEFT", panel.CopyProfileDropdown,"BOTTOMLEFT", 20, -8)
	panel.ExportProfile:SetWidth(170)
	panel.ExportProfile:SetJustifyH("LEFT")
	panel.ExportProfile:SetText(L["Export Profile"])

	panel.ExportProfileDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesExportProfileDropdown", panel, HubProfileList, nil, nil, true)
	panel.ExportProfileDropdown:SetPoint("TOPLEFT", panel.ExportProfile, "BOTTOMLEFT", -20, -2)

	----------------------------------------------
	-- Automation
	----------------------------------------------
	panel.AutomationLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.AutomationLabel:SetFont(font, 22, "")
	panel.AutomationLabel:SetText(L["Automation"])
	panel.AutomationLabel:SetPoint("TOPLEFT", panel.ExportProfileDropdown, "BOTTOMLEFT", 20, -20)
	panel.AutomationLabel:SetTextColor(255/255, 105/255, 6/255)


	---------------
	-- Column 1
	---------------
	-- Enemy Visibility
	panel.AutoShowEnemyLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.AutoShowEnemyLabel:SetPoint("TOPLEFT", panel.AutomationLabel,"BOTTOMLEFT", 0, -8)
	panel.AutoShowEnemyLabel:SetWidth(170)
	panel.AutoShowEnemyLabel:SetJustifyH("LEFT")
	panel.AutoShowEnemyLabel:SetText(L["Enemy Nameplates"]..':')

	panel.EnemyAutomation = PanelHelpers:CreateMultiStateOptions("Enemy", {"Combat", "Dungeon", "Raid", "Battleground", "Arena", "Scenario", "World"}, {["show"] = "|cFF60E025", ["hide"] = "|cFFFF1100"}, panel.AutoShowEnemyLabel:GetStringWidth(), panel)
	panel.EnemyAutomation:SetPoint("TOPLEFT", panel.AutoShowEnemyLabel, "BOTTOMLEFT", 0, -12)


	---------------
	-- Column 2
	---------------
	-- Friendly Visibility
	panel.AutoShowFriendlyLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.AutoShowFriendlyLabel:SetPoint("TOPLEFT", panel.AutoShowEnemyLabel,"TOPLEFT", 150, 0)
	panel.AutoShowFriendlyLabel:SetWidth(170)
	panel.AutoShowFriendlyLabel:SetJustifyH("LEFT")
	panel.AutoShowFriendlyLabel:SetText(L["Friendly Nameplates"]..':')

	panel.FriendlyAutomation = PanelHelpers:CreateMultiStateOptions("Friendly", {"Combat", "Dungeon", "Raid", "Battleground", "Arena", "Scenario", "World"}, {["show"] = "|cFF60E025", ["hide"] = "|cFFFF1100"}, panel.AutoShowFriendlyLabel:GetStringWidth(), panel)
	panel.FriendlyAutomation:SetPoint("TOPLEFT", panel.AutoShowFriendlyLabel, "BOTTOMLEFT", 0, -12)

	panel.AutomationTip = PanelHelpers:CreateTipBox("NeatPlatesOptions_GlobalAuraTip", green..L["Show"]..white.." || "..red..L["Hide"]..white.." || "..L["No Automation"], panel, "BOTTOMLEFT", panel.FriendlyAutomation, "TOPRIGHT", 0, 0)

	----------------------------------------------
	-- General Aura Filters
	----------------------------------------------

	panel.GeneralAuraLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.GeneralAuraLabel:SetFont(font, 22, "")
	panel.GeneralAuraLabel:SetText(L["General Aura Filters"])
	panel.GeneralAuraLabel:SetPoint("TOPLEFT", panel.EnemyAutomation, "BOTTOMLEFT", 0, -20)
	panel.GeneralAuraLabel:SetTextColor(255/255, 105/255, 6/255)

	-- -- Global Additional Auras
	panel.GlobalAuraLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.GlobalAuraLabel:SetPoint("TOPLEFT", panel.GeneralAuraLabel, "BOTTOMLEFT", 0, -8)
	panel.GlobalAuraLabel:SetWidth(190)
	panel.GlobalAuraLabel:SetJustifyH("LEFT")
	panel.GlobalAuraLabel:SetText(L["Additional Auras"]..':')

	-- panel.GlobalAuraEditBox = PanelHelpers.CreateEditBox("NeatPlatesOptions_GlobalAuraEditBox", nil, nil, panel, panel.GlobalAuraLabel, 16, 0)
	-- panel.GlobalAuraEditBox:SetWidth(200)
	-- PanelHelpers.CreateEditBoxButton(panel.GlobalAuraEditBox, function() OnOkay(_panel) end)


	-- -- Global Emphasized Auras
	-- panel.GlobalEmphasizedAuraLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	-- panel.GlobalEmphasizedAuraLabel:SetPoint("TOPLEFT", panel.GlobalAuraLabel, "TOPRIGHT", 64, 0)
	-- panel.GlobalEmphasizedAuraLabel:SetWidth(170)
	-- panel.GlobalEmphasizedAuraLabel:SetJustifyH("LEFT")
	-- panel.GlobalEmphasizedAuraLabel:SetText(L["Emphasized Auras"]..':')

	-- panel.GlobalEmphasizedAuraEditBox = PanelHelpers.CreateEditBox("NeatPlatesOptions_GlobalEmphasizedAuraEditBox", nil, nil, panel, panel.GlobalEmphasizedAuraLabel, 264, 0)
	-- panel.GlobalEmphasizedAuraEditBox:SetWidth(200)
	-- PanelHelpers.CreateEditBoxButton(panel.GlobalEmphasizedAuraEditBox, function() OnOkay(_panel) end)

	-- panel.GlobalEmphasizedAuraTip = PanelHelpers:CreateTipBox("NeatPlatesOptions_GlobalEmphasizedAuraTip", L["AURA_TIP"], panel, "BOTTOMRIGHT", panel.GlobalEmphasizedAuraEditBox, "TOPRIGHT", 6, 0)

	panel.GlobalAdditonalAuras = PanelHelpers:CreateAuraManagement("GlobalAdditonalAuras", panel, 500, 150)
	panel.GlobalAdditonalAuras:SetPoint("TOPLEFT", panel.GlobalAuraLabel, "BOTTOMLEFT", 0, -10)
	panel.GlobalAuraTip = PanelHelpers:CreateTipBox("NeatPlatesOptions_GlobalAuraTip", L["AURA_TIP"], panel, "BOTTOMRIGHT", panel.GlobalAdditonalAuras, "TOPRIGHT", 6, 0)

	----------------------------------------------
	-- Other Options
	----------------------------------------------

	panel.OtherOptionsLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.OtherOptionsLabel:SetFont(font, 22, "")
	panel.OtherOptionsLabel:SetText(L["Other Options"])
	-- panel.OtherOptionsLabel:SetPoint("TOPLEFT", panel.GlobalAuraEditBox, "BOTTOMLEFT", 0, -20)
	panel.OtherOptionsLabel:SetPoint("TOPLEFT", panel.GlobalAdditonalAuras, "BOTTOMLEFT", 0, -30)
	panel.OtherOptionsLabel:SetTextColor(255/255, 105/255, 6/255)

	if NEATPLATES_IS_CLASSIC then
		-- Emulated Target Plate
		panel.EmulatedTargetPlate = PanelHelpers:CreateCheckButton("NeatPlatesOptions_EmulatedTargetPlate", panel, L["Emulate Target Nameplate"].."*")
		panel.EmulatedTargetPlate:SetPoint("TOPLEFT", panel.OtherOptionsLabel, "BOTTOMLEFT", 0, -8)
		panel.EmulatedTargetPlate:SetScript("OnClick", function(self) NeatPlates:ToggleEmulatedTargetPlate(self:GetChecked()) end)
		panel.EmulatedTargetPlate.tooltipText = L["This feature is highly experimental, use on your own risk"]
	end

	-- Cast Bars
	panel.DisableCastBars = PanelHelpers:CreateCheckButton("NeatPlatesOptions_DisableCastBars", panel, L["Disable Cast Bars"])
	if NEATPLATES_IS_CLASSIC then
		panel.DisableCastBars:SetPoint("TOPLEFT", panel.EmulatedTargetPlate, "BOTTOMLEFT", 0, -8)
	else
		panel.DisableCastBars:SetPoint("TOPLEFT", panel.OtherOptionsLabel, "BOTTOMLEFT", 0, -8)
	end
	panel.DisableCastBars:SetScript("OnClick", function(self) SetCastBars(not self:GetChecked()) end)

	-- ForceHealthUpdates
	panel.ForceHealthUpdates = PanelHelpers:CreateCheckButton("NeatPlatesOptions_ForceHealthUpdates", panel, L["Force Health Updates"])
	panel.ForceHealthUpdates:SetPoint("TOPLEFT", panel.DisableCastBars, "TOPLEFT", 0, -25)
	panel.ForceHealthUpdates:SetScript("OnClick", function(self) NeatPlates.ToggleHealthTicker( self:GetChecked()) end)
	panel.ForceHealthUpdates.tooltipText = L["Forces health to update every .25sec, try this if you are having health update issues"]

	-- ForceBlizzardFont
	panel.ForceBlizzardFont = PanelHelpers:CreateCheckButton("NeatPlatesOptions_ForceBlizzardFont", panel, L["Force Multi-Lingual Font (Requires /reload)"])
	panel.ForceBlizzardFont:SetPoint("TOPLEFT", panel.ForceHealthUpdates, "TOPLEFT", 0, -25)
	panel.ForceBlizzardFont:SetScript("OnClick", function(self) NeatPlates.OverrideFonts( self:GetChecked()) end)


	-- Blizzard Scaling
	panel.BlizzardScaling = PanelHelpers:CreateCheckButton("NeatPlatesOptions_BlizzardScaling", panel, L["Use Blizzard Scaling"])
	panel.BlizzardScaling:SetPoint("TOPLEFT", panel.ForceBlizzardFont, "TOPLEFT", 0, -25)
	panel.BlizzardScaling.tooltipText = L["Allows some CVars to work(Might require a /reload)"]
	panel.BlizzardScaling:SetScript("OnClick", function() end) -- Empty function beacuse Shadowlands requires it now?

	-- Blizzard Scaling
	panel.BlizzardNameVisibility = PanelHelpers:CreateCheckButton("NeatPlatesOptions_BlizzardNameVisibility", panel, L["Use Blizzard Name Visibility"])
	panel.BlizzardNameVisibility:SetPoint("TOPLEFT", panel.BlizzardScaling, "TOPLEFT", 0, -25)
	panel.BlizzardNameVisibility.tooltipText = L["Allows some CVars to work(Might require a /reload)"]
	panel.BlizzardNameVisibility:SetScript("OnClick", function() end) -- Empty function beacuse Shadowlands requires it now?

	-- Blizzard Bar Widgets
	panel.BlizzardWidgets = PanelHelpers:CreateCheckButton("NeatPlatesOptions_BlizzardWidgets", panel, L["Use Blizzard Bar Widgets"])
	panel.BlizzardWidgets:SetPoint("TOPLEFT", panel.BlizzardNameVisibility, "TOPLEFT", 0, -25)
	panel.BlizzardWidgets.tooltipText = L["Use default blizzard bar widgets where applicable rather than the simpler widget bar built into NeatPlates (Might require a /reload)"]
	panel.BlizzardWidgets:SetScript("OnClick", function() end) -- Empty function beacuse Shadowlands requires it now?

	-- Override Outline Style
	panel.OverrideOutlineLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.OverrideOutlineLabel:SetPoint("TOPLEFT", panel.BlizzardWidgets,"BOTTOMLEFT", 0, -8)
	panel.OverrideOutlineLabel:SetWidth(170)
	panel.OverrideOutlineLabel:SetJustifyH("LEFT")
	panel.OverrideOutlineLabel:SetText(L["Outline Override"]..':')

	panel.OverrideOutline = PanelHelpers:CreateDropdownFrame("NeatPlatesOverrideOutline", panel, OutlineStyleItems, 1, nil, true)
	panel.OverrideOutline:SetPoint("TOPLEFT", panel.OverrideOutlineLabel, "BOTTOMLEFT", -15, -2)

	-- Class Colors
	panel.ClassColorLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.ClassColorLabel:SetFont(font, 22, "")
	panel.ClassColorLabel:SetText(L["Class Colors"])
	panel.ClassColorLabel:SetPoint("TOPLEFT", panel.OverrideOutline, "BOTTOMLEFT", 15, -30)
	panel.ClassColorLabel:SetTextColor(255/255, 105/255, 6/255)

	local F = panel.ClassColorLabel
	local columns = {
		[0] = { -240, -30 },
		[1] = { 120, 0 },
		[2] = { 120, 0 },
	}
	local i = 0
	for class in pairs(NEATPLATES_CLASS_COLORS) do
		local frameName = "ClassColor"..class
		panel[frameName] = PanelHelpers:CreateColorBox("NeatPlatesOptions_"..frameName, panel, L[class], function()
			local value = panel[frameName]:GetValue()
			panel[frameName]:SetValue(value)
			NEATPLATES_CLASS_COLORS[class] = value
		end, 0, .5, 1, 1)

		-- Assign column
		if i == 0 then
			panel[frameName]:SetPoint("TOPLEFT", F, "TOPLEFT", 15, -30)
		else
			panel[frameName]:SetPoint("TOPLEFT", F, "TOPLEFT", unpack(columns[i%3]))
		end
		F = panel[frameName]
		i = i + 1
	end

	-- Reset class colors button
	panel.ResetClassColors = CreateFrame("Button", "NeatPlatesOptions_ResetClassColors", panel, "NeatPlatesPanelButtonTemplate")
	panel.ResetClassColors:SetWidth(140)
	panel.ResetClassColors:SetText(L["Reset Class Colors"])
	panel.ResetClassColors:SetPoint("TOPLEFT", panel.ClassColorLabel, "BOTTOMLEFT", 15, -160)
	panel.ResetClassColors:SetScript("OnClick", function()
		table.foreach(RAID_CLASS_COLORS, function(class, color)
			local frameName = "ClassColor"..class
			panel[frameName]:SetValue(color)
			NEATPLATES_CLASS_COLORS[class] = color
		end)
	end)

	-- Nameplate Behaviour
	panel.CVarsLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.CVarsLabel:SetFont(font, 22, "")
	panel.CVarsLabel:SetText("CVars")
	panel.CVarsLabel:SetPoint("TOPLEFT", panel.ResetClassColors, "BOTTOMLEFT", -15, -25)
	panel.CVarsLabel:SetTextColor(255/255, 105/255, 6/255)

	panel.EnforceRequiredCVars = PanelHelpers:CreateCheckButton("NeatPlatesOptions_EnforceRequiredCVars", panel, L["Enforce required CVars"])
	panel.EnforceRequiredCVars.tooltipText = L["Helps ensure that everything is working as intended by enforcing certain CVars"]
	panel.EnforceRequiredCVars:SetPoint("TOPLEFT", panel.CVarsLabel, "BOTTOMLEFT", 0, -8)
	panel.EnforceRequiredCVars:SetScript("OnClick", function() end) -- Empty function beacuse Shadowlands requires it now?

	panel.NameplateTargetClamp = PanelHelpers:CreateCheckButton("NeatPlatesOptions_NameplateTargetClamp", panel, L["Always keep Target Nameplate on Screen"])
	panel.NameplateTargetClamp:SetPoint("TOPLEFT", panel.EnforceRequiredCVars, "TOPLEFT", 0, -25)
	panel.NameplateTargetClamp:SetScript("OnClick", function(self) SetCVarValue(self, "nameplateTargetRadialPosition", true) end)

	panel.NameplateStacking = PanelHelpers:CreateCheckButton("NeatPlatesOptions_NameplateStacking", panel, L["Stacking Nameplates"])
	panel.NameplateStacking:SetPoint("TOPLEFT", panel.NameplateTargetClamp, "TOPLEFT", 0, -25)
	panel.NameplateStacking:SetScript("OnClick", function(self) SetCVarValue(self, "nameplateMotion", true) end)

	panel.NameplateFriendlyNPCs = PanelHelpers:CreateCheckButton("NeatPlatesOptions_NameplateFriendlyNPCs", panel, L["Show Friendly NPCs Nameplates"])
	panel.NameplateFriendlyNPCs:SetPoint("TOPLEFT", panel.NameplateStacking, "TOPLEFT", 0, -25)
	panel.NameplateFriendlyNPCs:SetScript("OnClick", function(self) SetCVarValue(self, "nameplateShowFriendlyNPCs", true) end)

	panel.NameplateMaxDistance = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateMaxDistance", panel, L["Nameplate Max Distance"], 41, 0, 41, 1, "ACTUAL", 170)
	panel.NameplateMaxDistance:SetPoint("TOPLEFT", panel.NameplateFriendlyNPCs, "TOPLEFT", 10, -50)
	panel.NameplateMaxDistance.Callback = function(self) SetCVarValue(self, "nameplateMaxDistance") end

	panel.NameplateOccludedAlphaMult = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateOccludedAlphaMult", panel, L["Occluded Alpha Multiplier"], 0.4, 0, 1, 0.01, "ACTUAL", 170)
	panel.NameplateOccludedAlphaMult:SetPoint("TOPLEFT", panel.NameplateMaxDistance, "TOPLEFT", 0, -50)
	panel.NameplateOccludedAlphaMult.Callback = function(self) SetCVarValue(self, "nameplateOccludedAlphaMult") end
	panel.NameplateOccludedAlphaMult.tooltipText = L["The opacity multiplier for units occluded by line of sight"]

	panel.NameplateNotSelectedAlpha = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateNotSelectedAlpha", panel, L["Non-target Alpha"], 1, 0, 1, 0.01, "ACTUAL", 170)
	panel.NameplateNotSelectedAlpha:SetPoint("TOPLEFT", panel.NameplateMaxDistance, "TOPLEFT", 200, -50)
	panel.NameplateNotSelectedAlpha.Callback = function(self) SetCVarValue(self, "nameplateNotSelectedAlpha") end
	panel.NameplateNotSelectedAlpha.tooltipText = L["The opacity of nameplates when not selected, there is also options for this per profile"]

	panel.NameplateMinAlpha = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateMinAlpha", panel, L["Minimum Alpha"], 0.6, 0, 1, 0.01, "ACTUAL", 170)
	panel.NameplateMinAlpha:SetPoint("TOPLEFT", panel.NameplateOccludedAlphaMult, "TOPLEFT", 0, -50)
	panel.NameplateMinAlpha.Callback = function(self) SetCVarValue(self, "nameplateMinAlpha") end
	panel.NameplateMinAlpha.tooltipText = L["The minimum opacity of nameplates for 'Nameplate Minimum Alpha Distance'"]

	panel.NameplateMaxAlpha = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateMaxAlpha", panel, L["Maximum Alpha"], 1, 0, 1, 0.01, "ACTUAL", 170)
	panel.NameplateMaxAlpha:SetPoint("TOPLEFT", panel.NameplateOccludedAlphaMult, "TOPLEFT", 200, -50)
	panel.NameplateMaxAlpha.Callback = function(self) SetCVarValue(self, "nameplateMaxAlpha") end
	panel.NameplateMaxAlpha.tooltipText = L["The maximum opacity of nameplates for 'Nameplate Maximum Alpha Distance'"]

	panel.NameplateMinAlphaDistance = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateMinAlphaDistance", panel, L["Minimum Alpha Distance"], 10, 0, 100, 1, "ACTUAL", 170)
	panel.NameplateMinAlphaDistance:SetPoint("TOPLEFT", panel.NameplateMinAlpha, "TOPLEFT", 0, -50)
	panel.NameplateMinAlphaDistance.Callback = function(self) SetCVarValue(self, "nameplateMinAlphaDistance") end
	panel.NameplateMinAlphaDistance.tooltipText = L["The distance from the max distance that nameplates will reach their minimum alpha"]

	panel.NameplateMaxAlphaDistance = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateMaxAlphaDistance", panel, L["Maximum Alpha Distance"], 40, 0, 100, 1, "ACTUAL", 170)
	panel.NameplateMaxAlphaDistance:SetPoint("TOPLEFT", panel.NameplateMinAlpha, "TOPLEFT", 200, -50)
	panel.NameplateMaxAlphaDistance.Callback = function(self) SetCVarValue(self, "nameplateMaxAlphaDistance") end
	panel.NameplateMaxAlphaDistance.tooltipText = L["The distance from the camera that nameplates will reach their maxmimum alpha"]

	panel.NameplateOverlapH = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateOverlapH", panel, L["Horizontal Overlap"], 0, 0, 10, .1, "ACTUAL", 170)
	panel.NameplateOverlapH:SetPoint("TOPLEFT", panel.NameplateMinAlphaDistance, "TOPLEFT", 0, -50)
	panel.NameplateOverlapH.Callback = function(self) SetCVarValue(self, "nameplateOverlapH") end
	panel.NameplateOverlapH.tooltipText = L["The horizontal distance between nameplates when overlapping (Requires 'Stacking Nameplates')"]

	panel.NameplateOverlapV = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateOverlapV", panel, L["Vertical Overlap"], 0, 0, 10, .1, "ACTUAL", 170)
	panel.NameplateOverlapV:SetPoint("TOPLEFT", panel.NameplateMinAlphaDistance, "TOPLEFT", 200, -50)
	panel.NameplateOverlapV.Callback = function(self) SetCVarValue(self, "nameplateOverlapV") end
	panel.NameplateOverlapV.tooltipText = L["The vertical distance between nameplates when overlapping (Requires 'Stacking Nameplates')"]

	panel.NameplateClickableWidth = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateClickableWidth", panel, L["Clickable Width of Nameplates"], 1, .1, 2, .01, nil, 170)
	panel.NameplateClickableWidth:SetPoint("TOPLEFT", panel.NameplateOverlapH, "TOPLEFT", 0, -50)
	panel.NameplateClickableWidth.Callback = function() NeatPlates:ShowNameplateSize(true, panel.NameplateClickableWidth:GetValue(), panel.NameplateClickableHeight:GetValue()) end
	panel.NameplateClickableWidth.tooltipText = L["The size of the interactable area of the nameplates"]

	panel.NameplateClickableHeight = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateClickableHeight", panel, L["Clickable Height of Nameplates"], 1, .1, 2, .01, nil, 170)
	panel.NameplateClickableHeight:SetPoint("TOPLEFT", panel.NameplateOverlapH, "TOPLEFT", 200, -50)
	panel.NameplateClickableHeight.Callback = function() NeatPlates:ShowNameplateSize(true, panel.NameplateClickableWidth:GetValue(), panel.NameplateClickableHeight:GetValue()) end
	panel.NameplateClickableHeight.tooltipText = L["The size of the interactable area of the nameplates"]

	panel.NameplateClickableSizeTip = PanelHelpers:CreateTipBox("NeatPlatesOptions_GlobalHitBoxTip", L["HITBOX_TIP"], panel, "BOTTOMRIGHT", panel.NameplateClickableHeight, "TOPRIGHT", 35, -20)

	-- Blizz Button
	local BlizzOptionsButton = CreateFrame("Button", "NeatPlatesOptions_BlizzOptionsButton", panel, "NeatPlatesPanelButtonTemplate")
	BlizzOptionsButton:SetPoint("TOPLEFT", panel.NameplateClickableWidth, "TOPLEFT", -10, -70)
	BlizzOptionsButton:SetWidth(260)
	BlizzOptionsButton:SetText(L["Nameplate Motion & Visibility"])

	-- Reset
	local ResetButton = CreateFrame("Button", "NeatPlatesOptions_ResetButton", panel, "NeatPlatesPanelButtonTemplate")
	ResetButton:SetPoint("TOPLEFT", BlizzOptionsButton, "BOTTOMLEFT", 0, -10)
	ResetButton:SetWidth(155)
	ResetButton:SetText(L["Reset Configuration"])


	-- Update Functions
	_panel.okay = OnOkay
	_panel.refresh = OnRefresh

	_panel.OnCommit = _panel.okay;
	_panel.OnDefault = _panel.default;
	_panel.OnRefresh = _panel.refresh;
	panel.ActiveThemeDropdown.OnValueChanged = OnValueChange

	panel.FirstSpecDropdown.OnValueChanged = OnValueChange
	if not NEATPLATES_IS_CLASSIC then
		panel.SecondSpecDropdown.OnValueChanged = OnValueChange
		panel.ThirdSpecDropdown.OnValueChanged = OnValueChange
		panel.FourthSpecDropdown.OnValueChanged = OnValueChange
	end


	local createNewProfile = function(profileName)
		if not profileName then return end
		local color = RGBToColorCode(panel.ProfileColorBox:GetBackdropColor())

		ValidateProfileName(profileName, function()
			NeatPlatesUtility.OpenInterfacePanel(NeatPlatesHubMenus.CreateProfile(profileName, color))
			panel.ProfileNameEditBox:SetText("")
		end)
	end

	-- Profile Functions
	panel.CreateProfile:SetScript("OnClick", function(self)
		createNewProfile(panel.ProfileNameEditBox:GetText())
	end)

	panel.ImportProfile:SetScript("OnClick", function(self)
		local profileName = panel.ProfileNameEditBox:GetText()
		ValidateProfileName(profileName, function()
			NeatPlatesHubRapidPanel.CreateQuickEditboxPopup(L["Import Profile"].." ("..profileName..")", function(self)
				if NeatPlatesHubMenus.ImportProfile(profileName, self.EditBox:GetValue()) then
					createNewProfile(profileName)
					return true
				end
				return false
			end)
		end)
	end)

	panel.CopyProfileDropdown.OnValueChanged = function(self)
		local name = panel.ProfileNameEditBox:GetText()
		local copy = panel.CopyProfileDropdown:GetValue()
		local color = RGBToColorCode(panel.ProfileColorBox:GetBackdropColor())

		ValidateProfileName(name, function()
			NeatPlatesHubRapidPanel.CreateVariableSet("HubPanelProfile"..name, "HubPanelProfile"..copy)
			NeatPlatesUtility.OpenInterfacePanel(NeatPlatesHubMenus.CreateProfile(name, color))
			panel.ProfileNameEditBox:SetText("")
		end)
	end

	panel.RemoveProfileDropdown.OnValueChanged = function(self)
		local name = panel.RemoveProfileDropdown:GetValue()

		StaticPopupDialogs["NeatPlates_RemoveProfile"] = {
		  text = name:gsub('.+', L["Are you sure you wish to delete the profile '%1'?"]),
		  button1 = YES,
		  button2 = NO,
		  OnAccept = function()
				if RemoveProfile(_G["HubPanelProfile"..name.."_InterfaceOptionsPanel"]) then
					panel.RemoveProfileDropdown:SetValue("")
			  	print(orange.."NeatPlates: "..blue..name:gsub('.+', L["The profile '%1' was successfully deleted."]))
				end
		  end,
		  timeout = 0,
		  whileDead = true,
		  hideOnEscape = true,
		  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
		}
		StaticPopup_Show("NeatPlates_RemoveProfile")
	end

	panel.ExportProfileDropdown.OnValueChanged = function(self)
		local profileName = panel.ExportProfileDropdown:GetValue()

		local panel = NeatPlatesHubRapidPanel.CreateQuickEditboxPopup(L["Export Profile"].." ("..profileName..")", nil, true)
		panel.EditBox:SetValue(NeatPlatesHubMenus.ExportProfile(profileName))
	end

	-- Blizzard Nameplate Options Button
	BlizzOptionsButton:SetScript("OnClick", function()
		InterfaceOptionsFrame_OpenToCategory(_G["InterfaceOptionsNamesPanel"])
	end)

	-- Reset Button
	ResetButton:SetScript("OnClick", function()
		SetCVar("nameplateShowEnemies", 1)
		SetCVar("threatWarning", 3)		-- Required for threat/aggro detection
		SetCVar("nameplateMinScale", 1)
		SetCVar("showQuestTrackingTooltips", 1)

		if IsShiftKeyDown() then
			NeatPlatesOptions = wipe(NeatPlatesOptions)
			for i, v in pairs(NeatPlatesOptionsDefaults) do NeatPlatesOptions[i] = v end
			SetCVar("nameplateShowFriends", 0)
			ReloadUI()
		else
			NeatPlatesOptions = wipe(NeatPlatesOptions)
			for i, v in pairs(NeatPlatesOptionsDefaults) do NeatPlatesOptions[i] = v end
			OnRefresh(_panel)
			ApplyPanelSettings()
			print(ReplaceColorPatterns(L["%yellow%Resetting %orange%NeatPlates%yellow% Theme Selection to Default"]))
			print(ReplaceColorPatterns(L["%yellow%Holding down %blue%Shift %yellow%while clicking %red%Reset Configuration %yellow%will clear your saved settings, AND reload the user interface."]))
		end

	end)
end

-------------------------------------------------------------------------------------
-- Auto-Loader
-------------------------------------------------------------------------------------
local panelevents = {}
if not NEATPLATES_IS_CLASSIC then
	function panelevents:ACTIVE_TALENT_GROUP_CHANGED(self)
		--print("Panel:Talent Group Changed")
		ApplyPanelSettings()
		--OnRefresh(NeatPlatesInterfacePanel)
	end
end

function panelevents:PLAYER_ENTERING_WORLD()
	--print("Panel:Player Entering World")
	-- Tihs may happen every time a loading screen is shown
	local fallBackTheme

	-- Locate a fallback theme
	if NeatPlatesThemeList[FirstTryTheme] then
		fallBackTheme = FirstTryTheme
	else
		for i,v in pairs(NeatPlatesThemeList) do fallBackTheme = i break; end
	end

	-- Check to make sure the selected themes exist; if not, replace with fallback
	if not NeatPlatesThemeList[NeatPlatesOptions.ActiveTheme] then
		NeatPlatesOptions.ActiveTheme = fallBackTheme end

	VerifyPanelSettings()
	VerifySpecSelections()
	ApplyPanelSettings()
	ApplyAutomationSettings()
	NeatPlatesHubFunctions.ApplyRequiredCVars(NeatPlatesOptions)

	-- Nameplate automation in case of instance
	local inInstance, instanceType = IsInInstance()
	SetNameplateVisibility("nameplateShowEnemies", NeatPlatesOptions.EnemyAutomation, 'PLAYER_ENTERING_WORLD')
	SetNameplateVisibility("nameplateShowFriends", NeatPlatesOptions.FriendlyAutomation, 'PLAYER_ENTERING_WORLD')
end

function panelevents:PLAYER_REGEN_ENABLED()
	SetNameplateVisibility("nameplateShowEnemies", NeatPlatesOptions.EnemyAutomation, 'PLAYER_REGEN_ENABLED')
	SetNameplateVisibility("nameplateShowFriends", NeatPlatesOptions.FriendlyAutomation, 'PLAYER_REGEN_ENABLED')
end

function panelevents:PLAYER_REGEN_DISABLED()
	SetNameplateVisibility("nameplateShowEnemies", NeatPlatesOptions.EnemyAutomation, 'PLAYER_REGEN_DISABLED')
	SetNameplateVisibility("nameplateShowFriends", NeatPlatesOptions.FriendlyAutomation, 'PLAYER_REGEN_DISABLED')
end

function panelevents:PLAYER_LOGIN()
	-- This happens only once a session

	-- Setup class colors
	NeatPlatesUtility.SetupClassColors()

	-- Setup the interface panels
	CreateMenuTables()				-- Look at the theme table and get names
	BuildInterfacePanel(NeatPlatesInterfacePanel)


	-- First time setup
	if not NeatPlatesOptions.WelcomeShown then
		SetCVar("nameplateShowAll", 1)		--

		SetCVar("nameplateMinScale", 1)
		SetCVar("showQuestTrackingTooltips", 1)

		SetCVar("nameplateShowEnemies", 1)
		SetCVar("threatWarning", 3)		-- Required for threat/aggro detection
		NeatPlatesOptions.WelcomeShown = true

		NeatPlatesOptions.FirstSpecProfile = NeatPlatesSettings.DefaultProfile
		NeatPlatesOptions.SecondSpecProfile = NeatPlatesSettings.DefaultProfile
		NeatPlatesOptions.ThirdSpecProfile = NeatPlatesSettings.DefaultProfile
		NeatPlatesOptions.FourthSpecProfile = NeatPlatesSettings.DefaultProfile
	end

	-- NeatPlatesInterfacePanel:OnRefresh()
end

NeatPlatesInterfacePanel:SetScript("OnEvent", function(self, event, ...) panelevents[event](self, ...) end)
for eventname in pairs(panelevents) do NeatPlatesInterfacePanel:RegisterEvent(eventname) end

-- local PanelHandler = CreateFrame("Frame")
-- PanelHandler:SetScript("OnEvent", function(...)
-- 	local _,_,addon = ...

-- 	if addon == "NeatPlates" then

-- 		-- Frames are required to have OnCommit, OnDefault, and OnRefresh functions even if their implementations are empty.

-- 		PanelHandler:UnregisterEvent("ADDON_LOADED")
-- 	end
-- end)
-- PanelHandler:RegisterEvent("ADDON_LOADED")

-------------------------------------------------------------------------------------
-- Slash Commands
-------------------------------------------------------------------------------------

NeatPlatesSlashCommands = {}

function slash_NeatPlates(arg)
	if type(NeatPlatesSlashCommands[arg]) == 'function' then
		NeatPlatesSlashCommands[arg]()
		NeatPlates:ForceUpdate()
	else
		NeatPlatesUtility.OpenInterfacePanel(NeatPlatesInterfacePanel)
	end
end

SLASH_NeatPlates1 = '/NeatPlates'
SLASH_NeatPlates2 = '/np'
SlashCmdList['NeatPlates'] = slash_NeatPlates;

SLASH_NeatPlatesDebug1 = '/npdebug'
SlashCmdList['NeatPlatesDebug'] = function(arg)
	arg = string.lower(arg)

	if arg == "quest" then
		NeatPlatesWidgets.DebugQuests()
	end
end;



