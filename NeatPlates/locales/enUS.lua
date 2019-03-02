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

L["Profile Management"] = true
L["Profile Name"] = true
L["Add Profile"] = true
L["Copy Profile"] = true
L["Remove Profile"] = true

L["Automation"] = true
L["Enemy Nameplates:"] = true
L["Friendly Nameplates:"] = true
	-- Automation Dropdown
	L["No Automation"] = true
	L["Show during Combat, Hide when Combat ends"] = true
	L["Hide when Combat starts, Show when Combat ends"] = true

L["General Aura Filters"] = true

L["Other Options"] = true
L["Disable Cast Bars"] = true
L["Force Multi-Lingual Font (Requires /reload)"] = true
L["Use Frequent Health Updates"] = true
L["Use Blizzard Scaling"] = true

------------------------------
-- CVars
------------------------------
L["Always keep Target Nameplate on Screen"] = true
L["Stacking Nameplates"] = true
L["Nameplate Max Distance"] = true
L["Nameplate Horizontal Overlap"] = true
L["Nameplate Vertical Overlap"] = true
L["Clickable Width of Nameplates"] = true
L["Clickable Height of Nameplates"] = true

L["Nameplate Motion & Visibility"] = true
L["Reset Configuration"] = true
	-- Reset Messages
	L["%yellow%Resetting %orange%Neat Plates%yellow% Theme Selection to Default"] = true
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

L["Enemy Health Bars:"] = true
L["Friendly Health Bars:"] = true
	-- Healthbar Options
	L["All NPCs"] = true
	L["Exclude Instances"] = true
	L["Elite Units"] = true
	L["Players"] = true
	L["Active/Damaged Units"] = true
	L["Clickthrough"] = true

L["Health Bar View:"] = true
L["Force Bars on Targets"] = true

L["Headline View (Text-Only):"] = true
L["Force Headline on Neutral Units"] = true
L["Force Headline while Out-of-Combat"] = true
L["Force Headline on Mini-Mobs"] = true

------------------------------
-- Health Bar View
------------------------------
L["Health Bar View"] = true

L["Enemy Bar Color:"] = true
L["Friendly Bar Color:"] = true
	-- Bar Color Dropdown
	L["By Threat"] = true
	L["By Reaction"] = true
	L["By Class"] = true
	L["By Health"] = true

L["Enemy Name Color:"] = true
L["Friendly Name Color:"] = true
	-- Name Color Dropdown
	L["White"] = true
	L["By Level Color"] = true
	L["By Normal/Elite/Boss"] = true

L["Enemy Status Text:"] = true
L["Friendly Status Text:"] = true
	-- StatusText Dropdown
	L["None"] = true
	L["Percent Health"] = true
	L["Exact Health"] = true
	L["Approximate Health"] = true
		L["SHORT_ONE_HUNDRED_MILLION"] = "E"
		L["SHORT_MILLION"] = "M"
		L["SHORT_TEN_THOUSAND"] = "W"
		L["SHORT_THOUSAND"] = "K"
	L["Health Deficit"] = true
	L["Health Total & Percent"] = true
	L["Target Of"] = true
	L["Level"] = true
	L["Level and Approx Health"] = true
	L["Arena ID"] = true
	L["Arena ID, Health, and Power"] = true

L["Show Level"] = true
L["Show Status Text on Target & Mouseover"] = true
L["Show Status Text on Active/Damaged Units"] = true
L["Use Custom Target Color"] = true
L["Use Custom Focus Color"] = true
L["Use Custom Mouseover Color"] = true

------------------------------
-- Headline View
------------------------------
L["Headline View (Text-Only)"] = true

L["Enemy Headline Color:"] = true
L["Friendly Headline Color:"] = true
	-- Headline Color Dropdown
	-- (Same as Name Color Dropdown)

