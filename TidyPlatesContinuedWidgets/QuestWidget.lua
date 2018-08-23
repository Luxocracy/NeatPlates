---------------
-- Quest Icon Widget
---------------
local GetUnitQuestInfo = TidyPlatesContUtility.GetUnitQuestInfo
local art = "Interface\\Addons\\TidyPlatesContinuedWidgets\\QuestWidget\\QuestIndicator"

local function UpdateQuestWidget(self, unit, showFriendly)
	if unit and unit.type == "NPC" then
		local questName, questObjective = GetUnitQuestInfo(unit)
		if questName and questObjective then
			local questProgress, questTotal = string.match(questObjective, "([0-9]+)\/([0-9]+)")
			if questProgress < questTotal then
				self.Icon:SetTexture(art)
				self:Show()
			else
				self:Hide()
			end
		elseif questName then
			self.Icon:SetTexture(art)
			self:Show()
		else
			self:Hide()
		end
	end
end

local function CreateQuestWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(18); frame:SetHeight(18)

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints(frame)
	frame:Hide()
	frame.Update = UpdateQuestWidget
	return frame
end

TidyPlatesContWidgets.CreateQuestWidget = CreateQuestWidget


