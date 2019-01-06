
--[[
Neat Plates Hub: Interface Panel

Color Guide:
|cffffdd00		for Yellow
|cffff6906		for Orange
|cff999999		for Grey
|cffffaa33		for Brownish Orange

--]]

-- Rapid Panel Functions
local CreateQuickSlider = NeatPlatesHubRapidPanel.CreateQuickSlider
local CreateQuickCheckbutton = NeatPlatesHubRapidPanel.CreateQuickCheckbutton
local SetSliderMechanics = NeatPlatesHubRapidPanel.SetSliderMechanics
local CreateQuickEditbox = NeatPlatesHubRapidPanel.CreateQuickEditbox
local CreateQuickColorbox = NeatPlatesHubRapidPanel.CreateQuickColorbox
local CreateQuickDropdown = NeatPlatesHubRapidPanel.CreateQuickDropdown
local CreateQuickHeadingLabel = NeatPlatesHubRapidPanel.CreateQuickHeadingLabel
local CreateQuickItemLabel = NeatPlatesHubRapidPanel.CreateQuickItemLabel
local OnMouseWheelScrollFrame = NeatPlatesHubRapidPanel.OnMouseWheelScrollFrame
local CreateHubInterfacePanel = NeatPlatesHubRapidPanel.CreateInterfacePanel

-- Modes
local ThemeList = NeatPlatesHubMenus.ThemeList
local StyleModes = NeatPlatesHubMenus.StyleModes
local TextModes = NeatPlatesHubMenus.TextModes
local RangeModes = NeatPlatesHubMenus.RangeModes
local AuraWidgetModes = NeatPlatesHubMenus.AuraWidgetModes
local DebuffStyles = NeatPlatesHubMenus.DebuffStyles
local EnemyOpacityModes = NeatPlatesHubMenus.EnemyOpacityModes
local FriendlyOpacityModes = NeatPlatesHubMenus.FriendlyOpacityModes
local ScaleModes = NeatPlatesHubMenus.ScaleModes
local FriendlyBarModes = NeatPlatesHubMenus.FriendlyBarModes
local EnemyBarModes = NeatPlatesHubMenus.EnemyBarModes
local ThreatWidgetModes = NeatPlatesHubMenus.ThreatWidgetModes
local EnemyNameColorModes = NeatPlatesHubMenus.EnemyNameColorModes
local FriendlyNameColorModes = NeatPlatesHubMenus.FriendlyNameColorModes
local EnemyNameSubtextModes = NeatPlatesHubMenus.EnemyNameSubtextModes
local ArtStyles = NeatPlatesHubMenus.ArtStyles
local ArtModes = NeatPlatesHubMenus.ArtModes
local ThreatWarningModes = NeatPlatesHubMenus.ThreatWarningModes
local CustomTextModes = NeatPlatesHubMenus.CustomTextModes
local BasicTextModes = NeatPlatesHubMenus.BasicTextModes
local AbsorbModes = NeatPlatesHubMenus.AbsorbModes
local AbsorbUnits = NeatPlatesHubMenus.AbsorbUnits
local ComboPointsStyles = NeatPlatesHubMenus.ComboPointsStyles
local BorderTypes = NeatPlatesHubMenus.BorderTypes

local cEnemy = "|cffff5544"
local cFriendly = "|cffc8e915"

