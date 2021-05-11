local isClassic = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local wowversion, wowbuild, wowdate, wowtocversion = GetBuildInfo()
if wowtocversion and (wowtocversion > 90000 or (isClassic and wowtocversion > 20000)) then
	NeatPlatesBackdrop = "BackdropTemplate"
end