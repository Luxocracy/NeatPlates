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

local t = { 
	['DEATHKNIGHT'] = {
		["POWER"] = Enum.PowerType.Runes,
		[250] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.00, ["r"] = 0.125, ["o"] = 9}, -- blood
		[251] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.125, ["r"] = 0.250, ["o"] = 9}, -- frost
		[252] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.250, ["r"] = 0.375, ["o"] = 9}, -- unholy
	},
	
	['DRUID'] = {
		["POWER"] = Enum.PowerType.ComboPoints,
		["all"] = { ["w"] = 80, ["h"] = 20 },
		["5"] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.5, ["r"] = 0.625, ["o"] = 5}, -- all, since you can cat all the time :P
		["6"] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.5, ["r"] = 0.625, ["o"] = 9}, -- all, since you can cat all the time :P
	},
	
	['ROGUE'] = {
		["POWER"] = Enum.PowerType.ComboPoints,
		["all"] = { ["w"] = 80, ["h"] = 20 },
		["5"] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.5, ["r"] = 0.625, ["o"] = 5}, -- all, since you can combo all the time :P
		["6"] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.5, ["r"] = 0.625, ["o"] = 9}, -- all, since you can combo all the time :P
	},

	['MAGE'] = {
		["POWER"] = Enum.PowerType.ArcaneCharges,
		[62] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.00, ["r"] = 0.125, ["o"] = 1}, -- all, since you can cat all the time :P
	},

	['MONK'] = {
		["POWER"] = Enum.PowerType.Chi,
		["all"] = { ["w"] = 80, ["h"] = 20}, -- all, since you can cat all the time :P
		["5"] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.375, ["r"] = 0.5, ["o"] = 5}, -- all, since you can combo all the time :P
		["6"] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.375, ["r"] = 0.5, ["o"] = 9}, -- all, since you can combo all the time :P
	},

	['PALADIN'] = {
		["POWER"] = Enum.PowerType.HolyPower,
		[70] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.00, ["r"] = 0.125, ["o"] = 5}, -- retribution
	},

	['WARLOCK'] = {
		["POWER"] = Enum.PowerType.SoulShards,
		["all"] = { ["w"] = 80, ["h"] = 20, ["l"] = 0.125, ["r"] = 0.25, ["o"] = 4}, -- all
		["NOMOD"] = true,
		["MinMax"] = {{-6, 17}, {-6, 17}, {-6, 17}},  -- Actually 0-10, but textures aren't edge to edge so need an offset
		["SPARK"] = {-28.5, -14.5, 0, 14.5, 28.5}
	},
};

local grid =  .0625
local playeRole = "DAMAGER"
local PlayerClass = "NONE"
local playerSpec = 0
local WidgetList = {}

local function GetDKRunes()
	local runeAmount = 0;
	for i=1,6 do
		local _, _, runeReady = GetRuneCooldown(i)
		if runeReady ~= nil and runeReady == true then
		  runeAmount = runeAmount+1
		end
	end
	return runeAmount
end

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

	local maxPoints = UnitPowerMax("player", PlayerPowerType, PlayerPowerUnmodified)
	
	if PlayerPowerType == 4 then
		points = GetComboPoints("player", "target")
	elseif PlayerPowerType == 5 then
		maxPoints = 6
		points = GetDKRunes()
	else
		points = UnitPower("player", PlayerPowerType, PlayerPowerUnmodified)
	end
	return points, maxPoints
end 

local function SelectPattern(maxPower)
	local selectedPattern
	
	if (t[PlayerClass] == nil) then
		local _temp = { ["w"] = 64, ["h"] = 16 }
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
		local _temp = { ["w"] = 64, ["h"] = 16 }
		return _temp
	end

	return selectedPattern
end

-- Set the Combo Points Style
local function SetComboPointsStyle(style)
	artstyle = style
	NeatPlates:ForceUpdate()
end

NeatPlatesWidgets.SetComboPointsStyle = SetComboPointsStyle