------------------------------------------------------------------
-- Generate Panel
------------------------------------------------------------------
local function BuildHubPanel(panel)
	panel:Hide()
	local objectName = panel.objectName
	local AlignmentColumn = panel.AlignmentColumn
	local OffsetColumnB = 200						-- 240
	local F = nil									-- Cache for anchoring
	local ColumnTop, ColumnEnd

	panel.StyleLabel, F = CreateQuickHeadingLabel(nil, "Nameplate Style", AlignmentColumn, F, 0, 5)

	ColumnTop = F

	panel.StyleEnemyBarsLabel, F = CreateQuickItemLabel(nil, cEnemy.."Enemy Health Bars:", AlignmentColumn, F, 0, 2)
	panel.StyleEnemyBarsOnNPC, F = CreateQuickCheckbutton(objectName.."StyleEnemyBarsOnNPC", "All NPCs", AlignmentColumn, F, 16, 0)
	panel.StyleEnemyBarsInstanceMode, F = CreateQuickCheckbutton(objectName.."StyleEnemyBarsInstanceMode", "Exclude Instances", AlignmentColumn, F, 32*(1/.8), 0)
	panel.StyleEnemyBarsInstanceMode:SetScale(.8)
	panel.StyleEnemyBarsOnElite, F = CreateQuickCheckbutton(objectName.."StyleEnemyBarsOnElite", "Elite Units", AlignmentColumn, F, 16, 0)
	panel.StyleEnemyBarsOnPlayers, F = CreateQuickCheckbutton(objectName.."StyleEnemyBarsOnPlayers", "Players", AlignmentColumn, F, 16, 0)
	panel.StyleEnemyBarsOnActive, F = CreateQuickCheckbutton(objectName.."StyleEnemyBarsOnActive", "Active/Damaged Units", AlignmentColumn, F, 16, 0)
	panel.StyleEnemyBarsClickThrough, F = CreateQuickCheckbutton(objectName.."StyleEnemyBarsClickThrough", "Clickthrough", AlignmentColumn, F, 16, 0)

	ColumnEnd = F

	panel.StyleFriendlyBarsLabel, F = CreateQuickItemLabel(nil, cFriendly.."Friendly Health Bars:", AlignmentColumn, ColumnTop, OffsetColumnB, 2)
	panel.StyleFriendlyBarsOnNPC, F = CreateQuickCheckbutton(objectName.."StyleFriendlyBarsOnNPC", "All NPCs", AlignmentColumn, F, OffsetColumnB+16, 0)
	panel.StyleFriendlyBarsInstanceMode, F = CreateQuickCheckbutton(objectName.."StyleFriendlyBarsInstanceMode", "Exclude Instances", AlignmentColumn, F, (OffsetColumnB+32)*(1/.8), 0)
	panel.StyleFriendlyBarsInstanceMode:SetScale(.8)
	panel.StyleFriendlyBarsOnElite, F = CreateQuickCheckbutton(objectName.."StyleFriendlyBarsOnElite", "Elite Units", AlignmentColumn, F, OffsetColumnB+16, 0)

	panel.StyleFriendlyBarsOnPlayers, F = CreateQuickCheckbutton(objectName.."StyleFriendlyBarsOnPlayers", "Players", AlignmentColumn, F, OffsetColumnB+16, 0)
	panel.StyleFriendlyBarsOnActive, F = CreateQuickCheckbutton(objectName.."StyleFriendlyBarsOnActive", "Active/Damaged Units", AlignmentColumn, F, OffsetColumnB+16, 0)
	panel.StyleFriendlyBarsClickThrough, F = CreateQuickCheckbutton(objectName.."StyleFriendlyBarsClickThrough", "Clickthrough", AlignmentColumn, F, OffsetColumnB+16, 0)

	F =  ColumnEnd
	panel.HealthBarStyleLabel, F = CreateQuickItemLabel(nil, "Health Bar View:", AlignmentColumn, F, 0, 2)
	panel.StyleForceBarsOnTargets, F = CreateQuickCheckbutton(objectName.."StyleForceBarsOnTargets", "Force Bars on Targets", AlignmentColumn, F, 16, 2)

	panel.StyleHeadlineLabel, F = CreateQuickItemLabel(nil, "Headline View (Text-Only):", AlignmentColumn, F, 0, 2)
	panel.StyleHeadlineNeutral, F = CreateQuickCheckbutton(objectName.."StyleHeadlineNeutral", "Force Headline on Neutral Units", AlignmentColumn, F, 16, 2)
	panel.StyleHeadlineOutOfCombat, F = CreateQuickCheckbutton(objectName.."StyleHeadlineOutOfCombat", "Force Headline while Out-of-Combat", AlignmentColumn, F, 16, 0)
	panel.StyleHeadlineMiniMobs, F = CreateQuickCheckbutton(objectName.."StyleHeadlineMiniMobs", "Force Headline on Mini-Mobs", AlignmentColumn, F, 16, 0)

	------------------------------
    -- Health Bars
	------------------------------

    panel.HealthBarLabel, F = CreateQuickHeadingLabel(nil, "Health Bar View", AlignmentColumn, F, 0, 5)

    -- Enemy
	panel.EnemyBarColorMode, F =  CreateQuickDropdown(objectName.."EnemyBarColorMode", cEnemy.."Enemy Bar Color:", EnemyBarModes, 1, AlignmentColumn, F)
	panel.EnemyNameColorMode, F =  CreateQuickDropdown(objectName.."EnemyNameColorMode", cEnemy.."Enemy Name Color:", EnemyNameColorModes, 1, AlignmentColumn, F)
	panel.EnemyStatusTextMode, F =  CreateQuickDropdown(objectName.."EnemyStatusTextMode", cEnemy.."Enemy Status Text:", TextModes, 1, AlignmentColumn, F )
	--panel.EnemyStatusTextModeCenter, F =  CreateQuickDropdown(objectName.."EnemyStatusTextModeCenter", "", BasicTextModes, 1, AlignmentColumn, F, 0, -14 )
	--panel.EnemyStatusTextModeRight, F =  CreateQuickDropdown(objectName.."EnemyStatusTextModeRight", "", BasicTextModes, 1, AlignmentColumn, F, 0, -14 )

	-- Friendly
	panel.FriendlyBarColorMode, F =  CreateQuickDropdown(objectName.."FriendlyBarColorMode", cFriendly.."Friendly Bar Color:", FriendlyBarModes, 1, AlignmentColumn, panel.HealthBarLabel, OffsetColumnB)
	panel.FriendlyNameColorMode, F =  CreateQuickDropdown(objectName.."FriendlyNameColorMode", cFriendly.."Friendly Name Color:", FriendlyNameColorModes, 1, AlignmentColumn, F, OffsetColumnB)
	panel.FriendlyStatusTextMode, F =  CreateQuickDropdown(objectName.."FriendlyStatusTextMode", cFriendly.."Friendly Status Text:", TextModes, 1, AlignmentColumn, F, OffsetColumnB)
	--panel.FriendlyStatusTextModeCenter, F =  CreateQuickDropdown(objectName.."FriendlyStatusTextModeCenter", "", BasicTextModes, 1, AlignmentColumn, F, OffsetColumnB, -14)
	--panel.FriendlyStatusTextModeRight, F =  CreateQuickDropdown(objectName.."FriendlyStatusTextModeRight", "", BasicTextModes, 1, AlignmentColumn, F, OffsetColumnB, -14)

	-- Other
	panel.TextShowLevel, F = CreateQuickCheckbutton(objectName.."TextShowLevel", "Show Level", AlignmentColumn, F, 0, 2)
    panel.TextShowOnlyOnTargets, F = CreateQuickCheckbutton(objectName.."TextShowOnlyOnTargets", "Show Status Text on Target & Mouseover", AlignmentColumn, F, 0)
    panel.TextShowOnlyOnActive, F = CreateQuickCheckbutton(objectName.."TextShowOnlyOnActive", "Show Status Text on Active/Damaged Units", AlignmentColumn, F, 0)


	------------------------------
	-- Headline View
	------------------------------
	--[[
		Hostile Headline	(Current Selection in Dropdown)
			Default Bars
			Headline Always
			Out-of-Combat - Bars during Combat
			On Idle - Bars on Active
			On NPCs - Bars on Players
			On Non-Targets - Bar on Current Target
			On Aggroed Units - Bars on Low Threat (Tank Mode)

		Show Enemy/Friendly Health Bars:
			- On Elite Units
			- On NPCs
			- On Players (When available)
			- On Active/Damaged Units	- Low Threat (Tank Mode)  (Could roll the Tank mode into Active/Damaged units)

		- (Headline Neutral Units)
		- Force Headline Out-of-Combat		Bars during Combat; Headline Out-of-Combat 		(Eliminate this)

	--]]
	panel.StyleLabel, F = CreateQuickHeadingLabel(nil, "Headline View (Text-Only)", AlignmentColumn, F, 0, 5)

	ColumnTop = F

	panel.EnemyHeadlineColor, F = CreateQuickDropdown(objectName.."EnemyHeadlineColor", cEnemy.."Enemy Headline Color:", EnemyNameColorModes, 1, AlignmentColumn, F)	-- |cffee9900Text-Only Style
	panel.HeadlineEnemySubtext, F =  CreateQuickDropdown(objectName.."HeadlineEnemySubtext", cEnemy.."Enemy Headline Subtext:", EnemyNameSubtextModes, 1, AlignmentColumn, F )	-- |cffee9900Text-Only Style

	ColumnEnd = F

	panel.FriendlyHeadlineColor, F = CreateQuickDropdown(objectName.."FriendlyHeadlineColor", cFriendly.."Friendly Headline Color:", FriendlyNameColorModes, 1, AlignmentColumn, ColumnTop, OffsetColumnB)	-- |cffee9900Text-Only Style
	panel.HeadlineFriendlySubtext, F =  CreateQuickDropdown(objectName.."HeadlineFriendlySubtext", cFriendly.."Friendly Headline Subtext:", EnemyNameSubtextModes, 1, AlignmentColumn, F, OffsetColumnB )	-- |cffee9900Text-Only Style

	F = ColumnEnd

	------------------------------
	-- Aura (Buff and Debuff) Widget
	------------------------------
	panel.DebuffsLabel = CreateQuickHeadingLabel(nil, "Buffs & Debuffs", AlignmentColumn, F, 0, 5)
	panel.WidgetDebuff = CreateQuickCheckbutton(objectName.."WidgetDebuff", "Enable Aura Widget", AlignmentColumn, panel.DebuffsLabel)

	--panel.WidgetAuraMode =  CreateQuickDropdown(objectName.."WidgetAuraMode", "Filter Mode:", AuraWidgetModes, 1, AlignmentColumn, panel.WidgetDebuffStyle, 16)		-- used to be WidgetDebuffMode

	panel.WidgetMyDebuff = CreateQuickCheckbutton(objectName.."WidgetMyDebuff", "Include My Debuffs", AlignmentColumn, panel.WidgetDebuff, 16)
	panel.WidgetMyBuff = CreateQuickCheckbutton(objectName.."WidgetMyBuff", "Include My Buffs", AlignmentColumn, panel.WidgetMyDebuff, 16)

	panel.WidgetPandemic = CreateQuickCheckbutton(objectName.."WidgetPandemic", "Enable Pandemic Highlighting", AlignmentColumn, panel.WidgetMyBuff, 16)
	panel.ColorPandemic = CreateQuickColorbox(objectName.."ColorPandemic", "", nil, AlignmentColumn, panel.WidgetMyBuff , OffsetColumnB + 64)
	panel.BorderPandemic = CreateQuickDropdown(objectName.."BorderPandemic", "", BorderTypes, 1, AlignmentColumn, panel.WidgetMyBuff, OffsetColumnB + 90)

	panel.WidgetBuffPurgeable = CreateQuickCheckbutton(objectName.."WidgetBuffPurgeable", "Include Purgeable Buffs", AlignmentColumn, panel.WidgetPandemic, 16)
	panel.ColorBuffPurgeable = CreateQuickColorbox(objectName.."ColorBuffPurgeable", "", nil, AlignmentColumn, panel.WidgetPandemic , OffsetColumnB + 64)
	panel.BorderBuffPurgeable = CreateQuickDropdown(objectName.."BorderBuffPurgeable", "", BorderTypes, 1, AlignmentColumn, panel.WidgetPandemic, OffsetColumnB + 90)

	panel.WidgetBuffEnrage = CreateQuickCheckbutton(objectName.."WidgetBuffEnrage", "Include Enrage Buffs", AlignmentColumn, panel.WidgetBuffPurgeable, 16)
	panel.ColorBuffEnrage = CreateQuickColorbox(objectName.."ColorBuffEnrage", "", nil, AlignmentColumn, panel.WidgetBuffPurgeable , OffsetColumnB + 64)
	panel.BorderBuffEnrage = CreateQuickDropdown(objectName.."BorderBuffEnrage", "", BorderTypes, 1, AlignmentColumn, panel.WidgetBuffPurgeable, OffsetColumnB + 90)

	panel.SpacerSlots = CreateQuickSlider(objectName.."SpacerSlots", "Space Between buffs & debuffs:", "ACTUAL", 150, AlignmentColumn, panel.WidgetBuffEnrage, 16, 2)

	panel.WidgetDebuffListLabel = CreateQuickItemLabel(nil, "Additional Auras:", AlignmentColumn, panel.SpacerSlots, 16)
	panel.WidgetDebuffTrackList = CreateQuickEditbox(objectName.."WidgetDebuffTrackList", nil, nil, AlignmentColumn, panel.WidgetDebuffListLabel, 16)

	panel.WidgetDebuffStyle =  CreateQuickDropdown(objectName.."WidgetDebuffStyle", "Icon Style:", DebuffStyles, 1, AlignmentColumn, panel.WidgetDebuffTrackList, 16)

	panel.WidgetAuraTrackDispelFriendly = CreateQuickCheckbutton(objectName.."WidgetAuraTrackDispelFriendly", "Include Dispellable Debuffs on Friendly Units", AlignmentColumn, panel.WidgetDebuffStyle, 16, 4)
	panel.WidgetAuraTrackCurse = CreateQuickCheckbutton(objectName.."WidgetAuraTrackCurse", "Curse", AlignmentColumn, panel.WidgetAuraTrackDispelFriendly, 16+16, -2)
	panel.WidgetAuraTrackDisease = CreateQuickCheckbutton(objectName.."WidgetAuraTrackDisease", "Disease", AlignmentColumn, panel.WidgetAuraTrackCurse, 16+16, -2)
	panel.WidgetAuraTrackMagic = CreateQuickCheckbutton(objectName.."WidgetAuraTrackMagic", "Magic", AlignmentColumn, panel.WidgetAuraTrackDisease, 16+16, -2)
	panel.WidgetAuraTrackPoison = CreateQuickCheckbutton(objectName.."WidgetAuraTrackPoison", "Poison", AlignmentColumn, panel.WidgetAuraTrackMagic, 16+16, -2)


	------------------------------
	-- Debuff Help Tip
	panel.DebuffHelpTip = CreateQuickItemLabel(nil, "Tip: |cffCCCCCCAuras should be listed with the exact name, or a spell ID number. "..
		"You can use the prefixes, 'My' or 'All', to distinguish personal damage spells from global crowd control spells. The prefix 'Not' "..
		"may be used to blacklist an aura.  Auras at the top of the list will get displayed before lower ones.", AlignmentColumn, panel.WidgetDebuffListLabel, 225+40) -- 210, 275, )
	panel.DebuffHelpTip:SetHeight(150)
	panel.DebuffHelpTip:SetWidth(200)
	panel.DebuffHelpTip.Text:SetJustifyV("TOP")

	-- Expand Options
	-- Filtering mode: Show raid targets, show only my target

	------------------------------
	--Opacity
	------------------------------
	panel.OpacityLabel, F = CreateQuickHeadingLabel(nil, "Opacity", AlignmentColumn, panel.WidgetAuraTrackPoison, 0, 5)
	panel.EnemyAlphaSpotlightMode =  CreateQuickDropdown(objectName.."EnemyAlphaSpotlightMode", cEnemy.."Enemy Spotlight Mode:", EnemyOpacityModes, 1, AlignmentColumn, F)
	panel.FriendlyAlphaSpotlightMode, F =  CreateQuickDropdown(objectName.."FriendlySpotlightMode", cFriendly.."Friendly Spotlight Mode:", FriendlyOpacityModes, 1, AlignmentColumn, F, OffsetColumnB)

	panel.OpacitySpotlight = CreateQuickSlider(objectName.."OpacitySpotlight", "Spotlight Opacity:", nil, nil, AlignmentColumn, F, 0, 2)
	panel.OpacityTarget = CreateQuickSlider(objectName.."OpacityTarget", "Current Target Opacity:", nil, nil, AlignmentColumn, panel.OpacitySpotlight, 0, 2)
	panel.OpacityNonTarget = CreateQuickSlider(objectName.."OpacityNonTarget", "Non-Target Opacity:", nil, nil, AlignmentColumn, panel.OpacityTarget, 0, 2)

	panel.OpacitySpotlightSpell = CreateQuickCheckbutton(objectName.."OpacitySpotlightSpell", "Spotlight Casting Units", AlignmentColumn, panel.OpacityNonTarget, 0)
	panel.OpacitySpotlightMouseover = CreateQuickCheckbutton(objectName.."OpacitySpotlightMouseover", "Spotlight Mouseover", AlignmentColumn, panel.OpacitySpotlightSpell, 0)
	panel.OpacitySpotlightRaidMarked = CreateQuickCheckbutton(objectName.."OpacitySpotlightRaidMarked", "Spotlight Raid Marked", AlignmentColumn, panel.OpacitySpotlightMouseover, 0)

	panel.OpacityFullNoTarget = CreateQuickCheckbutton(objectName.."OpacityFullNoTarget", "Use Target Opacity When No Target Exists", AlignmentColumn, panel.OpacitySpotlightRaidMarked, 0)

	------------------------------
	--Scale
	------------------------------
	panel.ScaleLabel = CreateQuickHeadingLabel(nil, "Scale", AlignmentColumn, panel.OpacityFullNoTarget, 0, 5)
	panel.ScaleStandard = CreateQuickSlider(objectName.."ScaleStandard", "Normal Scale:", nil, nil, AlignmentColumn, panel.ScaleLabel, 0, 2)

	panel.ScaleFunctionMode =  CreateQuickDropdown(objectName.."ScaleFunctionMode", "Scale Spotlight Mode:", ScaleModes, 1, AlignmentColumn, panel.ScaleStandard)


	panel.ScaleSpotlight = CreateQuickSlider(objectName.."ScaleSpotlight", "Spotlight Scale:", nil, nil, AlignmentColumn, panel.ScaleFunctionMode, 0, 2)
	panel.ScaleIgnoreNeutralUnits= CreateQuickCheckbutton(objectName.."ScaleIgnoreNeutralUnits", "Ignore Neutral Units", AlignmentColumn, panel.ScaleSpotlight, 16)
	panel.ScaleIgnoreNonEliteUnits= CreateQuickCheckbutton(objectName.."ScaleIgnoreNonEliteUnits", "Ignore Non-Elite Units", AlignmentColumn, panel.ScaleIgnoreNeutralUnits, 16)
	panel.ScaleIgnoreInactive, F = CreateQuickCheckbutton(objectName.."ScaleIgnoreInactive", "Ignore Inactive Units", AlignmentColumn, panel.ScaleIgnoreNonEliteUnits, 16)

	panel.ScaleCastingSpotlight, F = CreateQuickCheckbutton(objectName.."ScaleCastingSpotlight", "Spotlight Casting Units", AlignmentColumn, F, 0)
	panel.ScaleTargetSpotlight, F = CreateQuickCheckbutton(objectName.."ScaleTargetSpotlight", "Spotlight Target Units", AlignmentColumn, F, 0)
	panel.ScaleMouseoverSpotlight, F = CreateQuickCheckbutton(objectName.."ScaleMouseoverSpotlight", "Spotlight Mouseover Units", AlignmentColumn, F, 0)
	--panel.ScaleMiniMobs, F = CreateQuickCheckbutton(objectName.."ScaleMiniMobs", "Auto-Scale Mini/Trivial Mobs", AlignmentColumn, F, 0)



	-- panel.ScaleTrivialMobsMultiplier =
	-- Downscale Trivial Mobs  (70%)

	------------------------------
	-- Trivial Mobs
	------------------------------
	-- Scale Multiplier
	-- Override Target Settings
	-- Ignore Threat
	--

	-- Hiding Mobs vs Filtering Mobs

	------------------------------
    -- Unit Search Spotlight/Searchlight
	------------------------------

	--[[
	panel.UnitSpotlightLabel = CreateQuickHeadingLabel(nil, "Unit Spotlight", AlignmentColumn, panel.ScaleCastingSpotlight, 0, 5)

	-- Column 1
	panel.UnitSpotlightOpacity = CreateQuickSlider(objectName.."UnitSpotlightOpacity", "Spotlight Opacity:", nil, nil, AlignmentColumn, panel.UnitSpotlightLabel, 0, 2)
	panel.UnitSpotlightScale = CreateQuickSlider(objectName.."UnitSpotlightScale", "Spotlight Scale:", nil, nil, AlignmentColumn, panel.UnitSpotlightOpacity, 0, 2)
	panel.UnitSpotlightColorLabel = CreateQuickItemLabel(nil, "Spotlight Color:", AlignmentColumn, panel.UnitSpotlightScale, 0, 0)
	panel.UnitSpotlightColor = CreateQuickColorbox(objectName.."UnitSpotlightColor", "Bar & Glow Color", nil, AlignmentColumn, panel.UnitSpotlightColorLabel , 6, 2)

	panel.UnitSpotlightListLabel = CreateQuickItemLabel(nil, "Unit Name:", AlignmentColumn, panel.UnitSpotlightColor, 0, 4)
	panel.UnitSpotlightList = CreateQuickEditbox(objectName.."UnitSpotlightList", nil, nil, AlignmentColumn, panel.UnitSpotlightListLabel, 0)

	-- Boss NPC units

	-- Column 2
	panel.UnitSpotlightOpacityEnable = CreateQuickCheckbutton(objectName.."UnitSpotlightOpacityEnable", "Enable Opacity", AlignmentColumn, panel.UnitSpotlightListLabel, 8+ OffsetColumnB, 0)
	panel.UnitSpotlightScaleEnable = CreateQuickCheckbutton(objectName.."UnitSpotlightScaleEnable", "Enable Scale", AlignmentColumn, panel.UnitSpotlightOpacityEnable, 8+ OffsetColumnB, 0)
	panel.UnitSpotlightBarEnable = CreateQuickCheckbutton(objectName.."UnitSpotlightBarEnable", "Enable Bar Color", AlignmentColumn, panel.UnitSpotlightScaleEnable, 8+OffsetColumnB)
	panel.UnitSpotlightGlowEnable = CreateQuickCheckbutton(objectName.."UnitSpotlightGlowEnable", "Enable Glow Color", AlignmentColumn, panel.UnitSpotlightBarEnable, 8+OffsetColumnB)

	--]]

	------------------------------
	-- Filter
	--------------------------------
	panel.FilterLabel = CreateQuickHeadingLabel(nil, "Unit Filter", AlignmentColumn, F, 0, 5)
	panel.OpacityFiltered, F = CreateQuickSlider(objectName.."OpacityFiltered", "Filtered Unit Opacity:", nil, nil, AlignmentColumn, panel.FilterLabel, 0, 2)
	panel.ScaleFiltered, F = CreateQuickSlider(objectName.."ScaleFiltered", "Filtered Unit Scale:", nil, nil, AlignmentColumn, F, 0, 2)
	panel.FilterScaleLock, F = CreateQuickCheckbutton(objectName.."FilterScaleLock", "Override Target/Spotlight Scale", AlignmentColumn, F, 16)

	panel.OpacityFilterNeutralUnits, F = CreateQuickCheckbutton(objectName.."OpacityFilterNeutralUnits", "Filter Neutral Units", AlignmentColumn, F, 8, 4)
	panel.OpacityFilterNonElite, F = CreateQuickCheckbutton(objectName.."OpacityFilterNonElite", "Filter Non-Elite", AlignmentColumn, F, 8)
	panel.OpacityFilterEnemyNPC, F = CreateQuickCheckbutton(objectName.."OpacityFilterEnemyNPC", "Filter Enemy NPC", AlignmentColumn, F, 8)
	panel.OpacityFilterFriendlyNPC, F = CreateQuickCheckbutton(objectName.."OpacityFilterFriendlyNPC", "Filter Friendly NPC", AlignmentColumn, F, 8)
	panel.OpacityFilterUntitledFriendlyNPC, F = CreateQuickCheckbutton(objectName.."OpacityFilterUntitledFriendlyNPC", "Filter Non-Titled Friendly NPC", AlignmentColumn, F, 8)

	panel.OpacityFilterPlayers = CreateQuickCheckbutton(objectName.."OpacityFilterPlayers", "Filter Players", AlignmentColumn, panel.FilterScaleLock, OffsetColumnB, 4)
	panel.OpacityFilterInactive = CreateQuickCheckbutton(objectName.."OpacityFilterInactive", "Filter Inactive", AlignmentColumn, panel.OpacityFilterPlayers, OffsetColumnB)
	panel.OpacityFilterMini = CreateQuickCheckbutton(objectName.."OpacityFilterMini", "Filter Mini-Mobs", AlignmentColumn, panel.OpacityFilterInactive, OffsetColumnB)

	panel.OpacityCustomFilterLabel = CreateQuickItemLabel(nil, "Filter By Unit Name:", AlignmentColumn, F, 8, 4)
	panel.OpacityFilterList, L = CreateQuickEditbox(objectName.."OpacityFilterList", nil, nil, AlignmentColumn, panel.OpacityCustomFilterLabel, 8)


