-------------------------------------------------------------------------------
-- Neat Plates: ClassicPlates 2.5b - 7.1 - Dic/01/2016.
-------------------------------------------------------------------------------

local path = "Interface\\Addons\\NeatPlates_ClassicPlates\\Media\\"
local font = path.."Alice.ttf"
local casty = 0

local VerticalAdjustment = 12

local NonLatinLocales = { ["koKR"] = true, ["zhCN"] = true, ["zhTW"] = true, }
if NonLatinLocales[GetLocale()] == true then font = STANDARD_TEXT_FONT end


local Theme = {}
local StyleDefault = {}

StyleDefault.hitbox = {
	width = 130,
	height = 36,
	x = 5,
	y = 0,
}

StyleDefault.frame = {
	width = 128,
	height = 64,
}

StyleDefault.skullicon = {
	width = 11,
	height = 11,
	x = 18.5,
	y = -4,
	anchor = "LEFT",
	show = true,
}

StyleDefault.castborder = {
	texture =					path.."CastStop",
	width = 128,
	height = 64,
	x = -5,
	y = -8,
	show = true,
}

StyleDefault.castnostop = {
	texture = 					path.."CastNoStop",
	width = 128,
	height = 64,
	x = -5,
	y = -8,
	show = true,
}

StyleDefault.castbar = {
	texture =					path.."StatusBar",
	width = 86,
	height = 8,
	x = 2,
	y = -22,
	orientation = "HORIZONTAL",
}

StyleDefault.healthbar = {
	texture = 					path.."StatusBar",
	width =105,
	height = 9,
	x = 6,
	y = 3.5,
	orientation = "HORIZONTAL",
}

StyleDefault.highlight = {
	texture =					path.."Highlight",
}

StyleDefault.healthborder = {
	texture = 					path.."NormalPlate",
	glowtexture =				path.."Highlight",
	width = 128,
	height = 64,
	x = 0,
	y = 0,
	anchor = "CENTER",
}

StyleDefault.eliteicon = {
	texture = 					path.."ElitePlate",
	glowtexture =				path.."HighlightElite",
	width = 128,
	height = 64,
	x = 0,
	y = 0,
	anchor = "CENTER",
	show = true,
}

StyleDefault.target = {
	texture		 =				path.."Highlight",
	width = 128,
	height = 64,
	x = 0,
	y = 0,
	anchor = "CENTER",
	show = true,
}

StyleDefault.name = {
	typeface =					font,
	size = 12,
	width = 128,
	y = 19,
	x = 6,
	align = "CENTER",
	--anchor = "CENTER",
	--vertical = "CENTER",
	shadow = true,
}

StyleDefault.level = {
	typeface =					font,
	size = 8,
	x = -39.5,
	y = -3,
	align = "CENTER",
	shadow = true,
}

