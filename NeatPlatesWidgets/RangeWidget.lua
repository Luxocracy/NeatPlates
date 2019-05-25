---------------------------------------------
---- Neat Plates Range Widget ----
---------------------------------------------

local AddonName, NeatPlatesInternal = ...
local rc = LibStub('LibRangeCheck-2.0')

local font = "FONTS\\arialn.ttf"

local WidgetList = {}
local WidgetMode = 1
local WidgetStyle = 1
local WidgetRange = 40
local WidgetScale = false
local WidgetColors = {}
local WidgetPos = {x = 0, y = 0}

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

local function UpdateRangeWidget(frame, unit)
	if not unit then return end
	local minRange, maxRange = rc:GetRange(unit)
	local height = frame:GetParent()._height or 12;
	local width = frame:GetParent()._width or 100;
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

		if WidgetScale and WidgetStyle == 1 then
			frame.Texture:SetWidth(math.max(width*0.15, width*math.min(1, minRange/WidgetRange)))
		elseif WidgetScale then
			local scaleSize = math.max(WidgetIconSize*0.15, WidgetIconSize*math.min(1, minRange/WidgetRange))
			frame.Texture:SetHeight(scaleSize)
			frame.Texture:SetWidth(scaleSize)
		end
	else
		frame.Texture:Hide()
	end
end

--[[ Called on Theme Change: Since bars aren't the same size we just have to update them ]]--
local function UpdateWidgetConfig(frame)
	local width = frame:GetParent()._width or 100
	local height = frame:GetParent()._height or 12

	frame.Texture:SetScale(1)
	if not WidgetScale then
		if WidgetStyle == 1 then
			frame.Texture:SetHeight(3)
			frame.Texture:SetWidth(width)
		else
			frame.Texture:SetHeight(WidgetIconSize)
			frame.Texture:SetWidth(WidgetIconSize)
		end
	end

	frame.Texture:SetPoint("CENTER", frame, "CENTER", WidgetPos.x, WidgetPos.y)
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
	--frame:UnregisterAllEvents()

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
	local height = frame:GetParent()._height or 12;
	local width = frame:GetParent()._width or 100;

	--[[ Widget Config can now pass width or height data from theme config ]]--
	frame:SetWidth(16); frame:SetHeight(16)
	frame.Texture = frame:CreateTexture(nil, "OVERLAY")
	frame.Texture:SetTexture(artfile[WidgetStyle])
	frame.Texture:SetPoint("CENTER", frame, "CENTER", WidgetPos.x, WidgetPos.y)
	frame.Texture:SetScale(1)

	if WidgetStyle == 1 then
		frame.Texture:SetHeight(3)
		frame.Texture:SetWidth(width)
	else
		frame.Texture:SetHeight(WidgetIconSize)
		frame.Texture:SetWidth(WidgetIconSize)
	end
	

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
	WidgetRange = LocalVars.WidgetMaxRange
	WidgetScale = LocalVars.WidgetRangeScale
	WidgetPos.x = LocalVars.WidgetOffsetX
	WidgetPos.y = LocalVars.WidgetOffsetY
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