-- [[

    ------------------------------
	-- Reaction
	------------------------------
	-- Health Bar Color
    panel.ReactionLabel = CreateQuickHeadingLabel(nil, "Reaction", AlignmentColumn, L, 0, 5)
	panel.ReactionColorLabel = CreateQuickItemLabel(nil, "Health Bar Color:", AlignmentColumn, panel.ReactionLabel, 0, 2)
	panel.ColorFriendlyNPC = CreateQuickColorbox(objectName.."ColorFriendlyNPC", "Friendly NPC", nil, AlignmentColumn, panel.ReactionColorLabel , 16)
	panel.ColorFriendlyPlayer = CreateQuickColorbox(objectName.."ColorFriendlyPlayer", "Friendly Player", nil, AlignmentColumn, panel.ColorFriendlyNPC , 16)
	panel.ColorNeutral= CreateQuickColorbox(objectName.."ColorNeutral", "Neutral", nil, AlignmentColumn, panel.ColorFriendlyPlayer , 16)
	panel.ColorHostileNPC = CreateQuickColorbox(objectName.."ColorHostileNPC", "Hostile NPC", nil, AlignmentColumn, panel.ColorNeutral , 16)
	panel.ColorHostilePlayer = CreateQuickColorbox(objectName.."ColorHostilePlayer", "Hostile Player", nil, AlignmentColumn, panel.ColorHostileNPC , 16)
	panel.ColorGuildMember = CreateQuickColorbox(objectName.."ColorGuildMember", "Guild Member", nil, AlignmentColumn, panel.ColorHostilePlayer , 16)
    -- Text Color
    panel.TextReactionColorLabel = CreateQuickItemLabel(nil, "Text Color:", AlignmentColumn, panel.ReactionLabel, OffsetColumnB )
	panel.TextColorFriendlyNPC = CreateQuickColorbox(objectName.."TextColorFriendlyNPC", "Friendly NPC", nil, AlignmentColumn, panel.ReactionColorLabel , OffsetColumnB + 16)
	panel.TextColorFriendlyPlayer = CreateQuickColorbox(objectName.."TextColorFriendlyPlayer", "Friendly Player", nil, AlignmentColumn, panel.TextColorFriendlyNPC , OffsetColumnB + 16)
	panel.TextColorNeutral= CreateQuickColorbox(objectName.."TextColorNeutral", "Neutral", nil, AlignmentColumn, panel.TextColorFriendlyPlayer , OffsetColumnB + 16)
	panel.TextColorHostileNPC = CreateQuickColorbox(objectName.."TextColorHostileNPC", "Hostile NPC", nil, AlignmentColumn, panel.TextColorNeutral , OffsetColumnB + 16)
	panel.TextColorHostilePlayer = CreateQuickColorbox(objectName.."TextColorHostilePlayer", "Hostile Player", nil, AlignmentColumn, panel.TextColorHostileNPC , OffsetColumnB + 16)
	panel.TextColorGuildMember = CreateQuickColorbox(objectName.."TextColorGuildMember", "Guild Member", nil, AlignmentColumn, panel.TextColorHostilePlayer , OffsetColumnB + 16)
	-- Other
	panel.OtherColorLabel = CreateQuickItemLabel(nil, "Other Colors:", AlignmentColumn, panel.ColorGuildMember, 0, 2)
	panel.ColorTapped = CreateQuickColorbox(objectName.."ColorTapped", "Tapped Unit", nil, AlignmentColumn, panel.OtherColorLabel , 16)
	--panel.ColorTotem = CreateQuickColorbox(objectName.."ColorTotem", "Totem", nil, AlignmentColumn, panel.ColorTapped , 16)
	-- Custom Colors
	panel.CustomColorLabel = CreateQuickItemLabel(nil, "Custom Color Conditions:", AlignmentColumn, panel.ColorTapped, 0, 2)
	panel.CustomColorList, L = CreateQuickEditbox(objectName.."CustomColorList", 200, 100, AlignmentColumn, panel.CustomColorLabel, 8)
	panel.CustomColorSelect = CreateQuickColorbox(objectName.."CustomColorSelect", "Color Select", function(hex) local value = panel.CustomColorList:GetValue(); if value == "" then value = hex else value = value.."\n"..hex end; panel.CustomColorList:SetValue(value) end, AlignmentColumn, panel.CustomColorLabel , OffsetColumnB + 50)
	panel.CustomColorInfo = CreateQuickItemLabel(nil, "|cffCCCCCCColor value in Hex(#) followed by:\n- Unit Name\n- Buff/Debuff Name/SpellID\n- Health Threshold\n\n(ex. #A300FF Spawn of G'huun)\n|cffff9320Prioritised top to bottom", AlignmentColumn, panel.CustomColorSelect, OffsetColumnB + 50, 2)
	panel.CustomColorInfo:SetHeight(150)
	panel.CustomColorInfo:SetWidth(220)
	panel.CustomColorInfo.Text:SetJustifyV("TOP")

--]]

	------------------------------
	-- Threat
	------------------------------
    -- Column 1
	panel.ThreatLabel = CreateQuickHeadingLabel(nil, "Threat", AlignmentColumn, L, 0, 5)
	panel.ThreatWarningMode =  CreateQuickDropdown(objectName.."ThreatWarningMode", "Threat Mode:", ThreatWarningModes, 1, AlignmentColumn, panel.ThreatLabel, 0, 2)
	panel.ThreatGlowEnable = CreateQuickCheckbutton(objectName.."ThreatGlowEnable", "Enable Warning Glow", AlignmentColumn, panel.ThreatWarningMode,0)

	panel.ColorThreatColorLabels = CreateQuickItemLabel(nil, "Threat Colors:", AlignmentColumn, panel.ThreatGlowEnable, 0, 2)
	panel.ColorThreatWarning = CreateQuickColorbox(objectName.."ColorThreatWarning", "Warning", nil, AlignmentColumn, panel.ColorThreatColorLabels , 16)
	panel.ColorThreatTransition = CreateQuickColorbox(objectName.."ColorThreatTransition", "Transition", nil, AlignmentColumn, panel.ColorThreatWarning , 16)
	panel.ColorThreatSafe = CreateQuickColorbox(objectName.."ColorThreatSafe", "Safe", nil, AlignmentColumn, panel.ColorThreatTransition, 16)

	panel.WidgetThreatIndicator, F = CreateQuickCheckbutton(objectName.."WidgetThreatIndicator", "Show Tug-o-Threat Indicator", AlignmentColumn, panel.ColorThreatSafe, 0, 2)
	panel.WidgetThreatPercentage, F = CreateQuickCheckbutton(objectName.."WidgetThreatPercentage", "Show Threat Percentage", AlignmentColumn, panel.WidgetThreatIndicator, 0, 2)

	--[[
	-- Warning Border Glow
	--]]

    -- Column 2
	panel.EnableOffTankHighlight = CreateQuickCheckbutton(objectName.."EnableOffTankHighlight", "Highlight Mobs on Off-Tanks", AlignmentColumn, panel.ThreatLabel, OffsetColumnB)
	panel.ColorAttackingOtherTank = CreateQuickColorbox(objectName.."ColorAttackingOtherTank", "Attacking another Tank", nil, AlignmentColumn, panel.EnableOffTankHighlight , 16+OffsetColumnB)

	panel.ColorShowPartyAggro = CreateQuickCheckbutton(objectName.."ColorShowPartyAggro", "Highlight Group Members holding Aggro", AlignmentColumn, panel.ColorAttackingOtherTank, OffsetColumnB)
	panel.ColorPartyAggro = CreateQuickColorbox(objectName.."ColorPartyAggro", "Group Member Aggro", nil, AlignmentColumn, panel.ColorShowPartyAggro , 14+OffsetColumnB)
	panel.ColorPartyAggroBar = CreateQuickCheckbutton(objectName.."ColorPartyAggroBar", "Health Bar Color", AlignmentColumn, panel.ColorPartyAggro, 16+OffsetColumnB)
	panel.ColorPartyAggroGlow = CreateQuickCheckbutton(objectName.."ColorPartyAggroGlow", "Border/Warning Glow", AlignmentColumn, panel.ColorPartyAggroBar, 16+OffsetColumnB)
	panel.ColorPartyAggroText = CreateQuickCheckbutton(objectName.."ColorPartyAggroText", "Name Text Color", AlignmentColumn, panel.ColorPartyAggroGlow, 16+OffsetColumnB)

	------------------------------
	-- Health
	------------------------------
	panel.HealthLabel, F = CreateQuickHeadingLabel(nil, "Health", AlignmentColumn, panel.WidgetThreatPercentage, 0, 5)
	panel.EnableHealerWarning, F = CreateQuickCheckbutton(objectName.."EnableHealerWarning", "Enable Healer Warning Glow", AlignmentColumn, F)
	panel.HighHealthThreshold = CreateQuickSlider(objectName.."HighHealthThreshold", "High Health Threshold:", nil, nil, AlignmentColumn, F, 0, 2)
	panel.LowHealthThreshold =  CreateQuickSlider(objectName.."LowHealthThreshold", "Low Health Threshold:", nil, nil, AlignmentColumn, panel.HighHealthThreshold, 0, 2)
	panel.HealthColorLabels = CreateQuickItemLabel(nil, "Health Colors:", AlignmentColumn, panel.LowHealthThreshold, 0)
	panel.ColorHighHealth = CreateQuickColorbox(objectName.."ColorHighHealth", "High Health", nil, AlignmentColumn, panel.HealthColorLabels , 16)
	panel.ColorMediumHealth = CreateQuickColorbox(objectName.."ColorMediumHealth", "Medium Health", nil, AlignmentColumn, panel.ColorHighHealth , 16)
	panel.ColorLowHealth, F = CreateQuickColorbox(objectName.."ColorLowHealth", "Low Health", nil, AlignmentColumn, panel.ColorMediumHealth , 16)
	-- [ ]  Highlight Enemy Healers


	------------------------------
    -- Cast Bars
	------------------------------
    panel.SpellCastLabel, F = CreateQuickHeadingLabel(nil, "Cast Bars", AlignmentColumn, F, 0, 5)
    panel.SpellCastEnableFriendly, F = CreateQuickCheckbutton(objectName.."SpellCastEnableFriendly", "Show Friendly Cast Bars", AlignmentColumn, F)
    panel.IntCastEnable, F = CreateQuickCheckbutton(objectName.."IntCastEnable", "Show Interrupted Cast Bar", AlignmentColumn, F)
    panel.IntCastWhoEnable, F = CreateQuickCheckbutton(objectName.."IntCastWhoEnable", "Show who Interrupted Cast", AlignmentColumn, F)
	panel.SpellCastColorLabel, F = CreateQuickItemLabel(nil, "Cast Bar Colors:", AlignmentColumn, F, 0, 2)
	panel.ColorNormalSpellCast, F = CreateQuickColorbox(objectName.."ColorNormalSpellCast", "Normal", nil, AlignmentColumn, F , 16)
	panel.ColorUnIntpellCast, F = CreateQuickColorbox(objectName.."ColorUnIntpellCast", "Un-interruptible", nil, AlignmentColumn, F , 16)
	panel.ColorIntpellCast, F = CreateQuickColorbox(objectName.."ColorIntpellCast", "Interrupted", nil, AlignmentColumn, F , 16)

	--[[
	------------------------------
	-- Text
	------------------------------
	panel.StatusTextLabel, F = CreateQuickHeadingLabel(nil, "Status Text", AlignmentColumn, F, 0, 5)

	panel.StatusTextLeft, F =  CreateQuickDropdown(objectName.."StatusTextLeft", "Custom Text Program:", CustomTextModes, 1, AlignmentColumn, F, 0, 0)
	panel.StatusTextLeftColor = CreateQuickCheckbutton(objectName.."StatusTextLeftColor", "Context Color", AlignmentColumn, F, 150, -16)
	--panel.StatusTextLeftBracket = CreateQuickCheckbutton(objectName.."StatusTextLeftBracket", "Bracket", AlignmentColumn, F, 300, -16)

	panel.StatusTextCenter, F =  CreateQuickDropdown(objectName.."StatusTextCenter", "", CustomTextModes, 1, AlignmentColumn, F, 0, -11)
	panel.StatusTextCenterColor = CreateQuickCheckbutton(objectName.."StatusTextCenterColor", "Context Color", AlignmentColumn, F, 150, -16)
	--panel.StatusTextCenterBracket = CreateQuickCheckbutton(objectName.."StatusTextCenterBracket", "Bracket", AlignmentColumn, F, 300, -16)

	panel.StatusTextRight, F =  CreateQuickDropdown(objectName.."StatusTextRight", "", CustomTextModes, 1, AlignmentColumn, F, 0, -11)
	panel.StatusTextRightColor = CreateQuickCheckbutton(objectName.."StatusTextRightColor", "Context Color", AlignmentColumn, F, 150, -16)
	--panel.StatusTextRightBracket = CreateQuickCheckbutton(objectName.."StatusTextRightBracket", "Bracket", AlignmentColumn, F, 300, -16)

	--]]

	------------------------------
	--Widgets
	------------------------------
	panel.WidgetLabel, F = CreateQuickHeadingLabel(nil, "Other Widgets", AlignmentColumn, F, 0, 5)
	panel.WidgetTargetHighlight = CreateQuickCheckbutton(objectName.."WidgetTargetHighlight", "Show Target Highlight", AlignmentColumn, panel.WidgetLabel)
	panel.WidgetEliteIndicator = CreateQuickCheckbutton(objectName.."WidgetEliteIndicator", "Show Elite Icon", AlignmentColumn, panel.WidgetTargetHighlight)
	panel.ClassEnemyIcon = CreateQuickCheckbutton(objectName.."ClassEnemyIcon", "Show Enemy Class Art", AlignmentColumn, panel.WidgetEliteIndicator)
	panel.ClassPartyIcon = CreateQuickCheckbutton(objectName.."ClassPartyIcon", "Show Friendly Class Art", AlignmentColumn, panel.ClassEnemyIcon)
	panel.WidgetTotemIcon = CreateQuickCheckbutton(objectName.."WidgetTotemIcon", "Show Totem Art", AlignmentColumn, panel.ClassPartyIcon)
	panel.WidgetQuestIcon = CreateQuickCheckbutton(objectName.."WidgetQuestIcon", "Show Quest Icon on Units", AlignmentColumn, panel.WidgetTotemIcon)
	panel.WidgetComboPoints = CreateQuickCheckbutton(objectName.."WidgetComboPoints", "Show Personal Resource on Target", AlignmentColumn, panel.WidgetQuestIcon)
	panel.WidgetComboPointsStyle, F =  CreateQuickDropdown(objectName.."WidgetComboPointsStyle", "Personal Resource Style:", ComboPointsStyles, 2, AlignmentColumn, panel.WidgetComboPoints, 16)

	--panel.WidgetEnableExternal = CreateQuickCheckbutton(objectName.."WidgetEnableExternal", "Enable External Widgets", AlignmentColumn, panel.WidgetComboPoints)

	--panel.WidgetThreatIndicatorMode =  CreateQuickDropdown(objectName.."WidgetThreatIndicatorMode", "Threat Indicator:", ThreatWidgetModes, 1, AlignmentColumn, panel.WidgetThreatIndicator, OffsetColumnB+16)
	
	panel.WidgetAbsorbIndicator = CreateQuickCheckbutton(objectName.."WidgetAbsorbIndicator", "Show Absorb Bars", AlignmentColumn, panel.WidgetLabel, OffsetColumnB+60)
	panel.WidgetAbsorbMode =  CreateQuickDropdown(objectName.."WidgetAbsorbMode", "Mode:", AbsorbModes, 1, AlignmentColumn, panel.WidgetAbsorbIndicator, OffsetColumnB+76)
	panel.WidgetAbsorbUnits = CreateQuickDropdown(objectName.."WidgetAbsorbUnits", "Show on:", AbsorbUnits, 1, AlignmentColumn, panel.WidgetAbsorbMode, OffsetColumnB+76)
	panel.WidgetRangeIndicator = CreateQuickCheckbutton(objectName.."WidgetRangeIndicator", "Show Party Range Warning", AlignmentColumn, panel.WidgetAbsorbUnits, OffsetColumnB+60)
	panel.WidgetRangeMode =  CreateQuickDropdown(objectName.."WidgetRangeMode", "Range:", RangeModes, 1, AlignmentColumn, panel.WidgetRangeIndicator, OffsetColumnB+76)

	------------------------------
	-- Advanced
	------------------------------
	panel.AdvancedLabel, F = CreateQuickHeadingLabel(nil, "Funky Stuff", AlignmentColumn, F, 0, 5)
	panel.TextUseBlizzardFont, F = CreateQuickCheckbutton(objectName.."TextUseBlizzardFont", "Use Blizzard Font", AlignmentColumn, F, 0)
	panel.FocusAsTarget, F = CreateQuickCheckbutton(objectName.."FocusAsTarget", "Treat Focus as a Target", AlignmentColumn, F, 0)
	panel.AdvancedEnableUnitCache, F = CreateQuickCheckbutton(objectName.."AdvancedEnableUnitCache", "Enable Title Caching ", AlignmentColumn, F)
	panel.FrameVerticalPosition, F = CreateQuickSlider(objectName.."FrameVerticalPosition", "Vertical Position of Artwork: (May cause targeting problems)", nil, nil, AlignmentColumn, F, 0, 4)
	panel.FrameBarWidth, F = CreateQuickSlider(objectName.."FrameBarWidth", "Health Bar Width (%)", nil, nil, AlignmentColumn, F, 0, 4)

	--panel.AdvancedCustomCodeLabel = CreateQuickItemLabel(nil, "Custom Theme Code:", AlignmentColumn, panel.FrameVerticalPosition, 0, 4)
	--panel.AdvancedCustomCodeTextbox = CreateQuickEditbox(objectName.."AdvancedCustomCodeTextbox", nil, nil, AlignmentColumn, panel.AdvancedHealthTextLabel, 8)


	--[[
	theme.Default.name.size = 18
	--]]
	local ClearCacheButton = CreateFrame("Button", objectName.."ClearCacheButton", AlignmentColumn, "NeatPlatesPanelButtonTemplate")
	ClearCacheButton:SetPoint("TOPLEFT", F, "BOTTOMLEFT",-6, -18)
	--ClearCacheButton:SetPoint("TOPLEFT", panel.AdvancedCustomCodeTextbox, "BOTTOMLEFT",-6, -18)
	ClearCacheButton:SetWidth(300)
	ClearCacheButton:SetText("Clear Cache")
	ClearCacheButton:SetScript("OnClick", function()
			local count = 0

			print("Neat Plates Hub: Cleared", count, "entries from cache.")
		end)

	local BlizzOptionsButton = CreateFrame("Button", objectName.."BlizzButton", AlignmentColumn, "NeatPlatesPanelButtonTemplate")
	BlizzOptionsButton:SetPoint("TOPLEFT", ClearCacheButton, "BOTTOMLEFT", 0, -16)
	--BlizzOptionsButton:SetPoint("TOPLEFT", panel.AdvancedCustomCodeTextbox, "BOTTOMLEFT",-6, -18)
	BlizzOptionsButton:SetWidth(300)
	BlizzOptionsButton:SetText("Blizzard Nameplate Motion & Visibility...")
	BlizzOptionsButton:SetScript("OnClick", function() InterfaceOptionsFrame_OpenToCategory(_G["InterfaceOptionsNamesPanel"]) end)


	------------------------------
	-- Set Sizes and Mechanics
	------------------------------
	panel.MainFrame:SetHeight(2800)

	panel.OpacityFilterList:SetWidth(200)
	panel.WidgetDebuffTrackList:SetWidth(200)

	SetSliderMechanics(panel.OpacityTarget, 1, 0, 1, .01)
	SetSliderMechanics(panel.OpacityNonTarget, 1, 0, 1, .01)
	SetSliderMechanics(panel.OpacitySpotlight, 1, 0, 1, .01)
	SetSliderMechanics(panel.OpacityFiltered, 1, 0, 1, .01)

	SetSliderMechanics(panel.ScaleFiltered, 1, .5, 2.2, .01)
	SetSliderMechanics(panel.ScaleStandard, 1, .5, 2.2, .01)
	SetSliderMechanics(panel.ScaleSpotlight, 1, .5, 2.2, .01)

	SetSliderMechanics(panel.SpacerSlots, 0, 0, 4, 1)

	SetSliderMechanics(panel.FrameVerticalPosition, .5, 0, 1, .02)
	SetSliderMechanics(panel.FrameBarWidth, 1, .3, 1.7, .02)

	SetSliderMechanics(panel.HighHealthThreshold, .7, .01, 1, .01)
	SetSliderMechanics(panel.LowHealthThreshold, .3, .01, 1, .01)

	-- "RefreshSettings" is called; A) When PLAYER_ENTERING_WORLD is called, and; B) When changes are made to settings

	local ConvertStringToTable = NeatPlatesHubHelpers.ConvertStringToTable
	local ConvertDebuffListTable = NeatPlatesHubHelpers.ConvertDebuffListTable
	local ConvertColorListTable = NeatPlatesHubHelpers.ConvertColorListTable
	local CallForStyleUpdate = NeatPlatesHubHelpers.CallForStyleUpdate

	function panel.RefreshSettings(LocalVars)
		-- print("RefreshSettings", panel:IsShown())
		CallForStyleUpdate()
		-- Convert Debuff Filter Strings
		ConvertDebuffListTable(LocalVars.WidgetDebuffTrackList, LocalVars.WidgetDebuffLookup, LocalVars.WidgetDebuffPriority)
		-- Convert Unit Filter Strings
		ConvertStringToTable(LocalVars.OpacityFilterList, LocalVars.OpacityFilterLookup)
		ConvertStringToTable(LocalVars.UnitSpotlightList, LocalVars.UnitSpotlightLookup)
		ConvertColorListTable(LocalVars.CustomColorList, LocalVars.CustomColorLookup)
	end

	--panel:Hide()