StyleDefault.customtext = {
	typeface =					font,
	size = 8.5,
	width = 90,
	x = 6,
	y = 4.3,
	align = "CENTER",
	anchor = "CENTER",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.spelltext = {
	typeface =					font,
	size = 9,
	x = 0,
	y = -21,
	width = 70,
	align = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.spellicon = {
	width =10,
	height = 10,
	x = -10,
	y = -21,
	anchor = "RIGHT",
}

StyleDefault.raidicon = {
	width = 14,
	height = 14,
	x = -66,
	y = 30,
	anchor = "CENTER",
}

StyleDefault.threatborder = {
	texture =					path.."ThreatBar",
	width = 128,
	height = 64,
	x = 0,
	y = 0,
	anchor = "CENTER",
}

StyleDefault.threatcolor = {
	LOW = { r = .5, g = 1, b = .2, a = 1, },
	MEDIUM = { r = .6, g = 1, b = 0, a = 1, },
	HIGH = { r = 1, g = .2, b = 0, a = 1, },
}

local CopyTable = NeatPlatesUtility.copyTable

-- No Bar
local StyleTextOnly = CopyTable(StyleDefault)

StyleTextOnly.threatborder.texture = EmptyTexture
StyleTextOnly.healthborder.texture = EmptyTexture
StyleTextOnly.healthbar.texture = EmptyTexture
StyleTextOnly.healthbar.backdrop = EmptyTexture
StyleTextOnly.eliteicon.texture = EmptyTexture
StyleTextOnly.name.show = true
StyleTextOnly.name.align = "CENTER"
StyleTextOnly.name.anchor = "CENTER"
StyleTextOnly.name.size = 16
StyleTextOnly.name.width = 150
StyleTextOnly.name.height = 20
StyleTextOnly.name.y = 17
StyleTextOnly.name.x = 0
StyleTextOnly.customtext.show = true
StyleTextOnly.customtext.align = "CENTER"
StyleTextOnly.customtext.anchor = "CENTER"
StyleTextOnly.customtext.vertical = "BOTTOM"
StyleTextOnly.customtext.size = 13
StyleTextOnly.customtext.width = 500
StyleTextOnly.customtext.x = 0
StyleTextOnly.customtext.y = 0
StyleTextOnly.level.show = false
StyleTextOnly.castbar.y = -28
StyleTextOnly.castbar.x = 0
StyleTextOnly.castborder.y = -15
StyleTextOnly.castborder.x = -7
StyleTextOnly.castnostop.y = -15
StyleTextOnly.castnostop.x = -7
StyleTextOnly.spelltext.y = -28
StyleTextOnly.spelltext.x = 0
StyleTextOnly.spellicon.y = -28
StyleTextOnly.spellicon.x = -13
StyleTextOnly.skullicon.show = false
StyleTextOnly.eliteicon.show = false
StyleTextOnly.raidicon.x = -66
StyleTextOnly.raidicon.y = 10
StyleTextOnly.raidicon.height = 14
StyleTextOnly.raidicon.width = 14
StyleTextOnly.raidicon.anchor = "TOP"
StyleTextOnly.highlight.texture = EmptyTexture
StyleTextOnly.target.texture = EmptyTexture
StyleTextOnly.target.y = 21
StyleTextOnly.target.height = 64
StyleTextOnly.target.height = 128
StyleTextOnly.target.anchor = "CENTER"

Theme["Default"] = StyleDefault
Theme["NameOnly"] = StyleTextOnly

local WidgetConfig = {}
WidgetConfig.ClassIcon = { anchor = "RIGHT", x = 22, y = 0 }
WidgetConfig.TotemIcon = { anchor = "RIGHT", x = 22, y = 0 }
WidgetConfig.ThreatWheelWidget = { anchor = "LEFT", x = -52, y = 3 }
WidgetConfig.ThreatLineWidget = {  x = 0 ,y = -10 }
WidgetConfig.ComboWidget = { x = 8 ,y = -27 }
WidgetConfig.RangeWidget = { anchor = "BOTTOM", x = 0 ,y = 0 }
WidgetConfig.DebuffWidget = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = -3 }
WidgetConfig.AbsorbWidget =	{ anchor="CENTER", x = 6 , y = 5, w = 104, h = 9}
WidgetConfig.QuestWidget = { anchor = "LEFT" , x = 4,y = 4 }
WidgetConfig.ThreatPercentageWidget = { anchor = "RIGHT" , x = 8,y = -6 }
--if (UnitClassBase("player") == "Druid") or (UnitClassBase("player") == "Rogue") then
	--WidgetConfig.DebuffWidgetPlus = { anchor = "CENTER" , x = 15 ,y = VerticalAdjustment + 24 }
--end

WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig
local ThemeName = "Classic"

---------------------------------------------
-- Neat Plates Hub Integration
---------------------------------------------
NeatPlatesThemeList[ThemeName] = Theme
NeatPlatesHubFunctions.ApplyHubFunctions(Theme)
