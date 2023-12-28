local L = LibStub("AceLocale-3.0"):NewLocale("NeatPlates", "enUS", true, nil)

------------------------------
-- Main panel
------------------------------
L["Theme"] = true

L["Profile Selection"] = true
L["First Spec"] = true
L["Second Spec"] = true
L["Third Spec"] = true
L["Fourth Spec"] = true
L["Active"] = true
L["Active Profile"] = true

L["Profile Management"] = true
L["Profile Name"] = true
L["Add Profile"] = true
L["Import Profile"] = true
L["Copy Profile"] = true
L["Remove Profile"] = true
L["Export Profile"] = true

L["Automation"] = true
L["Enemy Nameplates"] = true
L["Friendly Nameplates"] = true
	-- Automation Dropdown
	L["Combat"] = true
	L["World"] = true
	L["Dungeon"] = true
	L["Raid"] = true
	L["Battleground"] = true
	L["Arena"] = true
	L["Scenario"] = true
	-- Tooltip
	L["Show"] = true
	L["Hide"] = true
	L["No Automation"] = true

L["General Aura Filters"] = true

L["Other Options"] = true
L["Emulate Target Nameplate"] = true
L["Disable Cast Bars"] = true
L["Force Multi-Lingual Font (Requires /reload)"] = true
L["Force Health Updates"] = true
L["Forces health to update every .25sec, try this if you are having health update issues"] = true
L["Use Frequent Health Updates"] = true
L["Use Blizzard Scaling"] = true
L["Use Blizzard Name Visibility"] = true
L["Use Blizzard Bar Widgets"] = true
L["Outline Override"] = true
	L["Thin Outline"] = true
	L["Thick Outline"] = true

------------------------------
-- CVars
------------------------------
L["Enforce required CVars"] = true
L["Always keep Target Nameplate on Screen"] = true
L["Stacking Nameplates"] = true
L["Show Friendly NPCs Nameplates"] = true
L["Nameplate Max Distance"] = true
L["Occluded Alpha Multiplier"] = true
L["The opacity multiplier for units occluded by line of sight"] = true -- Tooltip
L["Non-target Alpha"] = true
L["The opacity of nameplates when not selected, there is also options for this per profile"] = true -- Tooltip
L["Minimum Alpha"] = true
L["The minimum opacity of nameplates for 'Nameplate Minimum Alpha Distance'"] = true -- Tooltip
L["Maximum Alpha"] = true
L["The maximum opacity of nameplates for 'Nameplate Maximum Alpha Distance'"] = true -- Tooltip
L["Minimum Alpha Distance"] = true
L["The distance from the max distance that nameplates will reach their minimum alpha"] = true -- Tooltip
L["Maximum Alpha Distance"] = true
L["The distance from the camera that nameplates will reach their maxmimum alpha"] = true -- Tooltip
L["Horizontal Overlap"] = true
L["The horizontal distance between nameplates when overlapping (Requires 'Stacking Nameplates')"] = true
L["Vertical Overlap"] = true
L["The vertical distance between nameplates when overlapping (Requires 'Stacking Nameplates')"] = true
L["Clickable Width of Nameplates"] = true
L["Clickable Height of Nameplates"] = true
L["The size of the interactable area of the nameplates"] = true

L["Nameplate Motion & Visibility"] = true
L["Reset Configuration"] = true
	-- Reset Messages
	L["%yellow%Resetting %orange%NeatPlates%yellow% Theme Selection to Default"] = true
	L["%yellow%Holding down %blue%Shift %yellow%while clicking %red%Reset Configuration %yellow%will clear your saved settings, AND reload the user interface."] = true

------------------------------
-- Error Messages & Prompts
------------------------------
L["Sorry, can't delete the Default profile :("] = true
L["You need to specify a 'Profile Name'."] = true
L["A profile with this name already exists, do you wish to overwrite it?"] = true
L["The profile '%1' was successfully overwritten."] = true
L["The profile '%1' already exists, try a different name."] = true
L["Are you sure you wish to delete the profile '%1'?"] = true
L["The profile '%1' was successfully deleted."] = true
L["Do you really want to make '%1' the default profile?"] = true
L["The profile '%1' is now the Default profile."] = true


