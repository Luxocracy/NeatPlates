local path = "Interface\\Addons\\NeatPlates_Simple\\Media" 
local font = path.."\\neuropol x cd rg.ttf";

-- Non-Latin Font Bypass
local NonLatinLocales = { ["koKR"] = true, ["zhCN"] = true, ["zhTW"] = true, }
if NonLatinLocales[GetLocale()] == true then font = STANDARD_TEXT_FONT end

local Theme = {}
local StyleDefault = {}

StyleDefault.hitbox = {
	width = 108,
	height = 18,
	x = 0,
	y = -6,
}

StyleDefault.healthborder = {
	texture 				= path.."\\empty.tga",
	width = 10,
	height = 10,
	x = -10,
	y = 1,
	anchor = "LEFT",
	show = false,
}

StyleDefault.healthbar = {
	texture 				= path.."\\barhealth.tga",
	height = 18,
	width = 110,
	x = 0,
	y = 0,
	anchor = "BOTTOM",
	orientation = "HORIZONTAL",
	show = true,
}

StyleDefault.powerbar = {
	texture 				= path.."\\barhealth.tga",
	height = 8,
	width = 110,
	x = 0,
	y = 0 - 1,
	anchor = "BOTTOM",
	orientation = "HORIZONTAL",
	show = true,
}

StyleDefault.eliteicon = {
	texture 				= path.."\\eliteicon.tga",
	width = 10,
	height = 10,
	x = 8,
	y = 2,
	anchor = "RIGHT",
	show = true,
}

StyleDefault.targetindicator_arrowtop = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Top",
	width = 64,
	height = 12,
	x = 0,
	y = 18,
	anchor = "CENTER",
	show = true,
}

StyleDefault.targetindicator_arrowsides = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Sides",
	width = 145,
	height = 18,
	x = 0,
	y = -3,
	anchor = "CENTER",
	show = true,
}

StyleDefault.targetindicator_arrowright = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Right",
	width = 18,
	height = 18,
	x = 26,
	y = -3,
	anchor = "RIGHT",
	show = true,
}

StyleDefault.targetindicator_arrowleft = {
	texture		 =				"Interface\\Addons\\NeatPlatesHub\\shared\\Arrow-Left",
	width = 18,
	height = 18,
	x = -26,
	y = -3,
	anchor = "LEFT",
	show = true,
}

StyleDefault.threatborder = {
	texture 				= path.."\\empty.tga",
	width = 110,
	height = 18,
	x = 0,
	y = -8,
	anchor = "BOTTOM",
	show = false,
}

StyleDefault.castborder = {
	texture 				= path.."\\empty.tga",
	height = 20,
	width = 112,
	x = 0,
	y = -20,
	anchor = "BOTTOM",
	orientation = "HORIZONTAL",
	show = true,
}  

StyleDefault.castnostop = {
	texture 				= path.."\\empty.tga",
	height = 18,
	width = 110,
	x = 0,
	y = -20,
	anchor = "BOTTOM",
	orientation = "HORIZONTAL",
	show = true,
}

StyleDefault.name = {
	typeface = font,
	size = 8,
	width = 106,
	height = 9,
	x = 0,
	y = 1,
	align = "CENTER",
	anchor = "TOP",
	shadow = false,
	vertical = "BOTTOM",
	show = true,
}

StyleDefault.subtext = {
	typeface = font,
	width = 106,
	x = 0,
	y = -5,
	yOffset = 6,
	align = "CENTER",
	anchor = "TOP",
	vertical = "BOTTOM",
	shadow = false,
}

StyleDefault.level = {
	typeface = font,
	size = 7,
	width = 30,
	height = 9,
	x = -60,
 	y = -6,
	align = "CENTER",
	anchor = "TOP",
   	shadow = false,
	vertical = "BOTTOM",
	show = true,
}

StyleDefault.castbar = {
	texture 				= path.."\\barcast.tga",
	height = 18,
	width = 110,
	x = 0,
	y = -16,
	anchor = "BOTTOM",
	orientation = "HORIZONTAL",
	show = true,
}