end


-- Create Instances of Panels
local Panels = {}

local function CreateProfile(label, color)
	color = color:gsub("|c","")
	if not NeatPlatesHubProfile.profiles[label] then NeatPlatesHubProfile.profiles[label] = color end  -- If profile doesn't exist, create it
	Panels[label] = CreateHubInterfacePanel("HubPanelProfile"..label, "|c"..color..label.." Profile", "Neat Plates" )	-- Create the basic settings panel
	NeatPlatesPanel:AddProfile(label)	-- Add profile to profile list
	BuildHubPanel(Panels[label])	-- Fill the settings panel with options
	InterfaceAddOnsList_Update()	-- Update Interface Options to display new profile
	--OnPanelItemChange(panel)
	return Panels[label]
end

--local Profiles = {
--	["Tank"] = "FF3782D1",
--	["Damage"] = "FFFF1100",
--	["Healer"] = "FF44DD55",
--	["Gladiator"] = "FFAA6600",
--}

local function LoadProfiles(profiles)
	--if next(profiles) == nil then profiles = {["Default"] = "FFFFFFFF"} end -- Make sure at least something is loaded
	for k, v in pairs(profiles) do
		CreateProfile(k, v)
	end
end

-- Temporary functions that imports settings from TPC
local function ImportTPCSettings(frame)
	local profileColor = {
		["Tank"] = "FF3782D1",
		["Damage"] = "FFFF1100",
		["Healer"] = "FF44DD55",
		["Gladiator"] = "FFAA6600",
	}
	local playerName = UnitName("player")

	for k, v in pairs(TidyPlatesContHubSettings) do
		local profile = k:gsub('HubPanelSettings', '')
		local profileName = playerName.." "..profile

		NeatPlatesHubProfile.profiles[profileName] = profileColor[profile] or "FFFFFFFF"
		NeatPlatesHubProfile["HubPanelProfile"..profileName] = v
	end

	DisableAddOn("TidyPlatesContinued")
	ReloadUI()

