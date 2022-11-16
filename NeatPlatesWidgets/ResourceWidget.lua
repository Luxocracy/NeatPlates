local PolledHideIn = NeatPlatesWidgets.PolledHideIn
local WidgetList = {}
local PlayerClass = select(2, UnitClass("player"))
local PlayerSpec = 0
local TimerFont = "FONTS\\ARIALN.TTF"

local validArtStyles = {
    ["Blizzard"] = true,
    ["Neat"] = true
}

------------------------------
-- Settings
------------------------------
local pointSpacing = 0
local artstyle = "Neat"
local timerFontSize = 8
local displayTimer = true
local hideOnEmpty = false

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
local function getPointIcon(points, i)
    -- Check if points is table
    if type(points) == "table" then
        return points[i]
    else
        return points
    end
end

local t = {
    ['RESOURCE_PATH'] = "Interface\\Addons\\NeatPlatesWidgets\\ResourceWidget\\",
	['DEATHKNIGHT'] = {
		["POWER"] = Enum.PowerType.Runes,
        ["POINT"] = "", -- Check further down, this will be diferent depending on client
        ["GetPower"] = function(self)
            local points = {}
            local runeMap = {
                ["RUNETYPE_BLOOD"] = "Blood",
                ["RUNETYPE_CHROMATIC"] = "Unholy",
                ["RUNETYPE_FROST"] = "Frost",
                ["RUNETYPE_DEATH"] = "Death",
                [1] = "Blood",
                [2] = "Frost",
                [3] = "Unholy",
                [4] = "Death",
            }

            -- Iterate through the runes in the order they appear in the UI
            local runeOrder = {1,2,3,4,5,6} -- Actually sorted by duration in retail
            if NEATPLATES_IS_CLASSIC_WOTLKC then
                runeOrder =  {1,2,5,6,3,4}
            end

            for _, i in pairs(runeOrder) do
                local point = {
                    ["ICON"] = getPointIcon(self.POINT, i),
                    ["STATE"] = "Off",
                    ["DURATION"] = 0,
                    ["EXPIRATION"] = 0,
                }

                local start, duration, runeReady = GetRuneCooldown(i)
                if runeReady ~= nil then
                    local expiration = start + duration
                    local runeType = ""
                    if NEATPLATES_IS_CLASSIC_WOTLKC then
                        runeTypeIndex = GetRuneType(i)
                        runeType = runeMap[runeTypeIndex]
                        point.ICON = point.ICON .. "-" .. runeType
                        point.SWIPE = point.ICON .. "-On"
                        if runeReady then
                            point["STATE"] = "On"
                        else
                            point["STATE"] = "Off"
                            point["DURATION"] = duration
                            point["EXPIRATION"] = expiration
                        end
                    else
                        runeType = runeMap[GetSpecialization()]
                        point.SWIPE = point.ICON .. "-" .. runeType .. "-On"
                        if runeReady then
                            point.ICON = point.ICON .. "-" .. runeType
                            point["STATE"] = "On"
                        else
                            point["STATE"] = "Off"
                            point["DURATION"] = duration
                            point["EXPIRATION"] = expiration
                        end
                    end
                end
                table.insert(points, point)
            end

            if not NEATPLATES_IS_CLASSIC then
                -- Sort by expiration time
                table.sort(points, function(a, b)
                    return a.EXPIRATION < b.EXPIRATION
                end)
            end

            return points, 6
        end,
	},

	['DRUID'] = {
		["POWER"] = Enum.PowerType.ComboPoints,
        ["POINT"] = "ComboPoint",
        ["GetPower"] = function(self)
            local points = {}
            local maxPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 5
            local currentPoints = GetComboPoints("player", "target")
            local powerType, powerTypeString = UnitPowerType("player");

            -- Don't show if not in cat form
            -- Note: Maybe still show if there are combopoints available
            if powerType ~= 3 or (hideOnEmpty and currentPoints == 0) then
                return nil, nil
            end

            for i = 1, maxPoints do
                local point = {
                    ["ICON"] = getPointIcon(self.POINT, i),
                    ["STATE"] = "Off",
                }
                if currentPoints >= i then
                    point.STATE = "On"
                end
               -- Insert Point
                table.insert(points, point)
            end

            return points, maxPoints
        end,
	},

	['ROGUE'] = {
		["POWER"] = Enum.PowerType.ComboPoints,
        ["POINT"] = "ComboPoint",
        ["GetPower"] = function(self)
            local points = {}
            local maxPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 5
            local currentPoints = GetComboPoints("player", "target")
            local chargedPoints = nil

            if not NEATPLATES_IS_CLASSIC then
                chargedPoints = GetUnitChargedPowerPoints("player")
                -- chargedPoints = DebugGetUnitChargedPowerPoints(currentPoints)
            end

            if hideOnEmpty and (currentPoints == 0 or not chargedPoints) then
                return nil, nil
            end

            for i = 1, maxPoints do
                local point = {
                    ["ICON"] = getPointIcon(self.POINT, i),
                    ["STATE"] = "Off",
                }

                -- Set state
                if chargedPoints and NeatPlatesUtility.contains(chargedPoints, i) then
                    if currentPoints >= i then
                        point.STATE = "Charged-On"
                    else
                        point.STATE = "Charged-Off"
                    end
                elseif currentPoints >= i then
                    point.STATE = "On"
                end
                -- Insert Point
                table.insert(points, point)
            end

            return points, maxPoints
        end,
	},

	['MAGE'] = {
		["POWER"] = Enum.PowerType.ArcaneCharges,
        ["POINT"] = "Mage-ArcaneCharge",
        ["SPEC"] = {62},
        ["HIDE_ON_EMPTY"] = true
	},

	['MONK'] = {
		["POWER"] = Enum.PowerType.Chi,
        ["POINT"] = "Monk-Chi",
        ["SPEC"] = {269},
        ["HIDE_ON_EMPTY"] = true
	},

	['PALADIN'] = {
		["POWER"] = Enum.PowerType.HolyPower,
        ["POINT"] = {
            [1] = "Paladin-HolyPower-1",
            [2] = "Paladin-HolyPower-2",
            [3] = "Paladin-HolyPower-3",
            [4] = "Paladin-HolyPower-4",
            [5] = "Paladin-HolyPower-5",
        },
        ["GetPower"] = function(self)
            local points = {}
            local maxPoints = UnitPowerMax("player", Enum.PowerType.HolyPower) or 5
            local currentPoints = UnitPower("player", Enum.PowerType.HolyPower)

            for i = 1, maxPoints do
                local point = {
                    ["ICON"] = getPointIcon(self.POINT, i),
                    ["STATE"] = "Off",
                }
                if currentPoints >= i then
                    point.STATE = "On"
                end
                table.insert(points, point)
            end

            return points, maxPoints
        end,
	},

	['WARLOCK'] = {
		["POWER"] = Enum.PowerType.SoulShards,
        ["POINT"] = "Warlock-Shard",
	},

    ['EVOKER'] = {
		["POWER"] = Enum.PowerType.Essence,
        ["POINT"] = "Evoker-Essence",
	},
};

