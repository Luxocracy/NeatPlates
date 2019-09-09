--[[-----------------------------------------------------------------------------
Name: ThreatClassic-1.0
Revision: $Revision: 3 $
Author(s): Es (EsreverWoW)
Website: https://github.com/EsreverWoW/LibThreatClassic
Documentation: https://github.com/EsreverWoW/LibThreatClassic/wiki
Description: Tracks and communicates player and pet threat levels.
License: LGPL v2.1

Copyright (C) 2019 Alexander Burt (Es / EsreverWoW)

ThreatClassic-1.0 incorporates work covered by the following copyright and permission notice:

Copyright (C) 2007 Chris Heald and the Threat-1.0/Threat-2.0 teams

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
-------------------------------------------------------------------------------]]
--[[-----------------------------------------------------------------------------
Name: Threat-2.0
Revision: $Revision: 7 $
Author(s): Antiarc (cheald at gmail)
Website: http://www.wowace.com/wiki/Threat-2.0
Documentation: http://www.wowace.com/wiki/Threat-2.0
SVN: http://svn.wowace.com/wowace/trunk/Threat-2.0/
Description: Tracks and communicates player and pet threat levels
License: LGPL v2.1

Copyright (C) 2007 Chris Heald and the Threat-1.0/Threat-2.0 teams

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
-------------------------------------------------------------------------------]]

local MAJOR_VERSION = "ThreatClassic-1.0"
local MINOR_VERSION = 4

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then _G.ThreatLib_MINOR_VERSION = MINOR_VERSION end

