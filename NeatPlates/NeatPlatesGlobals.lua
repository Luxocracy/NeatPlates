local wowversion, wowbuild, wowdate, wowtocversion = GetBuildInfo()
if wowtocversion and wowtocversion > 90001 then
	NeatPlatesBackdrop = "BackdropTemplate"
end