end

local function ImportSettingsPrompt()
	local frame = CreateFrame("Frame", "ImportSettingsPrompt", UIParent)

	frame:SetBackdrop({	bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 },})
	frame:SetBackdropColor(.1, .1, .1, .6)
	frame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

	frame:SetWidth(500)
	frame:SetHeight(140)

	frame:SetPoint("CENTER",0,0)

	frame.Text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	frame.Text:SetFont(NeatPlatesHubLocalizedFont or "Interface\\Addons\\NeatPlates\\Media\\DefaultFont.ttf", 14)
	frame.Text:SetTextColor(255/255, 105/255, 6/255)
	frame.Text:SetPoint("TOPLEFT", 12, -12)
	frame.Text:SetJustifyH("LEFT")
	frame.Text:SetJustifyV("BOTTOM")


	frame.Text:SetText("You seem to be running both NeatPlates and TidyPlatesContinued.\nDo you wish to import your TPC settings from this character to NeatPlates?\n\n(Once Importing is done TPC will be disabled and a UI Reload will be performed.\nYou will also have to re-select which profile to use for which spec, sorry...)")

	local CancelButton = CreateFrame("Button", "ImportSettingsPromptCancelButton", frame, "NeatPlatesPanelButtonTemplate")
	CancelButton:SetPoint("BOTTOMRIGHT", -12, 12)
	CancelButton:SetWidth(110)
	CancelButton:SetText("Cancel")

	CancelButton:SetScript("OnClick", function() frame:Hide(); LoadProfiles(NeatPlatesHubProfile.profiles); end)

	local ImportButton = CreateFrame("Button", "ImportSettingsPromptImportButton", frame, "NeatPlatesPanelButtonTemplate")
	ImportButton.tooltipText = "Import Settings from TidyPlatesContinued."
	ImportButton:SetPoint("RIGHT", CancelButton, "LEFT", -12, 0)
	ImportButton:SetWidth(140)
	ImportButton:SetText("Import TPC Settings")

	ImportButton:SetScript("OnClick", function() ImportTPCSettings(frame); end)

	frame:Show()
