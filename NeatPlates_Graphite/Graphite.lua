-----------------------------------------------------
-- Theme Definition
-----------------------------------------------------
local Theme = {}
local ThemeName = "Graphite"
local CopyTable = NeatPlatesUtility.copyTable
local EmptyTexture = "Interface\\Addons\\NeatPlatesHub\\shared\\Empty"
local path = "Interface\\Addons\\NeatPlates_Graphite\\"
--local font = "Interface\\Addons\\NeatPlatesHub\\shared\\AccidentalPresidency.ttf"
local font = "Interface\\Addons\\NeatPlatesHub\\shared\\RobotoCondensed-Bold.ttf"
--local fontsize = 12;

-- Non-Latin Font Bypass
local NonLatinLocales = { ["koKR"] = true, ["zhCN"] = true, ["zhTW"] = true, }
if NonLatinLocales[GetLocale()] == true then font = STANDARD_TEXT_FONT end


local castoffset = 1

local artwidth = 90
local barwidth = 90
local borderheight = 16
local barheight = 16
local widthfactor = 1 -- .85
local heightfactor = 1.2

local StyleDefault = {}

StyleDefault.hitbox = {
	width = 92,
	height = 24,
	x = 0,
	y = -2,
}

StyleDefault.frame = {
	--width = 100,
	--height = 45,
	x = 0,
	y = 0,		-- (-12) To put the bar near the middle
	anchor = "CENTER",
}

StyleDefault.healthbar = {
	texture 				= path.."StatusBar",
	width = barwidth*widthfactor,
	--width = 96*widthfactor,
	height = barheight*heightfactor,
	x = 0,
	y = 0,
}

StyleDefault.powerbar = {
	texture 				= path.."StatusBar",
	backdrop = path.."HealthBorder",
	width = barwidth*widthfactor,
	--width = 96*widthfactor,
	height = (barheight*heightfactor),
	x = 0,
	y = -(barheight*heightfactor) * 0.14,
}

StyleDefault.healthborder = {
	texture	= path.."HealthBorder",
	width = artwidth*widthfactor,
	height = borderheight*heightfactor,
	x = 0,
	y = 0,
}

StyleDefault.targetindicator = {
	texture 			= path.."Target",
	width = 128,
	height = 36,
	x = 0,
	y = -4,
	anchor = "CENTER",
	show = true,
}

StyleDefault.targetindicator_arrowtop = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Top",
	width = 64,
	height = 12,
	x = 0,
	y = 21,
	anchor = "CENTER",
	show = true,
}

StyleDefault.targetindicator_arrowsides = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Sides",
	width = 138,
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
	x = 21,
	y = 0,
	anchor = "RIGHT",
	show = true,
}

StyleDefault.targetindicator_arrowleft = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Left",
	width = 18,
	height = 18,
	x = -21,
	y = 0,
	anchor = "LEFT",
	show = true,
}

StyleDefault.highlight = {
	texture 			= path.."Mouseover",
}

StyleDefault.threatborder = {
	texture = path.."ThreatBorderSingleDot",
	--texture = path.."ThreatBorderDoubleDot",
	--texture = EmptyTexture,
	width = artwidth*widthfactor*2,
	height = borderheight*heightfactor*2,
	x = 0,
	y = 0,
	anchor = "CENTER",
	show = true
}

StyleDefault.castbar = {
	texture 				= path.."StatusBar",
	width = barwidth*widthfactor,
	height = barheight*heightfactor,
	anchor = "CENTER",
	x = 0,
	y = -6+castoffset,
}

StyleDefault.castborder = {
	texture	= path.."HealthBorder",
	width = artwidth*widthfactor,
	height = borderheight*heightfactor,
	anchor = "CENTER",
	x = 0,
	y = -6+castoffset,
}

StyleDefault.castnostop = {
	texture	= path.."HealthBorder",
	width = artwidth*widthfactor,
	height = borderheight*heightfactor,
	anchor = "CENTER",
	x = 0,
	y = -6+castoffset,
}

StyleDefault.name = {
	typeface =					font,
	size = 10,
	width = 175,
	height = 14,
	x = 0,
	y = 7,	-- For OVER the bar
	--y = -7,		-- For UNDER the bar
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	flags = "NONE",
	shadow = true,
	show = true,
}

StyleDefault.subtext = {
	typeface =					font,
	size = 10,
	width = 175,
	height = 14,
	x = 0,
	y = -3,
	yOffset = 11,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = true,
}

StyleDefault.level = {
	typeface =					font,
	show = false,
}



StyleDefault.customtext = {
	typeface =					font,
	size = 10,
	width = 175,
	height = 14,
	x = 0,
	y = -1,	-- For OVER the bar
	--y = -7,		-- For UNDER the bar
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	--flags = "",
	shadow = true,
	show = true,
}

StyleDefault.spelltext = {
	typeface =					font,
	size = 10,
	width = 175,
	height = 14,
	x = 0,
	y = -14+castoffset,		-- For UNDER the bar
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	--flags = "",
	shadow = false,
	show = true,
}