StyleDefault.spelltarget = {
	typeface =					font,
	size = 7,
	x = 0,
	y = -13,
	width = 108,
	align = "LEFT",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

StyleDefault.spellicon = {
	width = 10,
	height = 10,
	x = 52,
 	y = -9,
	anchor = "TOP",
	show = true,
}

StyleDefault.specialtext = {
	typeface = font,
	size = 10,
	width = 74,
	height = 9,
	x = 0,
	y = 2,
	align = "RIGHT",
	anchor = "BOTTOMRIGHT",
	vertical = "TOP",
	show = false,
}

StyleDefault.skullicon = {
	width = 14,
	height = 14,
	x = -7,
	y = 2,
	anchor = "RIGHT",
	show = false,
}

StyleDefault.frame = {
	width = 96,
	height = 16,
	x = 0,
	y = -5,
}

StyleDefault.raidicon = {
	width = 14,
	height = 14,
	x = 0,
	y = 14,
	anchor = "TOP",
	show = true,
}

StyleDefault.customtext = {
	typeface = font,
	width = 90,
	x = -3,
	y = -2,
	align = "CENTER",
	shadow = false,
	show = true,
}

StyleDefault.extrabar = {
	texture =						path.."\\barhealth.tga",
	--backdrop =					"Interface/Tooltips/UI-Tooltip-Background",
	width = 110,
	height = 12,
	x = 0,
	y = -6,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

StyleDefault.extratext = {
	typeface =					font,
	size = 7,
	width = 110,
	height = 12,
	x = 0,
	y = -6,
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

StyleTextOnly.healthborder.texture = EmptyTexture
StyleTextOnly.healthbar.texture = EmptyTexture
StyleTextOnly.healthbar.backdrop = EmptyTexture
StyleTextOnly.powerbar.texture = EmptyTexture
StyleTextOnly.powerbar.backdrop = EmptyTexture
StyleTextOnly.eliteicon.texture = EmptyTexture
StyleTextOnly.threatborder.texture = EmptyTexture
StyleTextOnly.extrabar.width = 70
StyleTextOnly.extrabar.y = -9
StyleTextOnly.extratext.y = -9
StyleTextOnly.extrabar.x = 0
StyleTextOnly.extratext.x = 0
StyleTextOnly.name.anchor = "CENTER"
StyleTextOnly.name.size = 12
StyleTextOnly.name.y = 6
StyleTextOnly.level.show = false
StyleTextOnly.raidicon.x = -66
StyleTextOnly.raidicon.y = 15
StyleTextOnly.subtext.show = true
StyleTextOnly.subtext.width = 500
StyleTextOnly.customtext.show = false


Theme["Default"] = StyleDefault
Theme["NameOnly"] = StyleTextOnly


local WidgetConfig = {}
WidgetConfig.ClassIcon = { anchor = "RIGHT", w = 24, h = 24 , x = 21 ,y = 9 }		-- Above Name
WidgetConfig.TotemIcon = { anchor = "RIGHT", w = 19, h = 18 , x = 21 ,y = 9 }
WidgetConfig.ThreatLineWidget = { anchor =  "TOP", x = -16 ,y = 14, w = 10, h = 2 }	-- y = 20
WidgetConfig.ThreatWheelWidget = { anchor =  "CENTER", x = 33 ,y = 15 } -- "CENTER", plate, 30, 18
WidgetConfig.ComboWidget = { anchor = "TOP" , x = 0 ,y = -2 }
WidgetConfig.RangeWidget = { anchor = "CENTER" , x = 0 ,y = 0 }
WidgetConfig.DebuffWidget = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = 4 }
WidgetConfig.AbsorbWidget =	{ anchor="LEFT", x = -5, y = -2.5, w = 106, h = 4 }
WidgetConfig.QuestWidget = { anchor = "LEFT" , x = -18,y = 0 }
WidgetConfig.QuestWidgetNameOnly = { anchor = "LEFT" , x = -18,y = 6 }
WidgetConfig.ThreatPercentageWidget = { anchor = "RIGHT" , x = 14,y = -9 }
WidgetConfig.RangeWidget = { anchor = "CENTER", x=0, y=-7, w = 106, h = 4 }


WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig

local ThemeName = "Simple"

---------------------------------------------
-- NeatPlates Hub Integration
---------------------------------------------
NeatPlatesThemeList[ThemeName] = Theme
NeatPlatesHubFunctions.ApplyHubFunctions(Theme)