------------------------------
-- Profile Panel
------------------------------
L["Categories"] = true
L["Default Profile"] = true

------------------------------
-- Nameplate Style
------------------------------
L["Nameplate Style"] = true

L["Enemy Health Bars"] = true
L["Friendly Health Bars"] = true
	-- Healthbar Options
	L["All NPCs"] = true
	L["Exclude Instances"] = true
	L["Exclude Minions"] = true
	L["Exclude Totems"] = true
	L["Elite Units"] = true
	L["Players"] = true
	L["Active/Damaged Units"] = true
	L["Clickthrough"] = true

L["Health Bar View"] = true
L["Force Bars on Targets"] = true

L["Headline View (Text-Only)"] = true
L["Force Headline on Neutral Units"] = true
L["Force Headline while Out-of-Combat"] = true
L["Force Headline on Mini-Mobs"] = true


L["Force Default Nameplates"] = true
L["Enemy Players"] = true
L["Friendly Players"] = true
L["Enemy NPCs"] = true
L["Friendly NPCs"] = true
L["Neutral NPCs"] = true

------------------------------
-- Health Bar View
------------------------------
L["Health Bar View"] = true

L["Enemy Bar Color"] = true
L["Friendly Bar Color"] = true
	-- Bar Color Dropdown
	L["By Threat"] = true
	L["By Reaction"] = true
	L["By Class"] = true
	L["By Health"] = true

L["Enemy Name Color"] = true
L["Friendly Name Color"] = true
	-- Name Color Dropdown
	L["White"] = true
	L["By Level Color"] = true
	L["By Normal/Elite/Boss"] = true

L["Enemy Status Text"] = true
L["Friendly Status Text"] = true
	-- StatusText Dropdown
	L["None"] = true
	L["Percent Health"] = true
	L["Percent Health (Colored)"] = true
	L["Exact Health"] = true
	L["Approximate Health"] = true
		L["SHORT_ONE_HUNDRED_MILLION"] = "E"
		L["SHORT_MILLION"] = "M"
		L["SHORT_TEN_THOUSAND"] = "W"
		L["SHORT_THOUSAND"] = "K"
	L["Health Deficit"] = true
	L["Health Total & Percent"] = true
	L["Exact Health & Percent"] = true
	L["Target Of"] = true
	L["Target Of (Class Colored)"] = true
	L["Level"] = true
	L["Level and Approx Health"] = true
	L["Arena ID"] = true
	L["Arena ID, Health, and Power"] = true
L["Enemy Subtext"] = true
L["Friendly Subtext"] = true
L["Subtext color override (0 opacity = default colors)"] = true


L["Additional settings"] = true
	L["Show Unit Level"] = true
	L["Show Unit Title"] = true
	L["Replace Unit Name with Arena ID"] = true
	L["Show Friendly Unit Powerbar"] = true
	L["Show Enemy Unit Powerbar"] = true
	L["Show Different Server Indicator (*)"] = true
	L["Force Shadow on Status Text"] = true
	L["Show Subtext in Bar View"] = true -- Not in use?
	L["Show Status Text on Target & Mouseover"] = true
	L["Show Status Text on Active/Damaged Units"] = true
	L["Prevent Friendly Nameplate Stacking *"] = true
	L["Health Percent Precision"] = true

	L["Use Custom Target Color"] = true
	L["Use Custom Focus Color"] = true
	L["Use Custom Mouseover Color"] = true

------------------------------
-- Headline View
------------------------------
L["Headline View (Text-Only)"] = true

L["Enemy Headline Color"] = true
L["Friendly Headline Color"] = true
	-- Headline Color Dropdown
	-- (Same as Name Color Dropdown)

L["Enemy Headline Subtext"] = true
L["Friendly Headline Subtext"] = true
	-- Headline Subtext Dropdown
	L["NPC Role, Guild, or Level"] = true
	L["NPC Role, Guild, or Quest"] = true
	L["NPC Role, Guild"] = true
	L["NPC Role"] = true
	L["Unit Title"] = true
	L["Quest"] = true
	L["Everything"] = true

