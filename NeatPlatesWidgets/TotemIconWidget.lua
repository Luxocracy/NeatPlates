--------------------
-- Totem Icon Widget
--------------------
local classWidgetPath = "Interface\\Addons\\NeatPlatesWidgets\\ClassWidget\\"
local TotemIcons, TotemTypes = {}, {}
local TotemFont = "FONTS\\ARIALN.TTF"


local AIR_TOTEM, EARTH_TOTEM, FIRE_TOTEM, WATER_TOTEM = 1, 2, 3, 4

local function SetTotemInfo(spellid, totemType)
	local name, _, icon = GetSpellInfo(spellid)
	if name and icon then --and totemType
		TotemIcons[name] = icon
		TotemTypes[name] = totemType
	end
end

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
local wowtocversion = tonumber((select(4, GetBuildInfo())))
if (wowtocversion >= 90000) then
-- Shadowlands update
	-- Covenant totems
	SetTotemInfo(324386,UNSPECIFIED_TOTEM) -- Vesper Totem
end

if (wowtocversion >= 70000) then
-- Legion Update
	-- Talent Totems
	SetTotemInfo(207399,UNSPECIFIED_TOTEM) -- Ancestral Protection Totem
	SetTotemInfo(157153,UNSPECIFIED_TOTEM) -- Cloudburst Totem
	SetTotemInfo(192058,UNSPECIFIED_TOTEM) -- Lightning Surge Totem
	SetTotemInfo(198838,UNSPECIFIED_TOTEM) -- Earthen Shield Totem
	SetTotemInfo(192077,UNSPECIFIED_TOTEM) -- Wind Rush Totem
	SetTotemInfo(196932,UNSPECIFIED_TOTEM) -- Voodoo Totem
	SetTotemInfo(51485,UNSPECIFIED_TOTEM)  -- Earthgrab Totem
	SetTotemInfo(192222,UNSPECIFIED_TOTEM) -- Liquid Magma Totem

	-- Totem Mastery Totems
	SetTotemInfo(202188,UNSPECIFIED_TOTEM) -- Resonance Totem
	SetTotemInfo(210651,UNSPECIFIED_TOTEM) -- Storm Totem
	SetTotemInfo(210657,UNSPECIFIED_TOTEM) -- Ember Totem
	SetTotemInfo(210660,UNSPECIFIED_TOTEM) -- Tailwind Totem

	-- Honor Talent Totems
	SetTotemInfo(204331,AIR_TOTEM)         -- Counterstrike Totem
	SetTotemInfo(204330,FIRE_TOTEM)        -- Skyfury Totem
	SetTotemInfo(204332,UNSPECIFIED_TOTEM) -- Windfury Totem
	SetTotemInfo(204336,AIR_TOTEM)         -- Grounding Totem

	-- Specialization Totems
	SetTotemInfo(98008,UNSPECIFIED_TOTEM)  -- Spirit Link Totem
	SetTotemInfo(108280,UNSPECIFIED_TOTEM) -- Healing Tide Totem
	SetTotemInfo(5394,UNSPECIFIED_TOTEM)   -- Healing Stream Totem
	SetTotemInfo(61882,UNSPECIFIED_TOTEM)  -- Earthquake Totem

