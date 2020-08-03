
local CopyTable = NeatPlatesUtility.copyTable
local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")

NeatPlatesHubCache = {}
NeatPlatesHubSettings = {
	profiles = {
		[L["Default"]] = "FFFFFFFF"
	}
}

NeatPlatesHubDefaults = {
	-- Profile
	---------------------------------------
	UseGlobalSet = false,

	-- Style
	---------------------------------------
	StyleHeadlineOutOfCombat = false,


	StyleFriendlyBarsOnActive = true,
	StyleFriendlyBarsOnElite = false,
	StyleFriendlyBarsInstanceMode = false,
	StyleFriendlyBarsOnPlayers = true,
	StyleFriendlyBarsNoMinions = false,
	StyleFriendlyBarsNoTotem = false,
	StyleFriendlyBarsOnNPC = false,
	StyleFriendlyBarsClickThrough = false,

	StyleEnemyBarsOnActive = true,
	StyleEnemyBarsOnElite = true,
	StyleEnemyBarsInstanceMode = false,
	StyleEnemyBarsNoMinions = false,
	StyleEnemyBarsNoTotem = false,
	StyleEnemyBarsOnPlayers = true,
	StyleEnemyBarsOnNPC = true,
	StyleEnemyBarsClickThrough = false,

	StyleHeadlineNeutral = false,
	StyleHeadlineMiniMobs = false,

	--ColorEnemyBarMode =  1,
	--ColorEnemyNameMode = 1,
	--ColorEnemyStatusTextMode = 1,

	--ColorFriendlyBarMode =  1,
	--ColorFriendlyNameMode = 1,
	--ColorFriendlyStatusTextMode = 1,

	TextShowOnlyOnActive = false,



	StyleForceBarsOnTargets = false,
	StyleShowPowerBar = false,

	-- Headline
	---------------------------------------
	StyleEnemyMode = 1,
	StyleFriendlyMode = 2,

	HeadlineEnemyColor = 4,
	HeadlineFriendlyColor = 4,
	HeadlineEnemySubtext = 3,
	HeadlineFriendlySubtext = 1,

	-- Opacity
	---------------------------------------
	OpacityTarget = 1,
	OpacityNonTarget = .5,
	--OpacitySpotlightMode = 1,

	EnemyAlphaSpotlightMode = 2,
	FriendlyAlphaSpotlightMode = 1,

	OpacitySpotlight = .85,
	OpacityFullNoTarget = true,				-- Use full opacity when No Target

	--OpacityFullSpell = false,				-- Deprecated 6.13
	--OpacityFullMouseover = false,			-- Deprecated 6.13

	OpacitySpotlightSpell = false,			-- Added 6.14
	OpacitySpotlightMouseover = false,		-- Added 6.14
	OpacitySpotlightRaidMarked = false,		-- Added 6.14

	-- Unit Spotlight
	---------------------------------------
	UnitSpotlightOpacity = 1,
	UnitSpotlightScale = 1.4,
	UnitSpotlightColor = {r = .8, g = 0, b = 0,},
	UnitSpotlightOpacityEnable = true,
	UnitSpotlightScaleEnable = true,
	UnitSpotlightBarEnable = true,
	UnitSpotlightGlowEnable = true,
	UnitSpotlightList = "",
	UnitSpotlightLookup = {},

	-- Filter
	---------------------------------------
	OpacityFiltered = 0,
	ScaleFiltered = .8,
	FilterScaleLock = false,

	OpacityFilterNeutralUnits = false,		-- OpacityHideNeutral = false,
	OpacityFilterNonElite = false,			-- OpacityHideNonElites = false,
	OpacityFilterEnemyNPC = false,
	OpacityFilterEnemyPet = false,
	OpacityFilterFriendlyPlayers = false,
	OpacityFilterEnemyPlayers = false,
	OpacityFilterPartyMembers = false,
	OpacityFilterNonPartyMembers = false,
	OpacityFilterFriendlyNPC = false,
	OpacityFilterFriendlyPet = false,
	OpacityFilterInactive = false,
	OpacityFilterMini = false,
	OpacityFilterUntitledFriendlyNPC = false,
	OpacityFilterLowLevelUnits = false,

	OpacityFilterList = "Fanged Pit Viper\nLiberated Karabor Prisoner",
	OpacityFilterLookup = {},

	-- Scale
	---------------------------------------
	ScaleStandard = 1,
	ScaleSpotlight = 1.2,
	ScaleSpotlightMode = 2,
	ScaleIgnoreNeutralUnits = true,
	ScaleIgnoreNonEliteUnits = false,
	ScaleIgnoreInactive = false,
	ScaleCastingSpotlight = false,
	ScaleTargetSpotlight = false,
	--ScaleMiniMobs = true,
	ScaleMouseoverSpotlight = false,

	-- Text
	---------------------------------------
	TextShowLevel = false,
	TextStatusForceShadow = false,
	TextUseBlizzardFont = false,
	TextHealthTextMode = 1,
	TextShowOnlyOnTargets = false,
	TextShowServerIndicator = true,
	TextShowUnitTitle = false,
	CustomTargetColor = false,
	CustomFocusColor = false,
	CustomMouseoverColor = false,

	-- Color
	---------------------------------------
	ColorHealthBarMode = 3,
	ColorDangerGlowMode = 2,
	TextNameColorMode = 1,
	ClassColorPartyMembers = false,
	EnableOffTankHighlight = false,

	-- Threat & Highlighting
	---------------------------------------
	ThreatMode = 1,
	ThreatGlowEnable = true,
	SafeColorSolo = false,
	ThreatSoloEnable = false,
	ColorShowPartyAggro = false,
	ColorPartyAggroBar = false,
	ColorPartyAggroGlow = true,
	ColorPartyAggroText = false,

	HighlightTargetMode = 1,
	HighlightFocusMode = 1,
	HighlightMouseoverMode = 1,
	HighlightTargetScale = {x = 1, y = 1, offset = {x = 0, y = 0}},
	HighlightFocusScale = {x = 1, y = 1, offset = {x = 0, y = 0}},
	HighlightMouseoverScale = {x = 1, y = 1, offset = {x = 0, y = 0}},

	ColorTarget = {r = 1, g = 1, b = 1,},
	ColorFocus = {r = 1, g = 1, b = 1,},
	ColorMouseover = {r = 1, g = 1, b = 1,},


	-- Reaction
	---------------------------------------
	ColorFriendlyNPC = {r = 0, g = 1, b = 0,},
	ColorFriendlyPlayer = {r = 0, g = 0, b = 1,},
	ColorNeutral = {r = 1, g = 1, b = 0,},
	ColorHostileNPC = {r = 1, g = 0, b = 0,},
	ColorHostilePlayer = {r = 1, g = 0, b = 0,},
	ColorGuildMember = {r = 60/255, g = 168/255, b = 255/255,},
	ColorPartyMember = {r = 60/255, g = 168/255, b = 255/255,},

	TextColorFriendlyNPC = {r = 96/255, g = 224/255, b = 37/255,},
	TextColorFriendlyPlayer = {r = 60/255, g = 168/255, b = 255/255,},
	TextColorNeutral = {r = 252/255, g = 180/255, b = 27/255,},
	TextColorHostileNPC = {r = 255/255, g = 51/255, b = 32/255,},
	TextColorHostilePlayer = {r = 255/255, g = 51/255, b = 32/255,},
	TextColorGuildMember = {r = 60/255, g = 168/255, b = 255/255,},
	TextColorPartyMember = {r = 60/255, g = 168/255, b = 255/255,},
	TextColorNormal = {r = .65, g = .65, b = .65, a = .4},
	TextColorElite = {r = .9, g = .7, b = .3, a = .5},
	TextColorBoss = {r = 1, g = .85, b = .1, a = .8},

	ColorThreatWarning = {r = .8, g = 0, b = 0,},		-- Red
	ColorThreatTransition = {r = 255/255, g = 160/255, b = 0},	-- Yellow
	ColorThreatSafe = {r = 15/255, g = 150/255, b = 230/255},	-- Bright Blue
	ColorAttackingOtherTank = {r = 15/255, g = 170/255, b = 200/255},	-- Bright Blue
	ColorPartyAggro = {r = 255/255, g = 0, b = .4,},

	ColorTapped = {r = 110/255, g = 110/255, b = 110/255,},

	CustomColorList = "",
	CustomColorLookup = {},

	-- Casting
	---------------------------------------
	ColorNormalSpellCast = { r = 252/255, g = 140/255, b = 0, },
	ColorUnIntpellCast = { r = 0.5137243866920471, g = 0.7529395222663879, b = 0.7647042274475098, },
	ColorIntpellCast = { r = 1, g = 0, b = 0, },
	ColorSchoolPhysical = { r = 0.5137243866920471, g = 0.7529395222663879, b = 0.7647042274475098, },
	ColorSchoolHoly = {r = 1, g = 0.9, b = 0.5},
	ColorSchoolFire = {r = 1, g = 0.5, b = 0},
	ColorSchoolNature = {r = 0.3, g = 1, b = 0.3},
	ColorSchoolFrost = {r = 0.5, g = 1, b = 1},
	ColorSchoolShadow = {r = 0.5, g = 0.5, b = 1},
	ColorSchoolArcane = {r = 1, g = 0.5, b = 1},
	ColorCastBySchool = true,
	SpellCastEnableEnemy = true,
	SpellCastEnableFriendly = false,
	IntCastEnable = true,
	IntCastWhoEnable = true,
	SpellIconEnable = true,
	SpellTargetEnable = false,

	-- Status Text
	---------------------------------------
	StatusTextLeft = 8,
	StatusTextCenter = 5,
	StatusTextRight = 7,

	StatusTextLeftColor = true,
	StatusTextCenterColor = true,
	StatusTextRightColor = true,



	-- Health
	---------------------------------------
	HighHealthThreshold = .7,
	LowHealthThreshold = .3,
	ColorLowHealth = {r = 1, g = 0, b = 0,},		-- Orange
	ColorMediumHealth = {r = 1, g = 1, b = 0},	-- Yellow
	ColorHighHealth = {r = 0, g = 1, b = .2},	-- Bright Blue

	-- Widgets
	---------------------------------------
	WidgetTargetHighlight = true,
	WidgetEliteIndicator = true,
	ClassEnemyIcon = false,
	ClassPartyIcon = false,
	ClassIconScaleOptions = {x = 1, y = 1, offset = {x = 0, y = 0}},
	WidgetTotemIcon = false,
	WidgetComboPoints = true,
	WidgetComboPointsStyle = 1,
	WidgetComboPointsScaleOptions = {x = 1, y = 1, offset = {x = 0, y = 0}},
	WidgetThreatIndicator = true,
	WidgetRangeIndicator = false,
	WidgetRangeScale = false,
	WidgetRangeMode = 1,
	WidgetRangeStyle = 1,
	WidgetRangeUnits = 2,
	WidgetRangeMax = 40,
	WidgetRangeScaleOptions = {x = 1, y = 1, offset = {x = 0, y = 0}},
	ColorRangeMelee = {r = 0.9, g = 0.9, b = 0.9, a = 0},	-- Opaque White
	ColorRangeClose = {r = 0.055, g = 0.875, b = 0.825},	-- Light Blue
	ColorRangeMid = {r = 0.035, g = 0.865, b = 0},	-- Green
	ColorRangeFar = {r = 1, g = 0.5, b = 0}, -- Orange
	ColorRangeOOR = {r = 0.9, g = 0.055, b = 0.075},	-- Red
	WidgetEnableExternal = true,
	WidgetAbsorbIndicator = false,
	WidgetAbsorbMode = 1,
	WidgetQuestIcon = false,
	WidgetThreatPercentage = false,

	-- Aura Widget
	---------------------------------------
	WidgetDebuff = true,
	WidgetDebuffStyle = 1,
	--WidgetAuraMode = 1,
	--WidgetAllAuras = false,
	--WidgetMyDebuff = true,
	--WidgetMyBuff = false,
	SpacerSlots = 1,
	AuraScale = 1,
	WidgetAuraScaleOptions = {x = 1, y = 1, offset = {x = 0, y = 0}},
	EmphasizedSlots = 1,
	PreciseAuraThreshold = 10,
	WidgetDebuffTrackList = "My Rake\nMy Rip\nMy Moonfire\nAll 339\nMy Regrowth\nMy Rejuvenation\nNot Facepalm Bolt",
	WidgetDebuffLookup = {},
	WidgetDebuffPriority = {},
	WidgetAuraTrackDispelFriendly = false,
	WidgetAuraTrackCurse = true,
	WidgetAuraTrackDisease = true,
	WidgetAuraTrackMagic = true,
	WidgetAuraTrackPoison = true,
	WidgetAuraSort = 1,
	WidgetAuraAlignment = 1,
	EmphasizedAuraList = "",
	EmphasizedAuraLookup = {},
	EmphasizedAuraPriority = {},
	EmphasizedUnique = true,
	HideCooldownSpiral = false,
	HideAuraDuration = false,
	HideAuraStacks = false,
	HideAuraInHeadline = false,

	-- Frame
	---------------------------------------
	FrameVerticalPosition = .7,
	AdvancedEnableUnitCache = true,
	FocusAsTarget = false,
	AltShortening = (LOCALE_zhCN or LOCALE_zhTW) or false,
	FrameBarWidth = 1,
	CastBarWidth = 1,
	--AdvancedHealthTextList = [[return unit.health]],
	Customization = {
		Default = {},
		NameOnly = {},
		WidgetConfig = {}
	},
}