end
-- END --

local HubHandler = CreateFrame("Frame")
HubHandler:SetScript("OnEvent", function(...)
	local _,_,name = ...
	local _,_,_,TPCEnabled = GetAddOnInfo("TidyPlatesContinuedHub")

	if name == "NeatPlatesHub" and not TPCEnabled then
		LoadProfiles(NeatPlatesHubProfile.profiles)
	end

	-- Temporary function for transfering settings from old addon
	if name == "TidyPlatesContinuedHub" then
		ImportSettingsPrompt()
	end
end)
HubHandler:RegisterEvent("ADDON_LOADED")





--Panels.Tank = CreateHubInterfacePanel( "HubPanelSettingsTank", "|cFF3782D1Tank Profile", "Neat Plates" )
--NeatPlatesPanel:AddProfile("Tank")
--BuildHubPanel(Panels.Tank)
--function ShowNeatPlatesHubTankPanel() NeatPlatesUtility.OpenInterfacePanel(Panels.Tank) end


--Panels.Damage = CreateHubInterfacePanel( "HubPanelSettingsDamage", "|cFFFF1100Damage Profile", "Neat Plates" )
--NeatPlatesPanel:AddProfile("Damage")
--BuildHubPanel(Panels.Damage)
--function ShowNeatPlatesHubDamagePanel() NeatPlatesUtility.OpenInterfacePanel(Panels.Damage) end



