---------------
-- Threat Percentage Widget
---------------

local font = "FONTS\\arialn.ttf"
local GetRelativeThreat = NeatPlatesUtility.GetRelativeThreat

local function UpdateThreatPercentageWidget(self, unit, showFriendly)
	local threat, targetOf = GetRelativeThreat(unit)
	local threatPercent

	if threat and threat > 0 then
		threatPercent = math.floor(threat)..'%'
		self.Text:SetText(threatPercent)
		self:Show()
	else
		self.Text:SetText("")
		self:Hide()
	end

end

local function UpdateWidget(frame)
	local unitid = frame.unitid

	UpdateThreatPercentageWidget(frame, unitid)
end

local function UpdateWidgetContext(frame, unit)
	local unitid = unit.unitid

	if unit.reaction == "FRIENDLY" or (not InCombatLockdown()) or (not (UnitInParty("player") or HasPetUI())) then
		frame:Hide()
		return
	end

	frame.unitid = unitid

	-- Make it self-aware
	frame:UnregisterAllEvents()
	frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
	frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	frame:RegisterUnitEvent("UNIT_HEALTH", unitid)
	frame:SetScript("OnEvent", UpdateWidget);

	UpdateThreatPercentageWidget(frame, unitid)
end

local function CreateThreatPercentageWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(32); frame:SetHeight(12)

	-- frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	-- frame.Icon:SetAllPoints(frame)

	frame.Text = frame:CreateFontString(nil, "OVERLAY")
	frame.Text:SetFont(font, 10, "OUTLINE")
	frame.Text:SetAllPoints(frame)
	frame.Text:SetJustifyH("CENTER")

	frame:Hide()
	frame.Update = UpdateWidget
	frame.UpdateContext = UpdateWidgetContext
	return frame
end

NeatPlatesWidgets.CreateThreatPercentageWidget = CreateThreatPercentageWidget


