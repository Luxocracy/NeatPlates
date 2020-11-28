---------------
-- Threat Percentage Widget
---------------

local font = "FONTS\\arialn.ttf"
local GetArenaIndex = NeatPlatesUtility.GetArenaIndex

local function UpdateArenaWidget(self, unit)
	local arenastring = ""
	local arenaindex = GetArenaIndex(unit.rawName)

	if NeatPlates._TestMode then arenaindex = 2 end -- Test Mode

	if unit.type == "PLAYER" or NeatPlates._TestMode then
		if arenaindex and arenaindex > 0 then
			arenastring = "|cffffcc00["..(tostring(arenaindex)).."]  |r"
		end
	end

	if arenastring ~= "" then
		self.Text:SetText(arenastring)
		self:Show()
	else
		self.Text:SetText("")
		self:Hide()
	end
end

-- local function UpdateWidget(frame)
-- 	local unitid = frame.unitid

-- 	UpdateArenaWidget(frame, unitid)
-- end

local function UpdateWidgetContext(frame, unit)
	frame.unitid = unit.unitid
	UpdateArenaWidget(frame, unit)
end

local function CreateArenaWidget(parent)
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

NeatPlatesWidgets.CreateArenaWidget = CreateArenaWidget


