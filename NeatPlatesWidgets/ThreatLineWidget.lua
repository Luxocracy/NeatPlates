
local GetRelativeThreat = NeatPlatesUtility.GetRelativeThreat
local GetGroupInfo = NeatPlatesUtility.GetGroupInfo


------------------------
-- Threat Function
------------------------

-- local function GetGroupThreatLeader(enemyUnitid)
-- 	-- tempUnitid, tempThreat
-- 	local friendlyUnitid, friendlyThreatval = nil, 0
-- 	local tempUnitid, tempThreat
-- 	local groupType, groupSize, startAt = nil, nil, 1

-- 	-- Get Group Type
-- 	if UnitInRaid("player") then
-- 		groupType = "raid"
-- 		groupSize = NeatPlatesUtility:GetNumRaidMembers()
-- 		startAt = 2
-- 	elseif UnitInParty("player") then
-- 		groupType = "party"
-- 		groupSize = NeatPlatesUtility:GetNumPartyMembers()
-- 	else
-- 		groupType = nil
-- 	end

-- 	-- Cycle through Party/Raid, picking highest threat holder
-- 	if groupType then
-- 		for allyIndex = startAt, groupSize do
-- 			tempUnitid = groupType..allyIndex
-- 			tempThreat = select(3, UnitDetailedThreatSituation(tempUnitid, enemyUnitid))
-- 			if tempThreat and tempThreat > friendlyThreatval then
-- 				friendlyThreatval = tempThreat
-- 				friendlyUnitid = tempUnitid
-- 			end
-- 		end
-- 	end

-- 	-- Request Pet Threat (if possible)
-- 	if HasPetUI() and UnitExists("pet") then
-- 		tempThreat = select(3, UnitDetailedThreatSituation("pet", enemyUnitid)) or 0
-- 		if tempThreat > friendlyThreatval then
-- 			friendlyThreatval = tempThreat
-- 			friendlyUnitid = "pet"
-- 		end
-- 	end

-- 	return friendlyUnitid, friendlyThreatval

-- end


-- local function GetRelativeThreat(enemyUnitid)		-- 'enemyUnitid' is a target/enemy
-- 	if not UnitExists(enemyUnitid) then return end

-- 	local playerIsTanking, playerSituation, playerThreat = UnitDetailedThreatSituation("player", enemyUnitid)
-- 	if not playerThreat then return end

-- 	local friendlyUnitid, friendlyThreat = GetGroupThreatLeader(enemyUnitid)

