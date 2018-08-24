local path = "Interface\\Addons\\TidyPlatesContinued_Alvara\\Media" 
local font = path.."\\anversbold.ttf";

-- Non-Latin Font Bypass
local NonLatinLocales = { ["koKR"] = true, ["zhCN"] = true, ["zhTW"] = true, }
if NonLatinLocales[GetLocale()] == true then font = STANDARD_TEXT_FONT end

local Theme = {}
local Alvara = {}

Alvara.frame = {
	width = 128,
	height = 16,
}
Alvara.threatborder = {
	texture = path.."\\Threat",
	elitetexture = path.."\\ThreatElite",
	width = 128,
	height = 16,
	x = 0,
	y = 0,
	anchor = "CENTER",
}
Alvara.threatcolor = {
	LOW = { r = 0, g = 1, b = 0, a= 1, },
	MEDIUM = { r = 1, g = 1, b = 0, a = 1, },
	HIGH = { r = 1, g = 0, b = 0, a = 1, },
}
Alvara.healthborder = {
	texture = path.."\\Shade",
	glowtexture = path.."\\Highlight",
	elitetexture = path.."\\ShadeElite",
	width = 128,
	height = 16,
	x = 0,
	y = 0,
	anchor = "CENTER",
}
Alvara.healthbar = {
	texture = path.."\\Statusbar",
	width = 128,
	height = 16,
	x = 0,
	y = 0,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}
Alvara.castbar = {
	texture = path.."\\StatusbarCast",
	width = 128,
	height = 16,
	x = 0,
	y = 0,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}
Alvara.castborder = {
	texture = path.."\\ShadeCast",
	width = 128,
	height = 16,
	x = 0,
	y = 0,
	anchor = "CENTER",
}
Alvara.name = {
	typeface = font,
	size = 10,
	width = 80,
	height = 10,
	x = 18,
	y = 10,
	align = "LEFT",
	anchor = "LEFT",
	vertical = "TOP",
	shadow = true,
}
Alvara.level = {
	typeface = font,
	size = 10,
	width = 20,
	height = 10,
	x = -18,
	y = 10,
	align = "RIGHT",
	anchor = "RIGHT",
	vertical = "TOP",
	shadow = true,
}
Alvara.dangerskull = {
	width = 12,
	height = 12,
	x = 0,
	y = 0,
	anchor = "RIGHT",
}
Alvara.spellicon = {
	width = 12,
	height = 12,
	x = 0,
	y = 0,
	anchor = "LEFT",
}
Alvara.raidicon = {
	width = 12,
	height = 12,
	x = 0,
	y = 22,
	anchor = "CENTER",
}
Alvara.specialText = {
	typeface = font,
	size = 10,
	width = 92,
	height = 10,
	x =  0,
	y =  0,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = false,
}
Alvara.options = {
	showLevel = true,
	showName = true,
	showSpecialText = true,
	showDangerSkull = true,
	showspellIcon = true,
}

local CopyTable = TidyPlatesContUtility.copyTable

-- No Bar
local StyleTextOnly = CopyTable(Alvara)

StyleTextOnly.threatborder.texture = EmptyTexture
StyleTextOnly.healthborder.texture = EmptyTexture
StyleTextOnly.healthbar.texture = EmptyTexture
StyleTextOnly.healthbar.backdrop = EmptyTexture
StyleTextOnly.name.align = "CENTER"
StyleTextOnly.name.anchor = "CENTER"
StyleTextOnly.name.size = 12
StyleTextOnly.name.y = 17
StyleTextOnly.level.show = false
StyleTextOnly.raidicon.x = -66
StyleTextOnly.raidicon.y = 15
StyleTextOnly.raidicon.height = 14
StyleTextOnly.raidicon.width = 14
StyleTextOnly.raidicon.anchor = "TOP"

Theme["Default"] = Alvara
Theme["NameOnly"] = StyleTextOnly

local WidgetConfig = {}
WidgetConfig.ClassIcon = { anchor = "TOP" , x = 57,y = 4 }		-- Above Name
WidgetConfig.TotemIcon = { anchor = "TOP" , x = 0 ,y = 14 }
WidgetConfig.ThreatLineWidget = { anchor =  "TOP", x = -16 ,y = 20, w = 10, h = 2 }	-- y = 20
WidgetConfig.ThreatWheelWidget = { anchor =  "CENTER", x = 33 ,y = 15 } -- "CENTER", plate, 30, 18
WidgetConfig.ComboWidget = { anchor = "TOP" , x = 0 ,y = -2 }
WidgetConfig.RangeWidget = { anchor = "CENTER" , x = 0 ,y = 0 }
WidgetConfig.DebuffWidget = { anchor = "TOP" , x = 19 ,y = 35 }
WidgetConfig.AbsorbWidget =	{ anchor="LEFT", x = 10, y = -2, w = 100, h = 8 }
WidgetConfig.QuestWidget = { anchor = "LEFT" , x = 5,y = 3 }
WidgetConfig.ThreatPercentageWidget = { anchor = "RIGHT" , x = -2,y = -10 }

WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig

local ThemeName = "Alvara"

---------------------------------------------
-- Tidy Plates Hub Integration
---------------------------------------------
TidyPlatesContThemeList[ThemeName] = Theme
TidyPlatesContHubFunctions.ApplyHubFunctions(Theme)
