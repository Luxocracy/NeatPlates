
------------------------------
-- Tank Aura/Role Tracking
------------------------------

local GetGroupInfo = NeatPlatesUtility.GetGroupInfo

-- Interface Functions...
---------------------------
local RaidTankList = {}
local inRaid = false
local playerTankRole = false
local currentSpec = 0
local playerClass = select(2, UnitClass("player"))
local rfSpellId = 25780
local playerGUID = UnitGUID("player")

local cachedAura = false
local cachedRole = false
local TankWatcher

local function IsEnemyTanked(unit)
	local unitid = unit.unitid
	local targetOf = unitid.."target"
	-- GetPartyAssignment("MAINTANK", raidid)
	local targetIsTank = UnitIsUnit(targetOf, "pet")

	return targetIsTank
end

local function IsPlayerTank()
	return playerTankRole
end

local function UpdatePlayerRole(playerTankAura)
	if not playerTankAura then
		if playerClass == "WARRIOR" then
			playerTankAura = GetShapeshiftForm() == 2 or IsEquippedItemType("Shields") -- Defensive Stance or shield
		elseif playerClass == "DRUID" then
			playerTankAura = GetShapeshiftForm() == 1 -- Bear Form
		elseif playerClass == "PALADIN" then
			for i=1,40 do
			  local spellId = select(10, UnitBuff("player",i))
			  if spellId == rfSpellId then
			    playerTankAura = true
			  end
			end
		end
	end

	if playerTankAura then
		playerTankRole = true
	else
		playerTankRole = false
	end
end

------------------------------------------------------------------------
-- UpdateGroupRoles: Builds a list of tanks and squishies
------------------------------------------------------------------------

local function UpdateGroupRoles()

	RaidTankList = wipe(RaidTankList)
	-- If a player is in a dungeon, no need for multi-tanking
	if UnitInRaid("player") then
		inRaid = true

		local groupType, groupSize = GetGroupInfo()
		local raidIndex

		for raidIndex = 1, groupSize do
			local raidid = "raid"..tostring(raidIndex)
			local guid = UnitGUID(raidid)

			local isTank = GetPartyAssignment("MAINTANK", raidid)

			if isTank then
				RaidTankList[guid] = true
			end

		end

	-- If not in a raid, try to use guardian pet
	-- as a tank..
	else
		inRaid = false
		if HasPetUI("player") and UnitName("pet") then
			RaidTankList[UnitGUID("pet")] = true
		end
	end

end

local function TankWatcherEvents(self, event, ...)
	local tankAura = false
	local triggerUpdate = event ~= "COMBAT_LOG_EVENT_UNFILTERED"

	-- Check for Tank Aura application/removal
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _,event,_,sourceGUID,sourceName,sourceFlags,_,destGUID,destName,_,_,spellId,spellName = CombatLogGetCurrentEventInfo()
		if (event == "SPELL_AURA_REMOVED" or event == "SPELL_AURA_APPLIED") and sourceGUID == playerGUID and destGUID == playerGUID then
			spellId = select(7, GetSpellInfo(spellName))
			if spellId == rfSpellId then
				if event == "SPELL_AURA_APPLIED" then tankAura = true end
				triggerUpdate = true
			end
		end
	end

	if triggerUpdate then
		UpdateGroupRoles()
		UpdatePlayerRole(tankAura)
	end
end

if not TankWatcher then TankWatcher = CreateFrame("Frame") end
TankWatcher:SetScript("OnEvent", TankWatcherEvents)
TankWatcher:RegisterEvent("GROUP_ROSTER_UPDATE")
TankWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
TankWatcher:RegisterEvent("UNIT_PET")
TankWatcher:RegisterEvent("PET_BAR_UPDATE_USABLE")
TankWatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
TankWatcher:RegisterEvent("UNIT_INVENTORY_CHANGED")
if playerClass == "PALADIN" then
	TankWatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end


NeatPlatesWidgets.IsEnemyTanked = IsEnemyTanked
NeatPlatesWidgets.IsPlayerTank = IsPlayerTank


--[[
local function Dummy() end
NeatPlatesWidgets.EnableTankWatch = Dummy
NeatPlatesWidgets.DisableTankWatch = Dummy
--]]





