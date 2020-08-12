local wowversion, wowbuild, wowdate, wowtocversion = GetBuildInfo()
if wowtocversion and wowtocversion > 90000 then
	NeatPlatesBackdrop = "BackdropTemplate"
end