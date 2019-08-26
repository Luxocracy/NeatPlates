---------------------------------------------
---- NeatPlates Range Widget ----
---------------------------------------------

local AddonName, NeatPlatesInternal = ...
local rc = LibStub('LibRangeCheck-2.0')

local font = "FONTS\\arialn.ttf"

local WidgetList = {}
local WidgetMode = 1
local WidgetStyle = 1
local WidgetUnits = 2 -- 1 - Target Only; 2 - All Units
local WidgetRange = 40
local WidgetScale = false
local WidgetWidthMod = 1
local WidgetColors = {}
local WidgetScaleOptions = {x = 1, y = 1, offset = {x = 0, y = 0}}

local WidgetIconSize = 10

--local art = "Interface\\Addons\\NeatPlatesWidgets\\RangeWidget\\RangeWidgetLine"
local artpath = "Interface\\Addons\\NeatPlatesWidgets\\RangeWidget\\"
local artfile = {
	artpath.."RangeWidgetLine",
	artpath.."RangeWidgetCircle",
}

--[[ Ticker that runs every 0.05 seconds ]]--
local function AttachNewTicker(frame)
	if not frame._ticker then
		frame._ticker = C_Timer.NewTicker(0.05, function(self)
			if not frame._ticker then self:Cancel() end
			frame:Update()
		end)
	end
end

local function GetWidgetSize(frame, minRange, maxRange)
	local width, height

	if WidgetStyle == 1 then
		width, height = frame:GetParent()._width or 100, 3
	else
		width, height = WidgetIconSize, WidgetIconSize
	end

	-- Apply user scaling
	width = width * WidgetScaleOptions.x
	height = height * WidgetScaleOptions.y

	-- Widget scaling by distance
	if minRange and maxRange then
		if WidgetScale and WidgetStyle == 1 then
			width = math.max(width*0.15, width*math.min(1, minRange/WidgetRange))
		elseif WidgetScale then
			width = math.max(width*0.15, width*math.min(1, minRange/WidgetRange))
			height = math.max(height*0.15, height*math.min(1, minRange/WidgetRange))
		end
	end

	return width, height
end

local function UpdateRangeWidget(frame, unit)
	if not unit or not frame._ticker then return end
	local minRange, maxRange = rc:GetRange(unit)
	local height = frame:GetParent()._height or 12;
	local width = frame:GetParent()._width or 100;

	if WidgetStyle == 1 then width = width * WidgetWidthMod end -- Account for width scale when using bar style
	
	frame:Show()
	frame:SetWidth(width); frame:SetHeight(32)

	if WidgetRange and minRange and maxRange then
		frame.Texture:Show()
		local color = {r = 0, g = 0, b = 0}

		if WidgetMode == 1 then
			if WidgetRange > minRange then
				color = WidgetColors["Mid"] or color -- Mid Range
			else
				color = WidgetColors["OOR"] or color -- Out of Range
			end
		else
			if WidgetRange > minRange and maxRange <= 5 then
				color = WidgetColors["Melee"] or color -- Melee Range
			elseif WidgetRange > minRange then
				if WidgetRange*0.75 <= minRange then
					color = WidgetColors["Far"] or color -- Far Range
				elseif WidgetRange*0.5 <= minRange then
					color = WidgetColors["Mid"] or color -- Mid Range
				else
					color = WidgetColors["Close"] or color -- Close Range
				end
			else
				color = WidgetColors["OOR"] or color -- Out of Range
			end
		end

		frame.Texture:SetVertexColor(color.r,color.g,color.b,color.a)
		width, height = GetWidgetSize(frame, minRange, maxRange)

		frame.Texture:SetWidth(width)
		frame.Texture:SetHeight(height)
		
	else
		frame.Texture:Hide()
	end
end