------------------------------
-- Buffs & Debuffs
------------------------------
L["Buffs & Debuffs"] = true
L["Aura Widget"] = true
L["Emphasized Aura Widget"] = true

L["Enable Aura Widget"] = true
	-- Aura Widget Options
	--L["Include All Auras"] = true
	--L["Include My Debuffs"] = true
	--L["Include My Buffs"] = true
	L["Debuff Filter"] = true
	L["Buff Filter"] = true
		L["Show None"] = true
		L["Show Mine"] = true
		L["Show All"] = true
	L["Enable Pandemic Highlighting"] = true
	L["Include Purgeable Buffs"] = true
	L["Include Enrage Buffs"] = true
		-- Border Types Dropdown
		L["Border Color"] = true
		L["Glow"] = true

L["Space Between buffs & debuffs"] = true
L["Aura Scale"] = true
L["Emphasized Aura Scale"] = true
L["Aura Offsets"] = true
L["Emphasized Aura Offsets"] = true
L["Amount of Emphasized Auras"] = true
L["Precise Aura Duration Threshold"] = true
L["Additional Auras"] = true
L["Emphasized Auras"] = true
L["Emphasize Hides Normal Aura"] = true
L["Hide Cooldown Spiral"] = true
L["Hide Aura Duration"] = true
L["Hide Aura Stacks"] = true
L["Hide Aura Widget in Headline Mode"] = true
L["Icon Style"] = true
	-- Icon Style Dropdown
	L["Wide"] = true
	L["Compact"] = true
	L["Blizzlike"] = true

L["Sorting Mode"] = true
		-- Aura Sorting Dropdown
	L["By Duration"] = true

L["Aura Alignment"] = true
	-- Aura Alignment Dropdown
	L["Left"] = true
	L["Center"] = true
	L["Right"] = true

L["Buff Separation Mode"] = true
	-- Buff Separation Dropdown
	L["Separate Row"] = true
	L["Space Between"] = true
	L["No Space"] = true

L["Include Dispellable Debuffs on Friendly Units"] = true
	-- Dispellable Options
	L["Curse"] = true
	L["Disease"] = true
	L["Magic"] = true
	L["Poison"] = true

-- Aura Help Config Help Tip
-- Important to not translate the prefixes.('My', 'All', 'Not')
L["AURA_TIP"] = "Tip: |cffCCCCCCAuras should be listed with the exact name, or a spell ID number. You can change the filter mode to distinguish personal damage spells from global crowd control spells or simply exclude an aura completely. Auras at the top of the list will get displayed before lower ones."
L["HITBOX_TIP"] = "Tip: |cffCCCCCCNameplates will be displayed with a green overlay while editing these values to help visualize the size of the area."

------------------------------
-- Opacity
------------------------------
L["Opacity"] = true

L["Enemy Spotlight Mode"] = true
L["Friendly Spotlight Mode"] = true
	-- Spotlight Mode Dropdown
	L["On Low-Health Units"] = true
	L["On NPC"] = true
	L["On Enemy Healers"] = true
	L["On Active/Damaged Units"] = true
	L["On Party Members"] = true
	L["On Players"] = true
	L["On Damaged Units"] = true

L["Spotlight Opacity"] = true
L["Current Target Opacity"] = true
L["Non-Target Opacity"] = true

L["Spotlight Casting Units"] = true
L["Spotlight Casting Units (Interruptible)"] = true
L["Spotlight Mouseover"] = true
L["Spotlight Raid Marked"] = true
L["Use Target Opacity When No Target Exists"] = true

------------------------------
-- Scale
------------------------------
L["Scale"] = true

L["Normal Scale"] = true
L["Scale Spotlight Mode"] = true
	-- Scale Spotlight Mode Dropdown
	L["On Elite Units"] = true
	L["On Enemy Units"] = true
	L["On NPCs"] = true
	L["On Raid Targets"] = true
	L["On Bosses"] = true

