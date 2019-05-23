---------------------------------------------
---- Neat Plates Range Widget ----
---------------------------------------------

local AddonName, NeatPlatesInternal = ...
local rc = LibStub('LibRangeCheck-2.0')

local font = "FONTS\\arialn.ttf"

local WidgetList = {}
local WidgetUnits = 2
local WidgetRange = 40

local art = "Interface\\Addons\\NeatPlatesWidgets\\RangeWidget\\RangeWidget"

--[[ Ticker that runs every 0.05 seconds ]]--
local function AttachNewTicker(frame)
	if not frame._ticker then
		frame._ticker = C_Timer.NewTicker(0.05, function(self)
			if not frame._ticker then self:Cancel() end
			frame:Update()
		end)
	end
end

local function UpdateRangeWidget(frame, unit)
	if not unit then return end
	local minRange, maxRange = rc:GetRange(unit)
	frame:Show()

	if WidgetRange and minRange and maxRange then
		frame.Texture:Show()

		if WidgetRange > minRange then
			frame.Texture:SetVertexColor(.25,1,0,.50)  -- Green
		else
			frame.Texture:SetVertexColor(1,.25,0,.50)  -- Red
		end
	else
		frame.Texture:Hide()
	end
end

--[[ Called on Theme Change: Since bars aren't the same size we just have to update them ]]--
local function UpdateWidgetConfig(frame)

end

-- [[ Widget frame self update ]] --
local function UpdateWidget(frame)
	local unitid = frame.unitid
	UpdateRangeWidget(frame, unitid)
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

	AttachNewTicker(frame)
	UpdateRangeWidget(frame, unitid)
end

local function ClearWidgetContext(frame)
	local guid = frame.guid
	if guid then
		WidgetList[guid] = nil
		frame.guid = nil
	end
end

-- Widget Creation
local function CreateWidgetFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)

	--[[ Widget Config can now pass width or height data from theme config ]]--
	frame:SetWidth(16); frame:SetHeight(16)
	frame.Texture = frame:CreateTexture(nil, "OVERLAY")
	frame.Texture:SetTexture(art)
	frame.Texture:SetPoint("CENTER")
	frame.Texture:SetWidth(128)
	frame.Texture:SetHeight(128)

	-- Required Widget Code
	frame.UpdateContext = UpdateWidgetContext
	frame.Update = UpdateWidget
	frame.UpdateConfig = UpdateWidgetConfig
	frame._Hide = frame.Hide
	frame.Hide = function()
	frame._ticker = nil
	ClearWidgetContext(frame);
	frame:_Hide()
	end
	
	return frame
end

local function SetRangeWidgetOptions(LocalVars)
	WidgetRange = LocalVars.WidgetMaxRange
end

NeatPlatesWidgets.UpdateRangeWidget = UpdateRangeWidget
NeatPlatesWidgets.CreateRangeWidget = CreateWidgetFrame
NeatPlatesWidgets.SetRangeWidgetOptions = SetRangeWidgetOptions




--			