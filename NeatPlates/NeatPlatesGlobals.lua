NEATPLATES_IS_CLASSIC_TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
NEATPLATES_IS_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
NEATPLATES_IS_CLASSIC = NEATPLATES_IS_CLASSIC_TBC or NEATPLATES_IS_CLASSIC_ERA
local wowversion, wowbuild, wowdate, wowtocversion = GetBuildInfo()
if wowtocversion and (wowtocversion > 90000 or (NEATPLATES_IS_CLASSIC and wowtocversion >= 11400)) then
	NeatPlatesBackdrop = "BackdropTemplate"
end