-- ThreatLib by @Ipse#1953
local major = "ClassicThreat"
local minor = 1
assert(LibStub, format("%s requires LibStub.", major))
local Lib = LibStub:NewLibrary(major, minor)
if not Lib then return end
local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")
Lib.callbacks = Lib.callbacks or CallbackHandler:New(Lib)
local threatEvents = Lib.callbacks
-- bunch of frames
-- combatlog frame
if not Lib.combatParser then
	Lib.combatParser = CreateFrame("Frame")
end
-- locals
local tonumber, strsplit = _G.tonumber, _G.strsplit
local locale = GetLocale()
Lib.combatParser:UnregisterAllEvents()
Lib.combatParser:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
-- Items and talent check frame
if not Lib.talentItemUpdater then
    Lib.talentItemUpdater = CreateFrame("Frame")
end
Lib.talentItemUpdater:UnregisterAllEvents()
Lib.talentItemUpdater:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
Lib.talentItemUpdater:RegisterEvent("CHARACTER_POINTS_CHANGED")
Lib.talentItemUpdater:RegisterEvent("SPELLS_CHANGED")
-- Buff and Stance checker frame
if not Lib.auraChecker then
	Lib.auraChecker = CreateFrame("Frame")
end
Lib.auraChecker:UnregisterAllEvents()
Lib.auraChecker:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
Lib.auraChecker:RegisterEvent("PLAYER_ENTERING_WORLD")
Lib.auraChecker:RegisterEvent("UNIT_AURA")
-- Messager frame
if not Lib.groupMessageFrame then
    Lib.groupMessageFrame = CreateFrame("Frame")
end
Lib.groupMessageFrame:UnregisterAllEvents()
Lib.groupMessageFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
Lib.groupMessageFrame:RegisterEvent("CHAT_MSG_ADDON")
Lib.groupMessageFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- Threat info tables
Lib.GUIDThreatTable = {}
Lib.GUIDThreatTableByOrder = {}
-- Threat changes table
Lib.myThreatMulti = {
	["global"] = 1,
	["stance"] = 1,
	["spell"] = 1,
	["aura"] = 1,
	["healing"] = 0.5,
	["melee"] = 1.1,
	["range"] = 1.3,
	["rage"] = 5.0,
	["energy"] = 5.0,
	["mana"] = 0.5,
	["school"] = {
		[1] = 1, -- physical
		[2] = 1, -- holy
		[4] = 1, -- fire
		[8] = 1, -- nature
		[16] = 1, -- frost
		[32] = 1, -- shadow
		[64] = 1, -- arcane
	},
	["spells"] = {},
	["auraChanges"] = {},
	["stanceChanges"] = {}
}
-- List of stance modifiers
local stanceList = {
	["WARRIOR"] = {
		[1] = 0.8,
		[2] = 1.3,
		[3] = 0.8,
	},
	["DRUID"] = {
		[1] = 1.3,
		[3] = 0.8,
	}
}
local tauntSpells = {
    ["Taunt"] = true, -- Taunt - 355
    ["Growl"] = true, -- Growl (Druid) -- 6795
	-- pet growl 2649, 14916, 14917, 14918, 14919, 14920, 14921
}
local auraAppliedSpells = {
	["Holy Shield"] = 40,
	["Demoralizing Shout"] = 43,
}
local iterateGroupMembers = function()
	local unit = IsInRaid() and 'raid' or 'party'
	local numGroupMembers = unit == 'party' and GetNumSubgroupMembers() or GetNumGroupMembers()
	local i = unit == 'party' and 0 or 1
	return
	function()
	local ret
		if i == 0 and unit == 'party' then
			ret = 'player'
		elseif i <= numGroupMembers and i > 0 then
			ret = unit .. i
		end
		i = i + 1
		return ret
	end
