
--[[
Neat Plates Hub: Interface Panel

Color Guide:
|cffffdd00		for Yellow
|cffff6906		for Orange
|cff999999		for Grey
|cffffaa33		for Brownish Orange

--]]

local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")

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

local PanelHelpers = PanelHelpers

-- Modes
local ThemeList = NeatPlatesHubMenus.ThemeList
local StyleModes = NeatPlatesHubMenus.StyleModes
local TextModes = NeatPlatesHubMenus.TextModes
local RangeModes = NeatPlatesHubMenus.RangeModes
local RangeStyles = NeatPlatesHubMenus.RangeStyles
local AuraWidgetModes = NeatPlatesHubMenus.AuraWidgetModes
local DebuffStyles = NeatPlatesHubMenus.DebuffStyles
local AuraSortModes = NeatPlatesHubMenus.AuraSortModes
local AuraAlignmentModes = NeatPlatesHubMenus.AuraAlignmentModes
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
local HighlightTypes = NeatPlatesHubMenus.HighlightTypes

local cEnemy = "|cffff5544"
local cFriendly = "|cffc8e915"

------------------------------------------------------------------
-- Generate Panel
------------------------------------------------------------------
local function BuildHubPanel(panel)
	local objectName = panel.objectName
	local AlignmentColumn = panel.AlignmentColumn
	local OffsetColumnB = 200						-- 240
	local F = nil									-- Cache for anchoring
	local ColumnTop, ColumnEnd

	panel.StyleLabel, F = CreateQuickHeadingLabel(nil, L["Nameplate Style"], AlignmentColumn, F, 0, 5)

	ColumnTop = F

	panel.StyleEnemyBarsLabel, F = CreateQuickItemLabel(nil, cEnemy..L["Enemy Health Bars:"], AlignmentColumn, F, 0, 2)
	panel.StyleEnemyBarsOnNPC, F = CreateQuickCheckbutton(objectName.."StyleEnemyBarsOnNPC", L["All NPCs"], AlignmentColumn, F, 16, 0)
	panel.StyleEnemyBarsInstanceMode, F = CreateQuickCheckbutton(objectName.."StyleEnemyBarsInstanceMode", L["Exclude Instances"], AlignmentColumn, F, 32*(1/.8), 0)
	panel.StyleEnemyBarsInstanceMode:SetScale(.8)
	panel.StyleEnemyBarsOnElite, F = CreateQuickCheckbutton(objectName.."StyleEnemyBarsOnElite", L["Elite Units"], AlignmentColumn, F, 16, 0)
	panel.StyleEnemyBarsOnPlayers, F = CreateQuickCheckbutton(objectName.."StyleEnemyBarsOnPlayers", L["Players"], AlignmentColumn, F, 16, 0)
	panel.StyleEnemyBarsOnActive, F = CreateQuickCheckbutton(objectName.."StyleEnemyBarsOnActive", L["Active/Damaged Units"], AlignmentColumn, F, 16, 0)
	panel.StyleEnemyBarsClickThrough, F = CreateQuickCheckbutton(objectName.."StyleEnemyBarsClickThrough", L["Clickthrough"], AlignmentColumn, F, 16, 0)
	panel.StyleEnemyBarsClickThrough.tooltipText = L["Makes the Nameplates non-interactable"]

	ColumnEnd = F

	panel.StyleFriendlyBarsLabel, F = CreateQuickItemLabel(nil, cFriendly..L["Friendly Health Bars:"], AlignmentColumn, ColumnTop, OffsetColumnB, 2)
	panel.StyleFriendlyBarsOnNPC, F = CreateQuickCheckbutton(objectName.."StyleFriendlyBarsOnNPC", L["All NPCs"], AlignmentColumn, F, OffsetColumnB+16, 0)
	panel.StyleFriendlyBarsInstanceMode, F = CreateQuickCheckbutton(objectName.."StyleFriendlyBarsInstanceMode", L["Exclude Instances"], AlignmentColumn, F, (OffsetColumnB+32)*(1/.8), 0)
	panel.StyleFriendlyBarsInstanceMode:SetScale(.8)
	panel.StyleFriendlyBarsOnElite, F = CreateQuickCheckbutton(objectName.."StyleFriendlyBarsOnElite", L["Elite Units"], AlignmentColumn, F, OffsetColumnB+16, 0)

	panel.StyleFriendlyBarsOnPlayers, F = CreateQuickCheckbutton(objectName.."StyleFriendlyBarsOnPlayers", L["Players"], AlignmentColumn, F, OffsetColumnB+16, 0)
	panel.StyleFriendlyBarsOnActive, F = CreateQuickCheckbutton(objectName.."StyleFriendlyBarsOnActive", L["Active/Damaged Units"], AlignmentColumn, F, OffsetColumnB+16, 0)
	panel.StyleFriendlyBarsClickThrough, F = CreateQuickCheckbutton(objectName.."StyleFriendlyBarsClickThrough", L["Clickthrough"], AlignmentColumn, F, OffsetColumnB+16, 0)
	panel.StyleFriendlyBarsClickThrough.tooltipText = L["Makes the Nameplates non-interactable"]

	F =  ColumnEnd
	panel.HealthBarStyleLabel, F = CreateQuickItemLabel(nil, L["Health Bar View:"], AlignmentColumn, F, 0, 2)
	panel.StyleForceBarsOnTargets, F = CreateQuickCheckbutton(objectName.."StyleForceBarsOnTargets", L["Force Bars on Targets"], AlignmentColumn, F, 16, 2)

	panel.StyleHeadlineLabel, F = CreateQuickItemLabel(nil, L["Headline View (Text-Only):"], AlignmentColumn, F, 0, 2)
	panel.StyleHeadlineNeutral, F = CreateQuickCheckbutton(objectName.."StyleHeadlineNeutral", L["Force Headline on Neutral Units"], AlignmentColumn, F, 16, 2)
	panel.StyleHeadlineOutOfCombat, F = CreateQuickCheckbutton(objectName.."StyleHeadlineOutOfCombat", L["Force Headline while Out-of-Combat"], AlignmentColumn, F, 16, 0)
	panel.StyleHeadlineMiniMobs, F = CreateQuickCheckbutton(objectName.."StyleHeadlineMiniMobs", L["Force Headline on Mini-Mobs"], AlignmentColumn, F, 16, 0)

	------------------------------
    -- Health Bars
	------------------------------

    panel.HealthBarLabel, F = CreateQuickHeadingLabel(nil, L["Health Bar View"], AlignmentColumn, F, 0, 5)

    -- Enemy
	panel.EnemyBarColorMode, F =  CreateQuickDropdown(objectName.."EnemyBarColorMode", cEnemy..L["Enemy Bar Color:"], EnemyBarModes, 1, AlignmentColumn, F)
	panel.EnemyNameColorMode, F =  CreateQuickDropdown(objectName.."EnemyNameColorMode", cEnemy..L["Enemy Name Color:"], EnemyNameColorModes, 1, AlignmentColumn, F)
	panel.EnemyStatusTextMode, F =  CreateQuickDropdown(objectName.."EnemyStatusTextMode", cEnemy..L["Enemy Status Text:"], TextModes, 1, AlignmentColumn, F )
	--panel.EnemyStatusTextModeCenter, F =  CreateQuickDropdown(objectName.."EnemyStatusTextModeCenter", "", BasicTextModes, 1, AlignmentColumn, F, 0, -14 )
	--panel.EnemyStatusTextModeRight, F =  CreateQuickDropdown(objectName.."EnemyStatusTextModeRight", "", BasicTextModes, 1, AlignmentColumn, F, 0, -14 )

	-- Friendly
	panel.FriendlyBarColorMode, F =  CreateQuickDropdown(objectName.."FriendlyBarColorMode", cFriendly..L["Friendly Bar Color:"], FriendlyBarModes, 1, AlignmentColumn, panel.HealthBarLabel, OffsetColumnB)
	panel.FriendlyNameColorMode, F =  CreateQuickDropdown(objectName.."FriendlyNameColorMode", cFriendly..L["Friendly Name Color:"], FriendlyNameColorModes, 1, AlignmentColumn, F, OffsetColumnB)
	panel.FriendlyStatusTextMode, F =  CreateQuickDropdown(objectName.."FriendlyStatusTextMode", cFriendly..L["Friendly Status Text:"], TextModes, 1, AlignmentColumn, F, OffsetColumnB)
	--panel.FriendlyStatusTextModeCenter, F =  CreateQuickDropdown(objectName.."FriendlyStatusTextModeCenter", "", BasicTextModes, 1, AlignmentColumn, F, OffsetColumnB, -14)
	--panel.FriendlyStatusTextModeRight, F =  CreateQuickDropdown(objectName.."FriendlyStatusTextModeRight", "", BasicTextModes, 1, AlignmentColumn, F, OffsetColumnB, -14)

	-- Other
	panel.TextShowLevel, F = CreateQuickCheckbutton(objectName.."TextShowLevel", L["Show Level"], AlignmentColumn, F, 0, 2)
	panel.TextShowServerIndicator, F = CreateQuickCheckbutton(objectName.."TextShowServerIndicator", L["Show Different Server Indicator (*)"], AlignmentColumn, F, 0)
  panel.TextShowOnlyOnTargets, F = CreateQuickCheckbutton(objectName.."TextShowOnlyOnTargets", L["Show Status Text on Target & Mouseover"], AlignmentColumn, F, 0)
  panel.TextShowOnlyOnActive, F = CreateQuickCheckbutton(objectName.."TextShowOnlyOnActive", L["Show Status Text on Active/Damaged Units"], AlignmentColumn, F, 0)


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
	panel.StyleLabel, F = CreateQuickHeadingLabel(nil, L["Headline View (Text-Only)"], AlignmentColumn, F, 0, 5)

	ColumnTop = F

	panel.EnemyHeadlineColor, F = CreateQuickDropdown(objectName.."EnemyHeadlineColor", cEnemy..L["Enemy Headline Color:"], EnemyNameColorModes, 1, AlignmentColumn, F)	-- |cffee9900Text-Only Style
	panel.HeadlineEnemySubtext, F =  CreateQuickDropdown(objectName.."HeadlineEnemySubtext", cEnemy..L["Enemy Headline Subtext:"], EnemyNameSubtextModes, 1, AlignmentColumn, F )	-- |cffee9900Text-Only Style

	ColumnEnd = F

	panel.FriendlyHeadlineColor, F = CreateQuickDropdown(objectName.."FriendlyHeadlineColor", cFriendly..L["Friendly Headline Color:"], FriendlyNameColorModes, 1, AlignmentColumn, ColumnTop, OffsetColumnB)	-- |cffee9900Text-Only Style
	panel.HeadlineFriendlySubtext, F =  CreateQuickDropdown(objectName.."HeadlineFriendlySubtext", cFriendly..L["Friendly Headline Subtext:"], EnemyNameSubtextModes, 1, AlignmentColumn, F, OffsetColumnB )	-- |cffee9900Text-Only Style

	F = ColumnEnd

	------------------------------
	-- Aura (Buff and Debuff) Widget
	------------------------------
	panel.DebuffsLabel = CreateQuickHeadingLabel(nil, L["Buffs & Debuffs"], AlignmentColumn, F, 0, 5)
	panel.WidgetDebuff = CreateQuickCheckbutton(objectName.."WidgetDebuff", L["Enable Aura Widget"], AlignmentColumn, panel.DebuffsLabel)

	--panel.WidgetAuraMode =  CreateQuickDropdown(objectName.."WidgetAuraMode", "Filter Mode:", AuraWidgetModes, 1, AlignmentColumn, panel.WidgetDebuffStyle, 16)		-- used to be WidgetDebuffMode

	panel.WidgetMyDebuff = CreateQuickCheckbutton(objectName.."WidgetMyDebuff", L["Include My Debuffs"], AlignmentColumn, panel.WidgetDebuff, 16)
	panel.WidgetMyDebuff.tooltipText = L["Display Debuffs that have been applied by you"]
	panel.WidgetMyBuff = CreateQuickCheckbutton(objectName.."WidgetMyBuff", L["Include My Buffs"], AlignmentColumn, panel.WidgetMyDebuff, 16)
	panel.WidgetMyBuff.tooltipText = L["Display Buffs that have been applied by you"]

	panel.WidgetPandemic = CreateQuickCheckbutton(objectName.."WidgetPandemic", L["Enable Pandemic Highlighting"], AlignmentColumn, panel.WidgetMyBuff, 16)
	panel.WidgetPandemic.tooltipText = L["Highlight auras when they have less than 30% of their original duration remaining"]
	panel.ColorPandemic = CreateQuickColorbox(objectName.."ColorPandemic", "", nil, AlignmentColumn, panel.WidgetMyBuff , OffsetColumnB + 64)
	panel.ColorPandemic.tooltipText = L["Color of the border highlight"]
	panel.BorderPandemic = CreateQuickDropdown(objectName.."BorderPandemic", "", BorderTypes, 1, AlignmentColumn, panel.WidgetMyBuff, OffsetColumnB + 90)
	panel.BorderPandemic.tooltipText = L["Type of highlighting to use"]

	panel.WidgetBuffPurgeable = CreateQuickCheckbutton(objectName.."WidgetBuffPurgeable", L["Include Purgeable Buffs"], AlignmentColumn, panel.WidgetPandemic, 16)
	panel.WidgetBuffPurgeable.tooltipText = L["Display beneficial auras that can be removed by Dispel/Purge"]
	panel.ColorBuffPurgeable = CreateQuickColorbox(objectName.."ColorBuffPurgeable", "", nil, AlignmentColumn, panel.WidgetPandemic , OffsetColumnB + 64)
	panel.ColorBuffPurgeable.tooltipText = L["Color of the border highlight"]
	panel.BorderBuffPurgeable = CreateQuickDropdown(objectName.."BorderBuffPurgeable", "", BorderTypes, 1, AlignmentColumn, panel.WidgetPandemic, OffsetColumnB + 90)
	panel.BorderBuffPurgeable.tooltipText = L["Type of highlighting to use"]

	panel.WidgetBuffEnrage = CreateQuickCheckbutton(objectName.."WidgetBuffEnrage", L["Include Enrage Buffs"], AlignmentColumn, panel.WidgetBuffPurgeable, 16)
	panel.WidgetBuffEnrage.tooltipText = L["Display Enrage effects that can be removed by Soothe"]
	panel.ColorBuffEnrage = CreateQuickColorbox(objectName.."ColorBuffEnrage", "", nil, AlignmentColumn, panel.WidgetBuffPurgeable , OffsetColumnB + 64)
	panel.ColorBuffEnrage.tooltipText = L["Color of the border highlight"]
	panel.BorderBuffEnrage = CreateQuickDropdown(objectName.."BorderBuffEnrage", "", BorderTypes, 1, AlignmentColumn, panel.WidgetBuffPurgeable, OffsetColumnB + 90)
	panel.BorderBuffEnrage.tooltipText = L["Type of highlighting to use"]

	panel.SpacerSlots = CreateQuickSlider(objectName.."SpacerSlots", L["Space Between buffs & debuffs:"], "ACTUAL", 150, AlignmentColumn, panel.WidgetBuffEnrage, 16, 2)
	panel.SpacerSlots.tooltipText = L["The amount of empty aura slots between Buffs & Debuffs.\nMax value means they never share a row"]

	panel.AuraScale = CreateQuickSlider(objectName.."AuraScale", L["Aura Scale:"], nil, 160, AlignmentColumn, panel.WidgetBuffEnrage, OffsetColumnB + 64, 2)
	panel.AuraScale.tooltipText = L["Might require a '/reload' to display correctly"]

	panel.EmphasizedSlots = CreateQuickSlider(objectName.."EmphasizedSlots", L["Amount of Emphasized Auras:"], "ACTUAL", 150, AlignmentColumn, panel.SpacerSlots, 16, 2)
	panel.EmphasizedSlots.tooltipText = L["The amount of Emphasized auras that can be displayed at once"]

	panel.WidgetDebuffStyle =  CreateQuickDropdown(objectName.."WidgetDebuffStyle", L["Icon Style:"], DebuffStyles, 1, AlignmentColumn, panel.EmphasizedSlots, 16)
	panel.WidgetAuraSort =  CreateQuickDropdown(objectName.."WidgetAuraSort", L["Sorting Mode:"], AuraSortModes, 1, AlignmentColumn, panel.EmphasizedSlots, OffsetColumnB)
	panel.WidgetAuraAlignment =  CreateQuickDropdown(objectName.."WidgetAuraAlignment", L["Aura Alignment:"], AuraAlignmentModes, 1, AlignmentColumn, panel.WidgetDebuffStyle, 16)

	panel.WidgetDebuffListLabel = CreateQuickItemLabel(nil, L["Additional Auras:"], AlignmentColumn, panel.WidgetAuraAlignment, 16)
	panel.WidgetDebuffTrackList = CreateQuickEditbox(objectName.."WidgetDebuffTrackList", nil, nil, AlignmentColumn, panel.WidgetDebuffListLabel, 16)
	panel.WidgetDebuffAuraTip = PanelHelpers:CreateTipBox(objectName.."AuraTip", L["AURA_TIP"], AlignmentColumn, "BOTTOMRIGHT", panel.WidgetDebuffTrackList, "TOPRIGHT", 6, 0)
	PanelHelpers.CreateEditBoxButton(panel.WidgetDebuffTrackList, panel.onEditboxOkay)

	panel.EmphasizedAuraListLabel = CreateQuickItemLabel(nil, L["Emphasized Auras:"], AlignmentColumn, panel.WidgetAuraAlignment, OffsetColumnB + 64)
	panel.EmphasizedAuraList = CreateQuickEditbox(objectName.."EmphasizedAuraList", nil, nil, AlignmentColumn, panel.EmphasizedAuraListLabel, OffsetColumnB + 64)
	panel.EmphasizedAuraTip = PanelHelpers:CreateTipBox(objectName.."AuraTip", L["AURA_TIP"], AlignmentColumn, "BOTTOMRIGHT", panel.EmphasizedAuraList, "TOPRIGHT", 6, 0)
	PanelHelpers.CreateEditBoxButton(panel.EmphasizedAuraList, panel.onEditboxOkay)

	panel.EmphasizedUnique = CreateQuickCheckbutton(objectName.."EmphasizedUnique", L["Emphasize Hides Normal Aura"], AlignmentColumn, panel.EmphasizedAuraList, 16, 4)
	panel.EmphasizedUnique.tooltipText = L["Hides the regular aura from the aura widget if it is currently emphasized"]
	panel.HideCooldownSpiral = CreateQuickCheckbutton(objectName.."HideCooldownSpiral", L["Hide Cooldown Spiral"], AlignmentColumn, panel.EmphasizedUnique, 16, 0)
	panel.HideCooldownSpiral.tooltipText = L["Hides the Cooldown Spiral on Auras"]
	panel.HideAuraDuration = CreateQuickCheckbutton(objectName.."HideAuraDuration", L["Hide Aura Duration"], AlignmentColumn, panel.HideCooldownSpiral, 16, 0)
	panel.HideAuraDuration.tooltipText = L["Hides the duration text on Auras. (Use this if you want something like OmniCC to handle the aura durations."]

	--panel.WidgetDebuffStyle =  CreateQuickDropdown(objectName.."WidgetDebuffStyle", L["Icon Style:"], DebuffStyles, 1, AlignmentColumn, panel.HideAuraDuration, 16)
	--panel.WidgetAuraSort =  CreateQuickDropdown(objectName.."WidgetAuraSort", L["Sorting Mode:"], AuraSortModes, 1, AlignmentColumn, panel.HideAuraDuration, OffsetColumnB)
	--panel.WidgetAuraAlignment =  CreateQuickDropdown(objectName.."WidgetAuraAlignment", L["Aura Alignment:"], AuraAlignmentModes, 1, AlignmentColumn, panel.WidgetDebuffStyle, 16)

	panel.WidgetAuraTrackDispelFriendly = CreateQuickCheckbutton(objectName.."WidgetAuraTrackDispelFriendly", L["Include Dispellable Debuffs on Friendly Units"], AlignmentColumn, panel.HideAuraDuration, 16, 4)
	panel.WidgetAuraTrackCurse = CreateQuickCheckbutton(objectName.."WidgetAuraTrackCurse", L["Curse"], AlignmentColumn, panel.WidgetAuraTrackDispelFriendly, 16+16, -2)
	panel.WidgetAuraTrackDisease = CreateQuickCheckbutton(objectName.."WidgetAuraTrackDisease", L["Disease"], AlignmentColumn, panel.WidgetAuraTrackCurse, 16+16, -2)
	panel.WidgetAuraTrackMagic = CreateQuickCheckbutton(objectName.."WidgetAuraTrackMagic", L["Magic"], AlignmentColumn, panel.WidgetAuraTrackDisease, 16+16, -2)
	panel.WidgetAuraTrackPoison = CreateQuickCheckbutton(objectName.."WidgetAuraTrackPoison", L["Poison"], AlignmentColumn, panel.WidgetAuraTrackMagic, 16+16, -2)


	------------------------------
	-- Debuff Help Tip
	--panel.DebuffHelpTip = CreateQuickItemLabel(nil, L["AURA_TIP"], AlignmentColumn, panel.WidgetDebuffListLabel, 225+40) -- 210, 275, )
	--panel.DebuffHelpTip:SetHeight(150)
	--panel.DebuffHelpTip:SetWidth(200)
	--panel.DebuffHelpTip.Text:SetJustifyV("TOP")

	-- Expand Options
	-- Filtering mode: Show raid targets, show only my target

	------------------------------
	--Opacity
	------------------------------
	panel.OpacityLabel, F = CreateQuickHeadingLabel(nil, L["Opacity"], AlignmentColumn, panel.WidgetAuraTrackPoison, 0, 5)
	panel.EnemyAlphaSpotlightMode =  CreateQuickDropdown(objectName.."EnemyAlphaSpotlightMode", cEnemy..L["Enemy Spotlight Mode:"], EnemyOpacityModes, 1, AlignmentColumn, F)
	panel.FriendlyAlphaSpotlightMode, F =  CreateQuickDropdown(objectName.."FriendlySpotlightMode", cFriendly..L["Friendly Spotlight Mode:"], FriendlyOpacityModes, 1, AlignmentColumn, F, OffsetColumnB)

	panel.OpacitySpotlight = CreateQuickSlider(objectName.."OpacitySpotlight", L["Spotlight Opacity:"], nil, nil, AlignmentColumn, F, 0, 2)
	panel.OpacityTarget = CreateQuickSlider(objectName.."OpacityTarget", L["Current Target Opacity:"], nil, nil, AlignmentColumn, panel.OpacitySpotlight, 0, 2)
	panel.OpacityNonTarget = CreateQuickSlider(objectName.."OpacityNonTarget", L["Non-Target Opacity:"], nil, nil, AlignmentColumn, panel.OpacityTarget, 0, 2)

	panel.OpacitySpotlightSpell = CreateQuickCheckbutton(objectName.."OpacitySpotlightSpell", L["Spotlight Casting Units"], AlignmentColumn, panel.OpacityNonTarget, 0)
	panel.OpacitySpotlightMouseover = CreateQuickCheckbutton(objectName.."OpacitySpotlightMouseover", L["Spotlight Mouseover"], AlignmentColumn, panel.OpacitySpotlightSpell, 0)
	panel.OpacitySpotlightRaidMarked = CreateQuickCheckbutton(objectName.."OpacitySpotlightRaidMarked", L["Spotlight Raid Marked"], AlignmentColumn, panel.OpacitySpotlightMouseover, 0)

	panel.OpacityFullNoTarget = CreateQuickCheckbutton(objectName.."OpacityFullNoTarget", L["Use Target Opacity When No Target Exists"], AlignmentColumn, panel.OpacitySpotlightRaidMarked, 0)

	------------------------------
	--Scale
	------------------------------
	panel.ScaleLabel = CreateQuickHeadingLabel(nil, L["Scale"], AlignmentColumn, panel.OpacityFullNoTarget, 0, 5)
	panel.ScaleStandard = CreateQuickSlider(objectName.."ScaleStandard", L["Normal Scale:"], nil, nil, AlignmentColumn, panel.ScaleLabel, 0, 2)

	panel.ScaleFunctionMode =  CreateQuickDropdown(objectName.."ScaleFunctionMode", L["Scale Spotlight Mode:"], ScaleModes, 1, AlignmentColumn, panel.ScaleStandard)


	panel.ScaleSpotlight = CreateQuickSlider(objectName.."ScaleSpotlight", L["Spotlight Scale:"], nil, nil, AlignmentColumn, panel.ScaleFunctionMode, 0, 2)
	panel.ScaleIgnoreNeutralUnits= CreateQuickCheckbutton(objectName.."ScaleIgnoreNeutralUnits", L["Ignore Neutral Units"], AlignmentColumn, panel.ScaleSpotlight, 16)
	panel.ScaleIgnoreNonEliteUnits= CreateQuickCheckbutton(objectName.."ScaleIgnoreNonEliteUnits", L["Ignore Non-Elite Units"], AlignmentColumn, panel.ScaleIgnoreNeutralUnits, 16)
	panel.ScaleIgnoreInactive, F = CreateQuickCheckbutton(objectName.."ScaleIgnoreInactive", L["Ignore Inactive Units"], AlignmentColumn, panel.ScaleIgnoreNonEliteUnits, 16)

	panel.ScaleCastingSpotlight, F = CreateQuickCheckbutton(objectName.."ScaleCastingSpotlight", L["Spotlight Casting Units"], AlignmentColumn, F, 0)
	panel.ScaleTargetSpotlight, F = CreateQuickCheckbutton(objectName.."ScaleTargetSpotlight", L["Spotlight Target Units"], AlignmentColumn, F, 0)
	panel.ScaleMouseoverSpotlight, F = CreateQuickCheckbutton(objectName.."ScaleMouseoverSpotlight", L["Spotlight Mouseover Units"], AlignmentColumn, F, 0)
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
	panel.FilterLabel = CreateQuickHeadingLabel(nil, L["Unit Filter"], AlignmentColumn, F, 0, 5)
	panel.OpacityFiltered, F = CreateQuickSlider(objectName.."OpacityFiltered", L["Filtered Unit Opacity:"], nil, nil, AlignmentColumn, panel.FilterLabel, 0, 2)
	panel.ScaleFiltered, F = CreateQuickSlider(objectName.."ScaleFiltered", L["Filtered Unit Scale:"], nil, nil, AlignmentColumn, F, 0, 2)
	panel.FilterScaleLock, F = CreateQuickCheckbutton(objectName.."FilterScaleLock", L["Override Target/Spotlight Scale"], AlignmentColumn, F, 16)

	panel.OpacityFilterNeutralUnits, F = CreateQuickCheckbutton(objectName.."OpacityFilterNeutralUnits", L["Filter Neutral Units"], AlignmentColumn, F, 8, 4)
	panel.OpacityFilterNonElite, F = CreateQuickCheckbutton(objectName.."OpacityFilterNonElite", L["Filter Non-Elite"], AlignmentColumn, F, 8)
	panel.OpacityFilterEnemyNPC, F = CreateQuickCheckbutton(objectName.."OpacityFilterEnemyNPC", L["Filter Enemy NPC"], AlignmentColumn, F, 8)
	panel.OpacityFilterFriendlyNPC, F = CreateQuickCheckbutton(objectName.."OpacityFilterFriendlyNPC", L["Filter Friendly NPC"], AlignmentColumn, F, 8)
	panel.OpacityFilterUntitledFriendlyNPC, F = CreateQuickCheckbutton(objectName.."OpacityFilterUntitledFriendlyNPC", L["Filter Non-Titled Friendly NPC"], AlignmentColumn, F, 8)

	panel.OpacityFilterPlayers = CreateQuickCheckbutton(objectName.."OpacityFilterPlayers", L["Filter Players"], AlignmentColumn, panel.FilterScaleLock, OffsetColumnB, 4)
	panel.OpacityFilterInactive = CreateQuickCheckbutton(objectName.."OpacityFilterInactive", L["Filter Inactive"], AlignmentColumn, panel.OpacityFilterPlayers, OffsetColumnB)
	panel.OpacityFilterMini = CreateQuickCheckbutton(objectName.."OpacityFilterMini", L["Filter Mini-Mobs"], AlignmentColumn, panel.OpacityFilterInactive, OffsetColumnB)

	panel.OpacityCustomFilterLabel = CreateQuickItemLabel(nil, L["Filter By Unit Name:"], AlignmentColumn, F, 8, 4)
	panel.OpacityFilterList, F = CreateQuickEditbox(objectName.."OpacityFilterList", nil, nil, AlignmentColumn, panel.OpacityCustomFilterLabel, 8)
	PanelHelpers.CreateEditBoxButton(panel.OpacityFilterList, panel.onEditboxOkay)