--Panels.Healer = CreateHubInterfacePanel( "HubPanelSettingsHealer", "|cFF44DD55Healer Profile", "Neat Plates"  )
--NeatPlatesPanel:AddProfile("Healer")
--BuildHubPanel(Panels.Healer)
--function ShowNeatPlatesHubHealerPanel() NeatPlatesUtility.OpenInterfacePanel(Panels.Healer) end


--Panels.Gladiator = CreateHubInterfacePanel( "HubPanelSettingsGladiator", "|cFFAA6600Gladiator Profile", "Neat Plates"  )
--NeatPlatesPanel:AddProfile("Gladiator")
--BuildHubPanel(Panels.Gladiator)
--function ShowNeatPlatesHubGladiatorPanel() NeatPlatesUtility.OpenInterfacePanel(Panels.Gladiator) end


local function RefreshPanel(name)
	local panel = Panels[name]
	if panel then panel:refresh() end
end

NeatPlatesHubMenus.RefreshPanel = RefreshPanel
NeatPlatesHubMenus.CreateProfile = CreateProfile

---------------------------------------------
-- Slash Commands
---------------------------------------------

function ShowNeatPlatesHubPanel()
	local profile = NeatPlatesOptions.ActiveProfile
	if profile then
		NeatPlatesUtility.OpenInterfacePanel(Panels[profile])
	else
		NeatPlatesUtility.OpenInterfacePanel(Panels["Damage"])
	end
	--if profile == "Tank" then
	--	ShowNeatPlatesHubTankPanel()
	--elseif profile == "Healer" then
	--	ShowNeatPlatesHubHealerPanel()
	--elseif profile == "Gladiator" then
	--	ShowNeatPlatesHubGladiatorPanel()
	--else
	--	ShowNeatPlatesHubDamagePanel()
	--end