elseif(not NEATPLATES_IS_CLASSIC) then
	-- Mists of Pandaria 5.x Specific Totems
	SetTotemInfo(120668, AIR_TOTEM) --  Stormlash
	SetTotemInfo(108273, AIR_TOTEM) --  Windwalk
	SetTotemInfo(98008, AIR_TOTEM)  --  Spirit Link
	SetTotemInfo(108269, AIR_TOTEM)  --  Capacitor Totem

	SetTotemInfo(51485, EARTH_TOTEM)  -- Earthgrab Totem
	SetTotemInfo(108270, EARTH_TOTEM)  -- Stone Bulwark Totem

	SetTotemInfo(108280, WATER_TOTEM)  -- Healing Tide Totem

	-- Cataclysm 4.x Specific Totems
	SetTotemInfo(8512,AIR_TOTEM) -- Windfury Totem
	SetTotemInfo(3738,AIR_TOTEM) -- Wrath of Air Totem

	SetTotemInfo(5730,EARTH_TOTEM) -- Stoneclaw Totem
	SetTotemInfo(8071,EARTH_TOTEM) -- Stoneskin Totem
	SetTotemInfo(8075,EARTH_TOTEM)  -- Strength of Earth Totem

	SetTotemInfo(8227,FIRE_TOTEM) -- Flametongue Totem

	SetTotemInfo(8184,WATER_TOTEM)  -- Elemental Resistance Totem
	SetTotemInfo(5675,WATER_TOTEM) -- Mana Spring Totem
	SetTotemInfo(87718,WATER_TOTEM) -- Totem of Tranquil Mind

elseif (NEATPLATES_IS_CLASSIC) then
	SetTotemInfo(8170, WATER_TOTEM) 		-- Disease Cleansing Totem
	SetTotemInfo(1535, FIRE_TOTEM) 			-- Fire Nova Totem
	SetTotemInfo(8184, WATER_TOTEM) 		-- Fire Resistance Totem
	SetTotemInfo(8227, FIRE_TOTEM) 			-- Flametongue Totem
	SetTotemInfo(8181, FIRE_TOTEM) 			-- Frost Resistance Totem
	SetTotemInfo(8835, AIR_TOTEM) 			-- Grace of Air Totem
	SetTotemInfo(5675, WATER_TOTEM) 		-- Mana Spring Totem
	SetTotemInfo(10595, AIR_TOTEM) 			-- Nature Resistance Totem
	SetTotemInfo(5730, EARTH_TOTEM) 		-- Stoneclaw Totem
	SetTotemInfo(8166, WATER_TOTEM) 		-- Poison Cleansing Totem
	SetTotemInfo(6495, AIR_TOTEM) 			-- Sentry Totem
	SetTotemInfo(8071, EARTH_TOTEM) 		-- Stoneskin Totem
	SetTotemInfo(8075, EARTH_TOTEM) 		-- Strength of Earth Totem
	SetTotemInfo(25908, AIR_TOTEM) 			-- Tranquil Air Totem
	SetTotemInfo(8512, AIR_TOTEM) 			-- Windfury Totem
	SetTotemInfo(15107, AIR_TOTEM) 			-- Windwall Totem
	SetTotemInfo(3738, AIR_TOTEM) 			-- Wrath of Air Totem
end


	SetTotemInfo(8177, AIR_TOTEM) -- Grounding Totem

	SetTotemInfo(2062,EARTH_TOTEM) -- Earth Elemental Totem
	SetTotemInfo(2484,EARTH_TOTEM) -- Earthbind Totem
	SetTotemInfo(8143,EARTH_TOTEM) -- Tremor Totem

	SetTotemInfo(2894, FIRE_TOTEM)  -- Fire Elemental Totem
	SetTotemInfo(8190, FIRE_TOTEM)  -- Magma Totem
	SetTotemInfo(3599, FIRE_TOTEM)  -- Searing Totem

	SetTotemInfo(5394, WATER_TOTEM)  -- Healing Stream Totem
	SetTotemInfo(16190, WATER_TOTEM)  -- Mana Tide Totem



----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

local function IsTotem(name) if name then return (TotemIcons[name] ~= nil) end end
local function TotemSlot(name) if name then return TotemTypes[name] end end

local function UpdateWidgetTime(frame)
	expiration = frame.expiration or 0
	local timeleft = expiration-GetTime()
	if timeleft <= 0 or HideAuraDuration then
		frame.TimeLeft:SetText("")
	else
		if timeleft > 60 then
			frame.TimeLeft:SetText(round(timeleft/60).."m")
		else
			-- if timeleft < PreciseAuraThreshold then
			-- 	frame.TimeLeft:SetText((("%%.%df"):format(1)):format(timeleft))
			-- else
				frame.TimeLeft:SetText(floor(timeleft))
			-- end
			--frame.TimeLeft:SetText(floor(timeleft*10)/10)
		end
	end