L["Enemy Headline Subtext:"] = true
L["Friendly Headline Subtext:"] = true
	-- Headline Subtext Dropdown
	L["NPC Role, Guild, or Level"] = true
	L["NPC Role, Guild, or Quest"] = true
	L["NPC Role, Guild"] = true
	L["NPC Role"] = true
	L["Quest"] = true
	L["Everything"] = true

------------------------------
-- Buffs & Debuffs
------------------------------
L["Buffs & Debuffs"] = true

L["Enable Aura Widget"] = true
	-- Aura Widget Options
	L["Include My Debuffs"] = true
	L["Include My Buffs"] = true
	L["Enable Pandemic Highlighting"] = true
	L["Include Purgeable Buffs"] = true
	L["Include Enrage Buffs"] = true
		-- Border Types Dropdown
		L["Border Color"] = true
		L["Glow"] = true

L["Space Between buffs & debuffs:"] = true
L["Amount of Emphasized Auras:"] = true
L["Additional Auras:"] = true
L["Emphasized Auras:"] = true
L["Emphasize Hides Normal Aura"] = true
L["Icon Style:"] = true
	-- Icon Style Dropdown
	L["Wide"] = true
	L["Compact (May require UI reload to take effect)"] = true

L["Include Dispellable Debuffs on Friendly Units"] = true
	-- Dispellable Options
	L["Curse"] = true
	L["Disease"] = true
	L["Magic"] = true
	L["Poison"] = true

-- Aura Help Config Help Tip
-- Important to not translate the prefixes.('My', 'All', 'Not')
L["AURA_TIP"] = "Tip: |cffCCCCCCAuras should be listed with the exact name, or a spell ID number. You can use the prefixes, 'My' or 'All', to distinguish personal damage spells from global crowd control spells. The prefix 'Not' may be used to blacklist an aura.  Auras at the top of the list will get displayed before lower ones."

------------------------------
-- Opacity
------------------------------
L["Opacity"] = true

L["Enemy Spotlight Mode:"] = true
L["Friendly Spotlight Mode:"] = true
	-- Spotlight Mode Dropdown
	L["On Low-Health Units"] = true
	L["On NPC"] = true
	L["On Enemy Healers"] = true
	L["On Active/Damaged Units"] = true
	L["On Party Members"] = true
	L["On Players"] = true
	L["On Damaged Units"] = true

L["Spotlight Opacity:"] = true
L["Current Target Opacity:"] = true
L["Non-Target Opacity:"] = true

L["Spotlight Casting Units"] = true
L["Spotlight Mouseover"] = true
L["Spotlight Raid Marked"] = true
L["Use Target Opacity When No Target Exists"] = true

------------------------------
-- Scale
------------------------------
L["Scale"] = true

L["Normal Scale:"] = true
L["Scale Spotlight Mode:"] = true
	-- Scale Spotlight Mode Dropdown
	L["On Elite Units"] = true
	L["On Enemy Units"] = true
	L["On NPCs"] = true
	L["On Raid Targets"] = true
	L["On Bosses"] = true

L["Spotlight Scale:"] = true
	-- Spotlight Scale Options
	L["Ignore Neutral Units"] = true
	L["Ignore Non-Elite Units"] = true
	L["Ignore Inactive Units"] = true

L["Spotlight Casting Units"] = true
L["Spotlight Target Units"] = true
L["Spotlight Mouseover Units"] = true

-- Unit Filter
L["Unit Filter"] = true

L["Filtered Unit Opacity:"] = true
L["Filtered Unit Scale:"] = true
	L["Override Target/Spotlight Scale"] = true

L["Filter Neutral Units"] = true
L["Filter Non-Elite"] = true
L["Filter Enemy NPC"] = true
L["Filter Friendly NPC"] = true
L["Filter Non-Titled Friendly NPC"] = true

L["Filter Players"] = true
L["Filter Inactive"] = true
L["Filter Mini-Mobs"] = true

L["Filter By Unit Name:"] = true

------------------------------
-- Reaction
------------------------------
L["Reaction"] = true

