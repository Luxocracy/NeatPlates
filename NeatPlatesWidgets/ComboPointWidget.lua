------------------------------
-- Combo Point Widget
------------------------------

local comboWidgetPath = "Interface\\Addons\\NeatPlatesWidgets\\ComboWidget\\"
local artpath = "Interface\\Addons\\NeatPlatesWidgets\\ComboWidget\\"
local artstyle = 2 -- 1 - Blizzard; 2 - NeatPlates, 3 - NeatPlatesTraditional
local artfile = {
	artpath.."Powers.tga",
	artpath.."PowersNeat.tga",
	artpath.."PowersTrad.tga",
}
local ScaleOptions = {x = 1, y = 1, offset = {x = 0, y = 0}}

local t = { 	
	['DRUID'] = {
		["POWER"] = Enum.PowerType.Energy,
		["all"] = { ["w"] = 80, ["h"] = 20 },
		["5"] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.5, ["r"] = 0.625, ["o"] = 5}, -- all, since you can cat all the time :P
		["6"] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.5, ["r"] = 0.625, ["o"] = 9}, -- all, since you can cat all the time :P
	},
	
	['ROGUE'] = {
		["POWER"] = Enum.PowerType.Energy,
		["all"] = { ["w"] = 80, ["h"] = 20 },
		["5"] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.5, ["r"] = 0.625, ["o"] = 5}, -- all, since you can combo all the time :P
		["6"] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.5, ["r"] = 0.625, ["o"] = 9}, -- all, since you can combo all the time :P
	},
};

local grid =  .0625
local playeRole = "DAMAGER"
--local PlayerClass = "NONE"
local PlayerClass = select(2, UnitClass("player"))
local playerSpec = 0
local WidgetList = {}

local function GetPlayerPower()
	local PlayerPowerType = 0;
	local points = 0
	local maxPoints = 0
	local needsEnemy = playeRole ~= "HEALER"
	
	if UnitAffectingCombat("player") and not UnitCanAttack("player", "target") and needsEnemy then
		return 0, 0
	end

	if t[PlayerClass] == nil or t[PlayerClass]["POWER"] == nil then return 0, 0 end
	PlayerPowerType = t[PlayerClass]["POWER"]
	PlayerPowerUnmodified = t[PlayerClass]["NOMOD"]

	local maxPoints = UnitPowerMax("player", PlayerPowerType, PlayerPowerUnmodified) or 5
	
	if PlayerPowerType == Enum.PowerType.Energy then
		points = GetComboPoints("player", "target")
	elseif PlayerPowerType == 5 then
		maxPoints = 6
		--points = GetDKRunes()
	else
		points = UnitPower("player", PlayerPowerType, PlayerPowerUnmodified)
	end
	return points, maxPoints
end 

local function SelectPattern(maxPower)
	local selectedPattern
	
	if (t[PlayerClass] == nil) then
		local _temp = { ["w"] = 64, ["h"] = 16, ["o"] = 0}
		return _temp
	end
	
	-- Custom case if somehow the player should not have 5 but 6 combos
	if PlayerClass == "DRUID" or PlayerClass == "ROGUE" or PlayerClass == "MONK" then
		selectedPattern = t[PlayerClass][tostring(maxPower)]
	else
		selectedPattern = t[PlayerClass][playerSpec]
	end

	if selectedPattern == nil then
		selectedPattern = t[PlayerClass]["all"]
	end

	if selectedPattern == nil then
		local _temp = { ["w"] = 64, ["h"] = 16, ["o"] = 0}
		return _temp
	end

	return selectedPattern
end

