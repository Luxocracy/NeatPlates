---------------------------------------------
---- NeatPlates Absorb Widget ----
---------------------------------------------

local font = "FONTS\\arialn.ttf"
-- local art = "Interface\\Addons\\NeatPlatesWidgets\\AbsorbWidget\\Absorbs"
-- local artVertical = "Interface\\Addons\\NeatPlatesWidgets\\AbsorbWidget\\Absorbs"
local ArtDamage = {
	["HORIZONTAL"] = "Interface\\Addons\\NeatPlatesWidgets\\AbsorbWidget\\Absorbs",
	["VERTICAL"] = "Interface\\Addons\\NeatPlatesWidgets\\AbsorbWidget\\AbsorbsVertical"
}
local ArtHealing = {
	["HORIZONTAL"] = "Interface\\Addons\\NeatPlatesWidgets\\AbsorbWidget\\HealingAbsorbs",
	["VERTICAL"] = "Interface\\Addons\\NeatPlatesWidgets\\AbsorbWidget\\HealingAbsorbsVertical"
}

local WidgetList = {}
local WidgetMode = 1 -- 1 - Blizzard; 2 - Overlay
local WidgetUnits = 1 -- 1 - Target Only; 2 - All Units

--[[ Called on Theme Change: Since bars aren't the same size we just have to update them ]]--
local function UpdateWidgetConfig(frame)
	local height = frame:GetParent()._height or 12;
	local width = frame:GetParent()._width or 100;
	local orientation = frame:GetParent()._orientation or "HORIZONTAL";

	frame:SetHeight(32)
	frame:SetWidth(width)
	frame._orientation = orientation
	frame.LineDamage:SetTexture(ArtDamage[orientation], "REPEAT", "REPEAT")
	frame.LineHealing:SetTexture(ArtHealing[orientation], "REPEAT", "REPEAT")
	frame.LineDamage:SetTexCoord(0,1,11/32,22/32)
	frame.LineHealing:SetTexCoord(0,1,11/32,22/32)

	if orientation == "VERTICAL" then
		frame._frameWidth = height
		frame.LineDamage:SetHorizTile(false)
		frame.LineHealing:SetHorizTile(false)
		frame.LineDamage:SetVertTile(true)
		frame.LineHealing:SetVertTile(true)
	else
		frame._frameWidth = width
		frame.LineDamage:SetVertTile(false)
		frame.LineHealing:SetVertTile(false)
		frame.LineDamage:SetHorizTile(true)
		frame.LineHealing:SetHorizTile(true)
	end
end

--[[ Actual Absorb update ]]--
local function UpdateAbsorbs(frame, unitid)
	local _frameWidth = frame._frameWidth
	local _orientation = frame._orientation
	local showFrame = false
	-- local anchor = "RIGHT"
	local absorb = {
		["damage"] = UnitGetTotalAbsorbs(unitid) or 0,
		["healing"] = UnitGetTotalHealAbsorbs(unitid) or 0,
	}
  local health = UnitHealth(unitid) or 0
	local healthmax = UnitHealthMax(unitid) or 1
	
	-- For testing absorbs
	--absorb.damage = healthmax/2
	--absorb.healing = healthmax/4

	--[[ We wont update the widget until something has changed ]] --
	if frame.lastAbsorb ~= nil and frame.lastAbsorb.damage == absorb.damage and
		frame.lastAbsorb.healing == absorb.healing and
		frame.lasthp ~= nil and frame.lasthp == health and
		frame.lastmaxhp ~= nil and frame.lastmaxhp == healthmax and
		frame.lastStyle ~= nil and frame.lastStyle == "Default" then
		return
	end
	
	--[[ Let's store the last values ]] --
	frame.lastAbsorb = absorb
	frame.lasthp = health
	frame.lastmaxhp = healthmax

	if absorb.damage == 0 and absorb.healing == 0 then
		frame:_Hide();
		return
	end

	for k,v in pairs(absorb) do
		local length = 0
		local type = {
			["damage"] = "LineDamage",
			["healing"] = "LineHealing",
		}

		if absorb[k] ~= 0 then
			frame[type[k]]:SetAlpha(1)
			-- Determine which style of absorbs should be displayed
			if v == absorb.damage and WidgetMode == 1 then
				length = max(0, _frameWidth * v/healthmax)	-- Blizzard
			else
				length = max(0, _frameWidth * min(v, health)/healthmax) -- Overlay
			end

			if v > 0 and length > 0 then
				local helper = _frameWidth * (health/healthmax)
				local width = max(1, min( _frameWidth, length))
				local offset = helper - length

				if v == absorb.damage and WidgetMode == 1 then
					offset = helper
					if offset + width >= _frameWidth then
						if _frameWidth == helper then
							offset = offset - _frameWidth*0.015
						end 

						width = _frameWidth - offset
					end
				end

				-- Set which absorb is overlayed on top of the other
				if (v == absorb.damage and absorb.damage > absorb.healing) or (v == absorb.healing and absorb.healing > absorb.damage) then
					frame[type[k]]:SetDrawLayer("BACKGROUND")
				else
					frame[type[k]]:SetDrawLayer("OVERLAY")
				end

				frame[type[k]]:ClearAllPoints()
				if _orientation == "VERTICAL" then
					frame[type[k]]:SetHeight(width)
					frame[type[k]]:SetPoint("BOTTOM", frame, "BOTTOM", 0, offset)
				else
					frame[type[k]]:SetWidth(width)
					frame[type[k]]:SetPoint("LEFT", frame, "LEFT", offset, -1)
				end

				showFrame = true -- Show frame
			end
		else
			frame[type[k]]:SetAlpha(0)
		end
	end

	if showFrame then
		frame:Show()
	else
		frame:_Hide()
	end
end

-- [[ Widget frame self update ]] --
local function UpdateWidget(frame)
	local unitid = frame.unitid
	UpdateAbsorbs(frame, unitid)
end

-- Context
local function UpdateWidgetContext(frame, unit)
	local guid = unit.guid
	local unitid = unit.unitid
	frame.unitid = unitid
	frame.lastStyle = unit.style

	if guid then
		if frame.guid then WidgetList[frame.guid] = nil end
		frame.guid = guid
		WidgetList[guid] = frame
	end

	--[[ Update Widget Frame ]]--
	frame:UnregisterAllEvents()

	if unit.style == "Default" and (WidgetUnits == 2 or (WidgetUnits == 1 and UnitGUID("target") == guid)) then
		frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unitid)
		frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unitid)
		frame:RegisterUnitEvent("UNIT_HEALTH", unitid)
		frame:RegisterUnitEvent("UNIT_AURA", unitid)
		frame:SetScript("OnEvent", UpdateWidget);
		UpdateAbsorbs(frame, unitid)
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

--[[ Target chancge check + a little extra to be sure ]]--
local WatcherFrame = CreateFrame("Frame", nil, WorldFrame )
local isEnabled = false
WatcherFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
WatcherFrame:RegisterEvent("UNIT_HEALTH")

local function WatcherFrameHandler(frame, event, unitid)
	local guid = UnitGUID("target")
	if UnitExists("target") then
		local widget = WidgetList[guid]
		if widget then
			UpdateAbsorbs(widget, widget.unitid)
			--lastWidget = widget
		end
	--else
	--	lastWidget = nil
	end
end

local function EnableWatcherFrame(arg)
	if arg then
		WatcherFrame:SetScript("OnEvent", WatcherFrameHandler); isEnabled = true
	else WatcherFrame:SetScript("OnEvent", nil); isEnabled = false end
end

-- Widget Creation
local function CreateWidgetFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)

	--[[ Widget Config can now pass width or height data from theme config ]]--
	local height = frame:GetParent()._height or 12;
	local width = frame:GetParent()._width or 100;
	local orientation = parent._orientation or "HORIZONTAL"

	-- frame._frameWidth = width
	frame._orientation = orientation
	frame:Hide()
	frame:SetWidth(width)
	frame:SetHeight(32)
	frame.LineDamage = frame:CreateTexture(nil, "OVERLAY")
	frame.LineHealing = frame:CreateTexture(nil, "OVERLAY")
	frame.LineDamage:SetTexture(ArtDamage[orientation], "REPEAT", "REPEAT")
	frame.LineHealing:SetTexture(ArtHealing[orientation], "REPEAT", "REPEAT")
	frame.LineDamage:SetTexCoord(0,1,11/32,22/32)
	frame.LineHealing:SetTexCoord(0,1,11/32,22/32)
	frame.LineDamage:SetHeight(height)
	frame.LineHealing:SetHeight(height)
	frame.LineDamage:SetWidth(width)
	frame.LineHealing:SetWidth(width)
	frame:SetAlpha(1)

	if orientation == "VERTICAL" then
		frame._frameWidth = height
		frame.LineDamage:SetHorizTile(false)
		frame.LineHealing:SetHorizTile(false)
		frame.LineDamage:SetVertTile(true)
		frame.LineHealing:SetVertTile(true)
	else
		frame._frameWidth = width
		frame.LineDamage:SetVertTile(false)
		frame.LineHealing:SetVertTile(false)
		frame.LineDamage:SetHorizTile(true)
		frame.LineHealing:SetHorizTile(true)
	end

	-- Required Widget Code
	frame.UpdateContext = UpdateWidgetContext
	frame.Update = UpdateWidget
	frame.UpdateConfig = UpdateWidgetConfig
	frame._Hide = frame.Hide
	frame.Hide = function() 
	frame.lastAbsorb = {
		["damage"] = 0,
		["healing"] = 0,
	}
	frame.lasthp = 0
	frame.lastmaxhp = 0
	ClearWidgetContext(frame);
	frame:_Hide()
	end
	
	if not isEnabled then EnableWatcherFrame(true) end
	return frame
end

local function SetAbsorbType(mode, units)
	WidgetMode = mode
	WidgetUnits = units
	NeatPlates:ForceUpdate()
end

NeatPlatesWidgets.CreateAbsorbWidget = CreateWidgetFrame
NeatPlatesWidgets.SetAbsorbType = SetAbsorbType