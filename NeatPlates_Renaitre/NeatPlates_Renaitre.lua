-----------------------------------------------------
-- Theme Definition
-----------------------------------------------------
local Theme = {}
local CopyTable = NeatPlatesUtility.copyTable
local path = "Interface\\Addons\\NeatPlates_Renaitre\\Textures\\"
--local font = "Interface\\Addons\\NeatPlates_Renaitre\\Fonts\\RobotoCondensed-Bold.ttf"; local fontsize = 10;
local font = "Interface\\Addons\\NeatPlatesHub\\shared\\RobotoCondensed-Bold.ttf"; local fontsize = 10;
local EmptyTexture = "Interface\\Addons\\NeatPlatesHub\\shared\\Empty"

-- Non-Latin Font Bypass
local NonLatinLocales = { ["koKR"] = true, ["zhCN"] = true, ["zhTW"] = true, }
if NonLatinLocales[GetLocale()] == true then font = STANDARD_TEXT_FONT end

local VerticalAdjustment = -12
local castbarVertical = VerticalAdjustment - 15

local StyleDefault = {}

-- [[
StyleDefault.hitbox = {
	width = 100,
	height = 24,
	x = 0,
	y = 0,
}

--]]

StyleDefault.frame = {
	width = 100,
	height = 45,
	x = 0,
	y = 0,		-- (-12) To put the bar near the middle
	anchor = "CENTER",
}

StyleDefault.healthborder = {
	texture		 =					path.."RegularBorder",
	width = 128,
	height = 64,
	x = 0,
	y = VerticalAdjustment,
	anchor = "CENTER",
}

StyleDefault.targetindicator = {
	texture		 =					path.."TargetBox",
	width = 128,
	height = 64,
	x = 0,
	y = VerticalAdjustment,
	anchor = "CENTER",
	show = true,
}

StyleDefault.targetindicator_arrowtop = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Top",
	width = 64,
	height = 12,
	x = 0,
	y = VerticalAdjustment+40,
	anchor = "CENTER",
	show = true,
}

StyleDefault.targetindicator_arrowsides = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Sides",
	width = 138,
	height = 18,
	x = 0,
	y = VerticalAdjustment+15,
	anchor = "CENTER",
	show = true,
}

StyleDefault.targetindicator_arrowright = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Right",
	width = 18,
	height = 18,
	x = 22,
	y = VerticalAdjustment+15,
	anchor = "RIGHT",
	show = true,
}

StyleDefault.targetindicator_arrowleft = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Left",
	width = 18,
	height = 18,
	x = -22,
	y = VerticalAdjustment+15,
	anchor = "LEFT",
	show = true,
}

StyleDefault.highlight = {
	texture		 =					path.."Highlight",
	--width = 128,
	--height = 64,
}

StyleDefault.threatborder = {
	texture =						path.."Warning",
	width = 128,
	height = 64,
	x = 0,
	y = VerticalAdjustment,
	anchor = "CENTER",
}