L["Spotlight Scale"] = true
	-- Spotlight Scale Options
	L["Ignore Neutral Units"] = true
	L["Ignore Non-Elite Units"] = true
	L["Ignore Inactive Units"] = true

L["Spotlight Casting Units"] = true
L["Spotlight Target Units"] = true
L["Spotlight Mouseover Units"] = true

-- Unit Filter
L["Unit Filter"] = true

L["Filtered Unit Opacity"] = true
L["Filtered Unit Scale"] = true
	L["Override Target/Spotlight Scale"] = true
	L["Override Target/Spotlight Opacity"] = true

L["Filter Neutral Units"] = true
L["Filter Non-Elite"] = true
L["Filter Non-Titled Friendly NPC"] = true
L["Filter Enemy NPC"] = true
L["Filter Friendly NPC"] = true
L["Filter Non-Titled Friendly NPC"] = true
L["Filter Low Level Units"] = true

L["Filter Players"] = true
L["Filter Party/Raid Members"] = true
L["Filter Non-Party/Raid Members"] = true
L["Filter Inactive"] = true

L["Filter Friendly Players"] = true
L["Filter Enemy Players"] = true
L["Filter Party/Raid Members"] = true
L["Filter Non-Party/Raid Members"] = true
L["Filter Enemy Pets"] = true
L["Filter Friendly Pets"] = true
L["Filter Mini-Mobs"] = true

L["Filter By Unit Name"] = true

------------------------------
-- Reaction
------------------------------
L["Reaction"] = true

L["Health Bar Color"] = true
L["Text Color"] = true
	L["Friendly NPC"] = true
	L["Friendly Player"] = true
	L["Neutral"] = true
	L["Hostile NPC"] = true
	L["Hostile Player"] = true
	L["Guild Member"] = true
	L["Party Member"] = true
	L["Elite"] = true
	L["Boss"] = true

L["Other Colors"] = true
	L["Tapped Unit"] = true
	L["Target Unit"] = true
	L["Focus Unit"] = true
	L["Mouseover Unit"] = true

