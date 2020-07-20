-------------------------------------------------------------------------------
-- NeatPlates: BlizzardPlates 1.5b (7.1) - Dic/01/2016
-------------------------------------------------------------------------------

local path = "Interface\\Addons\\NeatPlates_BlizzardPlates\\media\\"
local font = STANDARD_TEXT_FONT
local VerticalAdjustment = 12

local vert = -20

local NonLatinLocales = { ["koKR"] = true, ["zhCN"] = true, ["zhTW"] = true, ["ruRU"] = true, }
if NonLatinLocales[GetLocale()] == true then font = STANDARD_TEXT_FONT end


local Theme = {}
local StyleDefault = {}


StyleDefault.hitbox = {
	width = 128,
	height = 34,
	x = 0,
	y = 0,
}

StyleDefault.highlight = {
	texture = 					"Interface\\Tooltips\\Nameplate-Glow",
}


StyleDefault.healthborder = {
	texture		 =				path.."BlizzardPlates-Border",
	width = 128,
	height = 32,
	anchor = "CENTER",
	y = 8,
	show = true,
}

StyleDefault.healthbar = {
	texture =					"Interface\\TARGETINGFRAME\\UI-StatusBar",
	-- backdrop = 					"Interface/Tooltips/UI-Tooltip-Background",
	backdrop = 					path.."backdrop",
	height = 9.5,
	width = 103,
	x = -9,
	y = 0,
}

StyleDefault.powerbar = {
	texture =					"Interface\\TARGETINGFRAME\\UI-StatusBar",
	-- backdrop = 					"Interface/Tooltips/UI-Tooltip-Background",
	backdrop = 					path.."backdrop",
	height = 4.5,
	width = 98,
	x = -8.5,
	y = -7,
}

StyleDefault.eliteicon = {
	texture = 					path.."EliteBlizzardPlatesIcon",
	-- texture = 					"Interface\\Tooltips\\EliteNameplateIcon",
	width = 64,
	height = 32,
	x = 48,
	y = -3, 
	anchor = "RIGHT",
}

StyleDefault.targetindicator = {
	texture = 					"Interface\\Tooltips\\Nameplate-Glow",
	width = 130,
	height = 50,
	x = 0,
	y = 12,
	anchor = "CENTER",
	show = true,
	blend = "ADD",
}

StyleDefault.targetindicator_arrowtop = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Top",
	width = 64,
	height = 12,
	x = 0,
	y = 30,
	anchor = "CENTER",
	show = true,
}

StyleDefault.targetindicator_arrowsides = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Sides",
	width = 165,
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
	x = 33,
	y = 0,
	anchor = "RIGHT",
	show = true,
}

StyleDefault.targetindicator_arrowleft = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Left",
	width = 18,
	height = 18,
	x = -33,
	y = 0,
	anchor = "LEFT",
	show = true,
}

StyleDefault.threatborder = {
	texture =					"Interface\\TargetingFrame\\UI-TargetingFrame-Flash",
	width = 140,
	height = 32,
	x = 0,
	y = -2,
	left = 0,
	right = .555,
	top = .53,
	bottom = .6,
	show = true,
}

StyleDefault.castborder = {
	-- texture =					path.."BlizzardPlates-CastBar",
	-- noicon = 					path.."BlizzardPlates-CastBar-noicon",
	texture =					"Interface\\Tooltips\\Nameplate-CastBar",
	noicon = 					path.."Nameplate-CastBar-NoIcon",
	backdrop = 					path.."backdrop",
	width = 128,
	height = 32,
	x = 0,
	y = vert,
	show = true,
}

StyleDefault.castnostop = {
	-- texture = 					path.."BlizzardPlates-CastBar-Shield",
	-- noicon = 					path.."BlizzardPlates-CastBar-Shield-noicon",
	texture = 					"Interface\\Tooltips\\Nameplate-CastBar-Shield",
	noicon = 					path.."Nameplate-CastBar-Shield-NoIcon",
	backdrop = 					path.."backdrop",
	width = 128,
	height = 32,
	x = 0,
	y = vert,
	show = true,
}

StyleDefault.name = {
	typeface =	font,
	size = 10,
	width = 200,
	height = 16,
	y = 20,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "BOTTOM",
	flags = "NONE",
	shadow = true,
}

StyleDefault.subtext = {
	typeface =					font,
	width = 200,
	height = 16,
	y = 10,
	yOffset = 9,
	align = "CENTER",
	shadow = true,
}

StyleDefault.level = {
	typeface =					font,
	size = 8.5,
	x = 11.5,
	y = 1.5,
	width = 20,
	align = "CENTER",
	anchor = "RIGHT",
	shadow = true,
	flags = "NONE",
}

StyleDefault.castbar = {
	texture =					"Interface\\TARGETINGFRAME\\UI-StatusBar",
	backdrop = 					path.."backdrop",
	height = 10,
	width = 104,
	x = 9, 
	y = vert,
	show = true,
}

