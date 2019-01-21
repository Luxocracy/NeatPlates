local AddonName, addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale(AddonName, "enUS", true, nil)

-- Main panel
L["Theme"] = true

L["Profile Selection"] = true
L["First Spec"] = true
L["Second Spec"] = true
L["Third Spec"] = true
L["Fourth Spec"] = true

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

L["Disable Cast Bars"] = true
L["Force Multi-Lingual Font (Requires /reload)"] = true
L["Use Frequent Health Updates"] = true

-- CVars
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

-- Error Messages & Prompts
L["Sorry, can't delete the Default profile :("] = true
L["You need to specify a 'Profile Name'."] = true
L["A profile with this name already exists, do you wish to overwrite it?"] = true
L["The profile '%1' was successfully overwritten."] = true
L["The profile '%1' already exists, try a different name."] = true
L["Are you sure you wish to delete the profile '%1'?"] = true
L["The profile '%1' was successfully deleted."] = true