--[[ Called on Theme Change: Since bars aren't the same size we just have to update them ]]--
local function UpdateWidgetConfig(frame)
	local width = frame:GetParent()._width or 100
	local height = frame:GetParent()._height or 12

	if WidgetStyle == 1 then width = width * WidgetWidthMod end -- Account for width scale when using bar style

	frame.Texture:SetTexture(artfile[WidgetStyle])
	frame.Texture:SetScale(1)
	--if not WidgetScaling then
	--	if WidgetStyle == 1 then
	--		frame.Texture:SetHeight(3)
	--		frame.Texture:SetWidth(width)
	--	else
	--		frame.Texture:SetHeight(WidgetIconSize)
	--		frame.Texture:SetWidth(WidgetIconSize)
	--	end
	--end
	width, height = GetWidgetSize(frame)

	frame.Texture:SetWidth(width)
	frame.Texture:SetHeight(height)

	frame.Texture:SetPoint("CENTER", frame, "CENTER", WidgetScaleOptions.offset.x, WidgetScaleOptions.offset.y)
end

-- [[ Widget frame self update ]] --
local function UpdateWidget(frame)
	local unitid = frame.unitid
	UpdateRangeWidget(frame, unitid)
end

-- Context
local function UpdateWidgetContext(frame, unit)
	local guid = unit.guid
	local unitid = unit.unitid
	frame.unitid = unitid

	if guid then
		if frame.guid then WidgetList[frame.guid] = nil end
		frame.guid = guid
		WidgetList[guid] = frame
	end

	--[[ Update Widget Frame ]]--
	--frame:UnregisterAllEvents()

	if unit.style == "Default" and (WidgetUnits == 2 or (WidgetUnits == 1 and UnitGUID("target") == guid)) then
		AttachNewTicker(frame)
	else
		frame._ticker = nil
		frame:Hide()
	end
	
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
	local height = frame:GetParent()._height or 12;
	local width = frame:GetParent()._width or 100

	if WidgetStyle == 1 then width = width * WidgetWidthMod end -- Account for width scale when using bar style

	--[[ Widget Config can now pass width or height data from theme config ]]--
	frame:SetWidth(16); frame:SetHeight(16)
	frame.Texture = frame:CreateTexture(nil, "OVERLAY")
	frame.Texture:SetTexture(artfile[WidgetStyle])
	frame.Texture:SetPoint("CENTER", frame, "CENTER", WidgetScaleOptions.offset.x, WidgetScaleOptions.offset.y)
	frame.Texture:SetScale(1)

	--if WidgetStyle == 1 then
	--	frame.Texture:SetHeight(3)
	--	frame.Texture:SetWidth(width)
	--else
	--	frame.Texture:SetHeight(WidgetIconSize)
	--	frame.Texture:SetWidth(WidgetIconSize)
	--end

	width, height = GetWidgetSize(frame)

	frame.Texture:SetWidth(width)
	frame.Texture:SetHeight(height)
	

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
	WidgetMode = LocalVars.WidgetRangeMode
	WidgetStyle = LocalVars.WidgetRangeStyle
	WidgetUnits = LocalVars.WidgetRangeUnits
	WidgetRange = LocalVars.WidgetRangeMax
	WidgetScale = LocalVars.WidgetRangeScale
	WidgetScaleOptions = LocalVars.WidgetRangeScaleOptions
	--WidgetPos.x = LocalVars.WidgetOffsetX
	--WidgetPos.y = LocalVars.WidgetOffsetY
	WidgetWidthMod = LocalVars.FrameBarWidth or 1
	WidgetColors["Melee"] = LocalVars.ColorRangeMelee
	WidgetColors["Close"] = LocalVars.ColorRangeClose
	WidgetColors["Mid"] = LocalVars.ColorRangeMid
	WidgetColors["Far"] = LocalVars.ColorRangeFar
	WidgetColors["OOR"] = LocalVars.ColorRangeOOR
end

NeatPlatesWidgets.UpdateRangeWidget = UpdateRangeWidget
NeatPlatesWidgets.CreateRangeWidget = CreateWidgetFrame
NeatPlatesWidgets.SetRangeWidgetOptions = SetRangeWidgetOptions




--			