-- Set DK points for retail/classic
if NEATPLATES_IS_CLASSIC_WOTLKC then
    t['DEATHKNIGHT'].POINT = "DK-Rune-Classic"
else
    t['DEATHKNIGHT'].POINT = "DK-Rune"
end

-- Assign a default 'GetPower' function if one is not defined
for class, data in pairs(t) do
    if class ~= 'RESOURCE_PATH' and data["GetPower"] == nil then
        data["GetPower"] = function(self)
            local points = {}
            local maxPoints = UnitPowerMax("player", data["POWER"]) or 5
            local currentPoints = UnitPower("player", data["POWER"])

            if hideOnEmpty and data["HIDE_ON_EMPTY"] and currentPoints == 0 then
                return nil, nil
            end

            for i = 1, maxPoints do
                local point = {
                    ["ICON"] = getPointIcon(self.POINT, i),
                    ["STATE"] = "Off",
                }
                if currentPoints >= i then
                    point.STATE = "On"
                end
                table.insert(points, point)
            end

            return points, maxPoints
        end
    end
end

-- TODO: Add support for customizing the resource "theme"
ACTIVE_RESOURCE_THEME = {} -- Basically everything that is in 't'
-- Merge the default theme with the custom theme
for class, data in pairs(ACTIVE_RESOURCE_THEME) do
    if t[class] then
        for key, value in pairs(data) do
            t[class][key] = value
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
    if PlayerClass and PlayerSpec then
        local data = t[PlayerClass]
        if data then
            local showForSpec = not data["SPEC"] or NeatPlatesUtility.contains(data["SPEC"], PlayerSpec)
            if showForSpec then
                return data["GetPower"](data)
            end
        end
    end
    return nil, nil
