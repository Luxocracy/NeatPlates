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
	width = 125,
	height = 30,
	x = 0,
	y = -2,
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

StyleDefault.target = {
	texture		 =					path.."TargetBox",
	width = 128,
	height = 64,
	x = 0,
	y = VerticalAdjustment,
	anchor = "CENTER",
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
	width = 25,
	height = 25,
	x = -55,
	y = VerticalAdjustment + 21,
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
StyleTextOnly.eliteicon.texture = EmptyTexture
StyleTextOnly.customtext.align = "CENTER"
--StyleTextOnly.customtext.size = 10
StyleTextOnly.customtext.size = fontsize - 2
StyleTextOnly.customtext.y = VerticalAdjustment + 16
StyleTextOnly.level.show = false
StyleTextOnly.skullicon.show = false
StyleTextOnly.eliteicon.show = false
StyleTextOnly.highlight.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Highlight"
StyleTextOnly.target.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Target"


-- Active Styles
Theme["Default"] = StyleDefault
Theme["NameOnly"] = StyleTextOnly


local WidgetConfig = {}
WidgetConfig.ClassIcon = { anchor = "RIGHT" , x = 23, y = VerticalAdjustment + 14 }		-- Above Name
WidgetConfig.TotemIcon = { anchor = "RIGHT" , x = 23 ,y = VerticalAdjustment + 14 }
WidgetConfig.ThreatLineWidget = { anchor =  "TOP", x = 0 ,y = VerticalAdjustment + 20 }	-- y = 20
WidgetConfig.ThreatWheelWidget = { anchor =  "CENTER", x = 33 ,y = VerticalAdjustment + 27 } -- "CENTER", plate, 30, 18
WidgetConfig.ComboWidget = { anchor = "TOP" , x = 0 ,y = VerticalAdjustment + 0 }
WidgetConfig.RangeWidget = { anchor = "CENTER" , x = 0 ,y = VerticalAdjustment + 12 }
WidgetConfig.DebuffWidget = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = VerticalAdjustment + 12 }
WidgetConfig.AbsorbWidget =	{ anchor="LEFT", x = 1, y = VerticalAdjustment + 16.5, w = 98, h = 8.5 }
WidgetConfig.QuestWidget = { anchor = "LEFT" , x = -12,y = VerticalAdjustment + 16 }
WidgetConfig.ThreatPercentageWidget = { anchor = "RIGHT" , x = 13,y = VerticalAdjustment + 7 }

WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig
local ThemeName = "Renaitre|cFFFF4400"

---------------------------------------------
-- Neat Plates Hub Integration
---------------------------------------------
NeatPlatesThemeList[ThemeName] = Theme
NeatPlatesHubFunctions.ApplyHubFunctions(Theme)




