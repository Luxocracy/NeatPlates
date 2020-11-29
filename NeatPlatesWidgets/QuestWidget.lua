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

		for questName, questObjectives in pairs(questList) do
			for questObjective, questCompleted in pairs(questObjectives) do
				if (not isDungeon and not questCompleted) then
					showIcon = true
				end
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
-- table.foreach(NeatPlatesUtility.GetUnitQuestInfo({["unitid"] = "target"}), function(name, objectives) print("Name:", name); table.foreach(objectives, print) end)

local function UpdateQuestWidgetContext(self, unit, extended)
	local config = NeatPlates:GetTheme().WidgetConfig

	if unit.style == "Default" or not config.QuestWidgetNameOnly then config = config.QuestWidget else config = config.QuestWidgetNameOnly end
	self:ClearAllPoints()
	self:SetPoint(config.anchor or "TOP", extended, config.anchorRel or config.anchor or "TOP", config.x or 0, config.y or 0)
	UpdateQuestWidget(self, unit)
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

local function DebugQuests()
	local plate = C_NamePlate.GetNamePlateForUnit("target")
	local questList = GetUnitQuestInfo(plate.extended.unit)

	if next(questList) == nil then
		print("No active quests on target")
	else
		for questName, questObjectives in pairs(questList) do
			print('--'..questName..'--')
			for questObjective, questCompleted in pairs(questObjectives) do
				local prefix = "In progress - "
				if questCompleted then prefix = "Completed - " end
				print(prefix..questObjective)
			end
		end
	end
end

NeatPlatesWidgets.CreateQuestWidget = CreateQuestWidget
NeatPlatesWidgets.DebugQuests = DebugQuests