end

local function ExpireFunction(icon)
	UpdateWidget(icon.Parent)
end

function UpdateWidget(frame)
	-- local unitid = frame.unitid
	-- if(HideInHeadlineMode and frame.style == "NameOnly") then
	-- 	frame:Hide()
	-- else
	-- 	frame:Show()
	-- end
	-- UpdateIconGrid(frame, unitid)
end

local function UpdateTotemIconWidget(self, unit)
	local icon = TotemIcons[unit.name]

	if icon then
		self.Icon:SetTexture(icon)
		self:Show()
		UpdateWidgetTime(self)
	end
end

local function UpdateWidgetConfig(frame)
	local width = frame:GetParent()._width or 19;
	local height = frame:GetParent()._height or 18;
	frame:SetWidth(width); frame:SetHeight(height)

	--  Time Text
	frame.TimeLeft:SetFont(TotemFont, 9, "OUTLINE")
	frame.TimeLeft:SetShadowOffset(1, -1)
	frame.TimeLeft:SetShadowColor(0,0,0,1)
	frame.TimeLeft:SetPoint("RIGHT", 0, 8)
	frame.TimeLeft:SetWidth(26)
	frame.TimeLeft:SetHeight(16)
	frame.TimeLeft:SetJustifyH("RIGHT")
	--  Stacks
	frame.Stacks:SetFont(TotemFont, 10, "OUTLINE")
	frame.Stacks:SetShadowOffset(1, -1)
	frame.Stacks:SetShadowColor(0,0,0,1)
	frame.Stacks:SetPoint("RIGHT", 0, -6)
	frame.Stacks:SetWidth(26)
	frame.Stacks:SetHeight(16)
	frame.Stacks:SetJustifyH("RIGHT")

	local expiration = 0
	for i=1,5 do
		local exists, name, startTime, duration = GetTotemInfo(i)
		if exists and TotemTypes[name] == i then
			frame.expiration = startTime+duration + 1 -- Because the given time is off by about a second
			frame.Cooldown:SetCooldown(startTime, duration + 1)
			break
		end
	end


	UpdateWidgetTime(frame)

	-- frame.Overlay:SetAllPoints(frame)
	frame.Icon:SetPoint("CENTER",frame)
	frame.Icon:SetAllPoints(frame)
end

local function CreateTotemIconWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)

	-- frame.Overlay = frame:CreateTexture(nil, "OVERLAY")
	-- frame.Overlay:SetTexture(classWidgetPath.."BORDER")
	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetTexCoord(.07, 1-.07, .07, 1-.07)  -- obj:SetTexCoord(left,right,top,bottom)
	frame.Cooldown = CreateFrame("Cooldown", nil, frame, "NeatPlatesAuraWidgetCooldown")
	frame.Info = CreateFrame("Frame", nil, frame)

	frame.Cooldown:SetAllPoints(frame)
	frame.Cooldown:SetReverse(true)
	frame.Cooldown:SetHideCountdownNumbers(true)
	frame.Cooldown:SetDrawEdge(true)
	frame.Cooldown.noCooldownCount = true -- Disable OmniCC interaction

	frame.Info:SetAllPoints(frame)

	-- Text
	frame.TimeLeft = frame.Info:CreateFontString(nil, "OVERLAY")
	frame.Stacks = frame.Info:CreateFontString(nil, "OVERLAY")

	frame.Expire = ExpireFunction
	frame.Poll = UpdateWidgetTime

	UpdateWidgetConfig(frame)

	frame:Hide()
	frame.Update = UpdateTotemIconWidget
	frame.UpdateConfig = UpdateWidgetConfig
	return frame
end

NeatPlatesWidgets.CreateTotemIconWidget = CreateTotemIconWidget
NeatPlatesUtility.IsTotem = IsTotem
NeatPlatesUtility.TotemSlot = TotemSlot
