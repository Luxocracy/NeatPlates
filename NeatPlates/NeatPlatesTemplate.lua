
local addonName, NeatPlatesInternal = ...
local UseTheme = NeatPlatesInternal.UseTheme

if not NeatPlatesThemeList then NeatPlatesThemeList = {} end

-------------------------------------------------------------------------------------
-- Template
-------------------------------------------------------------------------------------

local TemplateTheme = {}
local defaultArtPath = "Interface\\Addons\\NeatPlates\\Media"
--local font =					"FONTS\\arialn.ttf"
local font =					NAMEPLATE_FONT
local EMPTY_TEXTURE = defaultArtPath.."\\Empty"

TemplateTheme.hitbox = {
	width = 160,
	height = 45,
	x = 0,
	y = 0,
	enabled = true,
}

TemplateTheme.highlight = {
	texture =					EMPTY_TEXTURE,
	width = 128,
	height = 64,
	enabled = true,
}

TemplateTheme.healthborder = {
	texture		 =				EMPTY_TEXTURE,
	width = 0,
	height = 64,
	x = 0,
	y = -5,
	anchor = "CENTER",
	show = true,
	-- Texture Coordinates
	left = 0,
	right = 1,
	top = 0,
	bottom = 1,
	enabled = true,
}

TemplateTheme.extraborder = {
	texture =					EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -11,
	anchor = "CENTER",
	show = true,
	enabled = true,
}

TemplateTheme.eliteicon = {
	texture = EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -5,
	anchor = "CENTER",
	show = false,
	-- Texture Coordinates
	left = 0,
	right = 1,
	top = 0,
	bottom = 1,
	enabled = true,
}

TemplateTheme.threatborder = {
	texture =			EMPTY_TEXTURE,
	--elitetexture =			EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -5,
	anchor = "CENTER",
	show = true,
	-- Texture Coordinates
	left = 0,
	right = 1,
	top = 0,
	bottom = 1,
	enabled = true,
}


TemplateTheme.castborder = {
	texture =					EMPTY_TEXTURE,
	noicon =					EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -11,
	anchor = "CENTER",
	show = true,
	enabled = true,
}

TemplateTheme.castnostop = {
	texture = 				EMPTY_TEXTURE,
	noicon = 				EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -11,
	anchor = "CENTER",
	show = true,
	enabled = true,
}

TemplateTheme.name = {
	typeface =					font,
	size = 9,
	width = 88,
	height = 10,
	x = 0,
	y = 1,
	align = "LEFT",
	anchor = "LEFT",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
	enabled = true,
}

TemplateTheme.subtext = {
	typeface =					font,
	size = 8,
	width = 100,
	height = 10,
	x = 0,
	y = -19,
	yOffset = 10,
	align = "LEFT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
	enabled = true,
}

TemplateTheme.level = {
	typeface =					font,
	size = 9,
	width = 25,
	height = 10,
	x = 36,
	y = 1,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
	enabled = true,
}

TemplateTheme.healthbar = {
	texture =					 EMPTY_TEXTURE,
	backdrop = 				EMPTY_TEXTURE,
	height = 12,
	--width = 101,
	width = 0,
	x = 0,
	y = 10,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
	enabled = true,
}

TemplateTheme.powerbar = {
	texture =					 EMPTY_TEXTURE,
	backdrop = 				EMPTY_TEXTURE,
	height = 0,
	--width = 101,
	width = 0,
	x = 0,
	y = 10,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
	enabled = true,
}

TemplateTheme.extrabar = {
	texture =					EMPTY_TEXTURE,
	backdrop = 				EMPTY_TEXTURE,
	height = 12,
	width = 99,
	x = 0,
	y = -19,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
	enabled = true,
}

TemplateTheme.castbar = {
	texture =					EMPTY_TEXTURE,
	backdrop = 				EMPTY_TEXTURE,
	height = 12,
	width = 99,
	x = 0,
	y = -19,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
	enabled = true,
}

TemplateTheme.extratext = {
	typeface =					font,
	size = 9,
	width = 93,
	height = 10,
	x = 0,
	y = 11,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = false,
	enabled = true,
}

TemplateTheme.spelltext = {
	typeface =					font,
	size = 9,
	width = 93,
	height = 10,
	x = 0,
	y = 11,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = false,
	durationtext = false,
	enabled = true,
}

TemplateTheme.spelltarget = {
	typeface =					font,
	size = 9,
	width = 93,
	height = 10,
	x = 0,
	y = 11,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = false,
	durationtext = false,
	enabled = true,
}

TemplateTheme.durationtext = {
	typeface =					font,
	size = 9,
	width = 93,
	height = 10,
	x = 0,
	y = 11,
	align = "RIGHT",
	anchor = "RIGHT",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = false,
	enabled = true,
}

TemplateTheme.customtext = {
	typeface =					font,
	size = 8,
	width = 100,
	height = 10,
	x = 1,
	y = -19,
	align = "LEFT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = false,
	enabled = true,
}

TemplateTheme.spellicon = {
	width = 18,
	height = 18,
	x = 62,
	y = -19,
	anchor = "CENTER",
	show = true,
	enabled = true,
}

TemplateTheme.raidicon = {
	texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
	width = 20,
	height = 20,
	x = -35,
	y = 7,
	anchor = "TOP",
	show = true,
	enabled = true,
}

TemplateTheme.skullicon = {
	texture = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull",
	width = 14,
	height = 14,
	x = 44,
	y = 3,
	anchor = "CENTER",
	show = true,
	enabled = true,
}

TemplateTheme.frame = {
	width = 101,
	height = 45,
	x = 0,
	y = 0,
	anchor = "CENTER",
	enabled = true,
}

TemplateTheme.targetindicator = {
	color = {},
	texture = EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -5,
	anchor = "CENTER",
	show = false,
	blend = "BLEND",
	enabled = true,
}

TemplateTheme.targetindicator_arrowtop = {
	color = {},
	texture = EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -5,
	anchor = "CENTER",
	show = false,
	enabled = true,
}

TemplateTheme.targetindicator_arrowsides = {
	color = {},
	texture = EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -5,
	anchor = "CENTER",
	show = false,
	enabled = true,
}
TemplateTheme.targetindicator_arrowright = {
	color = {},
	texture = EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -5,
	anchor = "CENTER",
	show = false,
	enabled = true,
}

TemplateTheme.targetindicator_arrowleft = {
	color = {},
	texture = EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -5,
	anchor = "CENTER",
	show = false,
	enabled = true,
}

TemplateTheme.target = {
	color = {},
	texture = EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -5,
	anchor = "CENTER",
	show = false,
	enabled = true,
}

TemplateTheme.focus = {
	color = {},
	texture = EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -5,
	anchor = "CENTER",
	show = false,
	enabled = true,
}

TemplateTheme.mouseover = {
	color = {},
	texture = EMPTY_TEXTURE,
	width = 128,
	height = 64,
	x = 0,
	y = -5,
	anchor = "CENTER",
	show = false,
	enabled = true,
}

TemplateTheme.rangeindicator = {
	show = false,
	enabled = true,
}

TemplateTheme.threatcolor = {
	LOW = { r = .75, g = 1, b = 0, a= 1, },
	MEDIUM = { r = 1, g = 1, b = 0, a = 1, },
	HIGH = { r = 1, g = 0, b = 0, a = 1, },
	enabled = true,
}

-----------------------------------------------
-- References
-----------------------------------------------
NeatPlatesInternal.ThemeTemplate = TemplateTheme
UseTheme(TemplateTheme)
