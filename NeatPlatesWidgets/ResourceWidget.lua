local WidgetList = {}
local PlayerClass = select(2, UnitClass("player"))
local PlayerSpec = 0

------------------------------
-- Debug
------------------------------
local lastDebugPoints = {}
local function DebugGetUnitChargedPowerPoints(currentPoints)
	local used = {
		[1] = true,
	}
	local points = lastDebugPoints
	if currentPoints == 1 then
		points = {}
		for i = 1, 4 do
			local point = math.random(0, 5)
			if not used[point] and point > 0 then
				used[point] = true
				table.insert(points, point)
			end
		end
		lastDebugPoints = points
	end
	if currentPoints == 2 then
		return {}
	end

	return points
end

------------------------------
-- Class Powers
------------------------------
local t = {
	['DEATHKNIGHT'] = {
		["POWER"] = Enum.PowerType.Runes,
        ["GetPower"] = function()
            local points = {}
            local runeMap = {
                ["RUNETYPE_BLOOD"] = "Blood",
                ["RUNETYPE_CHROMATIC"] = "Unholy",
                ["RUNETYPE_FROST"] = "Frost",
                ["RUNETYPE_DEATH"] = "Death",
                [1] = "Blood",
                [2] = "Frost",
                [3] = "Unholy",
            }

            -- Iterate through the runes in the order they appear in the UI
            local runeOrder = {6,5,4,3,2,1}
            if NEATPLATES_IS_CLASSIC_WOTLKC then
                runeOrder =  {1,2,5,6,3,4}
            end

            for _, i in pairs(runeOrder) do
                local start, duration, runeReady = GetRuneCooldown(i)
                local runeType = ""
                if NEATPLATES_IS_CLASSIC_WOTLKC then
                    runeType = runeMap[GetRuneType(i)]
                    if runeReady then
                        table.insert(points, "DK-Rune-Classic-"..runeType..".tga")
                    else
                        table.insert(points, "DK-Rune-Classic-"..runeType.."-Off.tga")
                    end
                else
                    runeType = runeMap[GetSpecialization()]
                    if runeReady then
                        table.insert(points, "DK-Rune-"..runeType..".tga")
                    else
                        table.insert(points, "DK-Rune-Off.tga")
                    end
                end

            end
            return points, 6
        end,
	},

	['DRUID'] = {
		["POWER"] = Enum.PowerType.ComboPoints,
        ["GetPower"] = function()
            local maxPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 5
            currentPoints = GetComboPoints("player", "target")

            for i = 1, maxPoints do
                if currentPoints >= i then
                    table.insert(points, "ComboPoint-On.tga")
                else
                    table.insert(points, "ComboPoint-Off.tga")
                end
            end

            return points, maxPoints
        end,
	},

	['ROGUE'] = {
		["POWER"] = Enum.PowerType.ComboPoints,
        ["GetPower"] = function()
            local points = {}
            local maxPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 5
            local currentPoints = GetComboPoints("player", "target")
            local chargedPoints = nil

            if not NEATPLATES_IS_CLASSIC then
                chargedPoints = GetUnitChargedPowerPoints("player")
                chargedPoints = DebugGetUnitChargedPowerPoints(currentPoints)
            end

            for i = 1, maxPoints do
                if chargedPoints and table.contains(chargedPoints, i) then
                    if currentPoints >= i then
                        table.insert(points, "ComboPoint-Charged-On.tga")
                    else
                        table.insert(points, "ComboPoint-Charged-Off.tga")
                    end
                elseif currentPoints >= i then
                    table.insert(points, "ComboPoint-On.tga")
                else
                    table.insert(points, "ComboPoint-Off.tga")
                end
            end

            return points, maxPoints
        end,
	},

	['MAGE'] = {
		["POWER"] = Enum.PowerType.ArcaneCharges,
        ["POINT"] = {
            ["ON"] = "Mage-ArcaneCharge-On.tga",
            ["OFF"] = "Mage-ArcaneCharge-Off.tga",
        },
	},

	['MONK'] = {
		["POWER"] = Enum.PowerType.Chi,
        ["POINT"] = {
            ["ON"] = "Monk-Chi-On.tga",
            ["OFF"] = "Monk-Chi-Off.tga",
        },
	},

	['PALADIN'] = {
		["POWER"] = Enum.PowerType.HolyPower,
        ["GetPower"] = function()
            local points = {}
            local maxPoints = UnitPowerMax("player", Enum.PowerType.HolyPower) or 5
            local currentPoints = UnitPower("player", Enum.PowerType.HolyPower)

            for i = 1, maxPoints do
                if currentPoints >= i then
                    table.insert(points, "Paladin-HolyPower-"..i.."-On.tga")
                else
                    table.insert(points, "Paladin-HolyPower-"..i.."-Off.tga")
                end
            end

            return points, maxPoints
        end,
	},

	['WARLOCK'] = {
		["POWER"] = Enum.PowerType.SoulShards,
        ["POINT"] = {
            ["ON"] = "Warlock-Shard-On.tga",
            ["OFF"] = "Warlock-Shard-Off.tga",
        },
	},
};

-- Assign a default 'GetPower' function if one is not defined
for class, data in pairs(t) do
    if data["GetPower"] == nil then
        data["GetPower"] = function()
            local points = {}
            local maxPoints = UnitPowerMax("player", data["POWER"]) or 5
            local currentPoints = UnitPower("player", data["POWER"])

            for i = 1, maxPoints do
                if currentPoints >= i then
                    table.insert(points, data["POINT"]["ON"])
                else
                    table.insert(points, data["POINT"]["OFF"])
                end
            end

            return points, maxPoints
        end
    end