end

local function GetResourceTexture(path, state)
    local texturePath = t['RESOURCE_PATH']
    local style = artstyle .. "\\"
    local fullPath = texturePath .. style .. path
    if state then
        fullPath = fullPath .. "-" .. state
    end
    return fullPath .. ".tga"
end

local function UpdateWidgetTime(frame, expiration)
    if not expiration then return end
	if expiration <= 0 or HideAuraDuration then
		frame.TimeLeft:SetText("")
	else
		local timeleft = expiration-GetTime()
		if timeleft > 60 then
			frame.TimeLeft:SetText(floor(timeleft/60).."m")
		else
            if timeleft < 3 then
				frame.TimeLeft:SetText((("%%.%df"):format(1)):format(timeleft))
			else
				frame.TimeLeft:SetText(floor(timeleft))
			end
		end
	end
end

local function CalculatePointSpacing(maxPoints)
    local spacing = {}
    -- Calculate spacing (4, 2, 0, -2, -4)
    for i = 1, maxPoints do
        -- if max points is odd, and we are in the middle point, then we don't want to add spacing
        if maxPoints % 2 == 1 and i == math.ceil(maxPoints / 2) then
            spacing[i] = 0
        else
            spacing[i] =  (i - math.ceil(maxPoints / 2)) * pointSpacing -- Calculate point spacing
            -- If we have an even mount of points.
            -- Add half the point spacing to center the points
            if maxPoints % 2 == 0 then
                spacing[i] = spacing[i] + ((pointSpacing * -1) / 2)
            end
        end
    end
    return spacing
end

local function ExpireFunction(icon)
    if icon and icon.Parent and icon.Parent.UpdatePoints then
        icon.Parent:UpdatePoints()
    end
end

local function CreateResourceIcon(parent, pointData)
    local frame = CreateFrame("Frame", nil, parent)
    frame.Parent = parent

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Cooldown = CreateFrame("Cooldown", nil, frame, "NeatPlatesResourceWidgetCooldown")
    frame.Info = CreateFrame("Frame", nil, frame)

    frame.Icon:SetAllPoints(frame)

    frame.Cooldown:SetAllPoints(frame)
    frame.Cooldown:SetReverse(true)
    frame.Cooldown:SetHideCountdownNumbers(true)
    frame.Cooldown:SetDrawEdge(false)
    frame.Cooldown.noCooldownCount = true -- Disable OmniCC interaction

    frame.Info:SetAllPoints(frame)
    --  Time Text
    frame.TimeLeft = frame.Info:CreateFontString(nil, "OVERLAY")
	frame.TimeLeft:SetFont(TimerFont, timerFontSize, "OUTLINE")
	frame.TimeLeft:SetShadowOffset(1, -1)
	frame.TimeLeft:SetShadowColor(0,0,0,1)
	frame.TimeLeft:SetPoint("CENTER", 0.5, 0)
	-- frame.TimeLeft:SetWidth(32)
	-- frame.TimeLeft:SetHeight(32)
	frame.TimeLeft:SetJustifyH("RIGHT")
    -- frame.Stacks = frame.Info:CreateFontString(nil, "OVERLAY")

    if displayTimer then frame.TimeLeft:Show() else frame.TimeLeft:Hide() end

    -- frame.Expire = ExpireFunction
    frame.Poll = UpdateWidgetTime
    frame.Name = "NeatPlatesResourceWidget"
    frame:Hide()

    return frame
