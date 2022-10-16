
---------------------------------------------
-- Style Definition
---------------------------------------------
local ArtworkPath = "Interface\\Addons\\NeatPlates_Slim_Vertical\\"
--local font = "Interface\\Addons\\NeatPlatesHub\\shared\\AccidentalPresidency.ttf"; local fontsize = 12;
local font = "Interface\\Addons\\NeatPlatesHub\\shared\\RobotoCondensed-Bold.ttf"; local fontsize = 10;
--print(font, fontsize)
--local fontsize = 12;
local EmptyTexture = "Interface\\Addons\\NeatPlatesHub\\shared\\Empty"
local VerticalAdjustment = 20 --25
local CastBarOffset = 10
local NameTextVerticalAdjustment = VerticalAdjustment - 25 -- -22

-- Non-Latin Font Bypass
local NonLatinLocales = { ["koKR"] = true, ["zhCN"] = true, ["zhTW"] = true, }
if NonLatinLocales[GetLocale()] == true then font = STANDARD_TEXT_FONT end


--   /run print(NeatPlates.ActiveThemeTable["Default"].frame.y)
---------------------------------------------
-- Default Style
---------------------------------------------
local Theme = {}
local StyleDefault = {}

StyleDefault.hitbox = {
	width = 14,
	height = 42,
	x = 0,
	y = 14,
}

StyleDefault.highlight = {
	texture =					ArtworkPath.."Slim_Highlight",
	width = 16,
	height = 64,
}

StyleDefault.healthborder = {
	texture		 =				ArtworkPath.."Slim_HealthOverlay",
	width = 16,
	height = 64,
	y = VerticalAdjustment,
	show = true,
}

StyleDefault.healthbar = {
	texture =					 ArtworkPath.."Slim_Bar",
	backdrop =					 ArtworkPath.."Slim_Bar_Backdrop",
	width = 6,
	height = 36,
	x = 0,
	y = VerticalAdjustment,
	orientation = "VERTICAL",
}

StyleDefault.powerbar = {
	texture =					 ArtworkPath.."Slim_Bar",
	backdrop =					 ArtworkPath.."Slim_Bar_Backdrop",
	width = 2,
	height = 35,
	x = 0 + 5,
	y = VerticalAdjustment,
	orientation = "VERTICAL",
}

StyleDefault.castborder = {
	texture =					 ArtworkPath.."Slim_CastOverlay",
	noicon =					 ArtworkPath.."Slim_CastOverlay-noicon",
	width = 16,
	height = 64,
	x = CastBarOffset,
	y = VerticalAdjustment,
	show = true,
}

StyleDefault.castnostop = {
	texture =					 ArtworkPath.."Slim_CastShield",
	noicon =					 ArtworkPath.."Slim_CastShield-noicon",
	width = 16,
	height = 64,
	x = CastBarOffset,
	y = VerticalAdjustment,
	show = true,
}

StyleDefault.spellicon = {
	width = 7,
	height = 7,
	x = CastBarOffset,
	y = VerticalAdjustment - 15,
	show = true,
}

StyleDefault.castbar = {
	texture =					 ArtworkPath.."Slim_Bar",
	backdrop =					 ArtworkPath.."Slim_Bar_Backdrop",
	width = 6,
	height = 30,
	x = CastBarOffset,
	y = VerticalAdjustment + 3,
	orientation = "VERTICAL",
}

StyleDefault.targetindicator = {
	texture =                    ArtworkPath.."Slim_Select",
	width = 16,
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
	neon_texture = 				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Neon-Sides",
	width = 64,
	height = 18,
	x = 0,
	y = VerticalAdjustment+0,
	anchor = "CENTER",
	show = true,
}

StyleDefault.targetindicator_arrowright = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Right",
	width = 18,
	height = 18,
	x = 0,
	y = VerticalAdjustment+0,
	anchor = "RIGHT",
	show = true,
}

StyleDefault.targetindicator_arrowleft = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Left",
	width = 18,
	height = 18,
	x = 0,
	y = VerticalAdjustment+0,
	anchor = "LEFT",
	show = true,
}

StyleDefault.raidicon = {
	width = 22,
	height = 22,
	x = -18,
	y = VerticalAdjustment - 3,
	anchor = "CENTER",
	texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
	show = true,
}

StyleDefault.eliteicon = {
	texture =                    ArtworkPath.."Slim_EliteIcon",
	width = 10,
	height = 10,
	x = -6,
	y = VerticalAdjustment - 15,
	anchor = "CENTER",
	show = true,
}

StyleDefault.skullicon = {
	width = 10,
	height = 10,
	x = -6,
	y = VerticalAdjustment - 15,
	anchor = "CENTER",
	show = true,
}

StyleDefault.name = {
	typeface = font,
	size = fontsize,
	width = 200,
	height = 11,
	x = 0,
	y = NameTextVerticalAdjustment,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = true,
	flags = "NONE",
}

StyleDefault.subtext = {
	typeface = font,
	size = 11,
	width = 200,
	height = 11,
	x = 0,
	y = NameTextVerticalAdjustment - 10,
	yOffset = 0,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = true,
	flags = "NONE",
}