-- [[

    ------------------------------
	-- Reaction
	------------------------------
	-- Health Bar Color
    panel.ReactionLabel = CreateQuickHeadingLabel(nil, L["Reaction"], AlignmentColumn, F, 0, 5)
	panel.ReactionColorLabel = CreateQuickItemLabel(nil, L["Health Bar Color:"], AlignmentColumn, panel.ReactionLabel, 0, 2)
	panel.ColorFriendlyNPC = CreateQuickColorbox(objectName.."ColorFriendlyNPC", L["Friendly NPC"], nil, AlignmentColumn, panel.ReactionColorLabel , 16)
	panel.ColorFriendlyPlayer = CreateQuickColorbox(objectName.."ColorFriendlyPlayer", L["Friendly Player"], nil, AlignmentColumn, panel.ColorFriendlyNPC , 16)
	panel.ColorNeutral= CreateQuickColorbox(objectName.."ColorNeutral", L["Neutral"], nil, AlignmentColumn, panel.ColorFriendlyPlayer , 16)
	panel.ColorHostileNPC = CreateQuickColorbox(objectName.."ColorHostileNPC", L["Hostile NPC"], nil, AlignmentColumn, panel.ColorNeutral , 16)
	panel.ColorHostilePlayer = CreateQuickColorbox(objectName.."ColorHostilePlayer", L["Hostile Player"], nil, AlignmentColumn, panel.ColorHostileNPC , 16)
	panel.ColorGuildMember = CreateQuickColorbox(objectName.."ColorGuildMember", L["Guild Member"], nil, AlignmentColumn, panel.ColorHostilePlayer , 16)
    -- Text Color
    panel.TextReactionColorLabel = CreateQuickItemLabel(nil, L["Text Color:"], AlignmentColumn, panel.ReactionLabel, OffsetColumnB )
	panel.TextColorFriendlyNPC = CreateQuickColorbox(objectName.."TextColorFriendlyNPC", L["Friendly NPC"], nil, AlignmentColumn, panel.ReactionColorLabel , OffsetColumnB + 16)
	panel.TextColorFriendlyPlayer = CreateQuickColorbox(objectName.."TextColorFriendlyPlayer", L["Friendly Player"], nil, AlignmentColumn, panel.TextColorFriendlyNPC , OffsetColumnB + 16)
	panel.TextColorNeutral= CreateQuickColorbox(objectName.."TextColorNeutral", L["Neutral"], nil, AlignmentColumn, panel.TextColorFriendlyPlayer , OffsetColumnB + 16)
	panel.TextColorHostileNPC = CreateQuickColorbox(objectName.."TextColorHostileNPC", L["Hostile NPC"], nil, AlignmentColumn, panel.TextColorNeutral , OffsetColumnB + 16)
	panel.TextColorHostilePlayer = CreateQuickColorbox(objectName.."TextColorHostilePlayer", L["Hostile Player"], nil, AlignmentColumn, panel.TextColorHostileNPC , OffsetColumnB + 16)
	panel.TextColorGuildMember = CreateQuickColorbox(objectName.."TextColorGuildMember", L["Guild Member"], nil, AlignmentColumn, panel.TextColorHostilePlayer , OffsetColumnB + 16)
	panel.TextColorNormal = CreateQuickColorbox(objectName.."TextColorNormal", L["Normal"], nil, AlignmentColumn, panel.TextColorGuildMember , OffsetColumnB + 16)
	panel.TextColorElite = CreateQuickColorbox(objectName.."TextColorElite", L["Elite"], nil, AlignmentColumn, panel.TextColorNormal , OffsetColumnB + 16)
	panel.TextColorBoss = CreateQuickColorbox(objectName.."TextColorBoss", L["Boss"], nil, AlignmentColumn, panel.TextColorElite , OffsetColumnB + 16)
	-- Threat Colors
		panel.ColorThreatColorLabel = CreateQuickItemLabel(nil, L["Threat Colors:"], AlignmentColumn, panel.TextColorBoss, 0, 2)
	panel.ColorThreatWarning = CreateQuickColorbox(objectName.."ColorThreatWarning", L["Warning"], nil, AlignmentColumn, panel.ColorThreatColorLabel , 16)
	panel.ColorThreatTransition = CreateQuickColorbox(objectName.."ColorThreatTransition", L["Transition"], nil, AlignmentColumn, panel.ColorThreatWarning , 16)
	panel.ColorThreatSafe = CreateQuickColorbox(objectName.."ColorThreatSafe", L["Safe"], nil, AlignmentColumn, panel.ColorThreatTransition, 16)
	panel.ColorAttackingOtherTank = CreateQuickColorbox(objectName.."ColorAttackingOtherTank", L["Attacking another Tank"], nil, AlignmentColumn, panel.ColorThreatSafe , 16)
	panel.ColorPartyAggro = CreateQuickColorbox(objectName.."ColorPartyAggro", L["Group Member Aggro"], nil, AlignmentColumn, panel.ColorAttackingOtherTank , 16)
	-- Other
		panel.OtherColorLabel = CreateQuickItemLabel(nil, L["Other Colors:"], AlignmentColumn, panel.TextColorBoss, OffsetColumnB, 2)
	panel.ColorTapped = CreateQuickColorbox(objectName.."ColorTapped", L["Tapped Unit"], nil, AlignmentColumn, panel.OtherColorLabel , 16+OffsetColumnB)
	--panel.ColorTarget = CreateQuickColorbox(objectName.."ColorTarget", L["Target Unit"], nil, AlignmentColumn, panel.ColorTapped , 16+OffsetColumnB)
	--panel.ColorFocus = CreateQuickColorbox(objectName.."ColorFocus", L["Focus Unit"], nil, AlignmentColumn, panel.ColorTarget , 16+OffsetColumnB)
	--panel.ColorMouseover = CreateQuickColorbox(objectName.."ColorMouseover", L["Mouseover Unit"], nil, AlignmentColumn, panel.ColorFocus , 16+OffsetColumnB)
	--panel.ColorTotem = CreateQuickColorbox(objectName.."ColorTotem", "Totem", nil, AlignmentColumn, panel.ColorTapped , 16+OffsetColumnB)
	-- Custom Colors
		panel.CustomColorLabel = CreateQuickItemLabel(nil, L["Custom Color Conditions:"], AlignmentColumn, panel.ColorPartyAggro, 0, 2)
	panel.CustomColorList, F = CreateQuickEditbox(objectName.."CustomColorList", 200, 100, AlignmentColumn, panel.CustomColorLabel, 8)
	panel.CustomColorSelect = CreateQuickColorbox(objectName.."CustomColorSelect", L["Color Select"], function(hex) local value = panel.CustomColorList:GetValue(); if value == "" then value = hex else value = value.."\n"..hex end; panel.CustomColorList:SetValue(value) end, AlignmentColumn, panel.CustomColorLabel , OffsetColumnB + 50)
	panel.CustomColorTip = PanelHelpers:CreateTipBox(objectName.."CustomColorTip", L["CUSTOM_COLOR_CONDITION_TIP"], AlignmentColumn, "BOTTOMRIGHT", panel.CustomColorList, "TOPRIGHT", 6, 0)
	PanelHelpers.CreateEditBoxButton(panel.CustomColorList, panel.onEditboxOkay)
	--panel.CustomColorInfo = CreateQuickItemLabel(nil, L["CUSTOM_COLOR_CONDITION_TIP"], AlignmentColumn, panel.CustomColorSelect, OffsetColumnB + 50, 2)
	--panel.CustomColorInfo:SetHeight(150)
	--panel.CustomColorInfo:SetWidth(220)
	--panel.CustomColorInfo.Text:SetJustifyV("TOP")

--]]

	------------------------------
	-- Threat
	------------------------------
    -- Column 1
	panel.ThreatLabel = CreateQuickHeadingLabel(nil, L["Threat & Highlighting"], AlignmentColumn, F, 0, 5)
	panel.ThreatWarningMode =  CreateQuickDropdown(objectName.."ThreatWarningMode", L["Threat Mode:"], ThreatWarningModes, 1, AlignmentColumn, panel.ThreatLabel, 0, 2)
	panel.ThreatGlowEnable = CreateQuickCheckbutton(objectName.."ThreatGlowEnable", L["Enable Warning Glow"], AlignmentColumn, panel.ThreatWarningMode,0)

	--panel.ColorThreatColorLabels = CreateQuickItemLabel(nil, L["Threat Colors:"], AlignmentColumn, panel.ThreatGlowEnable, 0, 2)

	panel.WidgetThreatIndicator, F = CreateQuickCheckbutton(objectName.."WidgetThreatIndicator", L["Show Tug-o-Threat Indicator"], AlignmentColumn, panel.ThreatGlowEnable, 0, 2)
	panel.WidgetThreatPercentage, F = CreateQuickCheckbutton(objectName.."WidgetThreatPercentage", L["Show Threat Percentage"], AlignmentColumn, panel.WidgetThreatIndicator, 0, 2)

	--[[
	-- Warning Border Glow
	--]]

    -- Column 2
	panel.EnableOffTankHighlight = CreateQuickCheckbutton(objectName.."EnableOffTankHighlight", L["Highlight Mobs on Off-Tanks"], AlignmentColumn, panel.ThreatWarningMode, 16+OffsetColumnB)

	panel.ColorShowPartyAggro = CreateQuickCheckbutton(objectName.."ColorShowPartyAggro", L["Highlight Group Members holding Aggro"], AlignmentColumn, panel.EnableOffTankHighlight, 16+OffsetColumnB)
	panel.ColorPartyAggroBar = CreateQuickCheckbutton(objectName.."ColorPartyAggroBar", L["Health Bar Color"], AlignmentColumn, panel.ColorShowPartyAggro, 32+OffsetColumnB)
	panel.ColorPartyAggroGlow = CreateQuickCheckbutton(objectName.."ColorPartyAggroGlow", L["Border/Warning Glow"], AlignmentColumn, panel.ColorPartyAggroBar, 32+OffsetColumnB)
	panel.ColorPartyAggroText = CreateQuickCheckbutton(objectName.."ColorPartyAggroText", L["Name Text Color"], AlignmentColumn, panel.ColorPartyAggroGlow, 32+OffsetColumnB)

	panel.HighlightTargetMode =  CreateQuickDropdown(objectName.."HighlightTarget", L["Target Highlighting:"], HighlightTypes, 1, AlignmentColumn, F, 0, 2)
	panel.HighlightFocusMode =  CreateQuickDropdown(objectName.."HighlightFocus", L["Focus Highlighting:"], HighlightTypes, 1, AlignmentColumn, panel.HighlightTargetMode, 0, 2)
	panel.HighlightMouseoverMode =  CreateQuickDropdown(objectName.."HighlightMouseover", L["Mouseover Highlighting:"], HighlightTypes, 1, AlignmentColumn, panel.HighlightFocusMode, 0, 2)

	panel.ColorTarget = CreateQuickColorbox(objectName.."ColorTarget", "", nil, AlignmentColumn, panel.HighlightTargetMode, 130, -17)
	panel.ColorFocus = CreateQuickColorbox(objectName.."ColorFocus", "", nil, AlignmentColumn, panel.HighlightFocusMode,  130, -17)
	panel.ColorMouseover = CreateQuickColorbox(objectName.."ColorMouseover", "", nil, AlignmentColumn, panel.HighlightMouseoverMode, 130, -17)

	--panel.WidgetTargetHighlight, F = CreateQuickCheckbutton(objectName.."WidgetTargetHighlight", L["Show Target Highlight"], AlignmentColumn, F, 0)
	--panel.CustomTargetColor, F = CreateQuickCheckbutton(objectName.."CustomTargetColor", L["Use Target Highlight Color"], AlignmentColumn, F, 0)
 -- panel.CustomFocusColor, F = CreateQuickCheckbutton(objectName.."CustomFocusColor", L["Use Focus Highlight Color"], AlignmentColumn, F, 0)
 -- panel.CustomMouseoverColor, F = CreateQuickCheckbutton(objectName.."CustomMouseoverColor", L["Use Mouseover Highlight Color"], AlignmentColumn, F, 0)
 -- panel.CustomTargetColor.tooltipText = L["Color is defined under the 'Reaction' category."]
 -- panel.CustomFocusColor.tooltipText = L["Color is defined under the 'Reaction' category."]
 -- panel.CustomMouseoverColor.tooltipText = L["Color is defined under the 'Reaction' category."]

	------------------------------
	-- Health
	------------------------------
	panel.HealthLabel, F = CreateQuickHeadingLabel(nil, L["Health"], AlignmentColumn, panel.HighlightMouseoverMode, 0, 5)
	panel.EnableHealerWarning, F = CreateQuickCheckbutton(objectName.."EnableHealerWarning", L["Enable Healer Warning Glow"], AlignmentColumn, F)
	panel.HighHealthThreshold = CreateQuickSlider(objectName.."HighHealthThreshold", L["High Health Threshold:"], nil, nil, AlignmentColumn, F, 0, 2)
	panel.LowHealthThreshold =  CreateQuickSlider(objectName.."LowHealthThreshold", L["Low Health Threshold:"], nil, nil, AlignmentColumn, panel.HighHealthThreshold, 0, 2)
	panel.HealthColorLabels = CreateQuickItemLabel(nil, L["Health Colors:"], AlignmentColumn, panel.LowHealthThreshold, 0)
	panel.ColorHighHealth = CreateQuickColorbox(objectName.."ColorHighHealth", L["High Health"], nil, AlignmentColumn, panel.HealthColorLabels , 16)
	panel.ColorMediumHealth = CreateQuickColorbox(objectName.."ColorMediumHealth", L["Medium Health"], nil, AlignmentColumn, panel.ColorHighHealth , 16)
	panel.ColorLowHealth, F = CreateQuickColorbox(objectName.."ColorLowHealth", L["Low Health"], nil, AlignmentColumn, panel.ColorMediumHealth , 16)
	-- [ ]  Highlight Enemy Healers


	------------------------------
  -- Cast Bars
	------------------------------
  panel.SpellCastLabel, F = CreateQuickHeadingLabel(nil, L["Cast Bars"], AlignmentColumn, F, 0, 5)
  panel.SpellCastEnableFriendly, F = CreateQuickCheckbutton(objectName.."SpellCastEnableFriendly", L["Show Friendly Cast Bars"], AlignmentColumn, F)
  panel.IntCastEnable, F = CreateQuickCheckbutton(objectName.."IntCastEnable", L["Show Interrupted Cast Bar"], AlignmentColumn, F)
  panel.IntCastWhoEnable, F = CreateQuickCheckbutton(objectName.."IntCastWhoEnable", L["Show who Interrupted Cast"], AlignmentColumn, F)
	panel.SpellCastColorLabel, F = CreateQuickItemLabel(nil, L["Cast Bar Colors:"], AlignmentColumn, F, 0, 2)
	panel.ColorNormalSpellCast, F = CreateQuickColorbox(objectName.."ColorNormalSpellCast", L["Normal"], nil, AlignmentColumn, F , 16)
	panel.ColorUnIntpellCast, F = CreateQuickColorbox(objectName.."ColorUnIntpellCast", L["Un-interruptible"], nil, AlignmentColumn, F , 16)
	panel.ColorIntpellCast, F = CreateQuickColorbox(objectName.."ColorIntpellCast", L["Interrupted"], nil, AlignmentColumn, F , 16)


	------------------------------
  -- Range Indicator
	------------------------------
	panel.WidgetRangeIndicatorLabel = CreateQuickHeadingLabel(nil, L["Range Indicator"], AlignmentColumn, F, 0, 5)
	panel.WidgetRangeIndicator = CreateQuickCheckbutton(objectName.."WidgetRangeIndicator", L["Enable Range Indicator"], AlignmentColumn, panel.WidgetRangeIndicatorLabel)
	panel.WidgetRangeScale, F = CreateQuickCheckbutton(objectName.."WidgetRangeScale", L["Scale based on distance"], AlignmentColumn, panel.WidgetRangeIndicator)
	panel.WidgetRangeColorLabel, F = CreateQuickItemLabel(nil, L["Range Indicator Colors:"], AlignmentColumn, F, 0, 2)
	panel.ColorRangeMelee, F = CreateQuickColorbox(objectName.."ColorRangeMelee", L["Melee Range"], nil, AlignmentColumn, F , 16)
	panel.ColorRangeClose, F = CreateQuickColorbox(objectName.."ColorRangeClose", L["Close Range"], nil, AlignmentColumn, F , 16)
	panel.ColorRangeMid, F = CreateQuickColorbox(objectName.."ColorRangeMid", L["Mid Range"], nil, AlignmentColumn, F , 16)
	panel.ColorRangeFar, F = CreateQuickColorbox(objectName.."ColorRangeFar", L["Far Range"], nil, AlignmentColumn, F , 16)
	panel.ColorRangeOOR, F = CreateQuickColorbox(objectName.."ColorRangeOOR", L["Out of Range"], nil, AlignmentColumn, F , 16)

	panel.WidgetRangeMode = CreateQuickDropdown(objectName.."WidgetRangeMode", L["Mode:"], RangeModes, 1, AlignmentColumn, panel.WidgetRangeIndicatorLabel, OffsetColumnB+76)
	panel.WidgetRangeMode.tooltipText1 = L["Only uses the 'Mid Range' & 'Out of Range' colors to indicate unit range"]
	panel.WidgetRangeMode.tooltipText2 = L["Uses multiple colors to indicate unit range"]
	panel.WidgetRangeStyle = CreateQuickDropdown(objectName.."WidgetRangeStyle", L["Style:"], RangeStyles, 1, AlignmentColumn, panel.WidgetRangeMode, OffsetColumnB+76)
	panel.WidgetMaxRange = CreateQuickSlider(objectName.."WidgetMaxRange", L["Range Threshold:"], "ACTUAL", 150, AlignmentColumn, panel.WidgetRangeStyle, OffsetColumnB+76, 2)
	panel.WidgetMaxRange.tooltipText = L["Your 'Out of Range' distance"]
	panel.WidgetOffsetX = CreateQuickSlider(objectName.."WidgetOffsetX", L["Offset X:"], "ACTUAL", 150, AlignmentColumn, panel.WidgetMaxRange, OffsetColumnB+76, 2)
	panel.WidgetOffsetY, F = CreateQuickSlider(objectName.."WidgetOffsetY", L["Offset Y:"], "ACTUAL", 150, AlignmentColumn, panel.WidgetOffsetX, OffsetColumnB+76, 2)

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
	panel.WidgetLabel, F = CreateQuickHeadingLabel(nil, L["Other Widgets"], AlignmentColumn, F, 0, 5)
	panel.WidgetEliteIndicator = CreateQuickCheckbutton(objectName.."WidgetEliteIndicator", L["Show Elite Icon"], AlignmentColumn, panel.WidgetLabel)
	panel.ClassEnemyIcon = CreateQuickCheckbutton(objectName.."ClassEnemyIcon", L["Show Enemy Class Art"], AlignmentColumn, panel.WidgetEliteIndicator)
	panel.ClassPartyIcon = CreateQuickCheckbutton(objectName.."ClassPartyIcon", L["Show Friendly Class Art"], AlignmentColumn, panel.ClassEnemyIcon)
	panel.WidgetTotemIcon = CreateQuickCheckbutton(objectName.."WidgetTotemIcon", L["Show Totem Art"], AlignmentColumn, panel.ClassPartyIcon)
	panel.WidgetQuestIcon = CreateQuickCheckbutton(objectName.."WidgetQuestIcon", L["Show Quest Icon on Units"], AlignmentColumn, panel.WidgetTotemIcon)
	panel.WidgetComboPoints = CreateQuickCheckbutton(objectName.."WidgetComboPoints", L["Show Personal Resource on Target"], AlignmentColumn, panel.WidgetQuestIcon)
	panel.WidgetComboPointsStyle, F =  CreateQuickDropdown(objectName.."WidgetComboPointsStyle", L["Personal Resource Style:"], ComboPointsStyles, 2, AlignmentColumn, panel.WidgetComboPoints, 16)

	--panel.WidgetEnableExternal = CreateQuickCheckbutton(objectName.."WidgetEnableExternal", "Enable External Widgets", AlignmentColumn, panel.WidgetComboPoints)

	--panel.WidgetThreatIndicatorMode =  CreateQuickDropdown(objectName.."WidgetThreatIndicatorMode", "Threat Indicator:", ThreatWidgetModes, 1, AlignmentColumn, panel.WidgetThreatIndicator, OffsetColumnB+16)
	
	panel.WidgetAbsorbIndicator = CreateQuickCheckbutton(objectName.."WidgetAbsorbIndicator", L["Show Absorb Bars"], AlignmentColumn, panel.WidgetLabel, OffsetColumnB+60)
	panel.WidgetAbsorbMode =  CreateQuickDropdown(objectName.."WidgetAbsorbMode", L["Mode:"], AbsorbModes, 1, AlignmentColumn, panel.WidgetAbsorbIndicator, OffsetColumnB+76)
	panel.WidgetAbsorbUnits = CreateQuickDropdown(objectName.."WidgetAbsorbUnits", L["Show on:"], AbsorbUnits, 1, AlignmentColumn, panel.WidgetAbsorbMode, OffsetColumnB+76)

	------------------------------
	-- Advanced
	------------------------------
	panel.AdvancedLabel, F = CreateQuickHeadingLabel(nil, L["Funky Stuff"], AlignmentColumn, F, 0, 5)
	panel.TextUseBlizzardFont, F = CreateQuickCheckbutton(objectName.."TextUseBlizzardFont", L["Use Blizzard Font"], AlignmentColumn, F, 0)
	panel.FocusAsTarget, F = CreateQuickCheckbutton(objectName.."FocusAsTarget", L["Treat Focus as a Target"], AlignmentColumn, F, 0)
	panel.AltShortening, F = CreateQuickCheckbutton(objectName.."AltShortening", L["Use Chinese Number Shortening"], AlignmentColumn, F, 0)
	panel.AdvancedEnableUnitCache, F = CreateQuickCheckbutton(objectName.."AdvancedEnableUnitCache", L["Enable Title Caching"], AlignmentColumn, F)
	panel.FrameVerticalPosition, F = CreateQuickSlider(objectName.."FrameVerticalPosition", L["Vertical Position of Artwork: (May cause targeting problems)"], nil, nil, AlignmentColumn, F, 0, 4)
	panel.FrameBarWidth, F = CreateQuickSlider(objectName.."FrameBarWidth", L["Health Bar Width (%)"], nil, nil, AlignmentColumn, F, 0, 4)

	--panel.AdvancedCustomCodeLabel = CreateQuickItemLabel(nil, "Custom Theme Code:", AlignmentColumn, panel.FrameVerticalPosition, 0, 4)
	--panel.AdvancedCustomCodeTextbox = CreateQuickEditbox(objectName.."AdvancedCustomCodeTextbox", nil, nil, AlignmentColumn, panel.AdvancedHealthTextLabel, 8)


	--[[
	theme.Default.name.size = 18
	--]]
	local ClearCacheButton = CreateFrame("Button", objectName.."ClearCacheButton", AlignmentColumn, "NeatPlatesPanelButtonTemplate")
	ClearCacheButton:SetPoint("TOPLEFT", F, "BOTTOMLEFT",-6, -18)
	--ClearCacheButton:SetPoint("TOPLEFT", panel.AdvancedCustomCodeTextbox, "BOTTOMLEFT",-6, -18)
	ClearCacheButton:SetWidth(300)
	ClearCacheButton:SetText(L["Clear Cache"])
	ClearCacheButton:SetScript("OnClick", function()
			local count = 0

			print("Neat Plates Hub: Cleared", count, "entries from cache.")
		end)

	local BlizzOptionsButton = CreateFrame("Button", objectName.."BlizzButton", AlignmentColumn, "NeatPlatesPanelButtonTemplate")
	BlizzOptionsButton:SetPoint("TOPLEFT", ClearCacheButton, "BOTTOMLEFT", 0, -16)
	--BlizzOptionsButton:SetPoint("TOPLEFT", panel.AdvancedCustomCodeTextbox, "BOTTOMLEFT",-6, -18)
	BlizzOptionsButton:SetWidth(300)
	BlizzOptionsButton:SetText(L["Blizzard Nameplate Motion & Visibility..."])
	BlizzOptionsButton:SetScript("OnClick", function() InterfaceOptionsFrame_OpenToCategory(_G["InterfaceOptionsNamesPanel"]) end)


	------------------------------
	-- Set Sizes and Mechanics
	------------------------------
	panel.MainFrame:SetHeight(2800)

	panel.OpacityFilterList:SetWidth(200)
	panel.WidgetDebuffTrackList:SetWidth(200)
	panel.EmphasizedAuraList:SetWidth(200)

	SetSliderMechanics(panel.OpacityTarget, 1, 0, 1, .01)
	SetSliderMechanics(panel.OpacityNonTarget, 1, 0, 1, .01)
	SetSliderMechanics(panel.OpacitySpotlight, 1, 0, 1, .01)
	SetSliderMechanics(panel.OpacityFiltered, 1, 0, 1, .01)

	SetSliderMechanics(panel.ScaleFiltered, 1, .5, 2.2, .01)
	SetSliderMechanics(panel.ScaleStandard, 1, .5, 2.2, .01)
	SetSliderMechanics(panel.ScaleSpotlight, 1, .5, 2.2, .01)

	SetSliderMechanics(panel.SpacerSlots, 0, 0, 4, 1)
	SetSliderMechanics(panel.AuraScale, 1, .5, 2.2, .01)
	SetSliderMechanics(panel.EmphasizedSlots, 0, 1, 3, 1)

	SetSliderMechanics(panel.WidgetMaxRange, 0, 1, 100, 1)
	SetSliderMechanics(panel.WidgetOffsetX, 0, -100, 100, 1)
	SetSliderMechanics(panel.WidgetOffsetY, 0, -50, 50, 1)

	SetSliderMechanics(panel.FrameVerticalPosition, .5, 0, 1, .02)
	SetSliderMechanics(panel.FrameBarWidth, 1, .3, 1.7, .02)

	SetSliderMechanics(panel.HighHealthThreshold, .7, .01, 1, .01)
	SetSliderMechanics(panel.LowHealthThreshold, .3, .01, 1, .01)

	-- "RefreshSettings" is called; A) When PLAYER_ENTERING_WORLD is called, and; B) When changes are made to settings

	local ConvertStringToTable = NeatPlatesHubHelpers.ConvertStringToTable
	local ConvertAuraListTable = NeatPlatesHubHelpers.ConvertAuraListTable
	local ConvertColorListTable = NeatPlatesHubHelpers.ConvertColorListTable
	local CallForStyleUpdate = NeatPlatesHubHelpers.CallForStyleUpdate

	function panel.RefreshSettings(LocalVars)
		-- print("RefreshSettings", panel:IsShown())
		CallForStyleUpdate()
		-- Convert Debuff Filter Strings
		ConvertAuraListTable(LocalVars.WidgetDebuffTrackList, LocalVars.WidgetDebuffLookup, LocalVars.WidgetDebuffPriority)
		-- Convert Emphasized Filter Strings
		ConvertAuraListTable(LocalVars.EmphasizedAuraList, LocalVars.EmphasizedAuraLookup, LocalVars.EmphasizedAuraPriority)
		-- Convert Unit Filter Strings
		ConvertStringToTable(LocalVars.OpacityFilterList, LocalVars.OpacityFilterLookup)
		ConvertStringToTable(LocalVars.UnitSpotlightList, LocalVars.UnitSpotlightLookup)
		ConvertColorListTable(LocalVars.CustomColorList, LocalVars.CustomColorLookup)
	end

	panel:Hide()
