local MAJOR_VERSION = "ThreatClassic-1.0"
local MINOR_VERSION = 4

if not _G.ThreatLib_MINOR_VERSION or MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

MINOR_VERSION = _G.ThreatLib_MINOR_VERSION

-- No upgrade necessary
if (LibStub.minors[MAJOR_VERSION] or 0) >= MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = nil
	_G.ThreatLib_funcs = nil
	_G.collectgarbage("collect")
	return
end

-- Create ThreatLib as an AceAddon for module stuff
local ThreatLib = LibStub("AceAddon-3.0"):GetAddon("ThreatLib-2.0", true) or LibStub("AceAddon-3.0"):NewAddon("ThreatLib-2.0")
LibStub("AceAddon-3.0"):EmbedLibraries(ThreatLib,
	"AceComm-3.0",
	"AceConsole-3.0",
	"AceEvent-3.0",
	"AceTimer-3.0",
	"AceBucket-3.0",
	"AceSerializer-3.0"
)

-- Manually inject ThreatLib into LibStub
LibStub.libs[MAJOR_VERSION] = ThreatLib
LibStub.minors[MAJOR_VERSION] = MINOR_VERSION

-- Run all those fun functions to actually start up ThreatLib
_G.ThreatLib = ThreatLib
_G.ThreatLib.MINOR_VERSION = MINOR_VERSION
for i = 1, #_G.ThreatLib_funcs do
	_G.ThreatLib_funcs[i]()
end
_G.ThreatLib_MINOR_VERSION = nil
_G.ThreatLib_funcs = nil
_G.ThreatLib = nil

-- Clean up after ourselves!
_G.collectgarbage("collect")

_G.ThreatLibProfile = ThreatLib