StyleDefault.spellicon = {
	width = 14,
	height = 13,
	x = -8.5,
	y = vert,
	anchor = "LEFT",
}

StyleDefault.spelltext = {
	typeface =					font,
	size = 7,
	x = 5,
	y = vert+2,
	width = 140,
	align = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
	durationtext = {
		x = 30,
		align = "LEFT",
	},
}

StyleDefault.spelltarget = {
	typeface =					font,
	size = 7,
	x = 5,
	y = vert-9,
	width = 140,
	align = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
	durationtext = {
		x = 30,
		align = "LEFT",
	},
}

StyleDefault.durationtext = {
	typeface =					font,
	size = 7,
	x = 7,
	y = vert+2,
	width = 122,
	align = "RIGHT",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.skullicon = {
	texture =					"Interface\\TARGETINGFRAME\\UI-TargetingFrame-Skull",
	width = 13,
	height = 12,
	x = 8.5,
	y = 0.5,
	anchor = "RIGHT",
}

StyleDefault.customtext = {
	typeface =					font,
	width = 90,
	x = -3,
	y = 1.5,
	align = "CENTER",
	shadow = false,
	show = true,
}

StyleDefault.frame = {
	width = 101,
	height = 45,
	x = 0,
	y = 0,
	anchor = "CENTER",
}

StyleDefault.raidicon = {
	width = 14,
	height = 14,
	x = -70,
	y = 1,
	anchor = "CENTER",
}

StyleDefault.extrabar = {
	texture =					"Interface\\TARGETINGFRAME\\UI-StatusBar",
	backdrop = 					path.."backdrop",
	height = 6,
	width = 100,
	x = -8,
	y = vert+12,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.extratext = {
	typeface =					font,
	size = 7,
	height = 6,
	width = 100,
	x = -8,
	y = vert+11,
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
StyleTextOnly.eliteicon.texture = EmptyTexture
StyleTextOnly.extrabar.width = 60
StyleTextOnly.extrabar.y = vert+10
StyleTextOnly.extratext.y = vert+9
StyleTextOnly.extrabar.x = 0
StyleTextOnly.extratext.x = 0
StyleTextOnly.name.align = "CENTER"
StyleTextOnly.name.anchor = "CENTER"
StyleTextOnly.name.size = 12
StyleTextOnly.name.y = 17
StyleTextOnly.subtext.show = true
StyleTextOnly.subtext.align = "CENTER"
StyleTextOnly.subtext.anchor = "CENTER"
StyleTextOnly.subtext.vertical = "BOTTOM"
StyleTextOnly.subtext.size = 11
StyleTextOnly.subtext.height = 10
StyleTextOnly.subtext.width = 500
StyleTextOnly.subtext.x = 0
StyleTextOnly.subtext.y = 0
StyleTextOnly.customtext.show = false
StyleTextOnly.level.show = false
StyleTextOnly.raidicon.x = -66
StyleTextOnly.raidicon.y = 15
StyleTextOnly.raidicon.height = 14
StyleTextOnly.raidicon.width = 14
StyleTextOnly.raidicon.anchor = "TOP"
StyleTextOnly.highlight.texture = EmptyTexture


Theme["Default"] = StyleDefault
Theme["NameOnly"] = StyleTextOnly


local WidgetConfig = {}
WidgetConfig.ClassIcon =			{ anchor = "RIGHT", w = 24, h = 24, x = 36, y = -1 }
WidgetConfig.TotemIcon =			{ anchor = "RIGHT", w = 19, h = 18, x = 25, y = -1 }
WidgetConfig.ThreatLineWidget =		{ anchor="CENTER", x = 0 , y = 7 }
WidgetConfig.ThreatWheelWidget =	{ anchor =  "CENTER", x = 36 ,y = 12 }
WidgetConfig.ComboWidget =			{ anchor = "CENTER", x = -6, y = -10 }
--WidgetConfig.RangeWidget =			{ anchor="BOTTOM", x = 0, y = 0 }
WidgetConfig.DebuffWidget =			{ anchor = "BOTTOM", anchorRel = "TOP", x = 0, y = 4 }
WidgetConfig.AbsorbWidget =			{ anchor="LEFT", x = -9 , y = 1.5, w = 102, h = 9.5 }
-- WidgetConfig.DebuffWidgetPlus = { anchor="TOP", x = 12 , y = 26 }
WidgetConfig.QuestWidget = { anchor = "LEFT" , x = -24,y = 2 }
WidgetConfig.QuestWidgetNameOnly = { anchor = "LEFT" , x = -18,y = 14 }
WidgetConfig.ThreatPercentageWidget = { anchor = "RIGHT" , x = 5,y = -10 }
WidgetConfig.RangeWidget = { anchor = "CENTER", x=-8, y=-6, w = 102, h = 9.5 }

WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig
local ThemeName = "Blizzard"

---------------------------------------------
-- NeatPlates Hub Integration
---------------------------------------------
NeatPlatesThemeList[ThemeName] = Theme
NeatPlatesHubFunctions.ApplyHubFunctions(Theme)