end
local groupMessageFunction = function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, message = ...
		if prefix == "THREATLIB" then
			local sourceGUID, threatEvent, threat, destGUID = strsplit(":", message)
			threat = tonumber(threat)
			if threatEvent == "THREAT_RECALC" and sourceGUID ~= UnitGUID("player") then
				if Lib.groupMemberTable[sourceGUID] then
					if not Lib.GUIDThreatTable[destGUID] then
						Lib.GUIDThreatTable[destGUID] = {}
					end
					if not Lib.GUIDThreatTable[destGUID][sourceGUID] then
						Lib.GUIDThreatTable[destGUID][sourceGUID] = 0
					end
					Lib.GUIDThreatTable[destGUID][sourceGUID] = Lib.GUIDThreatTable[destGUID][sourceGUID] + threat
				--MyLib.callbacks:Fire("THREATLIBUPDATE", sourceGUID, destGUID)
				end
			end
		end
	end
end
local threatCalculation = function(source, dest, spell, school, value, isHeal)
	threatEvents:Fire("UNIT_THREAT_LIST_UPDATE")
	threatEvents:Fire("UNIT_THREAT_SITUATION_UPDATE")
	return value
end
local tauntCalculation = function(source, dest)
	local mobThreatTable = Lib.GUIDThreatTable[dest]
	local maxThreat = 0
	for k,v in pairs(mobThreatTable) do
		if v > maxThreat then
			maxThreat = v
		end
	end
	mobThreatTable[source] = maxThreat
end
local getUnitThreat = function(unit, mob)
	if not Lib.GUIDThreatTable[mob] then
		Lib.GUIDThreatTable[mob] = {}
	end
	--local mobThreatTable = Lib.GUIDThreatTable[mob]
	if not Lib.GUIDThreatTable[mob][unit] then
		Lib.GUIDThreatTable[mob][unit] = 0
	end
	return Lib.GUIDThreatTable[mob][unit]
end
local threatListUpdate = function(...)
	local combatLogInfo = {CombatLogGetCurrentEventInfo()}
	if combatLogInfo[4] ~= UnitGUID("player") then return end 
	if (combatLogInfo[2] == "SPELL_AURA_REFRESH" or combatLogInfo[2] == "SPELL_AURA_APPLIED") then
		local spellName = combatLogInfo[13]
        if auraAppliedSpells[combatLogInfo[13]] then
            local playerThreat = getUnitThreat(combatLogInfo[4], combatLogInfo[8])
            local threatIncrease = threatCalculation(combatLogInfo[4], combatLogInfo[8], combatLogInfo[12], combatLogInfo[13], auraAppliedSpells[combatLogInfo[12]])
            Lib.GUIDThreatTable[combatLogInfo[8]][combatLogInfo[4]] = playerThreat + threatIncrease
        end
	elseif combatLogInfo[2] == "SPELL_CAST_SUCCESS" then
		local spellName = combatLogInfo[13]
		if tauntSpells[Lib.locales[locale]["spell"][spellName]] then -- this spell is taunt
			tauntCalculation(combatLogInfo[4], combatLogInfo[8])
		end
	elseif (combatLogInfo[2] == "SPELL_ENERGIZE" or combatLogInfo[2] == "SPELL_PERIODIC_ENERGIZE") then
		for mobs, lists in pairs(Lib.GUIDThreatTable) do
			if lists[combatLogInfo[4]] then
				lists[combatLogInfo[4]] = lists[combatLogInfo[4]]
			end
		end
	elseif (combatLogInfo[2] == "SPELL_HEAL" or combatLogInfo[2] == "SPELL_PERIODIC_HEAL") then
		local healValue = combatLogInfo[15] - combatLogInfo[16]
		local mobCount = 0
		local mobList = {}
		for mobs, lists in pairs(Lib.GUIDThreatTable) do
			if lists[combatLogInfo[8]] then
				mobList[mobs] = true
				mobCount = mobCount + 1
			end
		end
		for mobGUID,_ in pairs(mobList) do
			local playerThreat = getUnitThreat(combatLogInfo[4], mobGUID)
			local threatIncrease = threatCalculation(combatLogInfo[4], mobGUID, combatLogInfo[12], combatLogInfo[13], healValue/mobCount, true)
			Lib.GUIDThreatTable[mobGUID][combatLogInfo[4]] = playerThreat + threatIncrease
		end
	elseif combatLogInfo[2] == "SWING_DAMAGE" then
		local playerThreat = getUnitThreat(combatLogInfo[4], combatLogInfo[8])
		local threatIncrease = threatCalculation(combatLogInfo[4], combatLogInfo[8], "swing", combatLogInfo[14], combatLogInfo[12])
		Lib.GUIDThreatTable[combatLogInfo[8]][combatLogInfo[4]] = playerThreat + threatIncrease
	elseif (combatLogInfo[2] == "SPELL_DAMAGE" or combatLogInfo[2] == "SPELL_LEECH"  or
	combatLogInfo[2] == "SPELL_DRAIN" or combatLogInfo[2] == "SPELL_PERIODIC_DAMAGE" or
	combatLogInfo[2] == "SPELL_PERIODIC_DRAIN" or combatLogInfo[2] == "SPELL_PERIODIC_LEECH" or combatLogInfo[2] == "RANGE_DAMAGE") then
		local playerThreat = getUnitThreat(combatLogInfo[4], combatLogInfo[8])
		local threatIncrease = threatCalculation(combatLogInfo[4], combatLogInfo[8], combatLogInfo[12], combatLogInfo[13], combatLogInfo[15])
		Lib.GUIDThreatTable[combatLogInfo[8]][combatLogInfo[4]] = playerThreat + threatIncrease
	elseif combatLogInfo[2] == "UNIT_DIED" then
		local unitType = strsplit("-", combatLogInfo[8])
		if unitType == "player" or unitType == "pet" then
			for mobs,lists in pairs(Lib.GUIDThreatTable) do
				if lists[combatLogInfo[8]] then 
					lists[combatLogInfo[8]] = nil
				end
			end
		elseif Lib.GUIDThreatTable[combatLogInfo[8]] then
			Lib.GUIDThreatTable[combatLogInfo[8]] = nil
		end
	end