end

------------------------------
-- Resource Widget
------------------------------

-- Widget Functions
local function SetPlayerSpecData()
	local _, class = UnitClass("player")
	local specializationIndex = tonumber(GetSpecialization())
	PlayerSpec = GetSpecializationInfo(specializationIndex)
	PlayerClass = class
end

local function GetPlayerPower()
    -- TODO: Do checks for if the power should be displayed etc here.
    return t[PlayerClass].GetPower()
end

local function GetResourceTexture(path)
    -- TODO: Add support for all the different themes/styles
    -- Most likely the folder structure will dictate which theme to use
    local texturePath = "Interface\\Addons\\NeatPlatesWidgets\\ResourceWidget\\"
    local style = ""
    if true then style = "Blizzard\\" end
    return texturePath .. style .. path
end

local function UpdatePoints(self)
    -- Create Resource Points
    self.Points = self.Points or {}
    local points, maxPoints = GetPlayerPower()
    table.foreach(self.Points, function(k, v) v:Hide() end) -- Hide current points
    if points == nil then
        return
    end
    table.foreach(points, print)

    local pointSize = 16
    local centerOffset = ((5 - maxPoints) * pointSize) / 2
    -- Update Points
    table.foreach(points, function(i, path)
        local point = self.Points[i] or self:CreateTexture(nil, "OVERLAY")
        point:SetSize(pointSize, pointSize)
        point:SetPoint("LEFT", self, "LEFT", (i - 1) * pointSize + centerOffset, 0)

        point:SetTexture(GetResourceTexture(path))

        self.Points[i] = point
        self.Points[i]:Show()
    end)
end

-- Widget Update
local function UpdateWidgetFrame(widget)
    widget:UpdatePoints()
end

-- Widget Context
local function ClearWidgetContext(frame)
	local guid = frame.guid
	if guid then
		WidgetList[guid] = nil
		frame.guid = nil
	end
end

local function UpdateWidgetContext(frame, unit)
	local guid = unit.guid

	-- Add to Widget List
	if guid then
		if frame.guid then WidgetList[frame.guid] = nil end
		frame.guid = guid
		WidgetList[guid] = frame
	end

    -- Update Widget
    if UnitGUID("target") == guid then
        frame:Show()
        frame:Update()
    else
        frame:_Hide()
    end
end

-- Watcher Frame
local WatcherFrame = CreateFrame("Frame", nil, WorldFrame)
WatcherFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
if not NEATPLATES_IS_CLASSIC or NEATPLATES_IS_CLASSIC_WOTLKC then
	WatcherFrame:RegisterEvent("RUNE_POWER_UPDATE")
end
WatcherFrame:RegisterEvent("UNIT_POWER_FREQUENT")
WatcherFrame:RegisterEvent("UNIT_MAXPOWER")
WatcherFrame:RegisterEvent("UNIT_POWER_UPDATE")
WatcherFrame:RegisterEvent("UNIT_DISPLAYPOWER")
WatcherFrame:RegisterEvent("UNIT_AURA")
WatcherFrame:RegisterEvent("UNIT_FLAGS")

local function WatcherFrameHandler(frame, event, unitid)
    local guid = UnitGUID("target")
    if UnitExists("target") then
        local widget = WidgetList[guid]
        -- print("WatcherFrameHandler", event, guid, widget)
        if widget then UpdateWidgetFrame(widget) end				-- To update all, use: for guid, widget in pairs(WidgetList) do UpdateWidgetFrame(widget) end
    end
end

local function EnableWatcherFrame(arg)
	if arg then
		WatcherFrame:SetScript("OnEvent", WatcherFrameHandler); isEnabled = true
	else WatcherFrame:SetScript("OnEvent", nil); isEnabled = false end
end

-- Used to decide whether we should display player power indicator on the target or not
local function SpecWatcherEvent(self, event, ...)
	SetPlayerSpecData()
end

-- Widget Creation
local function CreateWidgetFrame(parent)
    if not NEATPLATES_IS_CLASSIC then
		SetPlayerSpecData()
	end

    local frame = CreateFrame("Frame", nil, parent)
    frame:Hide()
    frame:SetFrameLevel(frame:GetFrameLevel() + 2)
    frame:SetWidth(80)
    frame:SetHeight(32)
    frame:SetPoint("CENTER", parent, "CENTER", 0, 0)

    frame.UpdatePoints = UpdatePoints -- Point update function
    frame:UpdatePoints() -- Create points

    -- Required Widget Code
	frame.UpdateContext = UpdateWidgetContext
	frame.UpdateScale = UpdateWidgetScaling
	frame.Update = UpdateWidgetFrame
	frame._Hide = frame.Hide
	frame.Hide = function() ClearWidgetContext(frame); frame:_Hide() end
	if not isEnabled then EnableWatcherFrame(true) end
	return frame
end

-- Widget Settings
local function SetResourceWidgetOptions(LocalVars)
	artstyle = LocalVars.WidgetComboPointsStyle
	ScaleOptions = LocalVars.WidgetComboPointsScaleOptions

	NeatPlates:ForceUpdate()
end

NeatPlatesWidgets.CreateResourceWidget = CreateWidgetFrame
NeatPlatesWidgets.SetResourceWidgetOptions = SetResourceWidgetOptions