StyleDefault.level = {
	typeface = font,
	size = 9,
	width = 22,
	height = 11,
	x = 0,
	y = VerticalAdjustment - 12,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	flags = "OUTLINE",
	shadow = false,
	show = false,
}

StyleDefault.spelltext = {
	typeface = font,
	size = fontsize - 2,
	width = 150,
	height = 11,
	x = CastBarOffset,
	y = VerticalAdjustment + 6,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = true,
	show = true,
}

StyleDefault.spelltarget = {
	typeface = font,
	size = fontsize - 2,
	width = 150,
	height = 11,
	x = CastBarOffset,
	y = VerticalAdjustment - 2,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = true,
	show = true,
}

StyleDefault.durationtext = {
	typeface = font,
	size = fontsize - 2,
	width = 150,
	height = 11,
	x = CastBarOffset,
	y = VerticalAdjustment+24,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = true,
	show = true,
}

StyleDefault.customart = {
	width = 14,
	height = 14,
	x = -5,
	y = VerticalAdjustment - 13,
	anchor = "CENTER",
	--show = true,
}

StyleDefault.customtext = {
	typeface = font,
	size = 11,
	width = 150,
	height = 11,
	x = 0,
	y = VerticalAdjustment + 1,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = false,
	flags = "OUTLINE",
	show = true,
}

StyleDefault.threatborder = {
	texture =                    ArtworkPath.."Slim_Invis",
	width = 2,
	_width = 2,
	height = 2,
	y = 0,
	x = 0,
	show = true,
}

StyleDefault.frame = {
	y = 0,
}

local CopyTable = NeatPlatesUtility.copyTable

-- No Bar
local StyleTextOnly = CopyTable(StyleDefault)


StyleTextOnly.healthborder.y = VerticalAdjustment - 24
StyleTextOnly.healthborder.height = 64
StyleTextOnly.healthborder.texture = EmptyTexture
StyleTextOnly.healthbar.texture = EmptyTexture
StyleTextOnly.healthbar.backdrop = EmptyTexture
StyleTextOnly.powerbar.texture = EmptyTexture
StyleTextOnly.powerbar.backdrop = EmptyTexture
StyleTextOnly.eliteicon.texture = EmptyTexture
StyleTextOnly.subtext.show = true
StyleTextOnly.subtext.size = fontsize - 2
StyleTextOnly.subtext.y = VerticalAdjustment-8
StyleTextOnly.subtext.width = 500
StyleTextOnly.customtext.show = false
StyleTextOnly.name.size = fontsize
StyleTextOnly.name.y = VerticalAdjustment + 1
StyleTextOnly.level.show = false
StyleTextOnly.eliteicon.show = false
StyleTextOnly.highlight.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Highlight"
StyleTextOnly.targetindicator.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Target"
StyleTextOnly.targetindicator.height = 72
StyleTextOnly.targetindicator.y = VerticalAdjustment -8 -18

StyleTextOnly.raidicon.x = 0
StyleTextOnly.raidicon.y = VerticalAdjustment - 25


-- Active Styles
Theme["Default"] = StyleDefault
Theme["NameOnly"] = StyleTextOnly


-- Widget
local WidgetConfig = {}
WidgetConfig.ClassIcon = { anchor = "TOP", w = 24, h = 24 , x = 15 ,y = VerticalAdjustment -1 }
WidgetConfig.TotemIcon = { anchor = "TOP", w = 19, h = 18 , x = 0 ,y = VerticalAdjustment + 2 }
WidgetConfig.ThreatLineWidget = { anchor =  "CENTER", x = -8 ,y = VerticalAdjustment + 15 }
WidgetConfig.ThreatWheelWidget = { anchor =  "CENTER", x = 36 ,y = VerticalAdjustment + 12 } -- "CENTER", plate, 30, 18
WidgetConfig.ComboWidget = { anchor = "CENTER" , x = 0 ,y = VerticalAdjustment - 35 }
WidgetConfig.DebuffWidget = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = VerticalAdjustment + 0 }
WidgetConfig.AbsorbWidget =	{ anchor="BOTTOM", x = 0 , y = VerticalAdjustment + 5.5, h = 35, w = 14, o = "VERTICAL" }
WidgetConfig.QuestWidget = { anchor = "CENTER" , x = -8,y = VerticalAdjustment - 10 }
WidgetConfig.QuestWidgetNameOnly = { anchor = "LEFT" , x = -2,y = VerticalAdjustment - 2 }
WidgetConfig.ThreatPercentageWidget = { anchor = "TOP" , x = 4,y = VerticalAdjustment + 6 }
WidgetConfig.RangeWidget = { anchor = "CENTER" , x = 0 ,y = VerticalAdjustment, h = 35, w = 14, o = "VERTICAL" }
WidgetConfig.ArenaWidget = { anchor = "LEFT" , x = 20, y = 8 }
WidgetConfig.ResourceWidget = { anchor = "CENTER" , x = 0 ,y = VerticalAdjustment - 35 }

WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig
local ThemeName = "Slim Vertical"


---------------------------------------------
-- NeatPlates Hub Integration
---------------------------------------------

NeatPlatesThemeList[ThemeName] = Theme
NeatPlatesHubFunctions.ApplyHubFunctions(Theme)