end
Lib.DetailedThreatSituation = function(player, mob)
	local playerGUID, mobGUID = UnitGUID(player), UnitGUID(mob)
	local highestThreatGUID, secondThreatGUID = UnitGUID(player), UnitGUID(player)
	local threatPct, maxThreat, maxThreat2, threatValue, isTanking, rawThreatPct, status = 100, 0, 0, 0, 0, 0, 3
	local isMelee = false
	local unitType = strsplit("-", playerGUID)
	if UnitIsUnit(player, mob.."target") then
		isTanking = 1
	end
	if Lib.GUIDThreatTable[mobGUID] then
		for unit,threat in pairs(Lib.GUIDThreatTable[mobGUID]) do
			if threat > maxThreat then
				maxThreat2 = maxThreat
				maxThreat = threat
				secondThreatGUID = highestThreatGUID
				highestThreatGUID = unit
			end
			if unit == playerGUID then
				threatValue = threat
			end
		end
	else
		return
	end
	if maxThreat > 0 then
		rawThreatPct = threatValue/maxThreat
	end
	if unitType == "Pet" then
		isMelee = true
	else
		isMelee = IsItemInRange(8149, mob)
	end
	if maxThreat ~= threatValue and threatValue > 0 then
		if isMelee then
			threatPct = threatValue/(maxThreat*1.1)*100
		else
			threatPct = threatValue/(maxThreat*1.3)*100
		end
	elseif threatValue <= 0 then
		threatPct = 0
	end
	return isTanking, status, threatPct, rawThreatPct, threatValue
end
Lib.groupMessageFrame:SetScript("OnEvent", groupMessageFunction)
Lib.combatParser:SetScript("OnEvent", threatListUpdate)
--Lib.talentItemUpdater:SetScript("OnEvent", Lib.itemUpdateInfo)
--Lib.auraChecker:SetScript("OnEvent", checkPlayerBuffs)
C_ChatInfo.RegisterAddonMessagePrefix("THREATLIB")