-- Update Graphics
local function UpdateWidgetFrame(frame)
	local points, maxPoints = GetPlayerPower()

	if points and points > 0 then
		local pattern = SelectPattern(maxPoints)

		if pattern == nil then
			print("[Neat Plates][ERROR] invalid pattern for " .. PlayerClass .. " - " .. playerSpec) -- should not happen
			frame:_Hide()
			return
		end

		local offset = pattern["o"];
		if maxPoints == 6 then
			frame.Icon:SetTexCoord(pattern["l"], pattern["r"], grid*(points + offset), grid *(points + offset + 1))
		elseif maxPoints == 50 then -- Warlock Specific
			local modPoints = math.floor(points/10)
			local fragments = points % 10
			frame.Icon:SetTexCoord(pattern["l"], pattern["r"], grid*(modPoints + offset), grid *(modPoints + 1 + offset))
			frame.PartialFill:SetTexCoord(pattern["l"], pattern["r"], grid*(modPoints + 1 + offset), grid*(math.min(6, modPoints + 2) + offset))
			frame.PartialFill:SetValue(fragments)

			if t[PlayerClass]["SPARK"] then
				frame.Spark.Texture:SetPoint("CENTER", frame, "CENTER", t[PlayerClass]["SPARK"][modPoints], 2) -- Offset texture per shard
				if frame.Spark.lastpower and modPoints > frame.Spark.lastpower then frame.Spark.Anim:Play() end -- Play Spark Animation
				frame.Spark.lastpower = modPoints
			end

			frame.PartialFill:SetStatusBarTexture(artfile[artstyle])
		else
			frame.Icon:SetTexCoord(pattern["l"], pattern["r"], grid*(points + offset - 1), grid *(points + offset))
		end

		frame.Icon:SetTexture(artfile[artstyle])

		frame:Show()
		return
	end

	frame:_Hide()
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
WatcherFrame:RegisterEvent("RUNE_POWER_UPDATE")
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

local function SetPlayerSpecData()
	local _, _class = UnitClass("player")
	local _specializationIndex = tonumber(GetSpecialization())

	if not _specializationIndex then
		playeRole = "DAMAGER"
		return
	end

	local _role = GetSpecializationRole(_specializationIndex)
	if _role == "HEALER" then
		playeRole = _role
	else
		playeRole = "DAMAGER"
	end

	playerSpec = GetSpecializationInfo(_specializationIndex)
	PlayerClass = _class
end

-- Widget Creation
local function CreateWidgetFrame(parent)
	SetPlayerSpecData()

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

	frame.Spark = CreateFrame("Frame", nil, frame)
	frame.Spark.Texture = frame.Spark:CreateTexture(nil, "OVERLAY")
	frame.Spark.Texture:SetPoint("CENTER", frame, "CENTER")
	frame.Spark.Texture:SetHeight(16)
	frame.Spark.Texture:SetWidth(16)
	frame.Spark.Texture:SetTexture(artpath.."ShardSpark.tga")
	frame.Spark.Texture:SetBlendMode("ADD")
	
	-- Spark Animation
	frame.Spark:SetAlpha(0)
	frame.Spark.Anim = frame.Spark:CreateAnimationGroup()
	frame.Spark.fadeIn = frame.Spark.Anim:CreateAnimation("Alpha")
	frame.Spark.fadeIn:SetFromAlpha(0)
	frame.Spark.fadeIn:SetToAlpha(1)
	frame.Spark.fadeIn:SetDuration(0.2)
	frame.Spark.fadeIn:SetOrder(1)
	frame.Spark.scaleIn = frame.Spark.Anim:CreateAnimation("Scale")
	frame.Spark.scaleIn:SetFromScale(0.6,0.6)
	frame.Spark.scaleIn:SetToScale(1.2,1.2)
	frame.Spark.scaleIn:SetDuration(0.25)
	frame.Spark.scaleIn:SetOrder(1)
	frame.Spark.scaleOut = frame.Spark.Anim:CreateAnimation("Scale")
	frame.Spark.scaleOut:SetFromScale(1.2,1.2)
	frame.Spark.scaleOut:SetToScale(0.1,0.1)
	frame.Spark.scaleOut:SetDuration(0.3)
	frame.Spark.scaleOut:SetOrder(2)
	frame.Spark.fadeOut = frame.Spark.Anim:CreateAnimation("Alpha")
	frame.Spark.fadeOut:SetFromAlpha(1)
	frame.Spark.fadeOut:SetToAlpha(0)
	frame.Spark.fadeOut:SetDuration(0.1)
	frame.Spark.fadeOut:SetOrder(2)

	if t[PlayerClass] and t[PlayerClass]["MinMax"] then
		local min, max = unpack(t[PlayerClass]["MinMax"][artstyle])
		frame.PartialFill:SetMinMaxValues(min, max)
	else
		frame.PartialFill:Hide()
	end

	-- Required Widget Code
	frame.UpdateContext = UpdateWidgetContext
	frame.Update = UpdateWidgetFrame
	frame._Hide = frame.Hide
	frame.Hide = function() ClearWidgetContext(frame); frame:_Hide() end
	if not isEnabled then EnableWatcherFrame(true) end
	return frame
end

-- Used to decide whether we should display player power indicator on the target or not
local function SpecWatcherEvent(self, event, ...)
	SetPlayerSpecData()
end

local SpecWatcher = CreateFrame("Frame")
SpecWatcher:SetScript("OnEvent", SpecWatcherEvent)
SpecWatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
SpecWatcher:RegisterEvent("GROUP_ROSTER_UPDATE")
SpecWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
SpecWatcher:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
SpecWatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
SpecWatcher:RegisterEvent("PLAYER_TALENT_UPDATE")

NeatPlatesWidgets.CreateComboPointWidget = CreateWidgetFrame