end

local function SlashCommandHub()
	--local profile = GetProfile()
	ShowNeatPlatesHubPanel()
end


SLASH_HUB1 = '/hub'
SlashCmdList['HUB'] = SlashCommandHub


--[[
	local ColorPanel = CreateInterfacePanel( "HubPanelSettingsColors", "Neat Plates Hub: Colors", nil )
	ColorPanel.RefreshSettings = function() end
	InterfaceOptions_AddCategory(ColorPanel)
--]]
--end

--local HubHandler = CreateFrame("Frame")
--HubHandler:SetScript("OnEvent", OnLogin)
--HubHandler:RegisterEvent("PLAYER_LOGIN")





--[[
local GladiatorPanel = CreateInterfacePanel( "HubPanelSettingsGladiator", "Neat Plates Hub: |cFFAA6600Gladiator", nil )
BuildHubPanel(GladiatorPanel)
function ShowNeatPlatesHubGladiatorPanel() InterfaceOptionsFrame_OpenToCategory(GladiatorPanel) end
--]]
--[[

-- Testing

/run print(HubDamageConfigFrame:GetParent())
/run HubDamageConfigFrame:SetParent(UIParent); HubDamageConfigFrame:SetPoint("TOPLEFT")

HubDamageConfigFrame = DamagePanel

--]]


StaticPopupDialogs["NeatPlatesHUB_RESETCHECK"] = {
  text = "Neat Plates Hub: Your current settings are outdated...",
  button1 = "Reset + Reload UI",
  button2 = "Ignore",

  OnAccept = function()
  		-- print()
  end,

  OnCancel = function()
  		-- print()
  end,

  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

--StaticPopup_Show ("NeatPlatesHUB_RESETCHECK")
--StaticPopup_Hide ("EXAMPLE_HELLOWORLD")