-- Update Graphics
local function UpdateWidgetFrame(frame)
	local points, maxPoints = GetPlayerPower()
	local maxPoints = 5 -- Couldn't go higher in classic?
	if points and points > 0 then
		local pattern = SelectPattern(maxPoints)

		if pattern == nil then
			print("[NeatPlates][ERROR] invalid pattern for " .. PlayerClass .. " - " .. playerSpec .. ", this should never happen, perhaps a '/reload' would be in order.") -- should not happen
			frame:_Hide()
			return
		end

		local offset = pattern["o"];

		if maxPoints == 6 then
			frame.Icon:SetTexCoord(pattern["l"], pattern["r"], grid*(points + offset), grid *(points + offset + 1))
		elseif maxPoints == 50 then -- Warlock Specific
			local modPoints = math.floor(points/10)
			local fragments = points % 10
			local fOffset = math.min(1, fragments)
			frame.Icon:SetTexCoord(pattern["l"], pattern["r"], grid*(modPoints + offset), grid *(modPoints + 1 + offset))
			frame.PartialFill:SetTexCoord(pattern["l"], pattern["r"], grid*(modPoints + fOffset + offset), grid*(math.min(6, modPoints + fOffset + 1) + offset))
			frame.PartialFill:SetValue(fragments)

			if t[PlayerClass]["SPARK"] then
				frame.Spark.Texture:SetPoint("CENTER", frame, "CENTER", (t[PlayerClass]["SPARK"][modPoints] or 0)*ScaleOptions.x+ScaleOptions.offset.x, 1*ScaleOptions.x+ScaleOptions.offset.y) -- Offset texture per shard
				if frame.Spark.lastpower and modPoints > frame.Spark.lastpower then frame.Spark.Anim:Play() end -- Play Spark Animation
				frame.Spark.lastpower = modPoints
			end

			frame.PartialFill:SetStatusBarTexture(artfile[artstyle])
		else
			frame.Icon:SetTexCoord(pattern["l"], pattern["r"], grid*(points + offset - 1), grid *(points + offset))
		end

		frame.Icon:SetTexture(artfile[artstyle])

		frame:UpdateScale()
		frame:Show()
		return
	end

	frame:_Hide()
end

local function UpdateWidgetScaling(frame)
	local pattern = SelectPattern(maxPower)
	local w = (pattern["w"] or 16)*ScaleOptions.x
	local h = (pattern["h"] or 64)*ScaleOptions.y

	frame:SetHeight(32)
	frame:SetWidth(w)
	frame.Icon:SetHeight(h)
	frame.Icon:SetWidth(w)
	frame.PartialFill:SetHeight(h)
	frame.PartialFill:SetWidth(w)
	frame.Icon:SetPoint("CENTER", frame, "CENTER", ScaleOptions.offset.x, ScaleOptions.offset.y)
	frame.PartialFill:SetPoint("CENTER", frame, "CENTER", ScaleOptions.offset.x, ScaleOptions.offset.y)

	if frame.Spark then
		frame.Spark.Texture:SetWidth(16*ScaleOptions.x)
		frame.Spark.Texture:SetHeight(16*ScaleOptions.y)
	end
end

-- Context
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
		UpdateWidgetFrame(frame)
	else
		frame:_Hide()
	end
end

local function ClearWidgetContext(frame)
	local guid = frame.guid
	if guid then
		WidgetList[guid] = nil
		frame.guid = nil
	end
end

-- Watcher Frame
local WatcherFrame = CreateFrame("Frame", nil, WorldFrame )
local isEnabled = false
WatcherFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
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
			if widget then UpdateWidgetFrame(widget) end				-- To update all, use: for guid, widget in pairs(WidgetList) do UpdateWidgetFrame(widget) end
		end
end

local function EnableWatcherFrame(arg)
	if arg then
		WatcherFrame:SetScript("OnEvent", WatcherFrameHandler); isEnabled = true
	else WatcherFrame:SetScript("OnEvent", nil); isEnabled = false end
end