ThreatLib_funcs[#ThreatLib_funcs + 1] = function()

-- Need to update this when backwards incompatible changes are made
local LAST_BACKWARDS_COMPATIBLE_REVISION = 3

local _G = _G
local error = _G.error
local pairs = _G.pairs
local select = _G.select
local ThreatLib = _G.ThreatLib
local math_floor, math_max, math_min = _G.math.floor, _G.math.max, _G.math.min
local tinsert, tremove, tconcat = _G.tinsert, _G.tremove, _G.table.concat
local table_sort = _G.table.sort
local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")
local strsplit = _G.string.split
local strsub = _G.string.sub
local gsub, format = _G.string.gsub, _G.string.format
local tostring, tonumber, type = _G.tostring, _G.tonumber, _G.type
local setmetatable = _G.setmetatable
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local IsResting = _G.IsResting
local UnitExists = _G.UnitExists
local IsInGuild = _G.IsInGuild
local GetTime = _G.GetTime
local UnitGUID = _G.UnitGUID
local UnitIsUnit = _G.UnitIsUnit
local UnitClass = _G.UnitClass
local UnitName = _G.UnitName
local UnitIsVisible = _G.UnitIsVisible
local CheckInteractDistance = _G.CheckInteractDistance

if not next(ThreatLib.modules) then
	ThreatLib:SetDefaultModuleState(false)
end

ThreatLib.Classic = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC
ThreatLib.OnCommReceive = {}
ThreatLib.playerName = UnitName("player")
ThreatLib.partyMemberAgents = ThreatLib.partyMemberAgents or {}
ThreatLib.lastPublishedThreat = ThreatLib.lastPublishedThreat or {player = {}, pet = {}}
ThreatLib.threatOffsets = ThreatLib.threatOffsets or {player = {}, pet = {}}
ThreatLib.publishInterval = ThreatLib.publishInterval or nil
ThreatLib.lastPublishTime = ThreatLib.lastPublishTime or 0
ThreatLib.dontPublishThreat = (ThreatLib.dontPublishThreat ~= nil and ThreatLib.dontPublishThreat) or false
ThreatLib.partyMemberRevisions = ThreatLib.partyMemberRevisions or {}
ThreatLib.threatTargets = ThreatLib.threatTargets or {}
ThreatLib.latestSeenRevision = _G.ThreatLib_MINOR_VERSION -- set later, to get the latest version of the whole lib
ThreatLib.isIncompatible = nil
ThreatLib.lastCompatible = LAST_BACKWARDS_COMPATIBLE_REVISION
ThreatLib.currentPartySize = ThreatLib.currentPartySize or 0
ThreatLib.latestSeenSender = ThreatLib.latestSeenSender or nil
ThreatLib.partyUnits = ThreatLib.partyUnits or {}
ThreatLib.callbacks = ThreatLib.callbacks or CallbackHandler:New(ThreatLib)
ThreatLib.GUIDNameLookup = ThreatLib.GUIDNameLookup or setmetatable({}, { __index = function() return "<unknown>" end })
ThreatLib.threatLog = ThreatLib.threatLog or {}
local guidLookup = ThreatLib.GUIDNameLookup

local _callbacks = ThreatLib.callbacks

local threatTargets = ThreatLib.threatTargets
local lastPublishedThreat = ThreatLib.lastPublishedThreat
local partyUnits = ThreatLib.partyUnits
local partyMemberAgents = ThreatLib.partyMemberAgents
local partyMemberRevisions = ThreatLib.partyMemberRevisions
local timers = {}
local inParty, inRaid = false, false
local lastPublishTime = ThreatLib.lastPublishTime
local new, del, newHash, newSet = ThreatLib.new, ThreatLib.del, ThreatLib.newHash, ThreatLib.newSet

-- For development
ThreatLib.DebugEnabled = false
ThreatLib.alwaysRunOnSolo = false

ThreatLib.prefix = "TC1"
ThreatLib.userAgent = "ThreatClassic-1.0"
ThreatLib:RegisterMemoizations({
	CLIENT_INFO 			= "CI",
	LEFT_COMBAT 			= "LC",
	MISDIRECT_THREAT 		= "MT",
	RAID_MOB_THREAT_WIPE 	= "MW",
	REQUEST_CLIENT_INFO 	= "RI",
	THREAT_UPDATE 			= "TU",
	WIPE_ALL_THREAT 		= "WT",
	ACTIVATE_NPC_MODULE 	= "AM",
	SET_NPC_MODULE_VALUE 	= "SV"
})
ThreatLib.WowVersion, ThreatLib.WowMajor, ThreatLib.WowMinor = strsplit(".", tostring(GetBuildInfo()))
ThreatLib.WowVersion, ThreatLib.WowMajor, ThreatLib.WowMinor = tonumber(ThreatLib.WowVersion), tonumber(ThreatLib.WowMajor), tonumber(ThreatLib.WowMinor)
ThreatLib.inCombat = InCombatLockdown

------------------------------------
-- Boot it up!
------------------------------------
local initialized = false -- hack for upgrading, is local so that each upgrade of the lib runs this
function ThreatLib:OnInitialize()
	self:UnregisterAllComm()
	self:RegisterComm(self.prefix)
	self.latestSeenRevision = select(2, LibStub("ThreatClassic-1.0"))
	self.MINOR_VERSION = self.latestSeenRevision
	initialized = true
end

function ThreatLib:OnEnable()
	if not initialized then self:OnInitialize() end

	self:UnregisterAllEvents()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_UPDATE_RESTING", "PLAYER_ENTERING_WORLD")

	self:RegisterEvent("PLAYER_ALIVE")
	self:RegisterEvent("PLAYER_LOGIN")

	-- (re)boot the NPC core
	self:DisableModule("NPCCore")
	self:EnableModule("NPCCore")

	-- Do event registrations here, as a Blizzard bug seems to be causing lockups if these are registered too early
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_NAME_UPDATE", "GROUP_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_LOGIN", "GROUP_ROSTER_UPDATE")

	self:GROUP_ROSTER_UPDATE()
	self:PLAYER_ENTERING_WORLD()

	self:SendComm(self:GroupDistribution(), "REQUEST_CLIENT_INFO", self.MINOR_VERSION, self.userAgent, LAST_BACKWARDS_COMPATIBLE_REVISION)
	if IsInGuild() then
		self:SendComm("GUILD", "REQUEST_CLIENT_INFO", self.MINOR_VERSION, self.userAgent, LAST_BACKWARDS_COMPATIBLE_REVISION)
	end
end

------------------------------------------------------------------------
-- Handled events
------------------------------------------------------------------------
function ThreatLib:PLAYER_ENTERING_WORLD(force)
	if UnitGUID("player") then
		guidLookup[UnitGUID("player")] = UnitName("player")
	end
	local previousRunning = self.running
	local inInstance, kind = IsInInstance()
	if inInstance and (kind == "pvp" or kind == "arena") then
		-- in a battleground that is not AV.
		self:Debug("Disabling, in a PVP instance")
		self.running = false
	elseif IsResting() then
		-- in a city/inn
		self:Debug("Disabling, resting")
		self.running = false
	elseif not self.alwaysRunOnSolo and not UnitExists("pet") and GetNumGroupMembers() == 0 then
		-- all alone
		self:Debug("Disabling, so lonely :'(")
		self.running = false
	else
		self:Debug("Activating...self.alwaysRunOnSolo: %s", self.alwaysRunOnSolo)
		self.running = true
	end
	if previousRunning ~= self.running or force then
		self:Debug("Dispatching event...")
		if self.running then
			_callbacks:Fire("Activate")
			self:EnableModule("Player")
			if UnitExists("pet") then
				self:EnableModule("Pet")
			end
		else
			_callbacks:Fire("Deactivate")
			self:DisableModule("Player")
			self:DisableModule("Pet")
		end
	end
end

function ThreatLib:PLAYER_LOGIN()
	self:DisableModule("Player")
	self:DisableModule("Pet")
	self:PLAYER_ENTERING_WORLD(true)
end

function ThreatLib:PLAYER_ALIVE()
	if not self.booted then
		self:DisableModule("Player")
		self:DisableModule("Pet")
		self.booted = true
		self:PLAYER_ENTERING_WORLD(true)
	end
end

function ThreatLib:PLAYER_REGEN_DISABLED()
	-- self.inCombat = true
	self:CancelTPSReset()
end

function ThreatLib:PLAYER_REGEN_ENABLED()
	-- self.inCombat = false
	self:ScheduleTPSReset()
end

-- #NODOC
function ThreatLib:ThreatUpdated(source_unit, target_guid, threat)
	self:ThreatUpdatedForUnit(source_unit, target_guid, threat)
	local t = GetTime()
	if not self.publishInterval then
		self.publishInterval = self:GetPublishInterval()
	end
	if t - lastPublishTime > self.publishInterval then
		self:PublishThreat()
	end
end

-- #NODOC
function ThreatLib:ThreatUpdatedForUnit(unit_id, target_guid, threat)
	if type(unit_id) ~= "string" then
		error(("Assertion failed: type(%s --[[unit_id]]) == %q, trace: %s"):format(self:toliteral(unit_id), "string", debugstack()))
	end

	if threat then
		self:UpdateTPS(unit_id, target_guid, threat)
		self:_setThreat(unit_id, target_guid, threat)
		_callbacks:Fire("ThreatUpdated", unit_id, target_guid, threat)
	end
end

-- #NODOC
function ThreatLib:UpdateParty()
	for k in pairs(partyUnits) do
		partyUnits[k] = nil
	end

	self.currentPartySize = self.currentPartySize or 0
	local sizeBeforeUpdate = self.currentPartySize
	local numRaid = IsInRaid() and GetNumGroupMembers() or 0
	if numRaid > 0 then
		inRaid = true
		inParty = true
		self.currentPartySize = numRaid
	else
		inRaid = false
		local numParty = GetNumGroupMembers()
		if numParty > 0 then
			inParty = true
			self.currentPartySize = numParty
		else
			inParty = false
			self.currentPartySize = 0
		end
	end

	self:Debug("currentPartySize: %s, sizeBeforeUpdate: %s", self.currentPartySize, sizeBeforeUpdate)
	if self.currentPartySize > sizeBeforeUpdate and self.currentPartySize > 0 then
		self:PublishVersion(self:GroupDistribution())
		self:UpdatePartyGUIDs()
	end
	_callbacks:Fire("PartyChanged")

	self.publishInterval = self:GetPublishInterval()
	self:PLAYER_ENTERING_WORLD()
end

function ThreatLib:UpdatePartyGUIDs()
	if not inRaid and not inParty then return end

	local playerFmt = inRaid and "raid%d" or "party%d"
	local petFmt = inRaid and "raidpet%d" or "partypet%d"

	for i = 1, self.currentPartySize, 1 do
		local unitID = format(playerFmt, i)
		local pGUID = UnitGUID(unitID)

		if pGUID then
			guidLookup[pGUID] = UnitName(unitID)

			-- lookup pet (if existing)
			local petID = format(petFmt, i)
			local petGUID = UnitGUID(petID)
			if petGUID then
				guidLookup[petGUID] = UnitName(petID)
			end
		end
	end
end

function ThreatLib:UNIT_PET(event, unit)
	if unit ~= "player" then return end
	local exists = UnitExists("pet")
	if exists and self.running then
		self:DisableModule("Pet")
		self:EnableModule("Pet")
	else
		self:DisableModule("Pet")
	end
	self:GROUP_ROSTER_UPDATE()	--- Does gaining or losing a pet already fire this? Is this needed?
end

function ThreatLib:GROUP_ROSTER_UPDATE()
	if timers.UpdateParty then
		self:CancelTimer(timers.UpdateParty, true)
		timers.UpdateParty = nil
	end
	timers.UpdateParty = self:ScheduleTimer("UpdateParty", 0.5)
end
------------------------------------------------------------------------
-- Handled chat messages
------------------------------------------------------------------------

local BLACKLIST_MOB_IDS = ThreatLib.BLACKLIST_MOB_IDS or {}

function ThreatLib.OnCommReceive:THREAT_UPDATE(sender, distribution, msg)
	if not msg then return end
	local guid, target_guid, val = strsplit(":", msg)
	target_guid, val = strsplit("=", target_guid)
	val = strsub(val, 1, -2)
	if guid then
		local dstGUID, threat = target_guid, tonumber(val)
		-- check against the blacklist to avoid trouble with clients that have an older version not blacklisting the mob
		if dstGUID and threat then -- and not BLACKLIST_MOB_IDS[ThreatLib:NPCID(dstGUID)] then
			self:ThreatUpdatedForUnit(guid, dstGUID, threat)
		end
	end
end

function ThreatLib.OnCommReceive:LEFT_COMBAT(sender, distribution, playerLeft, petLeft)
	local sGUID = UnitGUID(sender)

	if playerLeft and sGUID then
		self:_clearThreat(sGUID)
	end

	if petLeft then
		local pGUID = UnitGUID(sender .. "-pet")
		if pGUID then
			self:_clearThreat(pGUID)
		end
	end
end

do
	local function wipeAllThreatFunc(self)
		self:GetModule("Player"):MultiplyThreat(0)
		local petModule = self:GetModule("Pet")
		if petModule:IsEnabled() then
			petModule:MultiplyThreat(0)
		end
		self:ResetTPS(nil, true)
		self:ClearStoredThreatTables()
		_callbacks:Fire("ThreatCleared")
		self:PublishThreat(true)
		timers.ThreatWipe = nil
	end

	local lastWipe = 0
	function ThreatLib.OnCommReceive:WIPE_ALL_THREAT(sender)
		if self:IsGroupOfficer(sender) or UnitIsUnit(sender, "player") then
			if GetTime() - lastWipe > 10 then
				lastWipe = GetTime()
				timers.ThreatWipe = self:ScheduleTimer(wipeAllThreatFunc, 0.35, self)
			end
		end
	end
end

local cooldownTimes = {}
local function mobThreatWipeFunc(self, mob_id)
	local IDs = self:GetModule("Player"):GetGUIDsByNPCID(mob_id)
	for i = 1, #IDs do
		local id = IDs[i]
		self:GetModule("Player"):SetTargetThreat(id, 0)
		self:ResetTPS(id, true)
		self:ClearStoredThreatTables(id)
	end

	if UnitExists("pet") then
		local IDs = self:GetModule("Pet"):GetGUIDsByNPCID(mob_id)
		for i = 1, #IDs do
			local id = IDs[i]
			self:GetModule("Pet"):SetTargetThreat(id, 0)
			self:ResetTPS(id, true)
			self:ClearStoredThreatTables(id)
		end
	end
	self:PublishThreat(true)
end

function ThreatLib.OnCommReceive:RAID_MOB_THREAT_WIPE(sender, distribution, mob_guid)
	if BLACKLIST_MOB_IDS[ThreatLib:NPCID(mob_guid)] then return end
	if GetTime() - (cooldownTimes[mob_guid] or 0) > 10 then
		cooldownTimes[mob_guid] = GetTime()
		mobThreatWipeFunc(ThreatLib, mob_guid) -- self:ScheduleTimer(mobThreatWipeFunc, 0.5, mob_guid)
	end
end

function ThreatLib:ClearStoredThreatTables(mob_guid)
	for k, v in pairs(threatTargets) do
		for k2, v2 in pairs(v) do
			if not mob_guid or mob_guid == k2 then
				v[k2] = nil
			end
		end
	end
end

function ThreatLib.OnCommReceive:MISDIRECT_THREAT(sender, distribution, target_player_guid, target_enemy_guid, amount)
	if BLACKLIST_MOB_IDS[ThreatLib:NPCID(target_enemy_guid)] then return end
	ThreatLib:Debug("Got misdirect from %s: give %s threat to %s on mob %s", sender, amount, target_player_guid, target_enemy_guid)
	if select(2, UnitClass(sender)) ~= "HUNTER" then return end
	ThreatLib:Debug("%s is a hunter, continuing", sender)
	if target_player_guid == UnitGUID("player") then
		self:GetModule("Player"):AddTargetThreat(target_enemy_guid, amount)
		ThreatLib:Debug("Added %s threat to player", amount)
	elseif UnitExists("pet") and target_player_guid == UnitGUID("pet") then
		self:GetModule("Pet"):AddTargetThreat(target_enemy_guid, amount)
		ThreatLib:Debug("Added %s threat to pet", amount)
	end
end

function ThreatLib.OnCommReceive:REQUEST_CLIENT_INFO(sender, distribution, revision, useragent, lastCompatible)
	if type(revision) ~= "number" then return end

	if distribution == "RAID" or distribution == "PARTY" then
		partyMemberAgents[sender] = useragent or "(Unknown agent)"
		partyMemberRevisions[sender] = revision or "(Unknown)"
	end
	self:PublishVersion("WHISPER", sender)
	if useragent == self.userAgent then
		self:CheckLatestRevision(revision, sender, lastCompatible)
	end
end

function ThreatLib.OnCommReceive:CLIENT_INFO(sender, distribution, revision, useragent, lastCompatible)
	if type(revision) ~= "number" then return end
	self:Debug("Received client info from %s: revision %s (last compatible %s)[distribution: %s]", sender, revision, lastCompatible, distribution)
	partyMemberAgents[sender] = useragent or "(Unknown agent)"
	partyMemberRevisions[sender] = revision or "(Unknown)"
	if useragent == self.userAgent then
		self:CheckLatestRevision(revision, sender, lastCompatible)
	end
end

function ThreatLib.OnCommReceive:ACTIVATE_NPC_MODULE(sender, distribution, module_id)
	self:GetModule("NPCCore"):ActivateModule(module_id)
end

function ThreatLib.OnCommReceive:SET_NPC_MODULE_VALUE(sender, distribution, var_name, var_value)
	if not partyUnits[sender] then return end
	if self:IsGroupOfficer(partyUnits[sender]) then
		self:GetModule("NPCCore"):SetModuleVar(var_name, var_value)
		self:Debug("%s set variable %q = %q", sender, var_name, var_value)
	end
end

------------------------------------------------------------------------
-- Command invocation methods
------------------------------------------------------------------------

-- Arguments:
-- 	string - variable name to set
--	float - value to set for variable
function ThreatLib:SetNPCModuleValue(var_name, var_value)
	if self:IsGroupOfficer("player") then
		self:SendComm(self:GroupDistribution(), "SET_NPC_MODULE_VALUE", var_name, var_value)
		ThreatLib.OnCommReceive.SET_NPC_MODULE_VALUE(self, self.playerName, nil, var_name, var_value)
	end
end

-- #NODOC
function ThreatLib:NotifyGroupModuleActivate(module_name)
	self:SendComm(self:GroupDistribution(), "ACTIVATE_NPC_MODULE", module_name)
end

------------------------------------------------------------------------
-- Internal Methods
------------------------------------------------------------------------

-- #NODOC
function ThreatLib:_setThreat(sender, target_guid, threat)
	local data = threatTargets[sender]
	if not data then
		data = new()
		threatTargets[sender] = data
	end
	data[target_guid] = threat
end

-- #NODOC
function ThreatLib:_clearAllThreat()
	-- These do the standard clear but also comm that back to the group
	self:_clearThreat(UnitGUID("player"))
	self:_clearThreat(UnitGUID("pet"))

	for k,v in pairs(threatTargets) do
		threatTargets[k] = del(v)
	end

	for k,v in pairs(lastPublishedThreat) do
		for k2, v2 in pairs(v) do
			v[k2] = nil
		end
	end

	-- self:Debug("Clearing ALL threat!")
	_callbacks:Fire("ThreatCleared")
end

-- #NODOC
function ThreatLib:_clearThreat(guid)
	if self.tpsSigma[guid] then
		self.tpsSigma[guid] = del(self.tpsSigma[guid])
	end

	local data = threatTargets[guid]
	if not data then
		return
	end

	-- data[GLOBAL_HASH] = 0
	for k,v in pairs(data) do
		data[k] = nil
		self:ThreatUpdatedForUnit(guid, k, 0)
	end

	if UnitGUID("player") == guid then
		for k,v in pairs(lastPublishedThreat.player) do
			lastPublishedThreat.player[k] = nil
		end
	elseif UnitGUID("pet") == guid then
		for k,v in pairs(lastPublishedThreat.pet) do
			lastPublishedThreat.pet[k] = nil
		end
	end

	if threatTargets[guid] then
		threatTargets[guid] = del(data)
	end
	self:PublishThreat()
end

-------------------------------------------------------
-- Arguments:
--	boolean - Whether or not to publish threat updates
-- Notes:
--	Toggles threat publishes on and off, in case you don't want to send
--	threat values to your group for some reason
-------------------------------------------------------
function ThreatLib:ToggleThreatPublish(val)
	self.dontPublishThreat = not val
end

-- #NODOC
do
	local t = {}
	local function getThreatString(unit, module, force)
		local mod = ThreatLib:GetModule(module, true)
		if not mod or not mod:IsEnabled() then return nil, false end
		local nl = 1
		local uid = UnitGUID(unit) or mod.unitGUID
		if not uid then return nil, false end
		t[1] = uid .. ":"
		local changed = false
		for k, v in pairs(mod.targetThreat) do
			if type(k) ~= "string" then
				error(format("Assertion failed! Expected %s, got %s", "string", tostring(type(k))))
			end
			if lastPublishedThreat[unit][k] ~= v or force then
				local fv = math_floor(v)
				nl = nl + 1
				t[nl] = format("%s=%d,", k, fv)
				lastPublishedThreat[unit][k] = v
				changed = true
			end
		end
		for k, v in pairs(lastPublishedThreat[unit]) do
			if mod.targetThreat[k] == nil then
				if v ~= 0 then
					nl = nl + 1
					t[nl] = format("%s=%d,", k, 0)
					changed = true
				end
				lastPublishedThreat[unit][k] = nil
			end
		end

		if changed then
			return tconcat(t, "", 1, nl), true
		else
			return nil, false
		end
	end

	-- #NODOC
	function ThreatLib:PublishThreat(force)
		if (not inParty and not inRaid) or self.dontPublishThreat then return end
		local playerMsg = getThreatString("player", "Player", force)
		local petMsg = getThreatString("pet", "Pet", force)

		if playerMsg then
			self:SendCommRaw(self:GroupDistribution(), "THREAT_UPDATE", playerMsg)
		end
		if petMsg then
			self:SendCommRaw(self:GroupDistribution(), "THREAT_UPDATE", petMsg)
		end
		lastPublishTime = GetTime()
	end
end

-- #NODOC
local playerClass
function ThreatLib:GetPublishInterval()
	-- Scale publish interval from 1.5 to 2.5 based on party size, half that for tanks
	-- We'll be at 1.5 sec for 0-5 party size, scale from 1.5 to 2.5 for 6-25 players, and stay at 2.5 for > 20 players
	-- This means that we'll transmit as much as 40% less data in a raid
	local playerClass = playerClass or select(2, UnitClass("player"))
	local partyNum = math_max(0, (self.currentPartySize or 0) - 5)
	local interval = math_min(2.5, 1.5 + (1 * (partyNum / 20)))

	-- Make tanks update more often
	if playerClass == "WARRIOR" or playerClass == "DRUID" or playerClass == "PALADIN" then
		interval = interval * 0.5
	end
	return interval
end

local function outOfDateFunc()
	_callbacks:Fire("OutOfDateNotice", ThreatLib.MINOR_VERSION, ThreatLib.latestSeenRevision, ThreatLib.latestSeenSender, ThreatLib.isIncompatible, ThreatLib.lastCompatible)
	timers.notifyOutOfDate = nil
end

-- #NODOC
function ThreatLib:CheckLatestRevision(revision, sender, lastCompatible)
	revision = tonumber(revision)
	lastCompatible = tonumber(lastCompatible) or 0
	if not revision then return end
	if revision > self.latestSeenRevision then
		self.latestSeenRevision = revision
		self.latestSeenSender = sender
		self.isIncompatible = (lastCompatible > self.MINOR_VERSION)
		self.lastCompatible = lastCompatible
		if timers.notifyOutOfDate then
			self:CancelTimer(timers.notifyOutOfDate, true)
		end
		timers.notifyOutOfDate = self:ScheduleTimer(outOfDateFunc, 0.5)
	end
end

-- #NODOC
function ThreatLib:PublishVersion(distribution, whisperTo)
	partyMemberAgents[UnitName("player")] = self.userAgent
	partyMemberRevisions[UnitName("player")] = self.MINOR_VERSION
	if distribution == "WHISPER" and whisperTo ~= nil then
		self:SendCommWhisper(distribution, whisperTo, "CLIENT_INFO", self.MINOR_VERSION, self.userAgent, LAST_BACKWARDS_COMPATIBLE_REVISION)
	else
		self:SendComm(distribution, "CLIENT_INFO", self.MINOR_VERSION, self.userAgent, LAST_BACKWARDS_COMPATIBLE_REVISION)
	end
end

------------------------------------------------------------------------
-- API Methods
------------------------------------------------------------------------

------------------------------------------------------------------------
-- :RequestThreatClear()
-- Notes:
-- Executes a raid-wide threat wipe
-- Must have privileges to execute this; you can clear your own, but other
-- clients are going to verify that you're allowed to do this
------------------------------------------------------------------------
function ThreatLib:RequestThreatClear()
	if self:IsGroupOfficer("player") then
		self:Debug("We're an officer - sending threat clear request and wiping our own threat.")
		self:SendComm(self:GroupDistribution(), "WIPE_ALL_THREAT")
	else
		self:Debug("We aren't an officer - can't send clear request!")
	--	DEFAULT_CHAT_FRAME:AddMessage(("|cffffff7f%s|r - %s"):format(MAJOR_VERSION, L["You must be a raid officer or the raid leader to request a threat list clear."]))
	end
	self.OnCommReceive.WIPE_ALL_THREAT(self, "player", self:GroupDistribution())
end

------------------------------------------------------------------------
-- :GetThreat("playerName", "targetName" or "targetHash")
-- Arguments: 
--  string - Name of the player or pet to get threat for
--  string - Name or hash of the target to get threat on
-- Notes:
-- Returns a float corresponding to the given player or pet's threat level on the given target
------------------------------------------------------------------------
function ThreatLib:GetThreat(player_guid, target_guid)
	local data = threatTargets[player_guid]
	if not data then
		return 0
	end
	return math_max(0, data[target_guid] or 0)
end

--[[------------------------------------------------------------
Arguments:
	string - player name to get cumulative threat for
Returns:
	integer - this player's cumulative threat in the encounter, suitable for publishing to KTM or similar
--------------------------------------------------------------]]
function ThreatLib:GetCumulativeThreat()
	local data = threatTargets[UnitGUID("player")]
	if not data then
		return 0
	end
	local totalThreat = 0
	for k, v in pairs(data) do
		totalThreat = totalThreat + v
	end
	return math_max(0, totalThreat)
end

------------------------------------------------------------------------
-- :UnitInMeleeRange("unitID")
-- Arguments: 
--  string - UnitID to check melee range for
-- Notes:
-- Returns true if the unit is within 10 yards
------------------------------------------------------------------------
function ThreatLib:UnitInMeleeRange(unitID)
	return UnitExists(unitID) and UnitIsVisible(unitID) and CheckInteractDistance(unitID, 3)
end

------------------------------------------------------------------------
-- :EncounterMobs()
-- Arguments: none
-- Notes:
-- Returns the number of known alive mobs in the current encounter.
-- Not generally needed by GUIs; may be needed by Class core
------------------------------------------------------------------------
function ThreatLib:EncounterMobs()
	-- TODO: Re-enable mob count
	return math_max(1, self:GetModule("Player"):NumMobs())
end

------------------------------------------------------------------------
-- :IterateGroupThreatForTarget(target_guid)
-- Arguments: int - GUID of the target to iterate threat on
-- Notes:
-- Returns a list of all group members and their threat levels on the given
-- mob, sorted descending by threat value
------------------------------------------------------------------------
do
	local sortThreatDesc_values
	local function sortThreatDesc(alpha, bravo)
		return sortThreatDesc_values[alpha] > sortThreatDesc_values[bravo]
	end

	local function threatIter(t, key)
		if not t then return nil end
		local n = t.n + 1
		local k = t[n]
		if k == nil then
			del(t.values)
			del(t)
			return nil
		end
		t.n = n
		return k, t.values[k]
	end

	function ThreatLib:IterateGroupThreatForTarget(target_guid)
		local results = new()
		local t = new()
		for k, v in pairs(threatTargets) do
			t[#t + 1] = k
			results[k] = v[target_guid] or 0
		end
		sortThreatDesc_values = results
		table_sort(t, sortThreatDesc)
		sortThreatDesc_values = nil
		t.values = results
		t.n = 0
		return threatIter, t, nil
	end

	function ThreatLib:IteratePlayerThreat(player_guid)
		if not threatTargets[player_guid] then
			return threatIter, nil, nil
		end

		local results = new()
		local t = new()
		for k, v in pairs(threatTargets[player_guid]) do
			t[#t + 1] = k
			results[k] = v
		end
		sortThreatDesc_values = results
		table_sort(t, sortThreatDesc)
		sortThreatDesc_values = nil
		t.values = results
		t.n = 0
		return threatIter, t, nil
	end
end

------------------------------------------------------------------------
-- :GetMaxThreatOnTarget("unitGUID")
-- Arguments: string - GUID of the target to get max threat one.
-- Notes:
-- Returns the maximum threat value and the GUID of the player with the maximum threat
-- on the given target
------------------------------------------------------------------------
function ThreatLib:GetMaxThreatOnTarget(target_guid)
	local maxVal = 0
	local maxGUID = nil
	for k in pairs(threatTargets) do
		local v = self:GetThreat(k, target_guid)
		if v > maxVal then
			maxVal = v
			maxGUID = k
		end
	end
	return maxVal, maxGUID
end

do
	local function getSecondThreat(self, guid)
		local firstVal = 0
		local firstGUID = nil
		local secondVal = 0
		local secondGUID = nil
		for k in pairs(threatTargets) do
			local v = self:GetThreat(k, guid)
			if v > firstVal then
				secondVal = firstVal
				secondGUID = firstGUID
				firstVal = v
				firstGUID = k
			elseif v > secondVal then
				secondVal = v
				secondGUID = k
			end
		end
		return secondGUID, secondVal
	end

	local sortThreatDesc_values
	local function sortThreatDesc(alpha, bravo)
		return sortThreatDesc_values[alpha] > sortThreatDesc_values[bravo]
	end

	function ThreatLib:GetPlayerAtPosition(guid, position)
		if not guid or type(guid) ~= "string" or not position or type(position) ~= "number" or position < 1 then
			return nil, nil
		end
		if position == 1 then
			local g, t = self:GetMaxThreatOnTarget(guid)
			return t, g
		elseif position == 2 then
			return getSecondThreat(self, guid)
		end
		local results = new()
		local t = new()
		for playerGuid, v in pairs(threatTargets) do
			t[#t + 1] = playerGuid
			results[playerGuid] = v[guid] or 0
		end
		sortThreatDesc_values = results
		table_sort(t, sortThreatDesc)
		sortThreatDesc_values = nil
		local playerGuid, threat = t[position], nil
		if playerGuid then
			threat = threatTargets[playerGuid][guid] or 0
		end
		t = del(t)
		results = del(results)
		return playerGuid, threat
	end
end

------------------------------------------------------------------------
-- :SendThreatTo("GUIDOfGroupMember", "enemyGUID", threatValue)
-- Arguments:
--   string - guid of the group member to send threat to
--   string - guid of the enemy to send threat for
--   float  - amount of threat to send
-- Notes:
-- Sends a given amount of threat to a group member. Used for Misdirection.
-- Not needed by GUIs.
------------------------------------------------------------------------
function ThreatLib:SendThreatTo(targetPlayer, targetEnemy, threat)
	if type(targetPlayer) ~= "string" then
		error(("Bad argument #2 to `SendThreatTo`. expected %q, got %q (%s)"):format("string", type(targetPlayer), tostring(targetPlayer)), 2)
	end

	if UnitExists("pet") and UnitGUID("pet") == targetPlayer then
		ThreatLib:Debug("Sending threat to pet")
		self:GetModule("Pet"):AddTargetThreat(targetEnemy, threat)
	else
		ThreatLib:Debug("Sending threat to player, %s on %s to %s", threat, targetEnemy, targetPlayer)
		self:SendComm(self:GroupDistribution(), "MISDIRECT_THREAT", targetPlayer, targetEnemy, threat)
	end
end

------------------------------------------------------------------------
-- :WipeRaidThreatOnMob("mobID")
-- Arguments:
--   integer - NPC ID of the enemy to ask the group to wipe threat on
-- Notes:
-- Sends a comm message to the group instructing them to wipe their threat
-- levels on a specific mob. This is not protected as it needs to be able to 
-- be executed by anyone who sees the relevant events.
--
-- KTM protects this by requiring 2 or more people to send the event before
-- it is processed.
------------------------------------------------------------------------
function ThreatLib:WipeRaidThreatOnMob(mob_id)
	self:Debug("Wiping threat on %s", mob_id)
	self:SendComm(self:GroupDistribution(), "RAID_MOB_THREAT_WIPE", mob_id)
	self.OnCommReceive.RAID_MOB_THREAT_WIPE(self, nil, nil, mob_id)
end

------------------------------------------------------------------------
-- :IsUsingForeignThreatSource("partyMemberName")
-- Arguments:
--   string - name of the party member to check
-- Notes:
-- Returns a boolean indicating whether the given party member is using ThreatLib (false)
-- or an external source like KTM (true)
------------------------------------------------------------------------
function ThreatLib:IsUsingForeignThreatSource(partyMember)
	local partyUnit = partyUnits[partyMember]
	if not partyUnit then
		return true
	end
	partyUnit = partyUnit:gsub("pet", "")
	if partyUnit == "player" or partyUnit == "" then
		return false
	end

	local partyMemberName = UnitName(partyUnit)

	local r = not partyMemberRevisions[partyMemberName]
	return r
end

------------------------------------------------------------------------
-- :IsOutOfDate(["partyMemberName"])
-- Arguments:
--   string - name of the party member to check
-- Returns:
--   * boolean - whether the given party member is using an out-of-date ThreatLib or not
--   * integer - our version number
--   * integer - the latest revision number we've seen
--   * string  - the name of the person holding the latest revision
------------------------------------------------------------------------
function ThreatLib:IsOutOfDate(name)
	if name == nil or name == self.playerName then
		if self.latestSeenSender then
			return true, self.MINOR_VERSION, self.latestSeenRevision, self.latestSeenSender
		else
			return false, self.MINOR_VERSION, self.MINOR_VERSION, self.playerName
		end
	elseif not partyMemberRevisions[name] then
		return true, 0, self.latestSeenRevision, self.latestSeenSender or self.playerName
	else
		local num = partyMemberRevisions[name]
		if num < self.latestSeenRevision then
			return true, num, self.latestSeenRevision, self.latestSeenSender or self.playerName
		else
			return false, num, num, name
		end
	end
end

------------------------------------------------------------------------
-- :RequestActiveOnSolo([value])
-- Arguments:
--   boolean - whether to be activated. Default: true
-- Notes:
--   This is meant to be called by a GUI to allow for testing in solo situations.
------------------------------------------------------------------------
function ThreatLib:RequestActiveOnSolo(value)
	if value == nil then
		value = true
	end
	self.alwaysRunOnSolo = value
	self:PLAYER_ENTERING_WORLD()
end

function ThreatLib:IsCompatible(user)
	if self.partyMemberAgents[user] == MAJOR_VERSION then
		if (self.partyMemberRevisions[user] or 0) >= LAST_BACKWARDS_COMPATIBLE_REVISION then
			return true
		end
		return false
	end
	return true
end

------------------------------------------------------------------------
-- :IsActive()
-- Returns:
--   boolean - whether ThreatClassic-1.0 is currently activated.
------------------------------------------------------------------------
function ThreatLib:IsActive()
	return self.running or false
end

------------------------------------------------------------------------
-- :GetThreatStatusColor("unit", "mob")
-- Arguments: 
--  integer - the threat status value to get colors for.
-- Returns:
--  float - a value between 0 and 1 for the red content of the color
--  float - a value between 0 and 1 for the green content of the color
--  float - a value between 0 and 1 for the blue content of the color
------------------------------------------------------------------------
local threatColors = {
	[0] = {0.69, 0.69, 0.69},
	[1] = {1, 1, 0.47},
	[2] = {1, 0.6, 0},
	[3] = {1, 0, 0}
}

function ThreatLib:GetThreatStatusColor(statusIndex)
	if not (type(statusIndex) == "number" and statusIndex >= 0 and statusIndex < 4) then
		statusIndex = 0
	end

	return threatColors[statusIndex][1], threatColors[statusIndex][2], threatColors[statusIndex][3]
end

------------------------------------------------------------------------
-- :UnitDetailedThreatSituation("unit", "mob")
-- Arguments: 
--  string - unitID of the unit to get threat information for.
--  string - unitID of the target unit to reference.
-- Returns:
--  integer - returns 1 if the unit is primary threat target of the mob (is tanking), or nil otherwise.
--  integer - returns the threat status for the unit on the mob, or nil if unit is not on mob's threat table. (3 = securely tanking, 2 = insecurely tanking, 1 = not tanking but higher threat than tank, 0 = not tanking and lower threat than tank)
--  float - returns the unit's threat on the mob as a percentage of the amount required to pull aggro, scaled according to the unit's range from the mob. At 100 the unit will pull aggro. Returns 100 if the unit is tanking and nil if the unit is not on the mob's threat list.
--  float - returns the unit's threat as a percentage of the tank's current threat. Returns nil if the unit is not on the mob's threat list.
--  float - returns the unit's total threat on the mob.
------------------------------------------------------------------------
function ThreatLib:UnitDetailedThreatSituation(unit, target)
	local isTanking, threatStatus, threatPercent, rawThreatPercent, threatValue = nil, 0, nil, nil, 0
	if not UnitExists(unit) or not UnitExists(target) then
		return isTanking, threatStatus, threatPercent, rawThreatPercent, threatValue
	end

	local unitGUID, targetGUID = UnitGUID(unit), UnitGUID(target)
	local threatValue = self:GetThreat(unitGUID, targetGUID) or 0
	if threatValue == 0 then
		return isTanking, threatStatus, threatPercent, rawThreatPercent, threatValue
	end

	local targetTarget = target .. "target"
	local targetTargetGUID = UnitGUID(targetTarget)
	local targetTargetVal = self:GetThreat(unitGUID, targetTargetGUID) or 0

	local isPlayer
	if unit == "player" then isPlayer = true end
	local class = select(2, UnitClass(unit))

	local aggroMod = 1.3
	if isPlayer and self:UnitInMeleeRange(targetGUID) or (not isPlayer and (class == "ROGUE" or class == "WARRIOR")) or (strsplit("-", unitGUID) == "Pet" and class ~= "MAGE") then
		aggroMod = 1.1
	end

	local maxVal, maxGUID = self:GetMaxThreatOnTarget(targetGUID)

	local aggroVal = 0
	if targetTargetVal >= maxVal / aggroMod then
		aggroVal = targetTargetVal
	else
		aggroVal = maxVal
	end

	local hasTarget = UnitExists(target .. "target")

	if threatValue >= aggroVal then
		if UnitIsUnit(unit, targetTarget) then
			isTanking = 1
			if unitGUID == maxGUID then
				threatStatus = 3
			else
				threatStatus = 2
			end
		else
			threatStatus = 1
		end
	end

	rawThreatPercent = threatValue / aggroVal * 100

	if isTanking or (not hasTarget and threatStatus ~= 0 ) then
		threatPercent = 100
	else
		threatPercent = rawThreatPercent / aggroMod
	end

	threatValue = math_floor(threatValue)

	return isTanking, threatStatus, threatPercent, rawThreatPercent, threatValue
end

------------------------------------------------------------------------
-- :UnitThreatSituation("unit", "mob")
-- Arguments: 
--  string - unitID of the unit to get threat information for.
--  string - unitID of the target unit to reference.
-- Returns:
--  integer - returns the threat status for the unit on the mob, or nil if unit is not on mob's threat table. (3 = securely tanking, 2 = insecurely tanking, 1 = not tanking but higher threat than tank, 0 = not tanking and lower threat than tank)
------------------------------------------------------------------------
function ThreatLib:UnitThreatSituation(unit, target)
	if not UnitExists(unit) or not UnitExists(target) then return 0 end
	return select(2, self:UnitDetailedThreatSituation(unit, target))
end

end