StyleDefault.spelltarget = {
	typeface =					font,
	size = 10,
	width = 175,
	height = 14,
	x = 0,
	y = -24+castoffset,		-- For UNDER the bar
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	--flags = "",
	shadow = false,
	show = true,
}

StyleDefault.durationtext = {
	typeface =					font,
	size = 8,
	width = (barwidth-4)*widthfactor,
	height = 14,
	x = 0,
	y = -7+castoffset,		-- For UNDER the bar
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "CENTER",
	--flags = "",
	shadow = false,
	show = true,
}

StyleDefault.spellicon = {
	height = 12,
	width = 12,
	x = -38,
	y = -4,
	show = false,
}

StyleDefault.eliteicon = {
	texture = path.."EliteIcon",
	width = 10,
	height = 10,
	x = -46,
	y = -4,
	anchor = "CENTER",
	show = true,
}

StyleDefault.raidicon = {
	width = 12,
	height = 12,
	x = 0,
	y = 20,
	anchor = "CENTER",
}

StyleDefault.skullicon = {
	show = false,
}

StyleDefault.threatcolor = {
	LOW = {r = .6, g = 1, b = 0, a = 0,},
	MEDIUM = {r = .6, g = 1, b = 0, a = 1,},
	HIGH = {r = 1, g = 0, b = 0, a= 1,},
}

StyleDefault.extrabar = {
	texture =					path.."StatusBar",
	--backdrop = 				"Interface/Tooltips/UI-Tooltip-Background",
	width = (barwidth*widthfactor)/1.2,
	height = barheight*heightfactor,
	x = 0,
	y = -4,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.extratext = {
	typeface =					font,
	size = 7,
	width = (barwidth*widthfactor)/1.2,
	height = barheight*heightfactor,
	x = 0,
	y = 2,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

-- No-Bar Style		(6.2)
local StyleTextOnly = CopyTable(StyleDefault)
StyleTextOnly.threatborder.texture = EmptyTexture
StyleTextOnly.healthborder.texture = EmptyTexture
StyleTextOnly.healthborder.height = 64
StyleTextOnly.healthborder.y = -18
StyleTextOnly.healthbar.texture = EmptyTexture
StyleTextOnly.healthbar.backdrop = EmptyTexture
StyleTextOnly.powerbar.texture = EmptyTexture
StyleTextOnly.powerbar.backdrop = EmptyTexture
StyleTextOnly.eliteicon.texture = EmptyTexture
StyleTextOnly.extrabar.width = 60
StyleTextOnly.extrabar.y = -14
StyleTextOnly.extratext.y = -8
StyleTextOnly.extrabar.x = 0
StyleTextOnly.extratext.x = 0
StyleTextOnly.subtext.show = true
StyleTextOnly.subtext.align = "CENTER"
StyleTextOnly.subtext.size = 9
StyleTextOnly.subtext.y = -2
StyleTextOnly.subtext.width = 500
StyleTextOnly.customtext.show = false
StyleTextOnly.level.show = false
StyleTextOnly.skullicon.show = false
StyleTextOnly.eliteicon.show = false
StyleTextOnly.highlight.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Highlight"


-- Active Styles
Theme["Default"] = StyleDefault
Theme["NameOnly"] = StyleTextOnly

local WidgetConfig = {}
WidgetConfig.ClassIcon = { anchor = "RIGHT", w = 24, h = 24 , x = 16,y = 0 }		-- Above Name
WidgetConfig.TotemIcon = { anchor = "RIGHT", w = 19, h = 18 , x = 16,y = 0 }
WidgetConfig.ThreatLineWidget = { anchor =  "TOP", x = 0 ,y = 0 }	-- y = 20
--WidgetConfig.ThreatWheelWidget = { anchor =  "CENTER", x = 33 ,y = 12 } -- "CENTER", plate, 30, 18
WidgetConfig.ThreatWheelWidget = { anchor =  "CENTER", x = 0 ,y = 16 } -- "CENTER", plate, 30, 18
WidgetConfig.ComboWidget = { anchor = "CENTER" , x = 0 ,y = -8 }
WidgetConfig.RangeWidget = { anchor = "CENTER" , x = 0 ,y = 12 }
WidgetConfig.DebuffWidget = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = -5 }
WidgetConfig.AbsorbWidget =	{ anchor="CENTER", x = 0 , y = 0.5, w = 89, h = 1.5 }
WidgetConfig.QuestWidget = { anchor = "LEFT" , x = -8,y = 4 }
WidgetConfig.QuestWidgetNameOnly = { anchor = "LEFT" , x = -2,y = 4 }
WidgetConfig.ThreatPercentageWidget = { anchor = "RIGHT" , x = 11,y = -7 }
WidgetConfig.RangeWidget = { anchor = "CENTER", x=0, y=-5, w = 89, h = 1.5 }
-- 	WidgetConfig.DebuffWidgetPlus = { anchor = "TOP" , x = 15 ,y = 26.5 }

WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig
local ThemeName = "Graphite"

---------------------------------------------
-- NeatPlates Hub Integration
---------------------------------------------
NeatPlatesThemeList[ThemeName] = Theme
NeatPlatesHubFunctions.ApplyHubFunctions(Theme)