local function CreateSparkAnimation(parent)
	local spark = CreateFrame("Frame", nil, parent)
	spark.Texture = spark:CreateTexture(nil, "OVERLAY")
	spark.Texture:SetPoint("CENTER", parent, "CENTER")
	spark.Texture:SetHeight(16)
	spark.Texture:SetWidth(16)
	spark.Texture:SetTexture(artpath.."ShardSpark.tga")
	spark.Texture:SetBlendMode("ADD")
	
	spark:SetAlpha(0)

	-- Spark Animation
	spark.Anim = spark:CreateAnimationGroup()
	spark.fadeIn = spark.Anim:CreateAnimation("Alpha")
	spark.fadeIn:SetFromAlpha(0)
	spark.fadeIn:SetToAlpha(1)
	spark.fadeIn:SetDuration(0.2)
	spark.fadeIn:SetOrder(1)
	spark.scaleIn = spark.Anim:CreateAnimation("Scale")
	spark.scaleIn:SetFromScale(0.6,0.6)
	spark.scaleIn:SetToScale(1,1)
	spark.scaleIn:SetDuration(0.25)
	spark.scaleIn:SetOrder(1)
	spark.scaleOut = spark.Anim:CreateAnimation("Scale")
	spark.scaleOut:SetFromScale(1,1)
	spark.scaleOut:SetToScale(0.1,0.1)
	spark.scaleOut:SetDuration(0.3)
	spark.scaleOut:SetOrder(2)
	spark.fadeOut = spark.Anim:CreateAnimation("Alpha")
	spark.fadeOut:SetFromAlpha(1)
	spark.fadeOut:SetToAlpha(0)
	spark.fadeOut:SetDuration(0.1)
	spark.fadeOut:SetOrder(3)

	return spark
end

-- Widget Creation
local function CreateWidgetFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:Hide()

	local _, maxPower = GetPlayerPower() -- Rogues, Druids and Monks are always an exception
	local pattern = SelectPattern(maxPower)
	local w = pattern["w"] or 16
	local h = pattern["h"] or 64
	frame:SetHeight(32)
	frame:SetWidth(w)
	frame.Icon = frame:CreateTexture(nil, "OVERLAY")
	frame.Icon:SetPoint("CENTER", frame, "CENTER")
	frame.Icon:SetHeight(h)
	frame.Icon:SetWidth(w)
	frame.Icon:SetTexture(artfile[artstyle])

	frame.PartialFill = CreateNeatPlatesStatusbar(frame)
	frame.PartialFill:SetPoint("CENTER", frame, "CENTER")
	frame.PartialFill:SetHeight(h)
	frame.PartialFill:SetWidth(w)
	frame.PartialFill:SetStatusBarTexture(artfile[artstyle])
	frame.PartialFill:SetOrientation("VERTICAL")

	if t[PlayerClass] and t[PlayerClass]["MinMax"] then
		local min, max = unpack(t[PlayerClass]["MinMax"][artstyle])
		frame.PartialFill:SetMinMaxValues(min, max)
		frame.Spark = CreateSparkAnimation(frame)
	else
		frame.PartialFill:Hide()
	end

	-- Required Widget Code
	frame.UpdateContext = UpdateWidgetContext
	frame.UpdateScale = UpdateWidgetScaling
	frame.Update = UpdateWidgetFrame
	frame._Hide = frame.Hide
	frame.Hide = function() ClearWidgetContext(frame); frame:_Hide() end
	if not isEnabled then EnableWatcherFrame(true) end
	return frame
end

local function SetComboPointsWidgetOptions(LocalVars)
	artstyle = LocalVars.WidgetComboPointsStyle
	ScaleOptions = LocalVars.WidgetComboPointsScaleOptions

	NeatPlates:ForceUpdate()
end

local SpecWatcher = CreateFrame("Frame")
SpecWatcher:SetScript("OnEvent", SpecWatcherEvent)
SpecWatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
SpecWatcher:RegisterEvent("GROUP_ROSTER_UPDATE")
SpecWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")

NeatPlatesWidgets.CreateComboPointWidget = CreateWidgetFrame
NeatPlatesWidgets.SetComboPointsWidgetOptions = SetComboPointsWidgetOptions