L["Custom Color Conditions"] = true
L["Color Select"] = true
-- Custom Color Help Tip
L["CUSTOM_COLOR_CONDITION_TIP"] = [=[|cffCCCCCCColor value in Hex(#) followed by:
- Unit Name
- Buff/Debuff Name/SpellID
- Health Threshold
- Target Marker ({rt1-8})

Available prefixes:
- Unit (Only match units)
- My (Only match your auras)

(ex. '#A300FF Spawn of G'huun', 'unit #A300FF Skyfury Totem', or '#FF0000 {rt7}')

|cffff9320Prioritised top to bottom]=]

------------------------------
-- Threat & Highlighting
------------------------------
L["Threat & Highlighting"] = true

L["Threat Mode"] = true
	-- Threat Mode Dropdown
	L["Auto (Color Swap)"] = true
	L["Tank"] = true
	L["DPS/Healer"] = true

L["Enable Warning Glow"] = true
L["Enable Threat while Solo"] = true
L["Use Safe Color while Solo"] = true

L["Threat Colors"] = true
	L["Warning"] = true
	L["Transition"] = true
	L["Safe"] = true

L["Show Tug-o-Threat Indicator"] = true
L["Show Threat Percentage"] = true

L["Highlight Mobs on Off-Tanks"] = true
	L["Attacking another Tank"] = true

L["Highlight Group Members holding Aggro"] = true
	L["Group Member Aggro"] = true
	L["Health Bar Color"] = true
	L["Border/Warning Glow"] = true
	L["Name Text Color"] = true

L["Target Highlighting"] = true
L["Focus Highlighting"] = true
L["Mouseover Highlighting"] = true
	L["None"] = true
	L["Theme Default"] = true
	L["Healthbar"] = true
	L["Arrow(Top)"] = true
	L["Arrow(Sides)"] = true
	L["Arrow(Right)"] = true
	L["Arrow(Left)"] = true
	L["Neon Arrow(Sides)"] = true

------------------------------
-- Health
------------------------------
L["Health"] = true

L["Enable Healer Warning Glow"] = true
L["High Health Threshold"] = true
L["Low Health Threshold"] = true

L["Health Colors"] = true
	L["High Health"] = true
	L["Medium Health"] = true
	L["Low Health"] = true

------------------------------
-- Cast Bars
------------------------------
L["Cast Bars"] = true

L["Castbar Duration Style"] = true
	L["Time Remaining"] = true
	L["Time Elapsed"] = true
	L["Time Elapsed/Cast Time"] = true
L["Show Spell Icon"] = true
L["Show Name of Spell"] = true
L["Show Target of Spell"] = true
L["Show Enemy Cast Bars"] = true
L["Show Friendly Cast Bars"] = true
L["Show Interrupted Cast Bar"] = true
L["Show who Interrupted Cast"] = true

L["Cast Bar Colors"] = true
	L["Normal"] = true
	L["Un-interruptible"] = true
	L["Interrupted"] = true

------------------------------
-- Range Indicator
------------------------------
L["Range Indicator"] = true

L["Enable Range Indicator"] = true
L["Range Threshold"] = true
L["Scale based on distance"] = true

L["Range Indicator Colors"] = true
	L["Melee Range"] = true
	L["Close Range"] = true
	L["Mid Range"] = true
	L["Far Range"] = true
	L["Out of Range"] = true

	L["Simple"] = true
	L["Advanced"] = true

L["Style"] = true
	L["Line"] = true
	L["Icon"] = true

------------------------------
-- Personal Resource
------------------------------
L["Personal Resource Display"] = true
L["Show On"] = true
L["Icon Spacing"] = true
L["The spacing between each icon/point"] = true
L["Display Duration"] = true
L["Duration Font Size"] = true
L["Hide when empty"] = true
L["Show the time remaining on the resource icon. Only applicable to Death Knight runes"] = true
L["Hide the widget if the resource is empty/zero. Only applicable to some classes"] = true

------------------------------
-- Other Widgets
------------------------------
L["Other Widgets"] = true

L["Show Target Highlight"] = true
L["Show Elite Icon"] = true
L["Show on Boss Enemies"] = true
L["Show Arena ID"] = true
L["Show Enemy Class Art"] = true
L["Show Friendly Class Art"] = true
L["Class Icon"] = true
L["Class Icon Scale Options"] = true
L["Show Totem Art"] = true
L["Show Quest Icon on Units"] = true
L["Show Personal Resource"] = true
	L["Enemy Units"] = true
	L["Friendly Units"] = true
L["Personal Resource Style"] = true
	L["Blizzlike"] = true
	L["NeatPlates"] = true
	L["NeatPlatesTraditional"] = true

L["Show Absorb Bars"] = true
	L["Mode"] = true
		L["Blizzlike"] = true
		L["Overlay"] = true
	L["Show on"] = true
		L["Target Only"] = true
		L["All Units"] = true

------------------------------
-- Funky Stuff
------------------------------
L["Funky Stuff"] = true

L["Use Blizzard Font"] = true
L["Treat Focus as a Target"] = true
L["Use Chinese Number Shortening"] = true
L["Enable Title Caching"] = true

L["Vertical Position of Artwork: (May cause targeting problems)"] = true
L["Health Bar Width (%)"] = true
L["Cast Bar Width (%)"] = true

L["Clear Cache"] = true
L["Blizzard Nameplate Motion & Visibility..."] = true


------------------------------
-- Theme Customization
------------------------------
L["Theme Customization"] = true
L["Offset Width"] = true
L["Offset Height"] = true
L["Font Size"] = true

L["customtext"] = "Status Text"
--L["targetindicator"] = "Target Indicator"
L["eliteicon"] =  "Elite Icon/Border"
L["castnostop"] = "Castborder (non-interruptible)"
L["spellicon"] = "Spell Icon"
L["extratext"] = "Extra/Bodyguard Text"
L["extrabar"] = "Extra/Bodyguard Bar"
--L["hitbox"] = "Hitbox(Clickable Area)"
L["focus"] = "Focus Highlighting"
L["target"] = "Target Highlighting"
L["mouseover"] = "Mouseover Highlighting"
L["level"] = "Level Indicator"
L["name"] = "Unit Name"
L["subtext"] = "Unit Subtext"
L["extraborder"] = "Extra/Bodyguard Border"
L["castbar"] = "Castbar"
L["spelltext"] = "Castbar Spell Text"
L["spelltarget"] = "Castbar Spell Target"
L["healthbar"] = "Healthbar"
L["powerbar"] = "Powerbar"
--L["targetindicator_arrowleft"] =
--L["targetindicator_arrowright"] =
L["threatborder"] = "Threat Glow"
L["healthborder"] = "Healthbar Border"
L["skullicon"] = "Skull Icon"
L["durationtext"] = "Duration/Cast time Text"
L["castborder"] = "Castbar Border"
--L["targetindicator_arrowsides"] =
L["highlight"] = "Highlight"
--L["targetindicator_arrowtop"] =
--L["rangeindicator"] = "Range Indicator"
L["raidicon"] = "Raid Icon"
L["ComboWidget"] = "Combopoint Widget"
L["ResourceWidget"] = "Personal Resource Widget"
L["AbsorbWidget"] = "Absorb Widget"
L["QuestWidgetNameOnly"] = "Quest Widget(Headline View)"
L["ThreatPercentageWidget"] = "Threat Percent Widget"
L["DebuffWidget"] = "Aura Widget"
L["ThreatLineWidget"] = "Threat Line Widget"
L["TotemIcon"] = "Totem Icon"
--L["ThreatWheelWidget"] = "Threat Wheel Widget"
L["QuestWidget"] = "Quest Widget"
L["RangeWidget"] = "Range Indicator"
L["ClassIcon"] = "Class Icon"
L["ArenaIcon"] = "Arena Icon"


L["Main"] = true
L["Widgets"] = true
L["Configuration"] = true
L["Import"] = true
L["Export"] = true
L["Reset All"] = true
L["Reset"] = true

L["Are you sure you want to reset all Theme Customizations?"] = true
L["All Theme Customizations have been reset."] = true
L["Imported Theme Customizations."] = true

-- Tooltips
L["customtext_tooltip"] = "The status text that usually appears on the healthbar."
--L["targetindicator_tooltip"] = "Placeholder Tooltip"
L["eliteicon_tooltip"] = "The icon indicating if the unit is an 'Elite'"
L["castnostop_tooltip"] = "The castbar border texture used when a cast cannot be interrupted" -- Merge this with the normal one? / Unify all this under the 'castbar' option?
L["spellicon_tooltip"] = "The spellicon shown on the castbars"
L["extratext_tooltip"] = "Bar text for Nazjatar Bodyguards" -- Unify all this under the 'extrabar' option?
L["extrabar_tooltip"] = "Bar used for Nazjatar Bodyguard XP" -- Unify all this under the 'extrabar' option?
--L["hitbox_tooltip"] = "Placeholder Tooltip"
L["focus_tooltip"] = "Focus highlight texture"
L["target_tooltip"] = "Target highlight texture"
L["level_tooltip"] = "The level of the unit"
L["name_tooltip"] = "The units name"
L["subtext_tooltip"] = "The units subtext"
L["extraborder_tooltip"] = "Border for the 'extrabar', used for Nazjatar Bodyguards" -- Unify all this under the 'extrabar' option?
L["castbar_tooltip"] = "The units castbar" -- Unify all this under the 'castbar' option?
L["spelltext_tooltip"] = "The spellname that appears on the castbar"
L["spelltarget_tooltip"] = "The target of the spell that appears below the castbar"
L["healthbar_tooltip"] = "The actual bar that displays health" -- Unify all this under the 'healthbar' option?
L["powerbar_tooltip"] = "The bar that displays the units power/resource"
--L["targetindicator_arrowleft_tooltip"] = "Placeholder Tooltip"
--L["targetindicator_arrowright_tooltip"] = "Placeholder Tooltip"
L["threatborder_tooltip"] = "The border used with threat glow"
L["mouseover_tooltip"] = "Mouseover highlight texture"
L["healthborder_tooltip"] = "The border around the healthbar" -- Unify all this under the 'healthbar' option?
L["skullicon_tooltip"] = "The icon that appears when a units level normally would appear as '??'"
L["durationtext_tooltip"] = "The cast time text on the castbar"
L["castborder_tooltip"] = "The standard border used for castbars" -- Unify all this under the 'castbar' option?
--L["targetindicator_arrowsides_tooltip"] = "Placeholder Tooltip"
L["highlight_tooltip"] = "General highlighting (Only certain themes still use this)"
--L["targetindicator_arrowtop_tooltip"] = "Placeholder Tooltip"
--L["rangeindicator_tooltip"] = "Placeholder Tooltip"
L["raidicon_tooltip"] = "The raid marker icon on units"
L["ComboWidget_tooltip"] = "Personal resource/Combo points indicator"
L["ResourceWidget_tooltip"] = "Personal resource/Combo points indicator"
L["AbsorbWidget_tooltip"] = "The absorb overlay for healthbars" -- Unify all this under the 'healthbar' option?
L["QuestWidgetNameOnly_tooltip"] = "Quest icon for 'Headline-view'"
L["ThreatPercentageWidget_tooltip"] = "The threat percentage text"
L["DebuffWidget_tooltip"] = "Aura widget"
L["ThreatLineWidget_tooltip"] = "The 'Tug-o-Threat' widget"
L["TotemIcon_tooltip"] = "The totem icon"
--L["ThreatWheelWidget_tooltip"] = "Placeholder Tooltip"
L["QuestWidget_tooltip"] = "Quest icon for normal healthbar mode"
L["RangeWidget_tooltip"] = "The range indicator widget"
L["ClassIcon_tooltip"] = "The class icon"
L["ArenaIcon_tooltip"] = "The arena id icon"

L["Import_tooltip"] = "Import configuration"
L["Export_tooltip"] = "Export configuration"
L["ResetAll_tooltip"] = "Reset all theme customizations"

-- Dropdown Labels
L["Style Mode"] = true
L["Frame Anchor"] = true
L["Text Align"] = true
L["Element Enabled"] = true

-- Dropdown Options
L["Default/Healthbar"] = true
L["Headline/Text-Only"] = true
L["CENTER"] = true
L["TOP"] = true
L["LEFT"] = true
L["RIGHT"] = true
L["BOTTOM"] = true
L["TOPLEFT"] = true
L["TOPRIGHT"] = true
L["BOTTOMLEFT"] = true
L["BOTTOMRIGHT"] = true


-- Aura management
L["New Aura"] = true
L["Mine only"] = true
L["Anyones"] = true
L["Exclude"] = true
L["Emphasized"] = true
L["Priority"] = true
L["Aura Name/ID"] = true
L["Aura Filter"] = true
L["Aura Type"] = true
L["Filter"] = true
L["Type"] = true
L["Empty aura"] = true


------------------------------
-- Import Settings Prompt
------------------------------
--L["You seem to be running both NeatPlates and TidyPlatesContinued.\nDo you wish to import your TPC settings from this character to NeatPlates?\n\n(Once Importing is done TPC will be disabled and a UI Reload will be performed.\nYou will also have to re-select which profile to use for which spec, sorry...)"] = true
L["IMPORT_PROMPT_TEXT"] = [=[You seem to be running both NeatPlates and TidyPlatesContinued.
Do you wish to import your TPC settings from this character to NeatPlates?

(Once Importing is done TPC will be disabled and a UI Reload will be performed.
You will also have to re-select which profile to use for which spec, sorry...)]=]

L["Don't show this again"] = true
	L["Do not import settings from TidyPlatesContinued. And do not show this message again."] = true

L["Import TPC Settings"] = true
	L["Import Settings from TidyPlatesContinued."] = true

------------------------------
-- Version Warning Prompt
------------------------------
L["VERSION_WARNING_PROMPT_TEXT"] = [=[You seem to be running the wrong version of this addon for your client, things will most likely not work correctly.

Please ensure that you are on the correct version before continuing to use this addon.]=]


------------------------------
-- Various stuff & Tooltips
------------------------------
L["You"] = true
L["Tip"] = true

L["Default"] = true
L["Profile"] = true
L["Interrupted"] = true

-- Scale Panel
L["Scale X"] = true
L["Scale Y"] = true
L["Offset X"] = true
L["Offset Y"] = true

-- Main Panel
L["Might resolve some issues with health not updating properly"] = true
L["Allows some CVars to work(Might require a /reload)"] = true
L["Use default blizzard bar widgets where applicable rather than the simpler widget bar built into NeatPlates (Might require a /reload)"] = true
L["CVars could not applied due to combat"] = true
L["This feature is highly experimental, use on your own risk"] = true

-- Profile Panel
L["Makes the Nameplates non-interactable"] = true
L["Display all auras that have been applied regardless of source or duration."] = true
L["Display Debuffs that have been applied by you"] = true
L["Display Buffs that have been applied by you"] = true
L["Highlight auras when they have less than 30% of their original duration remaining"] = true
L["Color of the border highlight"] = true
L["Type of highlighting to use"] = true
L["Display beneficial auras that can be removed by Dispel/Purge"] = true
L["Display Enrage effects that can be removed by Soothe"] = true
L["The minimum amount of empty aura slots allowed between Buffs & Debuffs"] = true
L["The amount of Emphasized auras that can be displayed at once"] = true
L["Hides the regular aura from the aura widget if it is currently emphasized"] = true
L["Color is defined under the 'Reaction' category."] = true
L["Hides the Cooldown Spiral on Auras"] = true
L["Hides the duration text on Auras. (Use this if you want something like OmniCC to handle the aura durations."] = true
L["Might require a '/reload' to display correctly"] = true
L["Only uses the 'Mid Range' & 'Out of Range' colors to indicate unit range"] = true
L["Uses multiple colors to indicate unit range"] = true
L["Your 'Out of Range' distance"] = true
L["Requires 'All NPCs' to be unchecked"] = true
L["Helps ensure that everything is working as intended by enforcing certain CVars"] = true
L["Display Scale Options"] = true
L["Hides the aura widget when in 'Headline/Text-Only' mode"] = true
L["When aura durations should start to display tenths of a second"] = true
L["nameplate_no_stacking_friendly_tooltip"] = "This option also makes the nameplates clickthrough"


-- Warnings about unfinished stuff
L["powerbar_unfinished_warning"] = "The powerbar still has some overlap issues with some themes,\nyou might need to adjust this yourself in the 'Theme Customization'"

-- General warnings
L["Some settings could not be applied properly due to certain combat restrictions."] = true

-- Classic Specific
L["Couldn't update the targets role."] = true
L["Typing '/nptank', will toggle the role assignment of your target manually"] = true
L["Clear Spell Database"] = true
L["Cleared Spell Database of entries."] = true
L["Color Cast Bars by School"] = true
L["Spell School Colors"] = true
L["Physical"] = true
L["Holy"] = true
L["Fire"] = true
L["Nature"] = true
L["Frost"] = true
L["Shadow"] = true
L["Arcane"] = true

-- Classes
L["Class Colors"] = true
L["Reset Class Colors"] = true
L["DEATHKNIGHT"] = "Death Knight"
L["DEMONHUNTER"] = "Demon Hunter"
L["DRUID"] = "Druid"
L["HUNTER"] = "Hunter"
L["MAGE"] = "Mage"
L["MONK"] = "Monk"
L["PALADIN"] = "Paladin"
L["PRIEST"] = "Priest"
L["ROGUE"] = "Rogue"
L["SHAMAN"] = "Shaman"
L["WARLOCK"] = "Warlock"
L["WARRIOR"] = "Warrior"
L["EVOKER"] = "Evoker"