StyleDefault.castbar = {
	texture =						path.."RenStripe3L",
	backdrop = 						path.."RenStripe3",
	height = 8,
	width = 99,
	x = 0,
	y = 15+castbarVertical,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.castborder = {
	texture =						path.."RegularBorder",
	width = 128,
	height = 64,
	x = 0,
	y = castbarVertical,
	anchor = "CENTER",
}

StyleDefault.castnostop = {
	texture = 						path.."RegularBorder",
	width = 128,
	height = 64,
	x = 0,
	y = castbarVertical,
	anchor = "CENTER",
}

StyleDefault.name = {
	typeface =						font,
	size = fontsize,
	height = 12,
	width = 180,
	x = 0,
	y = VerticalAdjustment + 9,
	align = "CENTER",
	anchor = "TOP",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
}

StyleDefault.subtext = {
	typeface =						font,
	size = fontsize - 1,
	width = 180,
	height = 12,
	x = 0,
	y = VerticalAdjustment - 1,
	align = "CENTER",
	anchor = "TOP",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
}

StyleDefault.level = {
	typeface =						font,
	size = fontsize - 1,
	width = 93,
	height = 10,
	x = -1,
	y = VerticalAdjustment + 15,
	align = "LEFT",
	anchor = "CENTER",
	vertical = "MIDDLE",
	shadow = true,
	flags = "NONE",
	show = false,
}

StyleDefault.healthbar = {
	texture =						path.."Statusbar",
	backdrop =						path.."StatusbarBackground",
	height = 8.5,
	width = 98.5,
	x = 0,
	y = VerticalAdjustment + 15,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.powerbar = {
	texture =						path.."Statusbar",
	backdrop =						path.."StatusbarBackground",
	height = 4,
	width = 98.5,
	x = 0,
	y = VerticalAdjustment + 15 - 7,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.customtext = {
	typeface =						font,
	size = fontsize - 1,
	width = 93,
	height = 10,
	x = 0,
	y = VerticalAdjustment + 15,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.spelltext = {
	typeface =						font,
	size = fontsize,
	height = 12,
	width = 180,
	x = 0,
	y = -11 + castbarVertical,
	align = "CENTER",
	anchor = "TOP",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.spelltarget = {
	typeface =						font,
	size = fontsize,
	height = 12,
	width = 180,
	x = 0,
	y = -21 + castbarVertical,
	align = "CENTER",
	anchor = "TOP",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.durationtext = {
	typeface =						font,
	size = fontsize-1,
	height = 12,
	width = 96,
	x = 0,
	y = -0 + castbarVertical,
	align = "RIGHT",
	anchor = "TOP",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.spellicon = {
	width = 25,
	height = 25,
	x = -67,
	y = 22+castbarVertical,
	anchor = "CENTER",
}

StyleDefault.eliteicon = {
	texture = path.."EliteBorder",
	width = 128,
	height = 64,
	x = 0,
	y = VerticalAdjustment,
	anchor = "CENTER",
	show = true,
}

StyleDefault.raidicon = {
	width = 18,
	height = 18,
	x = -60,
	y = VerticalAdjustment + 16,
	anchor = "CENTER",
}

StyleDefault.customart = {
	width = 25,
	height = 25,
	x = -55,
	y = VerticalAdjustment + 21,
	anchor = "CENTER",
	show = true,
}

StyleDefault.extrabar = {
	texture =						path.."Statusbar",
	backdrop =						path.."StatusbarBackground",
	height = 4,
	width = 98,
	x = 0,
	y = VerticalAdjustment+8,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.extratext = {
	typeface =					font,
	size = 7,
	height = 4,
	width = 98,
	x = 0,
	y = VerticalAdjustment+7,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}


local arenaIconPath = "Interface\\AddOns\\NeatPlatesWidgets\\ArenaIcons"
local arenaUnitIDs = {"arena1", "arena2", "arena3", "arena4", "arena5"}

local function GetArenaIndex(unitname)
	if IsActiveBattlefieldArena() then
		local unitid, name
		for i = 1, #arenaUnitIDs do
			unitid = arenaUnitIDs[i]
			name = UnitName(unitid)
			if name and (name == unitname) then return unitid end
		end
	end
end

local function ArenaIconCustom(unit)
	local unitid = GetArenaIndex(unit.name)
	return "Interface\\AddOns\\NeatPlatesWidgets\\ArenaIcons\\arena5"
	--if unitid then return arenaIconPath..unitid end
end



StyleDefault.skullicon = {
	width = 8,
	height = 8,
	x = 2,
	y = VerticalAdjustment + 15,
	anchor = "LEFT",
}

StyleDefault.threatcolor = {
	LOW = {r = .6, g = 1, b = 0, a = 0,},
	MEDIUM = {r = .6, g = 1, b = 0, a = 1,},
	HIGH = {r = 1, g = 0, b = 0, a= 1,},  }


-- No-Bar Style		(6.2)
local StyleTextOnly = CopyTable(StyleDefault)
StyleTextOnly.threatborder.texture = EmptyTexture
StyleTextOnly.healthborder.texture = EmptyTexture
StyleTextOnly.healthbar.texture = EmptyTexture
StyleTextOnly.healthbar.backdrop = EmptyTexture
StyleTextOnly.powerbar.texture = EmptyTexture
StyleTextOnly.powerbar.backdrop = EmptyTexture
StyleTextOnly.eliteicon.texture = EmptyTexture
StyleTextOnly.extrabar.width = 80
StyleTextOnly.extrabar.y = VerticalAdjustment + 6
StyleTextOnly.extratext.y = VerticalAdjustment + 5
StyleTextOnly.extrabar.x = 0
StyleTextOnly.extratext.x = 0
StyleTextOnly.subtext.show = true
StyleTextOnly.subtext.align = "CENTER"
StyleTextOnly.subtext.anchor = "CENTER"
--StyleTextOnly.subtext.size = 10
StyleTextOnly.subtext.size = fontsize - 2
StyleTextOnly.subtext.y = VerticalAdjustment + 16
StyleTextOnly.subtext.width = 500
StyleTextOnly.customtext.show = false
StyleTextOnly.level.show = false
StyleTextOnly.skullicon.show = false
StyleTextOnly.eliteicon.show = false
StyleTextOnly.highlight.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Highlight"
StyleTextOnly.targetindicator.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Target"


-- Active Styles
Theme["Default"] = StyleDefault
Theme["NameOnly"] = StyleTextOnly


local WidgetConfig = {}
WidgetConfig.ClassIcon = { anchor = "RIGHT", w = 24, h = 24 , x = 23, y = VerticalAdjustment + 14 }		-- Above Name
WidgetConfig.TotemIcon = { anchor = "RIGHT", w = 19, h = 18 , x = 23 ,y = VerticalAdjustment + 14 }
WidgetConfig.ThreatLineWidget = { anchor =  "TOP", x = 0 ,y = VerticalAdjustment + 20 }	-- y = 20
WidgetConfig.ThreatWheelWidget = { anchor =  "CENTER", x = 33 ,y = VerticalAdjustment + 27 } -- "CENTER", plate, 30, 18
WidgetConfig.ComboWidget = { anchor = "TOP" , x = 0 ,y = VerticalAdjustment + 0 }
WidgetConfig.RangeWidget = { anchor = "CENTER" , x = 0 ,y = VerticalAdjustment + 12 }
WidgetConfig.DebuffWidget = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = VerticalAdjustment + 12 }
WidgetConfig.AbsorbWidget =	{ anchor="LEFT", x = 1, y = VerticalAdjustment + 16.5, w = 98, h = 8.5 }
WidgetConfig.QuestWidget = { anchor = "LEFT" , x = -12,y = VerticalAdjustment + 16 }
WidgetConfig.QuestWidgetNameOnly = { anchor = "LEFT" , x = -2,y = VerticalAdjustment + 22 }
WidgetConfig.ThreatPercentageWidget = { anchor = "RIGHT" , x = 13,y = VerticalAdjustment + 7 }
WidgetConfig.RangeWidget = { anchor = "CENTER", x=0, y=VerticalAdjustment + 10, w = 98, h = 8.5 }

WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig
local ThemeName = "Renaitre|cFFFF4400"

---------------------------------------------
-- NeatPlates Hub Integration
---------------------------------------------
NeatPlatesThemeList[ThemeName] = Theme
NeatPlatesHubFunctions.ApplyHubFunctions(Theme)




