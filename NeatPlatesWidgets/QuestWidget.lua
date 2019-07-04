---------------
-- Quest Icon Widget
---------------
local GetUnitQuestInfo = NeatPlatesUtility.GetUnitQuestInfo
local art = "Interface\\Addons\\NeatPlatesWidgets\\QuestWidget\\QuestIndicator"

local function UpdateQuestWidget(self, unit)	
	if unit and unit.type == "NPC" then
		local isDungeon = IsInInstance()
		local questList = GetUnitQuestInfo(unit)
		local showIcon = false

		for i=1, #questList do
			local questName, questObjective = unpack(questList[i])
			local questProgress, questTotal

			if questObjective then
				questProgress, questTotal = string.match(questObjective, "([0-9]+)\/([0-9]+)")
				questProgress = tonumber(questProgress)
				questTotal = tonumber(questTotal)
			end

			if (not isDungeon and ((questName and not (questProgress and questTotal)) or (questProgress and questTotal and questProgress < questTotal))) then
				showIcon = true
			end
		end	
		
		if showIcon then
			self.Icon:SetTexture(art)
			self:Show()
		else
			self:Hide()
		end
	end
end

local function UpdateQuestWidgetContext(self, unit, extended)
	local config = NeatPlates:GetTheme().WidgetConfig

	if unit.style == "Default" or not config.QuestWidgetNameOnly then config = config.QuestWidget else config = config.QuestWidgetNameOnly end
	self:ClearAllPoints()
	self:SetPoint(config.anchor or "TOP", extended, config.anchorRel or config.anchor or "TOP", config.x or 0, config.y or 0)
end

local function CreateQuestWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(18); frame:SetHeight(18)

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints(frame)
	frame:Hide()
	frame.Update = UpdateQuestWidget
	frame.UpdateContext = UpdateQuestWidgetContext
	return frame
end

NeatPlatesWidgets.CreateQuestWidget = CreateQuestWidget