end


-- Create Instances of Panels
local Panels = {}

local function CreateProfile(label, color)
	color = color:gsub("|c","")
	local suffix = ""

	if NeatPlatesSettings.DefaultProfile == label then suffix = "|cFFFFFFFF("..L["Default"]..")" end

	if not NeatPlatesHubSettings.profiles[label] then NeatPlatesHubSettings.profiles[label] = color end  -- If profile doesn't exist, create it
	if not Panels[label] then -- If panel doesn't exist, create it
		Panels[label] = CreateHubInterfacePanel("HubPanelProfile"..label, "|c"..color..label.." "..L["Profile"]..suffix, "Neat Plates" )	-- Create the basic settings panel
		NeatPlatesPanel:AddProfile(label)	-- Add profile to profile list
		BuildHubPanel(Panels[label])	-- Fill the settings panel with options
	else
		Panels[label].RefreshSettings(NeatPlatesHubSettings["HubPanelProfile"..label])	-- Update existing profile
	end

	InterfaceAddOnsList_Update()	-- Update Interface Options to display new profile

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
	--CreateProfile("Default", profiles["Default"]) -- Load Default first to keep it at the top of the list

	for k, v in pairs(profiles) do
		--if k ~= "Default" then CreateProfile(k, v) end
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

		NeatPlatesHubSettings.profiles[profileName] = profileColor[profile] or "FFFFFFFF"
		NeatPlatesHubSettings["HubPanelProfile"..profileName] = v
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
	frame.Text:SetFont(NeatPlatesLocalizedFont or "Interface\\Addons\\NeatPlates\\Media\\DefaultFont.ttf", 14)
	frame.Text:SetTextColor(255/255, 105/255, 6/255)
	frame.Text:SetPoint("TOPLEFT", 12, -12)
	frame.Text:SetJustifyH("LEFT")
	frame.Text:SetJustifyV("BOTTOM")


	frame.Text:SetText(L["IMPORT_PROMPT_TEXT"])

	local CancelButton = CreateFrame("Button", "ImportSettingsPromptCancelButton", frame, "NeatPlatesPanelButtonTemplate")
	CancelButton:SetPoint("BOTTOMRIGHT", -12, 12)
	CancelButton:SetWidth(80)
	CancelButton:SetText(CANCEL)

	CancelButton:SetScript("OnClick", function() frame:Hide(); LoadProfiles(NeatPlatesHubSettings.profiles); end)

	local NoImportButton = CreateFrame("Button", "ImportSettingsPromptNoImportButton", frame, "NeatPlatesPanelButtonTemplate")
	NoImportButton.tooltipText = L["Do not import settings from TidyPlatesContinued. And do not show this message again."]
	NoImportButton:SetPoint("RIGHT", CancelButton, "LEFT", -6, 0)
	NoImportButton:SetWidth(160)
	NoImportButton:SetText(L["Don't show this again"])

	NoImportButton:SetScript("OnClick", function() frame:Hide(); DisableAddOn("TidyPlatesContinued"); LoadProfiles(NeatPlatesHubSettings.profiles); end)

	local ImportButton = CreateFrame("Button", "ImportSettingsPromptImportButton", frame, "NeatPlatesPanelButtonTemplate")
	ImportButton.tooltipText = L["Import Settings from TidyPlatesContinued."]
	ImportButton:SetPoint("RIGHT", NoImportButton, "LEFT", -6, 0)
	ImportButton:SetWidth(140)
	ImportButton:SetText(L["Import TPC Settings"])

	ImportButton:SetScript("OnClick", function() ImportTPCSettings(frame); end)

	frame:Show()
