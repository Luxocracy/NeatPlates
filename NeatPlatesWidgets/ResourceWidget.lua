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
-- Folder structure will dictate the different style options
local t = {
	['DEATHKNIGHT'] = {
		["POWER"] = Enum.PowerType.Runes,
        ["POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
        ["CHARGED_POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
	},

	['DRUID'] = {
		["POWER"] = Enum.PowerType.ComboPoints,
        ["POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
        ["CHARGED_POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
	},

	['ROGUE'] = {
		["POWER"] = Enum.PowerType.ComboPoints,
        ["POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
        ["CHARGED_POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
	},

	['MAGE'] = {
		["POWER"] = Enum.PowerType.ArcaneCharges,
        ["POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
        ["CHARGED_POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
	},

	['MONK'] = {
		["POWER"] = Enum.PowerType.Chi,
        ["POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
        ["CHARGED_POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
	},

	['PALADIN'] = {
		["POWER"] = Enum.PowerType.HolyPower,
        ["POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
        ["CHARGED_POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
	},

	['WARLOCK'] = {
		["POWER"] = Enum.PowerType.SoulShards,
		["NOMOD"] = true,
        ["POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
        ["CHARGED_POINT"] = {
            ["ON"] = "RogueKyrianOverlayNeat.tga",
            ["OFF"] = "RogueKyrianOverlayNeatOff.tga",
        },
	},
};

------------------------------
-- Resource Widget
------------------------------
local WidgetList = {}
local PlayerClass = select(2, UnitClass("player"))
local playerSpec = 0

-- Widget Functions
local function SetPlayerSpecData()
	local _, class = UnitClass("player")
	local specializationIndex = tonumber(GetSpecialization())
	playerSpec = GetSpecializationInfo(specializationIndex)
	PlayerClass = class
end

local function GetPlayerPower()
	local PlayerPowerType = 0;
	local points = 0
	local maxPoints = 0
	local needsEnemy = playeRole ~= "HEALER"
    local chargedPowerPoints = nil

	if (t[PlayerClass] == nil or t[PlayerClass]["POWER"] == nil) or (UnitAffectingCombat("player") and not UnitCanAttack("player", "target") and needsEnemy) then
		return 0, 0, chargedPowerPoints
	end

    if not NEATPLATES_IS_CLASSIC then
        -- chargedPowerPoints = DebugGetUnitChargedPowerPoints(points)
        chargedPowerPoints = GetUnitChargedPowerPoints("player")
    end

	PlayerPowerType = t[PlayerClass]["POWER"]
    PlayerPowerUnmodified = t[PlayerClass]["NOMOD"]

	local maxPoints = UnitPowerMax("player", PlayerPowerType, PlayerPowerUnmodified) or 5

	if PlayerPowerType == Enum.PowerType.ComboPoints then
		points = GetComboPoints("player", "target")
	elseif PlayerPowerType == 5 then
		maxPoints = 6
		points = GetDKRunes()
	else
		points = UnitPower("player", PlayerPowerType, PlayerPowerUnmodified)
	end
	return points, maxPoints, chargedPowerPoints
end

local function GetResourceTexture(i, points, chargedPoints)
    local texturePath = "Interface\\Addons\\NeatPlatesWidgets\\ComboWidget\\"
    if chargedPoints and chargedPoints[i] then
        if points >= i then
            return texturePath..t[PlayerClass]["CHARGED_POINT"]["ON"]
        else
            return texturePath..t[PlayerClass]["CHARGED_POINT"]["OFF"]
        end
    elseif points >= i then
        return texturePath..t[PlayerClass]["POINT"]["ON"]
    else
        return texturePath..t[PlayerClass]["POINT"]["OFF"]
    end
end

local function UpdatePoints(self)
    -- Create Resource Points
    self.Points = self.Points or {}
    local points, maxPoints, chargedPoints = GetPlayerPower()
    local pointSize = 16
    local centerOffset = ((5 - maxPoints) * pointSize) / 2
    table.foreach(self.Points, function(k, v) v:Hide() end) -- Hide current points
    -- Update Points
    for i = 1, maxPoints do
        local point = self.Points[i] or self:CreateTexture(nil, "OVERLAY")
        point:SetSize(pointSize, pointSize)
        point:SetPoint("LEFT", self, "LEFT", (i - 1) * pointSize + centerOffset, 0)

        point:SetTexture(GetResourceTexture(i, points, chargedPoints))

        self.Points[i] = point
        self.Points[i]:Show()
    end
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
if not NEATPLATES_IS_CLASSIC then
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

-- Widget Creation
local function CreateWidgetFrame(parent)
    if not NEATPLATES_IS_CLASSIC then
		SetPlayerSpecData()
	end

    local frame = CreateFrame("Frame", nil, parent)
    frame:Hide()
    frame:SetFrameLevel(frame:GetFrameLevel() + 20) -- should be (2), just for debugging
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