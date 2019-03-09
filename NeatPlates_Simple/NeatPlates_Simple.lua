local path = "Interface\\Addons\\NeatPlates_Simple\\Media" 
local font = path.."\\neuropol x cd rg.ttf";

-- Non-Latin Font Bypass
local NonLatinLocales = { ["koKR"] = true, ["zhCN"] = true, ["zhTW"] = true, }
if NonLatinLocales[GetLocale()] == true then font = STANDARD_TEXT_FONT end

local Theme = {}
local SimpleBar = {}

SimpleBar.hitbox = {
	width = 135,
	height = 30,
	x = 0,
	y = -8,
}

SimpleBar.healthborder = {
	texture 				= path.."\\empty.tga",
	width = 10,
	height = 10,
	x = -10,
	y = 1,
	anchor = "LEFT",
	show = false,
}

SimpleBar.healthbar = {
	texture 				= path.."\\barhealth.tga",
	height = 18,
	width = 110,
	x = 0,
	y = 0,
	anchor = "BOTTOM",
	orientation = "HORIZONTAL",
	show = true,
}

SimpleBar.eliteicon = {
	texture 				= path.."\\eliteicon.tga",
	width = 10,
	height = 10,
	x = 8,
	y = 2,
	anchor = "RIGHT",
	show = true,
}

SimpleBar.threatborder = {
	texture 				= path.."\\empty.tga",
	width = 110,
	height = 18,
	x = 0,
	y = -8,
	anchor = "BOTTOM",
	show = false,
}

SimpleBar.castborder = {
	texture 				= path.."\\empty.tga",
	height = 20,
	width = 112,
	x = 0,
	y = -20,
	anchor = "BOTTOM",
	orientation = "HORIZONTAL",
	show = true,
}  

SimpleBar.castnostop = {
	texture 				= path.."\\empty.tga",
	height = 18,
	width = 110,
	x = 0,
	y = -20,
	anchor = "BOTTOM",
	orientation = "HORIZONTAL",
	show = true,
}

SimpleBar.name = {
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

SimpleBar.level = {
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

SimpleBar.castbar = {
	texture 				= path.."\\barcast.tga",
	height = 18,
	width = 110,
	x = 0,
	y = -20,
	anchor = "BOTTOM",
	orientation = "HORIZONTAL",
	show = true,
}

SimpleBar.spellicon = {
	width = 10,
	height = 10,
	x = 52,
 	y = -6,
	anchor = "TOP",
	show = true,
}

SimpleBar.specialtext = {
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

SimpleBar.skullicon = {
	width = 14,
	height = 14,
	x = -7,
	y = 2,
	anchor = "RIGHT",
	show = false,
}

SimpleBar.frame = {
	width = 96,
	height = 16,
	x = 0,
	y = -5,
}

SimpleBar.raidicon = {
	width = 14,
	height = 14,
	x = 0,
	y = 14,
	anchor = "TOP",
	show = true,
}

SimpleBar.customtext = {
	typeface = font,
	width = 90,
	x = -3,
	y = -2,
	align = "CENTER",
	shadow = false,
	show = true,
}


local CopyTable = NeatPlatesUtility.copyTable

-- No Bar
local StyleTextOnly = CopyTable(SimpleBar)

StyleTextOnly.healthborder.texture = EmptyTexture
StyleTextOnly.healthbar.texture = EmptyTexture
StyleTextOnly.healthbar.backdrop = EmptyTexture
StyleTextOnly.eliteicon.texture = EmptyTexture
StyleTextOnly.threatborder.texture = EmptyTexture
StyleTextOnly.name.anchor = "CENTER"
StyleTextOnly.name.size = 12
StyleTextOnly.name.y = 17
StyleTextOnly.level.show = false
StyleTextOnly.raidicon.x = -66
StyleTextOnly.raidicon.y = 15


Theme["Default"] = SimpleBar
Theme["NameOnly"] = StyleTextOnly


local WidgetConfig = {}
WidgetConfig.ClassIcon = { anchor = "RIGHT" , x = 21 ,y = 9 }		-- Above Name
WidgetConfig.TotemIcon = { anchor = "RIGHT" , x = 21 ,y = 9 }
WidgetConfig.ThreatLineWidget = { anchor =  "TOP", x = -16 ,y = 14, w = 10, h = 2 }	-- y = 20
WidgetConfig.ThreatWheelWidget = { anchor =  "CENTER", x = 33 ,y = 15 } -- "CENTER", plate, 30, 18
WidgetConfig.ComboWidget = { anchor = "TOP" , x = 0 ,y = -2 }
WidgetConfig.RangeWidget = { anchor = "CENTER" , x = 0 ,y = 0 }
WidgetConfig.DebuffWidget = { anchor = "BOTTOM", anchorRel = "TOP", x = 0 ,y = 4 }
WidgetConfig.AbsorbWidget =	{ anchor="LEFT", x = -5, y = -2.5, w = 106, h = 4 }
WidgetConfig.QuestWidget = { anchor = "LEFT" , x = -18,y = 0 }
WidgetConfig.ThreatPercentageWidget = { anchor = "RIGHT" , x = 14,y = -9 }


WidgetConfig._meta = true		-- tells the parser to ignore this table; ie. don't convert to "style" template
Theme.WidgetConfig = WidgetConfig

local ThemeName = "Simple"

---------------------------------------------
-- Neat Plates Hub Integration
---------------------------------------------
NeatPlatesThemeList[ThemeName] = Theme
NeatPlatesHubFunctions.ApplyHubFunctions(Theme)
