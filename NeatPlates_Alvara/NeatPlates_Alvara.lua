local path = "Interface\\Addons\\NeatPlates_Alvara\\Media" 
local font = path.."\\anversbold.ttf";

-- Non-Latin Font Bypass
local NonLatinLocales = { ["koKR"] = true, ["zhCN"] = true, ["zhTW"] = true, }
if NonLatinLocales[GetLocale()] == true then font = STANDARD_TEXT_FONT end

local Theme = {}
local StyleDefault = {}

StyleDefault.hitbox = {
	width = 96,
	height = 24,
	x = 0,
	y = -4,
}
StyleDefault.frame = {
	width = 128,
	height = 16,
}
StyleDefault.threatborder = {
	texture = path.."\\Threat",
	elitetexture = path.."\\ThreatElite",
	width = 128,
	height = 16,
	x = 0,
	y = 0,
	anchor = "CENTER",
}
StyleDefault.threatcolor = {
	LOW = { r = 0, g = 1, b = 0, a= 1, },
	MEDIUM = { r = 1, g = 1, b = 0, a = 1, },
	HIGH = { r = 1, g = 0, b = 0, a = 1, },
}
StyleDefault.healthborder = {
	texture = path.."\\Shade",
	--glowtexture = path.."\\Highlight",
	--elitetexture = path.."\\ShadeElite",
	width = 92,
	height = 8,
	x = 0,
	y = 0,
	anchor = "CENTER",
}
StyleDefault.eliteicon = {
	texture = path.."\\EliteIcon",
	width = 10,
	height = 10,
	x = -43,
	y = -4,
	anchor = "CENTER",
	show = true,
}
StyleDefault.targetindicator = {
	texture		 =				path.."\\Highlight",
	width = 130,
	height = 15,
	x = 0,
	y = 0,
	anchor = "CENTER",
	show = true,
}
StyleDefault.targetindicator_arrowtop = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Top",
	width = 64,
	height = 12,
	x = 0,
	y = 24,
	anchor = "CENTER",
	show = true,
}
StyleDefault.targetindicator_arrowsides = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Sides",
	width = 132,
	height = 18,
	x = 0,
	y = 0,
	anchor = "CENTER",
	show = true,
}
StyleDefault.targetindicator_arrowright = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Right",
	width = 18,
	height = 18,
	x = 5,
	y = 0,
	anchor = "RIGHT",
	show = true,
}
StyleDefault.targetindicator_arrowleft = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Leftt",
	width = 18,
	height = 18,
	x = -5,
	y = 0,
	anchor = "LEFT",
	show = true,
}
StyleDefault.skullicon = {
	width = 12,
	height = 12,
	x = -43,
	y = -4,
	anchor = "CENTER",
}
StyleDefault.healthbar = {
	texture = path.."\\Statusbar",
	width = 92,
	height = 8,
	x = 0,
	y = 0,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}
StyleDefault.powerbar = {
	texture = path.."\\Statusbar",
	backdrop =  path.."\\Shade",
	width = 92,
	height = 4,
	x = 0,
	y = - 6,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}
StyleDefault.castbar = {
	texture = path.."\\StatusbarCast",
	width = 128,
	height = 16,
	x = 0,
	y = 0,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}
