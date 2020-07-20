-----------------------------------------------------
-- Theme Definition
-----------------------------------------------------
local Theme = {}
local CopyTable = NeatPlatesUtility.copyTable
local path = "Interface\\Addons\\NeatPlates_Quatre\\"
--local font = "Interface\\Addons\\NeatPlatesHub\\shared\\AccidentalPresidency.ttf"; local fontsize = 12;
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
	width = 104,
	height = 30,
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
	texture		 =				path.."TargetBox_Original",
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
	y = VerticalAdjustment+36,
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
	--texture		 =				path.."Highlight",
	texture		 =					path.."Highlight",
	--width = 128,
	--height = 64,
}

StyleDefault.threatborder = {
	texture =			path.."Warning",
	width = 128,
	height = 64,
	x = 0,
	y = VerticalAdjustment,
	anchor = "CENTER",
}

StyleDefault.castbar = {
	texture =					path.."Statusbar",
	backdrop = 				EmptyTexture,
	height = 10,
	width = 99,
	x = 0,
	y = 15+castbarVertical,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.castborder = {
	texture =					path.."RegularBorder",
	width = 128,
	height = 64,
	x = 0,
	y = castbarVertical,
	anchor = "CENTER",
}

StyleDefault.castnostop = {
	texture = 				path.."RegularBorderAlternative",
	width = 128,
	height = 64,
	x = 0,
	y = castbarVertical,
	anchor = "CENTER",
}

StyleDefault.name = {
	typeface =					font,
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
	typeface =					font,
	size = fontsize - 1,
	width = 180,
	height = 12,
	x = 0,
	y = VerticalAdjustment + 0,
	yOffset = 11,
	align = "CENTER",
	anchor = "TOP",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
}

StyleDefault.level = {
	typeface =					font,
	size = fontsize - 1,
	width = 93,
	height = 10,
	x = -2,
	--y = VerticalAdjustment + 14.85,
	--y = VerticalAdjustment + 15.5,
	y = VerticalAdjustment + 16,
	align = "LEFT",
	anchor = "CENTER",
	vertical = "MIDDLE",
	shadow = true,
	flags = "NONE",
	show = false,
}

StyleDefault.healthbar = {
	texture =					 path.."Statusbar",
	backdrop = 				path.."StatusbarBackground",
	height = 9,
	width = 98.5,
	x = 0,
	y = VerticalAdjustment + 15,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.powerbar = {
	texture =					 path.."Statusbar",
	--backdrop = 				path.."StatusbarBackground",
	backdrop = 				path.."RegularBackdrop",
	height = 4,
	width = 98.5,
	x = 0,
	y = VerticalAdjustment + 15 - 7,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.customtext = {
	typeface =					font,
	size = fontsize - 1,
	width = 93,
	height = 10,
	x = 0,
	y = VerticalAdjustment + 16,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.spelltext = {
	typeface =					font,
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
	typeface =					font,
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
	typeface =					font,
	size = fontsize-1,
	height = 12,
	width = 96,
	x = 0,
	y = 0 + castbarVertical,
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
	--x = 0,
	--y = 39,
	x = -60,
	y = VerticalAdjustment + 16,
	anchor = "CENTER",
}

StyleDefault.customart = {
	width = 25,
	height = 25,
	--x = 0,
	--y = 39,
	x = -55,
	y = VerticalAdjustment + 21,
	anchor = "CENTER",
	show = true,
}

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
	HIGH = {r = 1, g = 0, b = 0, a= 1,},
}

StyleDefault.extrabar = {
	texture =					path.."Statusbar",
	backdrop = 				"Interface/Tooltips/UI-Tooltip-Background",
	height = 4,
	width = 98,
	x = 0,
	y = VerticalAdjustment+6,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.extratext = {
	typeface =					font,
	size = 7,
	height = 4,
	width = 98,
	x = 0,
	y = VerticalAdjustment+5,
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
StyleTextOnly.healthbar.texture = EmptyTexture
StyleTextOnly.healthbar.backdrop = EmptyTexture
StyleTextOnly.powerbar.texture = EmptyTexture
StyleTextOnly.powerbar.backdrop = EmptyTexture
StyleTextOnly.extrabar.width = 70
StyleTextOnly.extrabar.y = VerticalAdjustment + 5
StyleTextOnly.extratext.y = VerticalAdjustment + 4
StyleTextOnly.extrabar.x = 0
StyleTextOnly.extratext.x = 0
StyleTextOnly.eliteicon.texture = EmptyTexture
StyleTextOnly.subtextheight = 10
StyleTextOnly.subtext.align = "CENTER"
StyleTextOnly.subtext.anchor = "CENTER"
StyleTextOnly.subtext.vertical = "BOTTOM"
StyleTextOnly.subtext.size = fontsize - 2
StyleTextOnly.subtext.y = VerticalAdjustment + 16
StyleTextOnly.subtext.width = 500
StyleTextOnly.subtext.show = true
StyleTextOnly.customtext.show = false
StyleTextOnly.level.show = false
StyleTextOnly.skullicon.show = false
StyleTextOnly.eliteicon.show = false
StyleTextOnly.highlight.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Highlight"
StyleTextOnly.targetindicator.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Target"

-- Setup Target/Focus/Mouseover Indicator
--StyleDefault.target = CopyTable(StyleDefault.targetindicator)
--StyleDefault.focus = CopyTable(StyleDefault.targetindicator)
--StyleDefault.mouseover = CopyTable(StyleDefault.targetindicator)

--StyleTextOnly.target = CopyTable(StyleTextOnly.targetindicator)
--StyleTextOnly.focus = CopyTable(StyleTextOnly.targetindicator)
--StyleTextOnly.mouseover = CopyTable(StyleTextOnly.targetindicator)

-- Active Styles
Theme["Default"] = StyleDefault
Theme["NameOnly"] = StyleTextOnly


local WidgetConfig = {}
WidgetConfig.ClassIcon = { anchor = "RIGHT", w = 24, h = 24 , x = 23, y = VerticalAdjustment + 14 }		-- Above Name
WidgetConfig.TotemIcon = { anchor = "RIGHT", w = 19, h = 18 , x = 23 ,y = VerticalAdjustment + 14 }
WidgetConfig.ThreatLineWidget = { anchor =  "TOP", x = 0 ,y = VerticalAdjustment + 20 }	-- y = 20
WidgetConfig.ThreatWheelWidget = { anchor =  "CENTER", x = 33 ,y = VerticalAdjustment + 27 } -- "CENTER", plate, 30, 18
WidgetConfig.ComboWidget = { anchor = "TOP" , x = 0 ,y = VerticalAdjustment + 0 }
WidgetConfig.DebuffWidget = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = VerticalAdjustment + 10 }
WidgetConfig.AbsorbWidget =	{ anchor="LEFT", x = 1, y = 4, w = 98, h = 8.5 }
WidgetConfig.QuestWidget = { anchor = "LEFT" , x = -12,y = VerticalAdjustment + 16 }
WidgetConfig.QuestWidgetNameOnly = { anchor = "LEFT" , x = -2,y = VerticalAdjustment + 22 }
WidgetConfig.ThreatPercentageWidget = { anchor = "RIGHT" , x = 14,y = VerticalAdjustment + 7 }
WidgetConfig.RangeWidget = { anchor = "CENTER", x=0, y=VerticalAdjustment+9, w = 98, h = 8.5 }


WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig
local ThemeName = "Quatre"

---------------------------------------------
-- NeatPlates Hub Integration
---------------------------------------------
NeatPlatesThemeList[ThemeName] = Theme
NeatPlatesHubFunctions.ApplyHubFunctions(Theme)




