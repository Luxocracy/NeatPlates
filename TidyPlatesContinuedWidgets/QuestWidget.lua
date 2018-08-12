---------------
-- Quest Icon Widget
---------------
local GetUnitQuestInfo = TidyPlatesContUtility.GetUnitQuestInfo
local art = "Interface\\Addons\\TidyPlatesContinuedWidgets\\QuestWidget\\QuestIndicator"

local function UpdateQuestWidget(self, unit, showFriendly)
	if unit and unit.type == "NPC" then
		local questName, questObjective = GetUnitQuestInfo(unit)
		if questObjective or questName then
			self.Icon:SetTexture(art)
			-- self.Icon:SetTexCoord(0,1,0,1)
			self:Show()
		else
			self:Hide()
		end
	end
end

local function CreateQuestWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(16); frame:SetHeight(16)

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints(frame)
	frame:Hide()
	frame.Update = UpdateQuestWidget
	return frame
end

TidyPlatesContWidgets.CreateQuestWidget = CreateQuestWidget