---------------------------------------------
---- Tidy Plates Continued Absorb Widget ----
---------------------------------------------

local font = "FONTS\\arialn.ttf"
-- local art = "Interface\\Addons\\TidyPlatesContinuedWidgets\\AbsorbWidget\\Absorbs"
-- local artVertical = "Interface\\Addons\\TidyPlatesContinuedWidgets\\AbsorbWidget\\Absorbs"
local art = {
	["HORIZONTAL"] = "Interface\\Addons\\TidyPlatesContinuedWidgets\\AbsorbWidget\\Absorbs",
	["VERTICAL"] = "Interface\\Addons\\TidyPlatesContinuedWidgets\\AbsorbWidget\\AbsorbsVertical"
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
	frame.Line:SetHeight(height)
	frame.Line:SetWidth(width)
	frame._orientation = orientation
	-- frame:SetWidth(width)
	-- frame.Line:SetHeight(height)
	frame.Line:SetTexture(art[orientation], "REPEAT", "REPEAT")
	frame.Line:SetTexCoord(0,1,0,1)

	if orientation == "VERTICAL" then
		frame._frameWidth = height
		frame.Line:SetHorizTile(false)
		frame.Line:SetVertTile(true)
	else
		frame._frameWidth = width
		frame.Line:SetVertTile(false)
		frame.Line:SetHorizTile(true)
	end
end

--[[ Actual Absorb update ]]--
local function UpdateAbsorbs(frame, unitid)
	local _frameWidth = frame._frameWidth
	local _orientation = frame._orientation
	local length = 0
	-- local anchor = "RIGHT"
	local absorb = UnitGetTotalAbsorbs(unitid) or 0	
  local health = UnitHealth(unitid) or 0
	local healthmax = UnitHealthMax(unitid) or 1
	
	-- absorb = healthmax -- This is just for testing the bars

	--[[ We wont update the widget until something has changed ]] --
	if lastWidget == frame and frame.lastAbsorb ~= nil and frame.lastAbsorb == absorb and
		frame.lasthp ~= nil and frame.lasthp == health and
		frame.lastmaxhp ~= nil and frame.lastmaxhp == healthmax then 
		return
	end
	
	--[[ Let's store the last values ]] --
	frame.lastAbsorb = absorb
	frame.lasthp = health
	frame.lastmaxhp = healthmax

	if absorb == 0 then 
		frame:_Hide(); 
		return 
	end
	
	if WidgetMode == 1 then
		length = _frameWidth * absorb/healthmax
	else
		length = _frameWidth * min(absorb, health)/healthmax
	end
	
	if (length < 0) then length = 0 end
    
	if absorb > 0 and length > 0 then
		local helper = _frameWidth * health/healthmax
		local width = max(1, min( _frameWidth, length))
		local offset = helper - length

		if WidgetMode == 1 then
			offset = helper
			if offset + width >= _frameWidth then
				if _frameWidth == helper then
					offset = offset - _frameWidth*0.015
				end 

				width = _frameWidth - offset
			end
		end

		-- anchor = "LEFT"
		frame.Line:ClearAllPoints()
		if _orientation == "VERTICAL" then
			frame.Line:SetHeight(width)
			frame.Line:SetPoint("BOTTOM", frame, "BOTTOM", 0, offset)
		else
			frame.Line:SetWidth(width)
			frame.Line:SetPoint("LEFT", frame, "LEFT", offset, -1)
		end	

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

local function UpdateWidgetTarget(frame)
	if UnitExists("target") then
		UpdateAbsorbs(frame, "target")
	else
		frame:Hide()
	end
end

-- Context
local function UpdateWidgetContext(frame, unit)
	local guid = unit.guid
	frame.unitid = unitid
	
	if guid then
		if frame.guid then WidgetList[frame.guid] = nil end
		frame.guid = guid
		WidgetList[guid] = frame
	end

	--[[ Update Widget Frame ]]--
	frame:UnregisterAllEvents()

	if WidgetUnits == 2 or (WidgetUnits == 1 and UnitGUID("target") == guid) then
		frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unitid)
		frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unitid)
		frame:RegisterUnitEvent("UNIT_HEALTH", unitid)
		frame:RegisterUnitEvent("UNIT_AURA", unitid)
		frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unitid)
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
WatcherFrame:RegisterEvent("UNIT_HEALTH_FREQUENT")

local function WatcherFrameHandler(frame, event, unitid)
	local guid = UnitGUID("target")
	if UnitExists("target") then
		local widget = WidgetList[guid]
		if widget then
			UpdateAbsorbs(widget, widget.unitid)
			lastWidget = widget
		end
	else
		lastWidget = nil
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
	frame.Line = frame:CreateTexture(nil, "OVERLAY")
	frame.Line:SetTexture(art[orientation], "REPEAT", "REPEAT")
	frame.Line:SetTexCoord(0,1,0,1)
	frame.Line:SetHeight(height)
	frame.Line:SetWidth(width)
	frame:SetAlpha(1)

	if orientation == "VERTICAL" then
		frame._frameWidth = height
		frame.Line:SetHorizTile(false)
		frame.Line:SetVertTile(true)
	else
		frame._frameWidth = width
		frame.Line:SetVertTile(false)
		frame.Line:SetHorizTile(true)
	end

	-- Required Widget Code
	frame.UpdateContext = UpdateWidgetContext
	-- frame.Update = UpdateWidgetTarget
	frame.Update = UpdateWidget
	frame.UpdateConfig = UpdateWidgetConfig
	frame._Hide = frame.Hide
	frame.Hide = function() 
	frame.lastAbsorb = 0
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
	TidyPlatesCont:ForceUpdate()
end

TidyPlatesContWidgets.CreateAbsorbWidget = CreateWidgetFrame

TidyPlatesContWidgets.SetAbsorbType = SetAbsorbType