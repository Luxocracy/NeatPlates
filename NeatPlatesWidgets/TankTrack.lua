
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

local cachedAura = false
local cachedRole = false

local function IsEnemyTanked(unit)
	local unitid = unit.unitid
	local targetOf = unitid.."target"
	-- GetPartyAssignment("MAINTANK", raidid)
	local targetIsTank = UnitIsUnit(targetOf, "pet") or ("TANK" ==  UnitGroupRolesAssigned(targetOf))

	return targetIsTank
end

local function IsPlayerTank()
	return playerTankRole
end

local function UpdatePlayerRole()
	local playerTankAura = false

	-- Look at the Player's Specialization
	local specializationIndex = tonumber(GetSpecialization())

	if specializationIndex and GetSpecializationRole(specializationIndex) == "TANK" then
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

			local isTank = GetPartyAssignment("MAINTANK", raidid) or ("TANK" == UnitGroupRolesAssigned(raidid))

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
	UpdateGroupRoles()
	UpdatePlayerRole()
end

if not TankWatcher then TankWatcher = CreateFrame("Frame") end
TankWatcher:SetScript("OnEvent", TankWatcherEvents)
TankWatcher:RegisterEvent("GROUP_ROSTER_UPDATE")
TankWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
TankWatcher:RegisterEvent("UNIT_PET")
TankWatcher:RegisterEvent("PET_BAR_UPDATE_USABLE")
TankWatcher:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
TankWatcher:RegisterEvent("PLAYER_TALENT_UPDATE")
TankWatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM")


NeatPlatesWidgets.IsEnemyTanked = IsEnemyTanked
NeatPlatesWidgets.IsPlayerTank = IsPlayerTank


--[[
local function Dummy() end
NeatPlatesWidgets.EnableTankWatch = Dummy
NeatPlatesWidgets.DisableTankWatch = Dummy
--]]





