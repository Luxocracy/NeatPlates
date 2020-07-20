-----------------------------------------------------
-- NeatPlates Grey
-----------------------------------------------------
local Theme = {}
local CopyTable = NeatPlatesUtility.copyTable

local defaultArtPath = "Interface\\Addons\\NeatPlates_Grey"
--local font =					defaultArtPath.."\\LiberationSans-Regular.ttf"
--local font = "Interface\\Addons\\NeatPlatesHub\\shared\\AccidentalPresidency.ttf"
--local font = "Interface\\Addons\\NeatPlates\\media\\DefaultFont.ttf"
local font =					"FONTS\\ARIALN.TTF"

local nameplate_verticalOffset = -5
local castBar_verticalOffset = -6 -- Adjust Cast Bar distance
local EmptyTexture = "Interface\\Addons\\NeatPlatesHub\\shared\\Empty"

-- Non-Latin Font Bypass
local NonLatinLocales = { ["koKR"] = true, ["zhCN"] = true, ["zhTW"] = true, }
if NonLatinLocales[GetLocale()] == true then font = STANDARD_TEXT_FONT end

local StyleDefault = {}

StyleDefault.hitbox = {
	width = 104,
	height = 28,
	x = 0,
	y = 0,
}

StyleDefault.highlight = {
	texture =					defaultArtPath.."\\Highlight",
}

StyleDefault.healthborder = {
	texture		 =				defaultArtPath.."\\RegularBorder",
	glowtexture =					defaultArtPath.."\\Highlight",
	--texture =					defaultArtPath.."\\EliteBorder",
	width = 128,
	height = 64,
	x = 0,
	y = nameplate_verticalOffset,
	anchor = "CENTER",
}

StyleDefault.eliteicon = {
	texture = defaultArtPath.."\\EliteIcon",
	width = 14,
	height = 14,
	x = -45,
	y = 22+nameplate_verticalOffset,
	anchor = "CENTER",
	show = true,
}

StyleDefault.skullicon = {
	width = 14,
	height = 14,
	x = -45,
	y = 22+nameplate_verticalOffset,
	anchor = "CENTER",
}

StyleDefault.targetindicator = {
	texture = defaultArtPath.."\\TargetBox",
	width = 128,
	height = 64,
	x = 0,
	y = nameplate_verticalOffset,
	anchor = "CENTER",
	show = true,
}

StyleDefault.targetindicator_arrowtop = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Top",
	width = 64,
	height = 12,
	x = 0,
	y = 34+nameplate_verticalOffset,
	anchor = "CENTER",
	show = true,
}

StyleDefault.targetindicator_arrowsides = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Sides",
	width = 138,
	height = 18,
	x = 0,
	y = 15+nameplate_verticalOffset,
	anchor = "CENTER",
	show = true,
}

StyleDefault.targetindicator_arrowright = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Right",
	width = 18,
	height = 18,
	x = 22,
	y = 15+nameplate_verticalOffset,
	anchor = "RIGHT",
	show = true,
}

StyleDefault.targetindicator_arrowleft = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Left",
	width = 18,
	height = 18,
	x = -22,
	y = 15+nameplate_verticalOffset,
	anchor = "LEFT",
	show = true,
}

StyleDefault.threatborder = {
	texture =			defaultArtPath.."\\RegularThreat",
	width = 128,
	height = 64,
	x = 0,
	y = nameplate_verticalOffset,
	anchor = "CENTER",
}

StyleDefault.castborder = {
	texture =					defaultArtPath.."\\CastStoppable",
	width = 128,
	height = 64,
	x = 0,
	y = 0 +castBar_verticalOffset+nameplate_verticalOffset,
	anchor = "CENTER",
}

StyleDefault.castnostop = {
	texture = 				defaultArtPath.."\\CastNotStoppable",
	width = 128,
	height = 64,
	x = 0,
	y = 0+castBar_verticalOffset+nameplate_verticalOffset,
	anchor = "CENTER",
}

StyleDefault.name = {
	typeface =					font,
	size = 9,
	width = 100,
	height = 10,
	x = 0,
	y = 6+nameplate_verticalOffset,
	align = "LEFT",
	anchor = "LEFT",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
}

StyleDefault.subtext = {
	typeface =					font,
	size = 9,
	width = 100,
	height = 10,
	x = 0,
	y = -4+nameplate_verticalOffset,
	yOffset = 0,
	align = "LEFT",
	anchor = "LEFT",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
}

StyleDefault.level = {
	typeface =					font,
	size = 9,
	width = 25,
	height = 10,
	x = 36,
	y = 6+nameplate_verticalOffset,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
}