end
-- END --

local HubHandler = CreateFrame("Frame")
HubHandler:SetScript("OnEvent", function(...)
	local _,_,addon = ...
	local player = UnitName("player");
	local TPCEnabled = GetAddOnEnableState(player, "TidyPlatesContinued") ~= 0
	local TPCHubEnabled = GetAddOnEnableState(player, "TidyPlatesContinuedHub") ~= 0

	if addon == "NeatPlatesHub" and (not TPCEnabled or not TPCHubEnabled) then
		LoadProfiles(NeatPlatesHubSettings.profiles)
		HubHandler:UnregisterEvent("ADDON_LOADED")
	end

	-- Temporary function for transfering settings from old addon
	if addon == "TidyPlatesContinuedHub" and TPCEnabled then
		ImportSettingsPrompt()
		HubHandler:UnregisterEvent("ADDON_LOADED")
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

local function UpdateDefaultPanel(name)
	for k, v in pairs(Panels) do
		local panel = Panels[k]
		local color = NeatPlatesHubSettings.profiles[k]
		local suffix = ""
		local label

		if k == name then suffix = "|cFFFFFFFF("..L["Default"]..")" end
		label = "|c"..color..k.." "..L["Profile"]..suffix

		-- Update Panel Label
		panel.name = label
		panel.MainLabel.Text:SetText(label)

		-- Update List Label
		InterfaceAddOnsList_Update()
	end
end

NeatPlatesHubMenus.RefreshPanel = RefreshPanel
NeatPlatesHubMenus.UpdateDefaultPanel = UpdateDefaultPanel
NeatPlatesHubMenus.CreateProfile = CreateProfile

---------------------------------------------
-- Slash Commands
---------------------------------------------

function ShowNeatPlatesHubPanel()
	local profile = NeatPlates.GetProfile()
	if profile then
		NeatPlatesUtility.OpenInterfacePanel(Panels[profile])
	else
		NeatPlatesUtility.OpenInterfacePanel(Panels[NeatPlatesSettings.DefaultProfile])
	end
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