StyleDefault.castborder = {
	texture = path.."\\ShadeCast",
	width = 128,
	height = 16,
	x = 0,
	y = 0,
	anchor = "CENTER",
}
StyleDefault.name = {
	typeface = font,
	size = 10,
	width = 128,
	height = 10,
	x = 18,
	y = 10,
	align = "LEFT",
	anchor = "LEFT",
	vertical = "TOP",
	shadow = true,
}
StyleDefault.subtext = {
	typeface = font,
	width = 500,
	x = 18,
	y = 0,
	align = "LEFT",
	anchor = "LEFT",
	vertical = "TOP",
	shadow = true,
}
StyleDefault.level = {
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
StyleDefault.spellicon = {
	width = 12,
	height = 12,
	x = 5,
	y = 0,
	anchor = "LEFT",
}
StyleDefault.spelltext = {
	typeface = font,
	size = 8,
	height = 12,
	width = 180,
	x = 0,
	y = -6,
	align = "CENTER",
	anchor = "TOP",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}
StyleDefault.spelltarget = {
	typeface = font,
	size = 8,
	height = 12,
	width = 180,
	x = 0,
	y = -13,
	align = "CENTER",
	anchor = "TOP",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}
StyleDefault.durationtext = {
	typeface = font,
	size = 7,
	height = 12,
	width = 90,
	x = 0,
	y = -6,
	align = "RIGHT",
	anchor = "TOP",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}
StyleDefault.raidicon = {
	width = 12,
	height = 12,
	x = 0,
	y = 22,
	anchor = "CENTER",
}
StyleDefault.specialText = {
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
StyleDefault.options = {
	showLevel = true,
	showName = true,
	showSpecialText = true,
	showDangerSkull = true,
	showspellIcon = true,
}
StyleDefault.customtext = {
	typeface = font,
	width = 90,
	x = -3,
	y = 1.5,
	align = "CENTER",
	shadow = false,
	show = true,
}

StyleDefault.extrabar = {
	texture =	path.."\\Statusbar",
	backdrop = "Interface/Tooltips/UI-Tooltip-Background",
	height = 4,
	width = 92,
	x = 0,
	y = -7,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.extratext = {
	typeface = font,
	size = 7,
	height = 4,
	width = 97,
	x = 0,
	y = -8,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

local CopyTable = NeatPlatesUtility.copyTable

-- No Bar
local StyleTextOnly = CopyTable(StyleDefault)

StyleTextOnly.threatborder.texture = EmptyTexture
StyleTextOnly.healthborder.texture = EmptyTexture
StyleTextOnly.healthbar.texture = EmptyTexture
StyleTextOnly.healthbar.backdrop = EmptyTexture
StyleTextOnly.powerbar.texture = EmptyTexture
StyleTextOnly.powerbar.backdrop = EmptyTexture
StyleTextOnly.extrabar.width = 60
StyleTextOnly.extrabar.y = -9
StyleTextOnly.extratext.y = -10
StyleTextOnly.name.align = "CENTER"
StyleTextOnly.name.anchor = "CENTER"
StyleTextOnly.name.size = 12
StyleTextOnly.name.x = 0
StyleTextOnly.name.y = 14
StyleTextOnly.subtext.x = -3
StyleTextOnly.subtext.y = 1.5
StyleTextOnly.subtext.align = "CENTER"
StyleTextOnly.subtext.anchor = "CENTER"
StyleTextOnly.subtext.vertical = "BOTTOM"
StyleTextOnly.subtext.show = true
StyleTextOnly.customtext.show = false
StyleTextOnly.level.show = false
StyleTextOnly.raidicon.x = -66
StyleTextOnly.raidicon.y = 15
StyleTextOnly.raidicon.height = 14
StyleTextOnly.raidicon.width = 14
StyleTextOnly.raidicon.anchor = "TOP"


Theme["Default"] = StyleDefault
Theme["NameOnly"] = StyleTextOnly

local WidgetConfig = {}
WidgetConfig.ClassIcon = { anchor = "TOP", w = 24, h = 24 , x = 57,y = 4 }		-- Above Name
WidgetConfig.TotemIcon = { anchor = "TOP", w = 19, h = 18 , x = 0 ,y = 14 }
WidgetConfig.ThreatLineWidget = { anchor =  "TOP", x = -16 ,y = 20, w = 10, h = 2 }	-- y = 20
WidgetConfig.ThreatWheelWidget = { anchor =  "CENTER", x = 33 ,y = 15 } -- "CENTER", plate, 30, 18
WidgetConfig.ComboWidget = { anchor = "TOP" , x = 0 ,y = -2 }
WidgetConfig.DebuffWidget = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = 13 }
WidgetConfig.AbsorbWidget =	{ anchor="LEFT", x = 18, y = 1, w = 92, h = 9}
WidgetConfig.QuestWidget = { anchor = "LEFT" , x = 5,y = 3 }
WidgetConfig.QuestWidgetNameOnly = { anchor = "LEFT" , x = 4,y = 12 }
WidgetConfig.ThreatPercentageWidget = { anchor = "RIGHT" , x = -2,y = -10 }
WidgetConfig.RangeWidget = { anchor = "CENTER", x=0, y=-5, w = 92, h = 9 }

WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig

local ThemeName = "Alvara"

---------------------------------------------
-- NeatPlates Hub Integration
---------------------------------------------
NeatPlatesThemeList[ThemeName] = Theme
NeatPlatesHubFunctions.ApplyHubFunctions(Theme)