StyleDefault.healthbar = {
	texture =					 defaultArtPath.."\\Statusbar",
	backdrop = 				EmptyTexture,
	--backdrop = 				defaultArtPath.."\\Statusbar",
	height = 12,
	width = 101,
	x = 0,
	y = 15+nameplate_verticalOffset,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.powerbar = {
	texture =					 defaultArtPath.."\\Statusbar",
	backdrop = 				EmptyTexture,
	--backdrop = 				defaultArtPath.."\\Statusbar",
	height = 2.5,
	width = 101,
	x = 0,
	y = 15+nameplate_verticalOffset+6.5,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.castbar = {
	texture =					defaultArtPath.."\\Statusbar",
	backdrop = 				EmptyTexture,
	--backdrop = 				defaultArtPath.."\\Statusbar",
	height = 11,
	width = 99,
	x = 0,
	y = -8+castBar_verticalOffset+nameplate_verticalOffset,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.customtext = {
	typeface =					font,
	size = 9,
	width = 97,
	height = 10,
	x = 0,
	y = 15.5+nameplate_verticalOffset,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.spelltext = {
	typeface =					font,
	size = 8,
	width = 100,
	height = 10,
	x = 1,
	y = castBar_verticalOffset-7+nameplate_verticalOffset,
	align = "LEFT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.spelltarget = {
	typeface =					font,
	size = 8,
	width = 100,
	height = 10,
	x = 1,
	y = castBar_verticalOffset-17+nameplate_verticalOffset,
	align = "LEFT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.durationtext = {
	typeface =					font,
	size = 8,
	width = 92,
	height = 10,
	x = 1,
	y = castBar_verticalOffset-7+nameplate_verticalOffset,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.spellicon = {
	width = 18,
	height = 18,
	x = 62,
	y = -8+castBar_verticalOffset+nameplate_verticalOffset,
	anchor = "CENTER",
}

StyleDefault.raidicon = {
	width = 16,
	height = 16,
	x = -30,
	y = 8+nameplate_verticalOffset,
	anchor = "TOP",
		-- Texture Coordinates
	left = 0,
	right = 1,
	top = 0,
	bottom = 1,
	--show = false,
}

StyleDefault.frame = {
	width = 101,
	height = 45,
	x = 0,
	y = 0+nameplate_verticalOffset,
	anchor = "CENTER",
}

StyleDefault.threatcolor = {
	LOW = {r = .6, g = 1, b = 0, a = 1,},
	MEDIUM = {r = .6, g = 1, b = 0, a = 1,},
	HIGH = {r = 1, g = 0, b = 0, a= 1,},
}

StyleDefault.extrabar = {
	texture =					defaultArtPath.."\\Statusbar",
	backdrop = 				"Interface/Tooltips/UI-Tooltip-Background",
	width = 100,
	height = 4,
	x = 0,
	y = 24+nameplate_verticalOffset,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.extratext = {
	typeface =					font,
	size = 8,
	width = 100,
	height = 4,
	x = 0,
	y = 23+nameplate_verticalOffset,
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
StyleTextOnly.healthborder.y = nameplate_verticalOffset - 7
StyleTextOnly.healthbar.texture = EmptyTexture
StyleTextOnly.healthbar.backdrop = EmptyTexture
StyleTextOnly.powerbar.texture = EmptyTexture
StyleTextOnly.powerbar.backdrop = EmptyTexture
StyleTextOnly.eliteicon.texture = EmptyTexture
StyleTextOnly.extrabar.width = 70
StyleTextOnly.extrabar.y = nameplate_verticalOffset - 2
StyleTextOnly.extratext.y = nameplate_verticalOffset - 3
StyleTextOnly.extrabar.x = 0
StyleTextOnly.extratext.x = 0
--StyleTextOnly.name.flags = "OUTLINE"
StyleTextOnly.name.align = "CENTER"
StyleTextOnly.name.anchor = "CENTER"
StyleTextOnly.name.size = 12
StyleTextOnly.name.y = 12
StyleTextOnly.name.x = 0
StyleTextOnly.name.width = 200
StyleTextOnly.subtext.show = true
StyleTextOnly.subtext.align = "CENTER"
StyleTextOnly.subtext.anchor = "CENTER"
--StyleTextOnly.subtext.flags = "OUTLINE"
StyleTextOnly.subtext.size = 8
StyleTextOnly.subtext.y = 3
StyleTextOnly.subtext.x = 0
StyleTextOnly.subtext.width = 500
StyleTextOnly.customtext.show = false
StyleTextOnly.level.show = false
StyleTextOnly.skullicon.show = false
StyleTextOnly.eliteicon.show = false
StyleTextOnly.highlight.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Highlight"
StyleTextOnly.targetindicator.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Target"
StyleTextOnly.targetindicator.y = nameplate_verticalOffset - 8
StyleTextOnly.targetindicator.height = 66


-- Active Styles
Theme["Default"] = StyleDefault
Theme["NameOnly"] = StyleTextOnly

local WidgetConfig = {}
WidgetConfig.ClassIcon = { anchor = "TOPLEFT", w = 24, h = 24 , x = -15 ,y = 8 }
--WidgetConfig.TotemIcon = { anchor = "TOP" , x = -28 ,y = 12 }
WidgetConfig.TotemIcon = { anchor = "TOP", w = 19, h = 18 , x = 0 ,y = 10 }
WidgetConfig.ThreatLineWidget = { anchor =  "CENTER", x = 0 ,y = 18 }
WidgetConfig.ThreatWheelWidget = { anchor =  "CENTER", x = 31 ,y = 23 } -- "CENTER", plate, 30, 18
WidgetConfig.ComboWidget = { anchor = "CENTER" , x = 0 ,y = 24 }
WidgetConfig.DebuffWidget = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = 0 }
WidgetConfig.AbsorbWidget =	{ anchor="TOP", x = 0 , y = 5, w = 101, h = 12 }
WidgetConfig.DebuffWidgetPlus = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = 8 }
WidgetConfig.QuestWidget = { anchor = "LEFT" , x = -14,y = 10 }
WidgetConfig.QuestWidgetNameOnly = { anchor = "LEFT" , x = -8,y = 12 }
WidgetConfig.ThreatPercentageWidget = { anchor = "RIGHT" , x = 12,y = 24 }
WidgetConfig.RangeWidget = { anchor = "CENTER", x=0, y=4, w = 101, h = 12 }

WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig
local ThemeName = "Grey"

---------------------------------------------
-- NeatPlates Hub Integration
---------------------------------------------

NeatPlatesThemeList[ThemeName] = Theme
NeatPlatesHubFunctions.ApplyHubFunctions(Theme)