L["Health Bar Color:"] = true
L["Text Color:"] = true
	L["Friendly NPC"] = true
	L["Friendly Player"] = true
	L["Neutral"] = true
	L["Hostile NPC"] = true
	L["Hostile Player"] = true
	L["Guild Member"] = true
	L["Elite"] = true
	L["Boss"] = true

L["Other Colors:"] = true
	L["Tapped Unit"] = true
	L["Target Unit"] = true
	L["Focus Unit"] = true
	L["Mouseover Unit"] = true

L["Custom Color Conditions:"] = true
L["Color Select"] = true
-- Custom Color Help Tip
L["CUSTOM_COLOR_CONDITION_TIP"] = [=[|cffCCCCCCColor value in Hex(#) followed by:
- Unit Name
- Buff/Debuff Name/SpellID
- Health Threshold

(ex. #A300FF Spawn of G'huun)
|cffff9320Prioritised top to bottom]=]

------------------------------
-- Threat
------------------------------
L["Threat"] = true

L["Threat Mode:"] = true
	-- Threat Mode Dropdown
	L["Auto (Color Swap)"] = true
	L["Tank"] = true
	L["DPS/Healer"] = true

L["Enable Warning Glow"] = true

L["Threat Colors:"] = true
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

------------------------------
-- Health
------------------------------
L["Health"] = true

L["Enable Healer Warning Glow"] = true
L["High Health Threshold:"] = true
L["Low Health Threshold:"] = true

L["Health Colors:"] = true
	L["High Health"] = true
	L["Medium Health"] = true
	L["Low Health"] = true

------------------------------
-- Cast Bars
------------------------------
L["Cast Bars"] = true

L["Show Friendly Cast Bars"] = true
L["Show Interrupted Cast Bar"] = true
L["Show who Interrupted Cast"] = true

L["Cast Bar Colors:"] = true
	L["Normal"] = true
	L["Un-interruptible"] = true
	L["Interrupted"] = true

------------------------------
-- Other Widgets
------------------------------
L["Other Widgets"] = true

L["Show Target Highlight"] = true
L["Show Elite Icon"] = true
L["Show Enemy Class Art"] = true
L["Show Friendly Class Art"] = true
L["Show Totem Art"] = true
L["Show Quest Icon on Units"] = true
L["Show Personal Resource on Target"] = true
L["Personal Resource Style:"] = true
	L["Blizzlike"] = true
	L["NeatPlates"] = true
	L["NeatPlatesTraditional"] = true

L["Show Absorb Bars"] = true
	L["Mode:"] = true
		L["Blizzlike"] = true
		L["Overlay"] = true
	L["Show on:"] = true
		L["Target Only"] = true
		L["All Units"] = true

L["Show Party Range Warning"] = true
	L["Range:"] = true
		L["yards"] = true

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

L["Clear Cache"] = true
L["Blizzard Nameplate Motion & Visibility..."] = true

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
-- Various stuff & Tooltips
------------------------------
L["Tip"] = true

L["Default"] = true
L["Profile"] = true
L["Interrupted"] = true

-- Main Panel
L["Might resolve some issues with health not updating properly"] = true
L["Allows some CVars to work(Might require a /reload)"] = true

-- Profile Panel
L["Makes the Nameplates non-interactable"] = true
L["Display Debuffs that have been applied by you"] = true
L["Display Buffs that have been applied by you"] = true
L["Highlight auras when they have less than 30% of their original duration remaining"] = true
L["Color of the border highlight"] = true
L["Type of highlighting to use"] = true
L["Display beneficial auras that can be removed by Dispel/Purge"] = true
L["Display Enrage effects that can be removed by Soothe"] = true
L["The amount of empty aura slots between Buffs & Debuffs.\nMax value means they never share a row"] = true
L["The amount of Emphasized auras that can be displayed at once"] = true
L["Hides the regular aura from the aura widget if it is currently emphasized"] = true
L["Color is defined under the 'Reaction' category."] = true


