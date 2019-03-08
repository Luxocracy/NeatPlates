
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
local DefaultStyle = {}

DefaultStyle.hitbox = {
	width = 30,
	height = 46,
	x = 0,
	y = 14,
}

DefaultStyle.highlight = {
	texture =					ArtworkPath.."Slim_Highlight",
	width = 16,
	height = 64,
}

DefaultStyle.healthborder = {
	texture		 =				ArtworkPath.."Slim_HealthOverlay",
	width = 16,
	height = 64,
	y = VerticalAdjustment,
	show = true,
}

DefaultStyle.healthbar = {
	texture =					 ArtworkPath.."Slim_Bar",
	backdrop =					 ArtworkPath.."Slim_Bar_Backdrop",
	width = 6,
	height = 36,
	x = 0,
	y = VerticalAdjustment,
	orientation = "VERTICAL",
}

DefaultStyle.castborder = {
	texture =					 ArtworkPath.."Slim_CastOverlay",
	width = 16,
	height = 64,
	x = CastBarOffset,
	y = VerticalAdjustment,
	show = true,
}

DefaultStyle.castnostop = {
	texture =					 ArtworkPath.."Slim_CastShield",
	width = 16,
	height = 64,
	x = CastBarOffset,
	y = VerticalAdjustment,
	show = true,
}

DefaultStyle.spellicon = {
	width = 7,
	height = 7,
	x = CastBarOffset,
	y = VerticalAdjustment - 15,
	show = true,
}

DefaultStyle.castbar = {
	texture =					 ArtworkPath.."Slim_Bar",
	backdrop =					 ArtworkPath.."Slim_Bar_Backdrop",
	width = 6,
	height = 30,
	x = CastBarOffset,
	y = VerticalAdjustment + 3,
	orientation = "VERTICAL",
}

DefaultStyle.target = {
	texture =                    ArtworkPath.."Slim_Select",
	width = 16,
	height = 64,
	x = 0,
	y = VerticalAdjustment,
	anchor = "CENTER",
	show = true,
}

DefaultStyle.raidicon = {
	width = 22,
	height = 22,
	x = -18,
	y = VerticalAdjustment - 3,
	anchor = "CENTER",
	texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
	show = true,
}

DefaultStyle.eliteicon = {
	texture =                    ArtworkPath.."Slim_EliteIcon",
	width = 10,
	height = 10,
	x = -6,
	y = VerticalAdjustment - 15,
	anchor = "CENTER",
	show = true,
}

DefaultStyle.skullicon = {
	width = 10,
	height = 10,
	x = -6,
	y = VerticalAdjustment - 15,
	anchor = "CENTER",
	show = true,
}

DefaultStyle.name = {
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

DefaultStyle.level = {
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

DefaultStyle.spelltext = {
	typeface = font,
	size = fontsize - 2,
	width = 150,
	height = 11,
	x = CastBarOffset,
	y = VerticalAdjustment,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = true,
	show = true,
}

DefaultStyle.customart = {
	width = 14,
	height = 14,
	x = -5,
	y = VerticalAdjustment - 13,
	anchor = "CENTER",
	--show = true,
}

DefaultStyle.customtext = {
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

DefaultStyle.threatborder = {
	texture =                    ArtworkPath.."Slim_Invis",
	width = 2,
	_width = 2,
	height = 2,
	y = 0,
	x = 0,
	show = true,
}

DefaultStyle.frame = {
	y = 0,
}

local CopyTable = NeatPlatesUtility.copyTable

-- No Bar
local StyleTextOnly = CopyTable(DefaultStyle)


StyleTextOnly.healthborder.y = VerticalAdjustment - 24
StyleTextOnly.healthborder.height = 64
StyleTextOnly.healthborder.texture = EmptyTexture
StyleTextOnly.healthbar.texture = EmptyTexture
StyleTextOnly.healthbar.backdrop = EmptyTexture
StyleTextOnly.eliteicon.texture = EmptyTexture
StyleTextOnly.customtext.size = fontsize - 2
StyleTextOnly.customtext.flags = "NONE"
StyleTextOnly.customtext.y = VerticalAdjustment-8
StyleTextOnly.name.size = fontsize
StyleTextOnly.name.y = VerticalAdjustment + 1
StyleTextOnly.level.show = false
StyleTextOnly.eliteicon.show = false
StyleTextOnly.highlight.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Highlight"
StyleTextOnly.target.texture = "Interface\\Addons\\NeatPlatesHub\\shared\\Target"
StyleTextOnly.target.height = 72
StyleTextOnly.target.y = VerticalAdjustment -8 -18

StyleTextOnly.raidicon.x = 0
StyleTextOnly.raidicon.y = VerticalAdjustment - 25


-- Active Styles
Theme["Default"] = DefaultStyle
Theme["NameOnly"] = StyleTextOnly


-- Widget
local WidgetConfig = {}
WidgetConfig.ClassIcon = { anchor = "TOP" , x = 15 ,y = VerticalAdjustment -1 }
WidgetConfig.TotemIcon = { anchor = "TOP" , x = 0 ,y = VerticalAdjustment + 2 }
WidgetConfig.ThreatLineWidget = { anchor =  "CENTER", x = -8 ,y = VerticalAdjustment + 15 }
WidgetConfig.ThreatWheelWidget = { anchor =  "CENTER", x = 36 ,y = VerticalAdjustment + 12 } -- "CENTER", plate, 30, 18
WidgetConfig.ComboWidget = { anchor = "CENTER" , x = 0 ,y = VerticalAdjustment - 35 }
WidgetConfig.RangeWidget = { anchor = "CENTER" , x = 0 ,y = VerticalAdjustment }
WidgetConfig.DebuffWidget = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = VerticalAdjustment + 0 }
--if (UnitClassBase("player") == "Druid") or (UnitClassBase("player") == "Rogue") then
	--WidgetConfig.DebuffWidgetPlus = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = VerticalAdjustment + 0 }
--end
WidgetConfig.AbsorbWidget =	{ anchor="BOTTOM", x = 0 , y = VerticalAdjustment + 5.5, h = 35, w = 14, o = "VERTICAL", }
WidgetConfig.QuestWidget = { anchor = "CENTER" , x = -8,y = VerticalAdjustment - 10 }
WidgetConfig.ThreatPercentageWidget = { anchor = "TOP" , x = 4,y = VerticalAdjustment + 6 }

WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig
local ThemeName = "Slim Vertical"


---------------------------------------------
-- Neat Plates Hub Integration
---------------------------------------------

NeatPlatesThemeList[ThemeName] = Theme
NeatPlatesHubFunctions.ApplyHubFunctions(Theme)