end

local function UpdatePoints(self)
    -- Create Resource Points
    self.Points = self.Points or {}
    local points, maxPoints = GetPlayerPower()
    table.foreach(self.Points, function(k, v) v:Hide() end) -- Hide current points
    if points == nil then
        return
    end

    local pointSize = 16
    local centerOffset = ((5 - maxPoints) * pointSize) / 2
    local spacing = CalculatePointSpacing(maxPoints)
    -- table.foreach(spacing, print)

    -- Update Points
    -- TODO: Set z-index/framelevel of points
    table.foreach(points, function(i, pointData)
        local frame = self.Points[i] or CreateResourceIcon(self, pointData)

        local texture = GetResourceTexture(pointData["ICON"], pointData["STATE"])
        -- print(texture)
        frame.Icon:SetTexture(texture)
        if pointData["COLOR"] then
            r,g,b,a = unpack(pointData["COLOR"])
            frame.Icon:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
        end

        frame:SetSize(pointSize, pointSize)
        frame:SetPoint("LEFT", self, "LEFT", (i - 1) * pointSize + centerOffset + spacing[i], 0)

        local expiration, duration = pointData["EXPIRATION"], pointData["DURATION"]
        if expiration and expiration > 0 then
            if pointData["SWIPE"] then
                frame.Cooldown:SetSwipeTexture(GetResourceTexture(pointData["SWIPE"]))
                frame.Cooldown:SetSwipeColor(0.8, 0.8, 0.8, 1)
                frame.Cooldown:SetEdgeTexture(GetResourceTexture("SwipeEdge"))
            end
            frame.Cooldown:SetCooldown(expiration-duration, duration)
        else
            frame.Cooldown:SetCooldown(0, 0)
        end
        frame.Cooldown:SetDrawSwipe(true)
        frame.Cooldown:SetDrawEdge(true)

        frame:Poll(expiration)
        PolledHideIn(frame, expiration, "UpdateIcon")

        frame:Show()
        self.Points[i] = frame
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

    -- Update settings
    table.foreach(frame.Points, function(k, f)
        f.TimeLeft:SetFont(TimerFont, timerFontSize, "OUTLINE")
        if displayTimer then f.TimeLeft:Show() else f.TimeLeft:Hide() end
    end)

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

local function SpecWatcherEvent(self, event, ...)
	SetPlayerSpecData()
end

if not NEATPLATES_IS_CLASSIC then
	local SpecWatcher = CreateFrame("Frame")
	SpecWatcher:SetScript("OnEvent", SpecWatcherEvent)
	SpecWatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	SpecWatcher:RegisterEvent("GROUP_ROSTER_UPDATE")
	SpecWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
	SpecWatcher:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	SpecWatcher:RegisterEvent("PLAYER_TALENT_UPDATE")
	SpecWatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
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
    pointSpacing = LocalVars.WidgetResourceSpacing
	artstyle = LocalVars.WidgetResourceStyle
    if not validArtStyles[artstyle] then
        artstyle = "Neat"
    end
	timerFontSize = LocalVars.WidgetResourceTimerFontSize
    if timerFontSize == nil or timerFontSize <= 0 then
        timerFontSize = 8
    end
    displayTimer = LocalVars.WidgetResourceDisplayTimer
    hideOnEmpty = LocalVars.WidgetResourceHideEmpty

	NeatPlates:ForceUpdate()
end

NeatPlatesWidgets.CreateResourceWidget = CreateWidgetFrame
NeatPlatesWidgets.SetResourceWidgetOptions = SetResourceWidgetOptions