-- 	-- Return the appropriate value
-- 	if playerThreat and friendlyThreat and friendlyUnitid then
-- 		if playerThreat >= 100 then 	-- The enemy is attacking you. You are tanking. 	Returns: 1. Your threat, plus your lead over the next highest person, 2. Your Unitid (since you're tanking)
-- 			return tonumber(playerThreat + (100-friendlyThreat)), "player"
-- 		else 	-- The enemy is not attacking you.  Returns: 1. Your scaled threat percent, 2. Who is On Top
-- 			return tonumber(playerThreat), friendlyUnitid
-- 		end
-- 	end

-- end


---------------------------------------------------------------------
local font = NeatPlatesLocalizedThreatFont
local art = "Interface\\Addons\\NeatPlatesWidgets\\ThreatLine\\ThreatLineUnified"
local artCoordinates = {
	--None = 		{.75,1,0,1},
	Line = 		{0,.2,0,1},
	Right = 	{.5,.75,0,1},
	Left = 		{.25,.5,0,1},
}

local threatcolor

---------------------------------------------------------------------


local WidgetList = {}

local testMode = false

-- Graphics Update
local function UpdateThreatLine(frame, unitid)
	local maxwidth = 50
	--local maxwidth = frame._MaximumWidth
	local length = 0
	local anchor = "RIGHT"
	local threat, targetOf  = GetRelativeThreat(unitid) -- ;if testMode then threat, targetOf =  .00000000000000000000000000000000001, "player" end

	if not(threat and targetOf) then frame:_Hide(); return end

	if threat >= 0 then

		-- Get Positions and Size
		if threat >= 100 then						-- While tanking
			length = maxwidth * ((threat - 100)/100)
			threatcolor = frame._HighColor
			anchor = "LEFT"
		else 										-- While NOT tanking
			length = maxwidth * ((100 - threat)/150)
			threatcolor = frame._LowColor
		end

		frame.Line:ClearAllPoints()
		frame.Line:SetWidth( max(1, min( maxwidth, length)))
		frame.Line:SetPoint(anchor, frame, "CENTER")

		if targetOf and targetOf ~= "player" then
			if UnitIsUnit(targetOf, "pet")
				or GetPartyAssignment("MAINTANK", targetOf) then
					threatcolor = frame._TankedColor
			end

			frame.TargetText:SetText(UnitName(targetOf))								-- TP 6.1
			frame.TargetText:SetTextColor(threatcolor.r, threatcolor.g, threatcolor.b)		-- TP 6.1
		else frame.TargetText:SetText("") end

		-- Set Colors
		frame.Left:SetVertexColor(threatcolor.r, threatcolor.g, threatcolor.b)
		frame.Line:SetVertexColor(threatcolor.r, threatcolor.g, threatcolor.b)
		frame.Right:SetVertexColor(threatcolor.r, threatcolor.g, threatcolor.b)
		-- Set Fading
		frame:Show()
		--frame.FadeTime = GetTime() + 2
		--frame:FadeLater(frame.FadeTime)
	else frame:_Hide() end
end

local function UpdateWidget(frame)
	local unitid = frame.unitid

	UpdateThreatLine(frame, unitid)
end

local function UpdateWidgetTarget(frame)
	if UnitExists("target") then
		UpdateThreatLine(frame, "target")
	else
		frame:Hide()
	end
end

local function UpdateWidgetContext(frame, unit)
	local unitid = unit.unitid

	if unit.reaction == "FRIENDLY" or (not InCombatLockdown()) or (not (UnitInParty("player") or HasPetUI())) then
		frame:_Hide()
		return
	end

	frame.unitid = unitid

	-- Make it self-aware
	frame:UnregisterAllEvents()
	--frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
	--frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	frame:RegisterUnitEvent("UNIT_HEALTH", unitid)
	frame:SetScript("OnEvent", UpdateWidget);

	UpdateThreatLine(frame, unitid)
end

local function ClearWidgetContext(frame)
	frame:UnregisterAllEvents()
	frame:SetScript("OnEvent", nil);
end

-- GUID/UnitID Lookup List
local TargetList = {}
local updateCap = 1
local lastUpdate = 0

-- Widget Creation
local function CreateWidgetFrame(extended)
	--local parent = extended.widgetFrame
	local parent = extended
	-- Required Widget Code
	local frame = CreateFrame("Frame", nil, parent)
	frame:Hide()

	-- Custom Code
		frame:SetWidth(100)
		frame:SetHeight(24)
		-- Threat Line
		frame.Line = frame:CreateTexture(nil, "OVERLAY")
		frame.Line:SetTexture(art)
		frame.Line:SetTexCoord(unpack(artCoordinates["Line"]))
		frame.Line:SetHeight(32)
		frame.Line:SetWidth(50)		-- Set initial length
		frame._MaximumWidth = 50
		-- Left
		frame.Left = frame:CreateTexture(nil, "OVERLAY")
		frame.Left:SetTexture(art)
		frame.Left:SetTexCoord(unpack(artCoordinates["Left"]))
		frame.Left:SetPoint("RIGHT", frame.Line, "LEFT" )
		frame.Left:SetWidth(32)
		frame.Left:SetHeight(32)
		-- Right
		frame.Right = frame:CreateTexture(nil, "OVERLAY")
		frame.Right:SetTexture(art)
		frame.Right:SetTexCoord(unpack(artCoordinates["Right"]))
		frame.Right:SetPoint("LEFT", frame.Line, "RIGHT" )
		frame.Right:SetWidth(32)
		frame.Right:SetHeight(32)

		-- Target-Of Text
		frame.TargetText = frame:CreateFontString(nil, "OVERLAY")
		frame.TargetText:SetFont(font, 8, "OUTLINE")
		--frame.TargetText:SetShadowOffset(1, -1)
		--frame.TargetText:SetShadowColor(0,0,0,1)
		frame.TargetText:SetWidth(50)
		frame.TargetText:SetHeight(15)
		--[[ Text on top
		frame.TargetText:SetJustifyH("CENTER")
		frame.TargetText:SetPoint("CENTER",frame.Line,"LEFT", -3, 7)	-- was y=11
		--]]
		-- [[ Text on side
		frame.TargetText:SetJustifyH("RIGHT")
		frame.TargetText:SetPoint("RIGHT",frame.Line,"LEFT", -5, 2)
		--]]
		-- Mechanics/Setup
		frame.FadeLater = FadeLater
		frame.FadeTime = 0
		frame:Hide()
		frame.ThreatMax, frame.ThreatMin, frame.UseRawValues = 1, 0, false

		-- Customization
		frame._LowColor = { r = .14, g = .75, b = 1}
		frame._TankedColor = { r = 0, g = .9, b = .1}
		frame._HighColor = {r = 1, g = .67, b = .14}
		frame._ShowTargetOf = true
	-- End Custom Code

	-- Required Widget Code
	frame.UpdateContext = UpdateWidgetContext
	frame.Update = UpdateWidgetTarget
	frame._Hide = frame.Hide
	frame.Hide = function() ClearWidgetContext(frame); frame:_Hide() end
	--if not isEnabled then EnableWatcherFrame(true) end
	return frame
end

NeatPlatesWidgets.CreateThreatLineWidget = CreateWidgetFrame


