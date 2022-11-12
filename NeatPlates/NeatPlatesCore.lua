-- NeatPlates - SMILE! :-D

---------------------------------------------------------------------------------------------------------------------
-- Variables and References
---------------------------------------------------------------------------------------------------------------------
local addonName, NeatPlatesInternal = ...
local L = LibStub("AceLocale-3.0"):GetLocale("NeatPlates")
local NeatPlatesCore = CreateFrame("Frame", nil, WorldFrame)
local NeatPlatesTarget
local GetPetOwner = NeatPlatesUtility.GetPetOwner
local ParseGUID = NeatPlatesUtility.ParseGUID
NeatPlates = {}
NeatPlatesSpellDB = {}

if NEATPLATES_IS_CLASSIC then
	UnitEffectiveLevel = UnitLevel
end

-- Local References
local _
local max = math.max
local round = NeatPlatesUtility.round
local fade = NeatPlatesUtility.fade
local select, pairs, tostring  = select, pairs, tostring 			    -- Local function copy
local CreateNeatPlatesStatusbar = CreateNeatPlatesStatusbar			    -- Local function copy
local WorldFrame, UIParent = WorldFrame, UIParent
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local SetNamePlateFriendlySize = function(x,y)
	if NameplateNoStackingFriendly then x, y = 1, 1 end
	C_NamePlate.SetNamePlateFriendlySize(x,y)
end
local SetNamePlateEnemySize = C_NamePlate.SetNamePlateEnemySize

-- Internal Data
local Plates, PlatesVisible, PlatesFading, GUID = {}, {}, {}, {}	         	-- Plate Lists
local PlatesByUnit = {}
local PlatesByGUID = {}
local nameplate, extended, bars, regions, visual, carrier			    					-- Temp/Local References
local unit, unitcache, style, stylename, unitchanged, threatborder				  -- Temp/Local References
local numChildren = -1                                                     	-- Cache the current number of plates
local activetheme = {}                                                    	-- Table Placeholder
local InCombat, HasTarget, HasMouseover = false, false, false					   		-- Player State Data
local EnableFadeIn = true
local ShowCastBars = true
local ShowCastSpellName = true
local ShowIntCast = true
local ShowIntWhoCast = true
local ShowEnemyPowerBar = false
local ShowFriendlyPowerBar = false
local ShowSpellTarget = false
local ThreatSoloEnable = true
local ReplaceUnitNameArenaID = false
local ForceDefaultNameplates = {}
local EMPTY_TEXTURE = "Interface\\Addons\\NeatPlates\\Media\\Empty"
local ResetPlates, UpdateAll, UpdateAllHealth = false, false, false
local OverrideFonts = false
local OverrideOutline = 1
local HealthTicker = nil
local SpellSchoolByGUID = {}
local SpellCastCache = {} -- Classic era
local CTICache = {} -- Classic era
-- local NameplateOccludedAlphaMult = tonumber(GetCVar("nameplateOccludedAlphaMult"))

-- Raid Icon Reference
local RaidIconCoordinate = {
		["STAR"] = { x = 0, y =0 },
		["CIRCLE"] = { x = 0.25, y = 0 },
		["DIAMOND"] = { x = 0.5, y = 0 },
		["TRIANGLE"] = { x = 0.75, y = 0},
		["MOON"] = { x = 0, y = 0.25},
		["SQUARE"] = { x = .25, y = 0.25},
		["CROSS"] = { x = .5, y = 0.25},
		["SKULL"] = { x = .75, y = 0.25},
}

local spellBlacklist, spellCCList, spellCTI

if NEATPLATES_IS_CLASSIC_ERA then
	-- Special case spells
	spellBlacklist = {
		[GetSpellInfo(75)] = true, 				-- Auto Shot
		[GetSpellInfo(5019)] = true, 			-- Shoot
		[GetSpellInfo(2480)] = true, 			-- Shoot Bow
		[GetSpellInfo(7918)] = true, 			-- Shoot Gun
		[GetSpellInfo(7919)] = true, 			-- Shoot Crossbow
		[GetSpellInfo(2764)] = true, 			-- Throw
	}

	spellCCList = {
		[GetSpellInfo(118)] = true,				-- Polymorph
		[GetSpellInfo(408)] = true,				-- Kidney Shot
		[GetSpellInfo(605)] = true,				-- Mind Control
		[GetSpellInfo(853)] = true,				-- Hammer of Justice
		[GetSpellInfo(1090)] = true,			-- Sleep
		[GetSpellInfo(1513)] = true,			-- Scare Beast
		[GetSpellInfo(1776)] = true,			-- Gouge
		[GetSpellInfo(1833)] = true,			-- Cheap Shot
		[GetSpellInfo(2094)] = true,			-- Blind
		[GetSpellInfo(2637)] = true,			-- Hibernate
		[GetSpellInfo(3355)] = true,			-- Freezing Trap
		[GetSpellInfo(5211)] = true,			-- Bash
		[GetSpellInfo(5246)] = true,			-- Intimidating Shout
		[GetSpellInfo(5484)] = true,			-- Howl of Terror
		[GetSpellInfo(5530)] = true,			-- Mace Stun
		[GetSpellInfo(5782)] = true,			-- Fear
		[GetSpellInfo(6358)] = true,			-- Seduction
		[GetSpellInfo(6770)] = true,			-- Sap
		[GetSpellInfo(6789)] = true,			-- Death Coil
		[GetSpellInfo(7922)] = true,			-- Charge Stun
		[GetSpellInfo(8122)] = true,			-- Psychic Scream
		[GetSpellInfo(9005)] = true,			-- Pounce
		[GetSpellInfo(12355)] = true,			-- Impact
		[GetSpellInfo(12798)] = true,			-- Revenge Stun
		[GetSpellInfo(12809)] = true,			-- Concussion Blow
		[GetSpellInfo(15269)] = true,			-- Blackout
		[GetSpellInfo(15487)] = true,			-- Silence
		[GetSpellInfo(16922)] = true,			-- Improved Starfire
		[GetSpellInfo(18093)] = true,			-- Pyroclasm
		[GetSpellInfo(18425)] = true,			-- Kick - Silenced
		[GetSpellInfo(18469)] = true,			-- Counterspell - Silenced
		[GetSpellInfo(18498)] = true,			-- Shield Bash - Silenced
		[GetSpellInfo(19386)] = true,			-- Wyvern Sting
		[GetSpellInfo(19410)] = true,			-- Improved Concussive Shot
		[GetSpellInfo(19503)] = true,			-- Scatter Shot
		[GetSpellInfo(20066)] = true,			-- Repentance
		[GetSpellInfo(20170)] = true,			-- Seal of Justice Stun
		[GetSpellInfo(20253)] = true,			-- Intercept Stun
		[GetSpellInfo(20549)] = true,			-- War Stomp
		[GetSpellInfo(22703)] = true,			-- Inferno Effect (Summon Infernal)
		[GetSpellInfo(24259)] = true,			-- Spell Lock
		[GetSpellInfo(24394)] = true,			-- Intimidation
		[GetSpellInfo(28271)] = true,			-- Polymorph: Turtle
		[GetSpellInfo(28272)] = true,			-- Polymorph: Pig

		-- Items, Talents etc.
		[GetSpellInfo(56)] = true,				-- Stun (Weapon Proc)
		[GetSpellInfo(835)] = true,				-- Tidal Charm
		[GetSpellInfo(4064)] = true,			-- Rough Copper Bomb
		[GetSpellInfo(4065)] = true,			-- Large Copper Bomb
		[GetSpellInfo(4066)] = true,			-- Small Bronze Bomb
		[GetSpellInfo(4067)] = true,			-- Big Bronze Bomb
		[GetSpellInfo(4068)] = true,			-- Iron Grenade
		[GetSpellInfo(4069)] = true,			-- Big Iron Bomb
		[GetSpellInfo(5134)] = true,			-- Flash Bomb Fear
		[GetSpellInfo(12421)] = true,			-- Mithril Frag Bomb
		[GetSpellInfo(12543)] = true,			-- Hi-Explosive Bomb
		[GetSpellInfo(12562)] = true,			-- The Big One
		[GetSpellInfo(13181)] = true,			-- Gnomish Mind Control Cap
		[GetSpellInfo(13237)] = true,			-- Goblin Mortar
		[GetSpellInfo(13327)] = true,			-- Reckless Charge
		[GetSpellInfo(13808)] = true,			-- M73 Frag Grenade
		[GetSpellInfo(15283)] = true,			-- Stunning Blow (Weapon Proc)
		[GetSpellInfo(19769)] = true,			-- Thorium Grenade
		[GetSpellInfo(19784)] = true,			-- Dark Iron Bomb
		[GetSpellInfo(19821)] = true,			-- Arcane Bomb Silence
		[GetSpellInfo(26108)] = true,			-- Glimpse of Madness
	}

	spellCTI = {
		[GetSpellInfo(1714)] = 1.6,				-- Curse of Tongues
		[GetSpellInfo(1098)] = 1.3,				-- Enslave Demon
		[GetSpellInfo(5760)] = 1.6,				-- Mind-Numbing Poison
		[GetSpellInfo(17331)] = 1.1,			-- Fang of the Crystal Spider

		-- NPC Abilities
		[GetSpellInfo(3603)] = 1.35,			-- Distracting Pain
		[GetSpellInfo(7102)] = 1.25,			-- Contagion of Rot
		[GetSpellInfo(7127)] = 1.2,				-- Wavering Will
		[GetSpellInfo(8140)] = 1.5,				-- Befuddlement
		[GetSpellInfo(8272)] = 1.2,				-- Mind Tremor
		[GetSpellInfo(10651)] = 1.2,			-- Curse of the Eye
		[GetSpellInfo(12255)] = 1.15,			-- Curse of Tuten'kash
		[GetSpellInfo(19365)] = 1.5,			-- Ancient Dread
		[GetSpellInfo(22247)] = 1.8,			-- Suppression Aura
		[GetSpellInfo(22642)] = 1.5,			-- Brood Power: Bronze
		[GetSpellInfo(22909)] = 1.5,			-- Eye of Immol'thar
		[GetSpellInfo(23153)] = 1.5,			-- Brood Power: Blue
		[GetSpellInfo(28732)] = 1.25,			-- Widow's Embrace

		-- Uncategorized (Not sure if they are used)
		[GetSpellInfo(14538)] = 1.35,			-- Aural Shock
		--[GetSpellInfo(24415)] = 1.5,   	-- Slow
	}
end

---------------------------------------------------------------------------------------------------------------------
-- Core Function Declaration
---------------------------------------------------------------------------------------------------------------------
-- Helpers
local function ClearIndices(t) if t then for i,v in pairs(t) do t[i] = nil end return t end end
local function IsPlateShown(plate) return plate and plate:IsShown() end

-- Queueing
local function SetUpdateMe(plate) plate.UpdateMe = true end
local function SetUpdateAll() UpdateAll = true end
local function SetUpdateAllHealth() UpdateAllHealth = true end
local function SetUpdateHealth(source) source.parentPlate.UpdateHealth = true end

-- Overriding
local function BypassFunction() return true end
local ShowBlizzardPlate		-- Holder for later

-- Style
local UpdateStyle, CheckNameplateStyle

-- Indicators
local UpdateIndicator_CustomScaleText, UpdateIndicator_Standard, UpdateIndicator_CustomAlpha
local UpdateIndicator_Level, UpdateIndicator_ThreatGlow, UpdateIndicator_RaidIcon
local UpdateIndicator_EliteIcon, UpdateIndicator_UnitColor, UpdateIndicator_Name
local UpdateIndicator_HealthBar, UpdateIndicator_Highlight, UpdateIndicator_ExtraBar, UpdateIndicator_PowerBar
local OnUpdateCasting, OnStartCasting, OnStopCasting, OnUpdateCastMidway, OnInterruptedCast

-- Event Functions
local OnShowNameplate, OnHideNameplate, OnUpdateNameplate, OnResetNameplate
local OnHealthUpdate, UpdateUnitCondition
local UpdateUnitContext, OnRequestWidgetUpdate, OnRequestDelegateUpdate
local UpdateUnitIdentity

-- Main Loop
local OnUpdate
local OnNewNameplate
local ForEachPlate

-- Show Custom NeatPlates target frame
local ShowEmulatedTargetPlate = false

-- Store players faction
local PlayerFaction = UnitFactionGroup("player")

local function IsEmulatedFrame(guid)
	if NeatPlatesTarget and NeatPlatesTarget.unitGUID == guid then return NeatPlatesTarget else return end
end

local function toggleNeatPlatesTarget(show, ...)
	if not ShowEmulatedTargetPlate then return end
	local friendlyPlates, enemyPlates = GetCVar("nameplateShowFriends") == "0" and UnitIsFriend("player", "target"), GetCVar("nameplateShowEnemies") == "0" and UnitIsEnemy("player", "target")

	-- Create a new target frame if needed
	if not NeatPlatesTarget then
		NeatPlatesTarget = NeatPlatesUtility:CreateTargetFrame()
		OnNewNameplate(NeatPlatesTarget)
	end

	local _,_,_,x,y = ...
	local target = UnitExists("target")

	if not show or friendlyPlates or enemyPlates then OnHideNameplate(NeatPlatesTarget, "target"); return end
	if target then
		OnShowNameplate(NeatPlatesTarget, "target")
		if not x then x, y = GetCursorPosition() end
		NeatPlatesTarget:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y+20)
	end
end

-- UpdateNameplateSize
local function UpdateNameplateSize(plate, show, cWidth, cHeight)
	-- Needs return and timer or size will be set incorrectly on startup, no idea why...
	if not plate then return end

	C_Timer.NewTimer(0.1, function()
		local scaleStandard = activetheme.SetScale()
		local clickableWidth, clickableHeight = NeatPlatesPanel.GetClickableArea()
		local hitbox = {
			width = activetheme.Default.hitbox.width * (cWidth or clickableWidth),
			height = activetheme.Default.hitbox.height * (cHeight or clickableHeight),
			x = (activetheme.Default.hitbox.x*-1) * scaleStandard,
			y = (activetheme.Default.hitbox.y*-1) * scaleStandard,
		}

		if not InCombatLockdown() then
			if IsInInstance() or DisplayingBlizzardPlate(plate) then
				-- Reset to blizzard nameplate default to avoid issues while diplaying default blizzard nameplate
				-- NOTE: This means the 'Force Default Nameplates' option will still have this issue in some cases, but it's a much better than currently
				local zeroBasedScale = tonumber(GetCVar("NamePlateVerticalScale")) - 1.0;
				local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"));
				if NEATPLATES_IS_CLASSIC then
					SetNamePlateFriendlySize(128 * horizontalScale, 45 * Lerp(1.0, 1.25, zeroBasedScale))
				else
					SetNamePlateFriendlySize(145 * horizontalScale, 45 * Lerp(1.0, 1.25, zeroBasedScale))
				end
			else SetNamePlateFriendlySize(hitbox.width * scaleStandard, hitbox.height * scaleStandard) end -- Clickable area of the nameplate
			SetNamePlateEnemySize(hitbox.width * scaleStandard, hitbox.height * scaleStandard) -- Clickable area of the nameplate
		end

		if plate then
			plate.carrier:SetPoint("CENTER", plate, "CENTER", hitbox.x, hitbox.y)	-- Offset
			plate.extended.visual.hitbox:SetPoint("CENTER", plate)
			plate.extended.visual.hitbox:SetWidth(hitbox.width)
			plate.extended.visual.hitbox:SetHeight(hitbox.height)

			if show then plate.extended.visual.hitbox:Show() else plate.extended.visual.hitbox:Hide() end
		end

	end)
end

-- Check if the nameplate should be displayed as a blizzard plate or not
function DisplayingBlizzardPlate(plate)
	if plate.UnitFrame then
		local unit = plate.extended.unit
		local useDefault = ForceDefaultNameplates[unit.reaction]
		if useDefault ~= nil then	useDefault = useDefault[unit.type] end

		if plate.showBlizzardPlate or useDefault then
			return true
		end
	end

	return false
end

-- UpdateReferences
local function UpdateReferences(plate)
	nameplate = plate
	extended = plate.extended

	carrier = plate.carrier
	bars = extended.bars
	regions = extended.regions
	unit = extended.unit
	unitcache = extended.unitcache
	visual = extended.visual
	style = extended.style
	threatborder = visual.threatborder
end

---------------------------------------------------------------------------------------------------------------------
-- Nameplate Detection & Update Loop
---------------------------------------------------------------------------------------------------------------------
do
	-- Local References
	local WorldGetNumChildren, WorldGetChildren = WorldFrame.GetNumChildren, WorldFrame.GetChildren

	-- ForEachPlate
	function ForEachPlate(functionToRun, ...)
		for plate in pairs(PlatesVisible) do
			if plate.extended.Active then
				functionToRun(plate, ...)
			end
		end
	end

	function ShouldShowBlizzardPlate(plate)
		if DisplayingBlizzardPlate(plate) then
			plate.UnitFrame:Show()
			plate.extended:Hide()
		elseif plate.UnitFrame then
			plate.UnitFrame:Hide()
		end
	end

        -- OnUpdate; This function is run frequently, on every clock cycle
	function OnUpdate(self, e)
		-- Poll Loop
		local plate, curChildren

    -- Detect when cursor leaves the mouseover unit
		if HasMouseover and not UnitExists("mouseover") then
			HasMouseover = false
			SetUpdateAll()
		end

		for plate, unitid in pairs(PlatesVisible) do
			local UpdateMe = UpdateAll or plate.UpdateMe
			local UpdateHealth = plate.UpdateHealth or UpdateAllHealth
			local carrier = plate.carrier
			local extended = plate.extended

			-- CVar integrations
			if NeatPlatesOptions.BlizzardScaling then carrier:SetScale(plate:GetScale()) end	-- Scale the carrier to allow for certain CVars that control scale to function properly.
			if plate.extended.unit.alphaMult ~= plate:GetAlpha() then
				UpdateHealth = true
			end

			-- Check for an Update Request
			if UpdateMe or UpdateHealth then
				if not UpdateMe then
					OnHealthUpdate(plate)
				else
					OnUpdateNameplate(plate)
				end
				plate.UpdateMe = false
				plate.UpdateHealth = false

				if NEATPLATES_IS_CLASSIC_ERA then
					if plate.UpdateCastbar then -- Check if spell is being cast
						if unit and unit.unitid then
							local unitGUID = UnitGUID(unit.unitid)
							if unitGUID and SpellCastCache[unitGUID] and not SpellCastCache[unitGUID].finished then OnStartCasting(plate, unitGUID, false)
							else OnStopCasting(plate) end
						end
						plate.UpdateCastbar = false
					end
				end
			elseif unitid and not plate:IsVisible() then
				OnHideNameplate(plate, unitid)  -- If the 'NAME_PLATE_UNIT_REMOVED' event didn't trigger
			end

			ShouldShowBlizzardPlate(plate)

		-- This would be useful for alpha fades
		-- But right now it's just going to get set directly
		-- extended:SetAlpha(extended.requestedAlpha)

		end

		-- Reset Mass-Update Flag
		UpdateAll = false
		UpdateAllHealth = false
	end


end

---------------------------------------------------------------------------------------------------------------------
--  Nameplate Extension: Applies scripts, hooks, and adds additional frame variables and regions
---------------------------------------------------------------------------------------------------------------------
do

	local topFrameLevel = 0

	-- ApplyPlateExtesion
	function OnNewNameplate(plate, unitid)

	-- NeatPlates Frame
	--------------------------------
		local bars, regions = {}, {}
		local carrier
		local frameName = "NeatPlatesCarrier"..numChildren

		carrier = CreateFrame("Frame", frameName, WorldFrame)
		local extended = CreateFrame("Frame", nil, carrier)

		plate.carrier = carrier
		plate.extended = extended

    -- Add Graphical Elements
		local visual = {}
		-- Status Bars
		local healthbar = CreateNeatPlatesStatusbar(extended)
		local powerbar = CreateNeatPlatesStatusbar(extended)
		local extrabar = CreateNeatPlatesStatusbar(extended)	-- Currently used for Bodyguard XP in Nazjatar
		local castbar = CreateNeatPlatesStatusbar(extended)
		local textFrame = CreateFrame("Frame", nil, healthbar)
		local widgetParent = CreateFrame("Frame", nil, textFrame)

		textFrame:SetAllPoints()

		extended.widgetParent = widgetParent
		visual.healthbar = healthbar
		visual.powerbar = powerbar
		visual.extrabar = extrabar
		visual.castbar = castbar
		-- Is this still even needed?
		bars.healthbar = healthbar		-- For Threat Plates Compatibility
		bars.powerbar = powerbar		-- For Threat Plates Compatibility
		bars.extrabar = extrabar			-- For Threat Plates Compatibility
		bars.castbar = castbar			-- For Threat Plates Compatibility
		-- Parented to Health Bar - Lower Frame
		visual.healthborder = healthbar:CreateTexture(nil, "ARTWORK")
		visual.threatborder = healthbar:CreateTexture(nil, "ARTWORK")
		visual.highlight = healthbar:CreateTexture(nil, "OVERLAY")
		visual.hitbox = healthbar:CreateTexture(nil, "OVERLAY")
		-- Parented to Extended - Middle Frame
		visual.raidicon = textFrame:CreateTexture(nil, "OVERLAY")
		visual.eliteicon = textFrame:CreateTexture(nil, "OVERLAY")
		visual.skullicon = textFrame:CreateTexture(nil, "OVERLAY")
		visual.target = textFrame:CreateTexture(nil, "ARTWORK")
		visual.focus = textFrame:CreateTexture(nil, "ARTWORK")
		visual.mouseover = textFrame:CreateTexture(nil, "ARTWORK")
		-- TextFrame
		visual.customtext = textFrame:CreateFontString(nil, "OVERLAY")
		visual.name  = textFrame:CreateFontString(nil, "OVERLAY")
		visual.subtext = textFrame:CreateFontString(nil, "OVERLAY")
		visual.level = textFrame:CreateFontString(nil, "OVERLAY")
		-- Extra Bar Frame
		visual.extraborder = extrabar:CreateTexture(nil, "ARTWORK")
		visual.extratext = extrabar:CreateFontString(nil, "OVERLAY")
		-- Cast Bar Frame - Highest Frame
		visual.castborder = castbar:CreateTexture(nil, "ARTWORK")
		visual.castnostop = castbar:CreateTexture(nil, "ARTWORK")
		visual.spellicon = castbar:CreateTexture(nil, "OVERLAY")
		visual.spelltext = castbar:CreateFontString(nil, "OVERLAY")
		visual.spelltarget = castbar:CreateFontString(nil, "OVERLAY")
		visual.durationtext = castbar:CreateFontString(nil, "OVERLAY")
		castbar.durationtext = visual.durationtext -- Extra reference for updating castbars duration text
		-- Set Base Properties
		visual.raidicon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		visual.highlight:SetAllPoints(visual.healthborder)
		visual.highlight:SetBlendMode("ADD")
		visual.hitbox:SetBlendMode("ADD")
		visual.hitbox:SetColorTexture(0, 0.6, 0.0, 0.5)

		extended:SetFrameStrata("BACKGROUND")
		healthbar:SetFrameStrata("BACKGROUND")
		powerbar:SetFrameStrata("BACKGROUND")
		extrabar:SetFrameStrata("BACKGROUND")
		castbar:SetFrameStrata("BACKGROUND")
		textFrame:SetFrameStrata("BACKGROUND")
		widgetParent:SetFrameStrata("BACKGROUND")

		widgetParent:SetFrameLevel(textFrame:GetFrameLevel() - 1)
		castbar:SetFrameLevel(widgetParent:GetFrameLevel() + 1)
		powerbar:SetFrameLevel(healthbar:GetFrameLevel() + 1)

		topFrameLevel = topFrameLevel + 20
		extended.defaultLevel = topFrameLevel
		extended:SetFrameLevel(topFrameLevel)

		extrabar:Hide()
		extrabar:SetStatusBarColor(1,.6,0)

		castbar:Hide()
		castbar:SetStatusBarColor(1,.8,0)
		carrier:SetSize(16, 16)

		-- Default Fonts
		visual.name:SetFontObject("NeatPlatesFontNormal")
		visual.subtext:SetFontObject("NeatPlatesFontSmall")
		visual.level:SetFontObject("NeatPlatesFontSmall")
		visual.extratext:SetFontObject("NeatPlatesFontSmall")
		visual.spelltext:SetFontObject("NeatPlatesFontNormal")
		visual.spelltarget:SetFontObject("NeatPlatesFontNormal")
		visual.durationtext:SetFontObject("NeatPlatesFontNormal")
		visual.customtext:SetFontObject("NeatPlatesFontSmall")

		-- NeatPlates Frame References
		extended.regions = regions
		extended.bars = bars
		extended.visual = visual

		-- Allocate Tables
		extended.style,
		extended.unit,
		extended.unitcache,
		extended.stylecache,
		extended.widgets
			= {}, {}, {}, {}, {}

		extended.stylename = ""

		carrier:SetPoint("CENTER", plate, "CENTER")

		UpdateNameplateSize(plate)
	end

end

---------------------------------------------------------------------------------------------------------------------
-- Nameplate Event Handlers
---------------------------------------------------------------------------------------------------------------------
local function NameplateEventHandler(self, event, ...)
	-- Make sure we have a frame, as this can be called directly
	if not self then return end

	-- print(event, ...)

	local unitid = ...
	if event == "UNIT_HEALTH"
	or event == "UNIT_HEALTH_FREQUENT"
	or event == "UNIT_MAXHEALTH"
	or event == "UNIT_POWER_UPDATE"
	or event == "UNIT_LEVEL"
	or event == "UNIT_FACTION"
	or event == "UNIT_THREAT_SITUATION_UPDATE"
	then
		OnHealthUpdate(self)
	elseif event == "UNIT_NAME_UPDATE" then
		SetUpdateMe(self)
	elseif event == "UNIT_TARGET" then
		OnUpdateCastTarget(self, unitid)
	elseif event == "UNIT_LEVEL"
		or event == "UNIT_FACTION"
		or event == "UNIT_THREAT_SITUATION_UPDATE"
	then
		OnHealthUpdate(self)
	elseif event == "UNIT_SPELLCAST_START" then
		if not ShowCastBars then return end
		OnStartCasting(self, unitid, false)
	elseif event == "UNIT_SPELLCAST_STOP" then
		if not ShowCastBars then return end
		OnStopCasting(self, unitid, false)
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
		if not ShowCastBars then return end
		OnStartCasting(self, unitid, true)
	elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		if not ShowCastBars then return end
		OnStopCasting(self)
	elseif event == "UNIT_SPELLCAST_INTERRUPTED"
		or event == "UNIT_SPELLCSAT_FAILED"
	then
		if not ShowCastBars then return end
		if not self.extended.unit.interrupted then OnInterruptedCast(self) end
	elseif event == "UNIT_SPELLCAST_DELAYED"
		or event == "UNIT_SPELLCAST_CHANNEL_UPDATE"
		or event == "UNIT_SPELLCAST_INTERRUPTIBLE"
		or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
	then
		if not ShowCastBars then return end
		OnUpdateCastMidway(self, unitid)
	end
end

-- Register events to be handled on the nameplate
local function RegisterNameplateEvents(plate, unitid)
	plate:SetScript("OnEvent", NameplateEventHandler);

	-- Register Events
	plate:RegisterUnitEvent("UNIT_MAXHEALTH", unitid)
	plate:RegisterUnitEvent("UNIT_POWER_UPDATE", unitid)
	plate:RegisterUnitEvent("UNIT_NAME_UPDATE", unitid)
	plate:RegisterUnitEvent("UNIT_TARGET", unitid)
	plate:RegisterUnitEvent("UNIT_LEVEL", unitid)
	plate:RegisterUnitEvent("UNIT_FACTION", unitid)
	plate:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", unitid)
	plate:RegisterUnitEvent("UNIT_SPELLCAST_START", unitid)
	plate:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unitid)
	plate:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unitid)
	plate:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unitid)
	plate:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unitid)
	-- plate:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unitid)
	plate:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unitid)
	plate:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unitid)
	if not NEATPLATES_IS_CLASSIC then
		plate:RegisterUnitEvent("UNIT_HEALTH", unitid)
		plate:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unitid)
		plate:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unitid)
	else
		plate:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unitid) -- Why is this a thing again in the classic client???
	end
end

---------------------------------------------------------------------------------------------------------------------
-- Nameplate Script Handlers
---------------------------------------------------------------------------------------------------------------------
do

	-- UpdateUnitCache
	local function UpdateUnitCache() for key, value in pairs(unit) do unitcache[key] = value end end

	-- CheckNameplateStyle
	function CheckNameplateStyle()
		if activetheme.SetStyle then				-- If the active theme has a style selection function, run it..
			stylename = activetheme.SetStyle(unit)
			extended.style = activetheme[stylename]
		else 										-- If no style function, use the base table
			extended.style = activetheme;
			stylename = tostring(activetheme)
		end

		style = extended.style

		if style and (extended.stylename ~= stylename) then
			UpdateStyle()
			UpdateIndicator_Subtext()
			extended.stylename = stylename
			unit.style = stylename

			if(extended.widgets['AuraWidgetHub'] and unit.unitid) then extended.widgets['AuraWidgetHub']:UpdateContext(unit) end
		end

	end

	-- ProcessUnitChanges
	local function ProcessUnitChanges(unitchanged)
			-- Unit Cache: Determine if data has changed
			unitchanged = unitchanged or false

			for key, value in pairs(unit) do
				if unitchanged then break end
				if unitcache[key] ~= value then
					unitchanged = true
				end
			end

			-- Update Style/Indicators
			if unitchanged or UpdateAll or (not style) then
				CheckNameplateStyle()
				UpdateIndicator_Standard()
				UpdateIndicator_HealthBar()
				UpdateIndicator_PowerBar()
				UpdateIndicator_Highlight()
				if not NEATPLATES_IS_CLASSIC then
					UpdateIndicator_ExtraBar()
				end
			end

			-- Update Widgets
			if activetheme.OnUpdate then activetheme.OnUpdate(extended, unit) end

			-- Update Delegates
			UpdateIndicator_ThreatGlow()
			UpdateIndicator_CustomAlpha()
			UpdateIndicator_CustomScaleText()

			-- Cache the old unit information
			UpdateUnitCache()
	end

--[[
	local function HideWidgets(plate)
		if plate.extended and plate.extended.widgets then
			local widgetTable = plate.extended.widgets
			for widgetIndex, widget in pairs(widgetTable) do
				widget:Hide()
				--widgetTable[widgetIndex] = nil
			end
		end
	end

--]]

	---------------------------------------------------------------------------------------------------------------------
	-- Create / Hide / Show Event Handlers
	---------------------------------------------------------------------------------------------------------------------

	-- OnShowNameplate
	function OnShowNameplate(plate, unitid)
		local unitGUID = UnitGUID(unitid)
		-- or unitid = plate.namePlateUnitToken
		UpdateReferences(plate)

		carrier:Show()

		PlatesVisible[plate] = unitid
		PlatesByUnit[unitid] = plate
		if unitGUID and unitid ~= "target" then PlatesByGUID[unitGUID] = plate end

		unit.frame = extended
		unit.alpha = 0
		unit.isTarget = false
		unit.isMouseover = false
		unit.unitid = unitid
		extended.unitcache = ClearIndices(extended.unitcache)
		extended.stylename = ""
		extended.Active = true

		--visual.highlight:Hide()

		wipe(extended.unit)
		wipe(extended.unitcache)


		-- For Fading In
		PlatesFading[plate] = EnableFadeIn
		extended.requestedAlpha = 0
		--extended.visibleAlpha = 0
		extended:Hide()		-- Yes, it seems counterintuitive, but...
		extended:SetAlpha(0)

		-- Graphics
		unit.isCasting = false
		visual.extrabar:Hide()
		visual.castbar:Hide()
		visual.highlight:Hide()
		visual.hitbox:Hide()



		-- Widgets/Extensions
		-- This goes here because a user might change widget settings after nameplates have been created
		if activetheme.OnInitialize then activetheme.OnInitialize(extended, activetheme) end

		-- Skip the initial data gather and let the second cycle do the work.
		plate.UpdateMe = true
		plate.UpdateCastbar = true -- Classic era

		-- Register events
		RegisterNameplateEvents(plate, unitid)

	end


	-- OnHideNameplate
	function OnHideNameplate(plate, unitid)
		local unitGUID = UnitGUID(unitid)
		--plate.extended:Hide()
		plate.carrier:Hide()

		UpdateReferences(plate)

		extended.Active = false

		PlatesVisible[plate] = nil
		PlatesByUnit[unitid] = nil
		if unitGUID and unitid ~= "target" then PlatesByGUID[unitGUID] = nil end

		visual.extrabar:Hide()
		visual.castbar:Hide()
		visual.castbar:SetScript("OnUpdate", nil)
		unit.isCasting = false

		-- Remove anything from the function queue
		plate.UpdateMe = false

		for widgetname, widget in pairs(extended.widgets) do widget:Hide() end
	end

	-- OnUpdateNameplate
	function OnUpdateNameplate(plate)
		-- And stay down!
		-- plate:GetChildren():Hide()

		-- Gather Information
		local unitid = PlatesVisible[plate]
		UpdateReferences(plate)

		UpdateUnitIdentity(plate, unitid)
		UpdateUnitContext(plate, unitid)
		ProcessUnitChanges()
		OnUpdateCastMidway(plate, unitid)

	end

	-- OnHealthUpdate
	function OnHealthUpdate(plate)
		local unitid = PlatesVisible[plate]
		if not unitid then return end

		UpdateUnitCondition(plate, unitid)
		ProcessUnitChanges(true)
		--UpdateIndicator_HealthBar()		-- Just to be on the safe side
	end

     -- OnResetNameplate
	function OnResetNameplate(plate)
		local extended = plate.extended
		plate.UpdateMe = true
		extended.unitcache = ClearIndices(extended.unitcache)
		extended.stylename = ""
		local unitid = PlatesVisible[plate]

		UpdateNameplateSize(plate)
		OnShowNameplate(plate, unitid)
	end

end


---------------------------------------------------------------------------------------------------------------------
--  Unit Updates: Updates Unit Data, Requests indicator updates
---------------------------------------------------------------------------------------------------------------------
do
	local RaidIconList = { "STAR", "CIRCLE", "DIAMOND", "TRIANGLE", "MOON", "SQUARE", "CROSS", "SKULL" }

	-- GetUnitAggroStatus: Determines if a unit is attacking, by looking at aggro glow region
	local function GetUnitAggroStatus( threatRegion )
		if not  threatRegion:IsShown() then return "LOW", 0 end

		local red, green, blue, alpha = threatRegion:GetVertexColor()
		local opacity = threatRegion:GetVertexColor()

		if threatRegion:IsShown() and (alpha < .9 or opacity < .9) then
			-- Unfinished
		end

		if red > 0 then
			if green > 0 then
				if blue > 0 then return "MEDIUM", 1 end
				return "MEDIUM", 2
			end
			return "HIGH", 3
		end
	end

		-- GetUnitReaction: Determines the reaction, and type of unit from the health bar color
	local function GetReactionByColor(red, green, blue)
		if red < .1 then 	-- Friendly
			return "FRIENDLY"
		elseif red > .5 then
			if green > .9 then return "NEUTRAL"
			else return "HOSTILE" end
		end
	end

	local function GetReactionByUnit(unit)
		local reaction = UnitReaction("player", unit.unitid)
		local isEnemy = UnitExists(unit.unitid) and UnitIsEnemy("player", unit.unitid)

		if reaction == 4 then
			return "NEUTRAL"
		elseif isEnemy then
			return "HOSTILE"
		elseif reaction < 4 then
			return "HOSTILE"
		elseif reaction > 4 then
			return "FRIENDLY"
		end

		return nil
	end


	local EliteReference = {
		["elite"] = true,
		["rareelite"] = true,
		["worldboss"] = true,
	}

	local RareReference = {
		["rare"] = true,
		["rareelite"] = true,
	}

	local ThreatReference = {
		[0] = "LOW",
		[1] = "MEDIUM",
		[2] = "MEDIUM",
		[3] = "HIGH",
	}

	-- UpdateUnitIdentity: Updates Low-volatility Unit Data
	-- (This is essentially static data)
	--------------------------------------------------------
	function UpdateUnitIdentity(plate, unitid)
		unit.unitid = unitid
		unit.name, unit.realm = UnitName(unitid)
		unit.pvpname = UnitPVPName(unitid)
		unit.rawName = unit.name  -- gsub(unit.name, " %(%*%)", "")

		unit.showName = not NeatPlatesOptions.BlizzardNameVisibility or UnitShouldDisplayName(unit.unitid)

		local classification = UnitClassification(unitid)

		unit.isBoss = UnitEffectiveLevel(unitid) == -1
		unit.isDangerous = unit.isBoss

		unit.isElite = EliteReference[classification]
		unit.isRare = RareReference[classification]
		unit.isMini = classification == "minus"
		--unit.isPet = UnitIsOtherPlayersPet(unitid)
		--unit.isPet = ("Pet" == strsplit("-", UnitGUID(unitid)))
		unit.isPet = ParseGUID(UnitGUID(unitid)) == "Pet" or UnitIsOtherPlayersPet(unitid)

		if UnitIsPlayer(unitid) then
			_, unit.class = UnitClass(unitid)
			unit.type = "PLAYER"
		else
			unit.class = ""
			unit.type = "NPC"
		end

	end


        -- UpdateUnitContext: Updates Target/Mouseover
	function UpdateUnitContext(plate, unitid)
		local guid

		UpdateReferences(plate)

		unit.isMouseover = UnitIsUnit("mouseover", unitid)
		unit.isTarget = UnitIsUnit("target", unitid)
		unit.isFocus = UnitIsUnit("focus", unitid)

		unit.guid = UnitGUID(unitid)

		UpdateUnitCondition(plate, unitid)	-- This updates a bunch of properties

		if activetheme.OnContextUpdate then
			CheckNameplateStyle()
			activetheme.OnContextUpdate(extended, unit)
		end
		if activetheme.OnUpdate then activetheme.OnUpdate(extended, unit) end
	end

	-- UpdateUnitCondition: High volatility data
	function UpdateUnitCondition(plate, unitid)
		UpdateReferences(plate)

		unit.unitid = unit.unitid or unitid -- Just make sure it exists
		unit.level = UnitEffectiveLevel(unitid)

		local c = GetCreatureDifficultyColor(unit.level)
		unit.levelcolorRed, unit.levelcolorGreen, unit.levelcolorBlue = c.r, c.g, c.b

		unit.isTrivial = (c.r == 0.5 and c.g == 0.5 and c.b == 0.5)

		unit.red, unit.green, unit.blue = UnitSelectionColor(unitid)
		unit.reaction = GetReactionByColor(unit.red, unit.green, unit.blue) or "HOSTILE"
		-- unit.reaction = GetReactionByUnit(unit) or "HOSTILE"

		unit.health = UnitHealth(unitid) or 0
		unit.healthmax = UnitHealthMax(unitid) or 0
		if unit.healthmax == 0 then unit.healthmax = 1 end

		local powerType = UnitPowerType(unitid) or 0
		unit.power = UnitPower(unitid, powerType) or 0
		unit.powermax = UnitPowerMax(unitid, powerType) or 0

		unit.threatValue = 0
		if ThreatSoloEnable or UnitInParty("player") or UnitExists("pet") then
			unit.threatValue = UnitThreatSituation("player", unitid) or 0
			unit.threatSituation = ThreatReference[unit.threatValue]
		end
		unit.isInCombat = UnitAffectingCombat(unitid)
		unit.alphaMult = nameplate:GetAlpha()

		local raidIconIndex = GetRaidTargetIndex(unitid)

		if raidIconIndex then
			unit.raidIcon = RaidIconList[raidIconIndex]
			unit.isMarked = true
		else
			unit.isMarked = false
		end

		-- Unfinished....
		unit.isTapped = UnitIsTapDenied(unitid)
		--unit.isInCombat = false
		--unit.platetype = 2 -- trivial mini mob

	end

	-- OnRequestWidgetUpdate: Calls Update on just the Widgets
	function OnRequestWidgetUpdate(plate)
		if not IsPlateShown(plate) then return end
		UpdateReferences(plate)
		if activetheme.OnContextUpdate then activetheme.OnContextUpdate(extended, unit) end
		if activetheme.OnUpdate then activetheme.OnUpdate(extended, unit) end
	end

	-- OnRequestDelegateUpdate: Updates just the delegate function indicators
	function OnRequestDelegateUpdate(plate)
			if not IsPlateShown(plate) then return end
			UpdateReferences(plate)
			UpdateIndicator_ThreatGlow()
			UpdateIndicator_CustomAlpha()
			UpdateIndicator_CustomScaleText()
	end


end		-- End of Nameplate/Unit Events


---------------------------------------------------------------------------------------------------------------------
-- Indicators: These functions update the color, texture, strings, and frames within a style.
---------------------------------------------------------------------------------------------------------------------
do
	local color = {}
	local alpha, forcealpha, scale


	-- UpdateIndicator_HealthBar: Updates the value on the health bar
	function UpdateIndicator_HealthBar()
		visual.healthbar:SetMinMaxValues(0, unit.healthmax)
		visual.healthbar:SetValue(unit.health)
		-- Subtext
		UpdateIndicator_Subtext()
	end

	-- UpdateIndicator_PowerBar: Updates the value on the resource/power bar
	function UpdateIndicator_PowerBar()
		visual.powerbar:SetMinMaxValues(0, unit.powermax)
		visual.powerbar:SetValue(unit.power)

		-- Hide bar if max power is none as the unit doesn't use power
		local showPowerBar = (ShowFriendlyPowerBar and unit.reaction == "FRIENDLY") or (ShowEnemyPowerBar and unit.reaction ~= "FRIENDLY")
		if unit.powermax == 0 or not showPowerBar then
			visual.powerbar:Hide()
		elseif showPowerBar then
			visual.powerbar:Show()
		end

		-- Fixes issue with small sliver being displayed even at 0
		if unit.power == 0 then
			visual.powerbar.Bar:Hide()
		else
			visual.powerbar.Bar:Show()
		end
	end


	-- UpdateIndicator_Name:
	function UpdateIndicator_Name()
		local unitname = activetheme.SetUnitName(unit)

		if unit.showName then
				visual.name:SetText(unitname) -- Set name
		else
			visual.name:SetText("") -- Clear name
		end

		-- Name Color
		if activetheme.SetNameColor then
			visual.name:SetTextColor(activetheme.SetNameColor(unit))
		else visual.name:SetTextColor(1,1,1,1) end

		-- Subtext
		UpdateIndicator_Subtext()
	end

	-- UpdateIndicator_Subtext:
	function UpdateIndicator_Subtext()
		-- Subtext
		if style.subtext.show and style.subtext.enabled and activetheme.SetSubText then
				local text, r, g, b, a = activetheme.SetSubText(unit)
				visual.subtext:SetText(text or "")
				visual.subtext:SetTextColor(r or 1, g or 1, b or 1, a or 1)
		else visual.subtext:SetText("") end
	end


	-- UpdateIndicator_Level:
	function UpdateIndicator_Level()
		if unit.isBoss and style.skullicon.show and style.skullicon.enabled then visual.level:Hide(); visual.skullicon:Show() else visual.skullicon:Hide() end

		if unit.level < 0 then visual.level:SetText("")
		else visual.level:SetText(unit.level) end
		visual.level:SetTextColor(unit.levelcolorRed, unit.levelcolorGreen, unit.levelcolorBlue)
	end


	-- UpdateIndicator_ThreatGlow: Updates the aggro glow
	function UpdateIndicator_ThreatGlow()
		if not style.threatborder.show and style.threatborder.enabled then return end
		threatborder = visual.threatborder
		if activetheme.SetThreatColor then

			threatborder:SetVertexColor(activetheme.SetThreatColor(unit) )
		else
			if InCombat and unit.reaction ~= "FRIENDLY" and unit.type == "NPC" then
				local color = style.threatcolor[unit.threatSituation]
				threatborder:Show()
				threatborder:SetVertexColor(color.r, color.g, color.b, (color.a or 1))
			else threatborder:Hide() end
		end
	end


	-- UpdateIndicator_Highlight
	function UpdateIndicator_Highlight()
		local current = nil

		if not current and unit.isTarget and style.target.show and style.target.enabled then current = 'target'; visual.target:Show() else visual.target:Hide() end
		if not current and unit.isFocus and style.focus.show and style.focus.enabled then current = 'focus'; visual.focus:Show() else visual.focus:Hide() end
		if not current and unit.isMouseover and style.mouseover.show and style.mouseover.enabled then current = 'mouseover'; visual.mouseover:Show() else visual.mouseover:Hide() end

		if unit.isMouseover and not unit.isTarget and style.highlight.enabled then visual.highlight:Show() else visual.highlight:Hide() end

		if current then visual[current]:SetVertexColor(style[current].color.r, style[current].color.g, style[current].color.b, style[current].color.a) end
	end

	-- UpdateIndicator_ExtraBar
	function UpdateIndicator_ExtraBar()
		if not unit or not unit.unitid then return end
		local widgetSetID = UnitWidgetSet(unit.unitid);

		if widgetSetID then
			local widgetSet = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID)
			if not widgetSet or not widgetSet[1] then return end

			local widget
			for i = 1, #widgetSet do
				local widgetID = widgetSet[i].widgetID
				local widgetType = widgetSet[i].widgetType

				if NeatPlatesOptions.BlizzardWidgets then
					nameplate.showBlizzardPlate = true
				else
					if widgetType == 2 then
						widget = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widgetID)
					elseif widgetType == 1 then
						widget = C_UIWidgetManager.GetCaptureBarWidgetVisualizationInfo(widgetID)
					elseif widgetType == 8 then
						-- Do nothing
					else
						if not _G['NeatPlatesWidgetError'] then
							_G['NeatPlatesWidgetError'] = true
							error("NeatPlates: Unsupported widget type ("..widgetType..") please report this and what you were doing to the addon author.")
						end
						return -- Unsupported widget type
					end

					if widget then break end
				end
			end

			if not widget then return end



			local widgetBarMin = widget.barMin or widget.barMinValue
			local widgetBarMax = widget.barMax or widget.barMaxValue

			local rank = widget.overrideBarText
			local barCur = widget.barValue - widgetBarMin
			local barMax = widgetBarMax - widgetBarMin
			local text = rank

			-- Set neutral zone
			if widget.neutralZoneSize then
				local neutralZoneMin = widget.neutralZoneCenter - (widget.neutralZoneSize / 2)
				local neutralZoneMax = widget.neutralZoneCenter + (widget.neutralZoneSize / 2)
				visual.extrabar:SetNeutralZone(neutralZoneMin, neutralZoneMax, widget.neutralZoneCenter, barMax)
				visual.extrabar.Neutral:Show()
			else
				visual.extrabar.Neutral:Hide()
			end

			if unit.isMouseover then text = barCur.."/"..barMax end

			visual.extrabar:SetMinMaxValues(0, barMax)
			visual.extrabar:SetValue(barCur)
			visual.extratext:SetText(text)

			visual.extrabar:Show()
		end
	end


	-- UpdateIndicator_RaidIcon
	function UpdateIndicator_RaidIcon()
		if unit.isMarked and style.raidicon.show and style.raidicon.enabled then
			local iconCoord = RaidIconCoordinate[unit.raidIcon]
			if iconCoord then
				visual.raidicon:Show()
				visual.raidicon:SetTexCoord(iconCoord.x, iconCoord.x + 0.25, iconCoord.y, iconCoord.y + 0.25)
			else visual.raidicon:Hide() end
		else visual.raidicon:Hide() end
	end


	-- UpdateIndicator_EliteIcon: Updates the border overlay art and threat glow to Elite or Non-Elite art
	function UpdateIndicator_EliteIcon()
		threatborder = visual.threatborder
		if (unit.isElite or unit.isRare) and not unit.isBoss and style.eliteicon.show and style.eliteicon.enabled then visual.eliteicon:Show() else visual.eliteicon:Hide() end
		visual.eliteicon:SetDesaturated(unit.isRare) -- Desaturate if rare elite
	end


	-- UpdateIndicator_UnitColor: Update the health bar coloring, if needed
	function UpdateIndicator_UnitColor()
		-- Set Health Bar
		if activetheme.SetHealthbarColor then
			visual.healthbar:SetAllColors(activetheme.SetHealthbarColor(unit))

		else visual.healthbar:SetStatusBarColor(unit.red, unit.green, unit.blue) end

		-- Set Power Bar
		if activetheme.SetPowerbarColor then
			visual.powerbar:SetAllColors(activetheme.SetPowerbarColor(unit))

		else visual.powerbar:SetStatusBarColor(0,0,1,1) end

		-- Name Color
		if activetheme.SetNameColor then
			visual.name:SetTextColor(activetheme.SetNameColor(unit))
		else visual.name:SetTextColor(1,1,1,1) end
	end


	-- UpdateIndicator_Standard: Updates Non-Delegate Indicators
	function UpdateIndicator_Standard()
		if IsPlateShown(nameplate) then
			if unitcache.name ~= unit.name or unitcache.showName ~= unit.showName then UpdateIndicator_Name() end
			if unitcache.level ~= unit.level or unitcache.isBoss ~= unit.isBoss then UpdateIndicator_Level() end
			UpdateIndicator_RaidIcon()
			if unitcache.isElite ~= unit.isElite or unitcache.isRare ~= unit.isRare then UpdateIndicator_EliteIcon() end
		end
	end


	-- UpdateIndicator_CustomAlpha: Calls the alpha delegate to get the requested alpha
	function UpdateIndicator_CustomAlpha(event)
		if activetheme.SetAlpha then
			--local previousAlpha = extended.requestedAlpha
			extended.requestedAlpha = activetheme.SetAlpha(unit) or previousAlpha or unit.alpha or 1
		else
			extended.requestedAlpha = unit.alpha or 1
		end

		-- if unit.alphaMult <= NameplateOccludedAlphaMult then
			unit.alphaMult = unit.alphaMult or 0
			extended.requestedAlpha = extended.requestedAlpha * unit.alphaMult
		-- end

		extended:SetAlpha(extended.requestedAlpha)
		if extended.requestedAlpha > 0 then
			if nameplate:IsShown() then extended:Show() end
		else
			extended:Hide()        -- FRAME HIDE TEST
		end

		-- Better Layering
		if unit.isTarget then
			extended:SetFrameLevel(3000)
		elseif unit.isMouseover then
			extended:SetFrameLevel(3200)
		else
			extended:SetFrameLevel(extended.defaultLevel)
		end

	end


	-- UpdateIndicator_CustomScaleText: Updates indicators for custom text and scale
	function UpdateIndicator_CustomScaleText()
		threatborder = visual.threatborder

		if unit.health and (extended.requestedAlpha > 0) then
			-- Scale
			if activetheme.SetScale then
				scale = activetheme.SetScale(unit)
				if scale then extended:SetScale( scale )end
			end

			-- Set Special-Case Regions
			if style.customtext.show and style.customtext.enabled then
				if activetheme.SetCustomText and unit.unitid then
					local text, r, g, b, a = activetheme.SetCustomText(unit)
					visual.customtext:SetText( text or "")
					visual.customtext:SetTextColor(r or 1, g or 1, b or 1, a or 1)
				else visual.customtext:SetText("") end
			end

			UpdateIndicator_UnitColor()
		end
	end


	local function OnUpdateCastBarForward(self)
		local currentTime = GetTime() * 1000
		local startTime, endTime = self:GetMinMaxValues()
		local text = ""
		if activetheme.SetCastbarDuration then text = activetheme.SetCastbarDuration(currentTime, startTime, endTime) end

		self.durationtext:SetText(text)
		self:SetValue(currentTime)
	end


	local function OnUpdateCastBarReverse(self)
		local currentTime = GetTime() * 1000
		local startTime, endTime = self:GetMinMaxValues()
		local text = ""
		if activetheme.SetCastbarDuration then text = activetheme.SetCastbarDuration(currentTime, startTime, endTime, true) end

		self.durationtext:SetText(text)
		self:SetValue((endTime + startTime) - currentTime)
	end

	-- OnShowCastbar
	function OnStartCasting(plate, unitid, channeled)
		local guid = unitid -- Clasic era, we pass a guid instead of unitid

		UpdateReferences(plate)
		--if not extended:IsShown() then return end
		if not extended:IsShown() then return end

		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, increase
		local castBar = extended.visual.castbar

		if NEATPLATES_IS_CLASSIC_ERA then
			local unitType,_,_,_,_,creatureID = ParseGUID(guid)
			local spell = SpellCastCache[guid]
			local spellEntry

			if not spell or not unitType then return end -- Return if neccessary info is missing

			text = spell.name
			texture = NeatPlatesSpellDB.default[spell.name].texture or 136243

			if creatureID then spellEntry = NeatPlatesSpellDB[unitType][spell.name][creatureID]
			else spellEntry = NeatPlatesSpellDB[unitType][spell.name] end

			if spellEntry.castTime then
				startTime = spell.startTime
				endTime = spell.startTime + (spellEntry.castTime * spell.increase)

				castBar:SetScript("OnUpdate", OnUpdateCastBarForward)
			end
		else
			if channeled then
				name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unitid)
				castBar:SetScript("OnUpdate", OnUpdateCastBarReverse)
			else
				name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unitid)
				castBar:SetScript("OnUpdate", OnUpdateCastBarForward)
			end

			if isTradeSkill then return end
		end

		-- Set 'notInterruptible' to false, Because we cannot tell if it's interruptible or not in classic
		if NEATPLATES_IS_CLASSIC_ERA or NEATPLATES_IS_CLASSIC_TBC then notInterruptible = false end

		unit.isCasting = true
		unit.interrupted = false
		unit.interruptLogged = false
		unit.spellIsShielded = notInterruptible
		unit.spellInterruptible = not unit.spellIsShielded

		-- Clear registered events incase they weren't
		castBar:SetScript("OnEvent", nil)
		--castBar:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

		OnUpdateCastTarget(plate, unitid)

		-- Set spell text & duration
		if ShowCastSpellName then
			visual.spelltext:SetText(text)
		else
			visual.spelltext:SetText("")
		end
		visual.durationtext:SetText("")
		visual.spellicon:SetTexture(texture)
		castBar:SetMinMaxValues(startTime or 0, endTime or 0)

		local r, g, b, a = 1, 1, 0, 1

		if activetheme.SetCastbarColor then
			r, g, b, a = activetheme.SetCastbarColor(unit, SpellSchoolByGUID[unit.guid])
			if not (r and g and b and a) then return end
		end

		castBar:SetStatusBarColor( r, g, b)
		castBar:SetAlpha(a or 1)

		if style.castnostop and style.castnostop.enabled and unit.spellIsShielded then
			visual.castnostop:Show(); visual.castborder:Hide()
		elseif style.castborder and style.castborder.enabled then
			visual.castnostop:Hide(); visual.castborder:Show()
		else
			visual.castnostop:Hide(); visual.castborder:Hide()
		end

		UpdateIndicator_CustomScaleText()
		UpdateIndicator_CustomAlpha()

		castBar:Show()

	end

	-- OnInterruptedCasting
	function OnInterruptedCast(plate, sourceGUID, sourceName, destGUID)
		UpdateReferences(plate)

		local function setSpellText()
			local spellString, color
			local eventText = L["Interrupted"]

			if sourceGUID and sourceGUID ~= "" and ShowIntWhoCast then
				local _, engClass = GetPlayerInfoByGUID(sourceGUID)
				if NEATPLATES_CLASS_COLORS[engClass] then color = ConvertRGBtoColorString(NEATPLATES_CLASS_COLORS[engClass]) end
			end

			if sourceName and color then
				spellString = eventText.." "..color.."("..sourceName..")"
			else
				spellString = eventText
			end

			visual.spelltext:SetText(spellString)
			visual.durationtext:SetText("")
			visual.spelltarget:SetText("")
		end

		-- Main function
		if unit.interrupted and type and sourceGUID and sourceName and destGUID then
			setSpellText()
		else
			if unit.interrupted or not ShowIntCast then return end --not extended:IsShown() or

			unit.interrupted = true
			unit.isCasting = false

			local castBar = extended.visual.castbar
			local _unit = unit -- Store this reference as the unit might have change once the fade function uses it.

			castBar:Show()

			local r, g, b, a = 1, 1, 0, 1

			if activetheme.SetCastbarColor then
				r, g, b, a = activetheme.SetCastbarColor(unit)
				if not (r and g and b and a) then return end
			end
			castBar:SetStatusBarColor(r, g, b)
			castBar:SetMinMaxValues(1, 1)

			setSpellText()

			-- Fade out the castbar
			local alpha, ticks, duration, delay = a, 25, 2, 0.8
			local perTick = alpha/(ticks-(delay/(duration/ticks)))
			local stopFade = false
			fade(ticks, duration, delay, function()
				alpha = alpha - perTick
				if not _unit.isCasting and not stopFade then
					castBar:SetAlpha(alpha)
				else
					stopFade = true
				end
			end, function()
				if not _unit.isCasting and not stopFade then
					_unit.interrupted = false
					castBar:Hide()

					--UpdateIndicator_CustomScaleText()
					--UpdateIndicator_CustomAlpha()
				end
			end)

			castBar:SetScript("OnUpdate", nil)
		end
	end

	-- OnHideCastbar
	function OnStopCasting(plate)
		UpdateReferences(plate)

		if not extended:IsShown() or unit.interrupted then return end
		local castBar = extended.visual.castbar

		castBar:Hide()
		castBar:SetScript("OnUpdate", nil)

		visual.spelltarget:SetText("")

		unit.isCasting = false
		unit.interrupted = false
		UpdateIndicator_CustomScaleText()
		UpdateIndicator_CustomAlpha()
	end



	function OnUpdateCastMidway(plate, unitid)
		if not ShowCastBars then return end
		local currentTime = GetTime() * 1000

		if NEATPLATES_IS_CLASSIC_ERA then return end -- Skip if Classic era

		if UnitCastingInfo(unitid) then
			OnStartCasting(plate, unitid, false)	-- Check to see if there's a spell being cast
		elseif UnitChannelInfo(unitid) then
			OnStartCasting(plate, unitid, true)	-- See if one is being channeled...
		end
	end

	function OnUpdateCastTarget(plate, unitid)
		if ShowSpellTarget and plate and unitid then
			local targetof = unitid.."target"
			local targetname =  UnitName(targetof) or ""
			if UnitIsUnit(targetof, "player") then
				targetname = "|cFFFF1100"..">> "..L["You"].." <<" or ""	-- Red '>> You <<' instead of character name
			elseif UnitIsPlayer(targetof) then
				local targetclass = select(2, UnitClass(targetof))
				targetname = ConvertRGBtoColorString(NEATPLATES_CLASS_COLORS[targetclass])..targetname or ""
			end
			plate.extended.visual.spelltarget:SetText(targetname)
		end
	end


end -- End Indicator section


--------------------------------------------------------------------------------------------------------------
-- WoW Event Handlers: sends event-driven changes to the appropriate gather/update handler.
--------------------------------------------------------------------------------------------------------------
do


	----------------------------------------
	-- Frequently Used Event-handling Functions
	----------------------------------------
	-- Update everything
	local function WorldConditionChanged()
		SetUpdateAll()
	end

	local CoreEvents = {}

	local function EventHandler(self, event, ...)
		-- print(event)
		CoreEvents[event](event, ...)
	end

	----------------------------------------
	-- Game Events
	----------------------------------------
	local builtThisSession = false
	function CoreEvents:PLAYER_ENTERING_WORLD()
		NeatPlatesCore:SetScript("OnUpdate", OnUpdate);

		if NEATPLATES_IS_CLASSIC_ERA and not builtThisSession then
			NeatPlates.BuildDefaultSpellDB() -- Temporarily force a rebuild on login as this is a work in progress
			NeatPlates.CleanSpellDB() -- Remove empty table entries from the Spell DB
			builtThisSession = true
		end
	end

	function CoreEvents:NAME_PLATE_CREATED(...)
		local plate = ...
		OnNewNameplate(plate)
	 end

	function CoreEvents:NAME_PLATE_UNIT_ADDED(...)
		local unitid = ...
		local plate = GetNamePlateForUnit(unitid);

		-- Ignore if plate is Personal Display
		if plate then
			if UnitIsUnit("player", unitid) then
				plate.showBlizzardPlate = true
				ShouldShowBlizzardPlate(plate)
				OnHideNameplate(plate, unitid)
			else
				plate.showBlizzardPlate = false
				--local children = plate:GetChildren() -- Do children even need to be hidden anymore when UnitFrame is unhooked
				--if children then children:Hide() end
				--if plate._frame then plate._frame:Show() end -- Show Questplates frame
				if NEATPLATES_IS_CLASSIC and NeatPlatesTarget and unitid and UnitGUID(unitid) == NeatPlatesTarget.unitGUID then toggleNeatPlatesTarget(false) end

				-- Unhook UnitFrame events
				if plate.UnitFrame then
					plate.UnitFrame:Hide()
					plate.UnitFrame:UnregisterAllEvents()
				end

		 		OnShowNameplate(plate, unitid)
			end
	 	end
	end

	function CoreEvents:NAME_PLATE_UNIT_REMOVED(...)
		local unitid = ...
		local plate = GetNamePlateForUnit(unitid);

		if NEATPLATES_IS_CLASSIC and NeatPlatesTarget and plate.extended.unit.guid == NeatPlatesTarget.unitGUID then toggleNeatPlatesTarget(true) end

		OnHideNameplate(plate, unitid)
	end

	local function UpdateCustomTarget()
		local unitAlive = UnitIsDead("target") == false
		local guid = UnitGUID("target")
		HasTarget = (UnitExists("target") == true and not UnitIsUnit("target", "player"))
		-- Create a new target frame if needed
		if not NeatPlatesTarget then
			NeatPlatesTarget = NeatPlatesUtility:CreateTargetFrame()
			OnNewNameplate(NeatPlatesTarget)
		end
		-- Show Target frame, if other frame doesn't exist and isn't dead
		if NEATPLATES_IS_CLASSIC and HasTarget and NeatPlatesTarget then NeatPlatesTarget.unitGUID = guid end
		toggleNeatPlatesTarget(HasTarget and unitAlive and not PlatesByGUID[guid])
		SetUpdateAll()
	end

	function CoreEvents:PLAYER_TARGET_CHANGED()
		HasTarget = UnitExists("target") == true;
		UpdateCustomTarget()
		SetUpdateAll()
	end

	function CoreEvents:PLAYER_REGEN_ENABLED()
		InCombat = false
		SetUpdateAll()
	end

	function CoreEvents:PLAYER_REGEN_DISABLED()
		InCombat = true
		SetUpdateAll()
	end

	function CoreEvents:DISPLAY_SIZE_CHANGED()
		SetUpdateAll()
	end

	function CoreEvents:UPDATE_MOUSEOVER_UNIT(...)
		if UnitExists("mouseover") then
			HasMouseover = true
			SetUpdateAll()
		end
	end

	function updateCastbarSchoolColor(plate, school)
		local castBar = plate.extended.visual.castbar
		local unit = plate.extended.unit

		if activetheme.SetCastbarColor then
			r, g, b, a = activetheme.SetCastbarColor(unit, school)
			if not (r and g and b and a) then return end
		end

		castBar:SetStatusBarColor(r, g, b)
		castBar:SetAlpha(a or 1)
	end

	function CoreEvents:COMBAT_LOG_EVENT_UNFILTERED(...)
		local _,event,_,sourceGUID,sourceName,sourceFlags,_,destGUID,destName,_,_,spellID,spellName,spellSchool = CombatLogGetCurrentEventInfo()
		spellID = spellID or ""
		local plate = nil
		local ownerGUID
		local unitType,_,_,_,_,creatureID = ParseGUID(sourceGUID)

		-- Tracking spell school
		if event == "SPELL_CAST_START" or event == "SPELL_CAST_SUCCESS" then
			plate = PlatesByGUID[sourceGUID]
			SpellSchoolByGUID[sourceGUID] = spellSchool
			if plate and plate.extended and plate.extended.unit then
				updateCastbarSchoolColor(plate, spellSchool) -- Make sure color updates
			end
		elseif event == "SPELL_CAST_FAILED" or event == "SPELL_CAST_SUCCESS" or event == "SPELL_INTERRUPT" then
			SpellSchoolByGUID[sourceGUID] = nil -- Cleanup
		end

		-- Tracking spell school
		if event == "SPELL_CAST_START" or event == "SPELL_CAST_SUCCESS" then
			plate = PlatesByGUID[sourceGUID]
			SpellSchoolByGUID[sourceGUID] = spellSchool
			if plate and plate.extended and plate.extended.unit then
				updateCastbarSchoolColor(plate, spellSchool) -- Make sure color updates
			end
		elseif event == "SPELL_CAST_FAILED" or event == "SPELL_CAST_SUCCESS" or event == "SPELL_INTERRUPT" then
			SpellSchoolByGUID[sourceGUID] = nil -- Cleanup
		end

		-- Spell Interrupts
		if ShowIntCast then
			if event == "SPELL_INTERRUPT" or event == "SPELL_AURA_APPLIED" or event == "SPELL_CAST_FAILED" then
				-- With "SPELL_AURA_APPLIED" we are looking for stuns etc. that were applied.
				-- As the "SPELL_INTERRUPT" event doesn't get logged for those types of interrupts, but does trigger a "UNIT_SPELLCAST_INTERRUPTED" event.
				-- "SPELL_CAST_FAILED" is for when the unit themselves interrupt the cast.
				plate = PlatesByGUID[destGUID] or IsEmulatedFrame(destGUID)

				if plate and (not NEATPLATES_IS_CLASSIC_ERA or plate.extended.unit.isCasting) then
					if NEATPLATES_IS_CLASSIC_ERA and event == "SPELL_AURA_APPLIED" and spellCCList[spellName] and plate.extended.unit.unitid then NameplateEventHandler(plate, "UNIT_SPELLCAST_INTERRUPTED", plate.extended.unit.unitid) end
					if (event == "SPELL_AURA_APPLIED" or event == "SPELL_CAST_FAILED") and (not plate.extended.unit.interrupted or plate.extended.unit.interruptLogged) and (not NEATPLATES_IS_CLASSIC_ERA or not spellCCList[spellName]) then return end

					-- local unitType = strsplit("-", sourceGUID)

					-- If a pet interrupted, we need to change the source from the pet to the owner
					if unitType == "Pet" then
							ownerGUID, sourceName = GetPetOwner(sourceName)
					end

					plate.extended.unit.interruptLogged = true
					OnInterruptedCast(plate, ownerGUID or sourceGUID, sourceName, destGUID)
				end

				-- Set spell cast cache to finished
				if NEATPLATES_IS_CLASSIC_ERA and SpellCastCache[destGUID] and (event ~= "SPELL_AURA_APPLIED" or spellCCList[spellName]) then
					SpellCastCache[destGUID].finished = true
				end
			end
		end

		-- Fixate
		local fixate = {
			[268074] = true,	-- Spawn of G'huun(Uldir)
			[282209] = true,	-- Ravenous Stalker(Dazar'alor)
		}
		if (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") and fixate[spellID] then
			plate = PlatesByGUID[sourceGUID]
			if plate and event == "SPELL_AURA_APPLIED" and UnitIsUnit("player", destName) then
				plate.extended.unit.fixate = true 	-- Fixating player
			elseif plate then
				plate.extended.unit.fixate = false 	-- NOT Fixating player
			end
		end

		if NEATPLATES_IS_CLASSIC_ERA then
			-- Cast time increases
			CTICache[sourceGUID] = CTICache[sourceGUID] or {}
			if event == "SPELL_AURA_APPLIED" and spellCTI[spellName] then
				if CTICache[sourceGUID].timeout then CTICache[sourceGUID].timeout:Cancel() end
				CTICache[sourceGUID].increase = spellCTI[spellName]
				CTICache[sourceGUID].timeout = C_Timer.NewTimer(60, function()
					CTICache[sourceGUID] = {}
				end)
			elseif event == "SPELL_AURA_REMOVED" and spellCTI[spellName] then
				if CTICache[sourceGUID] and CTICache[sourceGUID].timeout then CTICache[sourceGUID].timeout:Cancel() end
				CTICache[sourceGUID] = {}
			end

			-- Spellcasts (Classic)
			if ShowCastBars and unitType and (spellName and type(spellName) == "string") and not spellBlacklist[spellName] then
				local currentTime = GetTime() * 1000
				local spellEntry
				plate = PlatesByGUID[sourceGUID] or IsEmulatedFrame(sourceGUID)
				NeatPlatesSpellDB[unitType] = NeatPlatesSpellDB[unitType] or {}
				NeatPlatesSpellDB[unitType][spellName] = NeatPlatesSpellDB[unitType][spellName] or {}
				if creatureID then
					NeatPlatesSpellDB[unitType][spellName][creatureID] = NeatPlatesSpellDB[unitType][spellName][creatureID] or {}
					spellEntry = NeatPlatesSpellDB[unitType][spellName][creatureID]
				else
					spellEntry = NeatPlatesSpellDB[unitType][spellName]
				end

				if event == "SPELL_CAST_START" then
					-- Add Spell to Spell Cast Cache
					SpellCastCache[sourceGUID] = SpellCastCache[sourceGUID] or {}
					SpellCastCache[sourceGUID].name = spellName
					SpellCastCache[sourceGUID].school = spellSchool
					SpellCastCache[sourceGUID].startTime = currentTime
					SpellCastCache[sourceGUID].finished = false
					SpellCastCache[sourceGUID].increase = CTICache[sourceGUID].increase or 1

					-- Timeout spell incase we don't catch the SUCCESS or FAILED event.(Times out after recorded casttime + 1 seconds, or 12 seconds if the spell is unknown)
					-- The FAILED event doesn't seem to trigger properly in the current beta test.
					if not spellEntry.castTime then spellEntry.castTime = NeatPlatesSpellDB.default[spellName].castTime end
					local timeout = 12
					local castTime = (spellEntry.castTime or 0) * SpellCastCache[sourceGUID].increase
					if castTime > 0 then timeout = (castTime+1000)/1000 end -- If we have a recorded cast time, use that as timeout base
					if SpellCastCache[sourceGUID].spellTimeout then SpellCastCache[sourceGUID].spellTimeout:Cancel() end	-- Cancel the old spell timeout if it exists

					SpellCastCache[sourceGUID].spellTimeout = C_Timer.NewTimer(timeout, function()
						local plate = PlatesByGUID[sourceGUID] or IsEmulatedFrame(sourceGUID)
						if SpellCastCache[sourceGUID].startTime == currentTime then SpellCastCache[sourceGUID].finished = true end -- Make sure we are on the same cast
						if plate then OnStopCasting(plate) end
					end)

					if plate then OnStartCasting(plate, sourceGUID, false) end
				elseif (event == "SPELL_CAST_SUCCESS" or event == "SPELL_CAST_FAILED") then
					-- Update SpellDB with castTime
					if event == "SPELL_CAST_SUCCESS" and SpellCastCache[sourceGUID] and SpellCastCache[sourceGUID].startTime then
						castTime = (currentTime-SpellCastCache[sourceGUID].startTime)/SpellCastCache[sourceGUID].increase -- Cast Time
						if castTime > 0 then spellEntry.castTime = castTime end
					end

					-- Clear Cast Cache
					if SpellCastCache[sourceGUID] and SpellCastCache[sourceGUID].spellTimeout then SpellCastCache[sourceGUID].spellTimeout:Cancel() end	-- Cancel the spell Timeout
					SpellCastCache[sourceGUID] = nil
					if plate then
						OnStopCasting(plate)
					end
				end

				-- Remove empty entries as they only take up space
				--if not next(NeatPlatesSpellDB[unitType][spellName]) then NeatPlatesSpellDB[unitType][spellName] = nil
				--elseif creatureID and not next(NeatPlatesSpellDB[unitType][spellName][creatureID]) then NeatPlatesSpellDB[unitType][spellName][creatureID] = nil end
			end
		end
	end

	function CoreEvents:CVAR_UPDATE(name, value)
		-- if name == "nameplateOccludedAlphaMult" then
		-- 	NameplateOccludedAlphaMult = tonumber(value) --Unusued?
		-- end
	end

	function CoreEvents:UPDATE_UI_WIDGET(widget)
		if widget then
			SetUpdateAll()
		end
	end

	CoreEvents.RAID_TARGET_UPDATE = WorldConditionChanged
	CoreEvents.PLAYER_FOCUS_CHANGED = WorldConditionChanged
	CoreEvents.PLAYER_CONTROL_LOST = WorldConditionChanged
	CoreEvents.PLAYER_CONTROL_GAINED = WorldConditionChanged


	-- Registration of Blizzard Events
	NeatPlatesCore:SetFrameStrata("TOOLTIP") 	-- When parented to WorldFrame, causes OnUpdate handler to run close to last
	NeatPlatesCore:SetScript("OnEvent", EventHandler)
	for eventName in pairs(CoreEvents) do NeatPlatesCore:RegisterEvent(eventName) end
	-- NeatPlatesCore:RegisterAllEvents() --Debugging

end




---------------------------------------------------------------------------------------------------------------------
--  Nameplate Styler: These functions parses the definition table for a nameplate's requested style.
---------------------------------------------------------------------------------------------------------------------
do
	-- Helper Functions
	local function SetObjectShape(object, width, height) object:SetWidth(width); object:SetHeight(height) end
	local function SetObjectJustify(object, horz, vert) object:SetJustifyH(horz); object:SetJustifyV(vert) end
	local function SetObjectAnchor(object, anchor, anchorTo, x, y) object:ClearAllPoints();object:SetPoint(anchor, anchorTo, anchor, x, y) end
	local function SetObjectTexture(object, texture) object:SetTexture(texture) end
	local function SetObjectBartexture(obj, tex, ori, crop) obj:SetStatusBarTexture(tex); obj:SetOrientation(ori); end

	local function SetObjectFont(object,  font, size, flags)
		if OverrideOutline == 2 then flags = "NONE" elseif OverrideOutline == 3 then flags = "OUTLINE" elseif OverrideOutline == 4 then flags = "THICKOUTLINE" end
		if (not OverrideFonts) and font then
			object:SetFont(font, size or 10, flags)
		--else
		--	object:SetFontObject("SpellFont_Small")
		end
	end --FRIZQT__ or ARIALN.ttf  -- object:SetFont("FONTS\\FRIZQT__.TTF", size or 12, flags)


	-- SetObjectShadow:
	local function SetObjectShadow(object, shadow)
		if shadow then
			object:SetShadowColor(0,0,0, 1)
			object:SetShadowOffset(1, -1)
		else object:SetShadowColor(0,0,0,0) end
	end

	-- SetFontGroupObject
	local function SetFontGroupObject(object, objectstyle)
		if objectstyle then
			SetObjectFont(object, objectstyle.typeface, objectstyle.size, objectstyle.flags)
			SetObjectJustify(object, objectstyle.align or "CENTER", objectstyle.vertical or "BOTTOM")
			SetObjectShadow(object, objectstyle.shadow)
		end
	end

	-- SetAnchorGroupObject
	local function SetAnchorGroupObject(object, objectstyle, anchorTo, offset)
		if objectstyle and anchorTo then
			SetObjectShape(object, objectstyle.width or 128, objectstyle.height or 16)
			SetObjectAnchor(object, objectstyle.anchor or "CENTER", anchorTo, objectstyle.x or 0, (objectstyle.y or 0) + (offset or 0))
		end
	end

	-- SetTextureGroupObject
	local function SetTextureGroupObject(object, objectstyle)
		if objectstyle then
			if objectstyle.texture then SetObjectTexture(object, objectstyle.texture or EMPTY_TEXTURE) end
			object:SetTexCoord(objectstyle.left or 0, objectstyle.right or 1, objectstyle.top or 0, objectstyle.bottom or 1)
		end
	end


	-- SetBarGroupObject
	local function SetBarGroupObject(object, objectstyle, anchorTo)
		if objectstyle then
			SetAnchorGroupObject(object, objectstyle, anchorTo)
			SetObjectBartexture(object, objectstyle.texture or EMPTY_TEXTURE, objectstyle.orientation or "HORIZONTAL")
			if objectstyle.backdrop then
				object:SetBackdropTexture(objectstyle.backdrop)
			end
			object:SetTexCoord(objectstyle.left, objectstyle.right, objectstyle.top, objectstyle.bottom)
		end
	end


	-- Style Groups
	local fontgroup = {"name", "subtext", "level", "extratext", "spelltext", "spelltarget", "durationtext", "customtext"}

	local anchorgroup = {"healthborder", "threatborder", "castborder", "castnostop",
						"name", "subtext", "extraborder", "extratext", "spelltext", "spelltarget", "durationtext", "customtext", "level",
						"spellicon", "raidicon", "skullicon", "eliteicon", "target", "focus", "mouseover"}

	local bargroup = {"castbar", "healthbar", "powerbar", "extrabar"}

	local texturegroup = { "extraborder", "castborder", "castnostop", "healthborder", "threatborder", "eliteicon",
						"skullicon", "highlight", "target", "focus", "mouseover", "spellicon", }

	local highlightgroup = { "target", "focus", "mouseover" }


	-- UpdateStyle:
	function UpdateStyle()
		local index, unitSubtext, unitPlateStyle
		local useYOffset = (style.subtext.show and style.subtext.enabled and activetheme.SetSubText(unit) and NeatPlatesHubFunctions.SetStyleNamed(unit) == "Default")
		if useYOffset and extended.widgets["AuraWidgetHub"] then extended.widgets["AuraWidgetHub"]:UpdateOffset(0, style.subtext.yOffset) end 	-- Update AuraWidget position if 'subtext' is displayed

		-- Frame
		SetAnchorGroupObject(extended, style.frame, carrier)

		-- Anchorgroup
		for index = 1, #anchorgroup do

			local objectname = anchorgroup[index]
			local object, objectstyle = visual[objectname], style[objectname]
			if objectstyle and objectstyle.show and objectstyle.enabled then
				local offset
				if useYOffset and (objectname == "name" or objectname == "subtext") then offset = style.subtext.yOffset end -- Subtext offset

				SetAnchorGroupObject(object, objectstyle, extended, offset)
				visual[objectname]:Show()
			else visual[objectname]:Hide() end
		end
		-- Bars
		for index = 1, #bargroup do
			local objectname = bargroup[index]
			local object, objectstyle = visual[objectname], style[objectname]
			if objectstyle then SetBarGroupObject(object, objectstyle, extended) end
		end
		-- Texture
		for index = 1, #texturegroup do
			local objectname = texturegroup[index]
			local object, objectstyle = visual[objectname], style[objectname]
			SetTextureGroupObject(object, objectstyle)
		end
		-- Raid Icon Texture
		if style and style.raidicon and style.raidicon.texture then
			visual.raidicon:SetTexture(style.raidicon.texture)
		end
		if style and style.healthbar.texture == EMPTY_TEXTURE then visual.noHealthbar = true end
		--if style and not ShowPowerBar then visual.powerbar:Hide() else visual.powerbar:Show() end
		-- Font Group
		for index = 1, #fontgroup do
			local objectname = fontgroup[index]
			local object, objectstyle = visual[objectname], style[objectname]
			SetFontGroupObject(object, objectstyle)
		end
		-- Update blend modes for highlighting elements
		for index = 1, #highlightgroup do
			local objectname = highlightgroup[index]
			local objectstyle = style[objectname]
			if objectstyle and objectstyle.blend then
				visual[objectname]:SetBlendMode(objectstyle.blend)
			else
				visual[objectname]:SetBlendMode("BLEND")	-- Default mode
			end
		end
		-- Hide Stuff
		if not unit.isElite and not unit.isRare then visual.eliteicon:Hide() end
		if not unit.isBoss then visual.skullicon:Hide() end

		if not unit.isTarget then visual.target:Hide() end
		if not unit.isFocus then visual.focus:Hide() end
		if not unit.isMouseover then visual.mouseover:Hide() end
		if not unit.isMarked then visual.raidicon:Hide() end

	end

end

--------------------------------------------------------------------------------------------------------------
-- Theme Handling
--------------------------------------------------------------------------------------------------------------
local function UseTheme(theme)
	if theme and type(theme) == 'table' and not theme.IsShown then
		activetheme = theme 						-- Store a local copy
		ResetPlates = true
	end
end

NeatPlatesInternal.UseTheme = UseTheme

local function GetTheme()
	return activetheme
end

local function GetThemeName()
	return NeatPlatesOptions.ActiveTheme
end

NeatPlates.GetTheme = GetTheme
NeatPlates.GetThemeName = GetThemeName


--------------------------------------------------------------------------------------------------------------
-- Misc. Utility
--------------------------------------------------------------------------------------------------------------
local function OnResetWidgets(plate)
	-- At some point, we're going to have to manage the widgets a bit better.

	local extended = plate.extended
	local widgets = extended.widgets

	for widgetName, widgetFrame in pairs(widgets) do
		widgetFrame:Hide()
		--widgets[widgetName] = nil			-- Nilling the frames may cause leakiness.. or at least garbage collection
	end

	plate.UpdateMe = true
end

--------------------------------------------------------------------------------------------------------------
-- Classic era specific functions
--------------------------------------------------------------------------------------------------------------

-- Cleanup Spell DB
local function CleanSpellDB()
	local checkTable
	checkTable = function(t)
		for k,v in pairs(t) do
			if type(v) == "table" then
				if next(v) then
					checkTable(v)
				else
					t[k] = nil
				end
			end
		end
	end
	checkTable(NeatPlatesSpellDB)
end

-- Build classic texture DB
local function BuildDefaultSpellDB()
	NeatPlatesSpellDB.texture = nil
	NeatPlatesSpellDB.default = {}
	for i = 1, 100000 do
		local spellName,_,icon,castTime = GetSpellInfo(i)
		-- 136235(Default Placeholder Icon)
		if spellName then
			if not NeatPlatesSpellDB.default[spellName] then NeatPlatesSpellDB.default[spellName] = {} end
			if not NeatPlatesSpellDB.default[spellName].texture and icon ~= 136235 then
				NeatPlatesSpellDB.default[spellName].texture = icon
				if castTime > 0 then NeatPlatesSpellDB.default[spellName].castTime = castTime end
			end
			if not NeatPlatesSpellDB.default[spellName].castTime and castTime > 0 then NeatPlatesSpellDB.default[spellName].castTime = castTime end
		end

	end
end

NeatPlates.BuildDefaultSpellDB = BuildDefaultSpellDB
NeatPlates.CleanSpellDB = CleanSpellDB

--------------------------------------------------------------------------------------------------------------
-- External Commands: Allows widgets and themes to request updates to the plates.
-- Useful to make a theme respond to externally-captured data (such as the combat log)
--------------------------------------------------------------------------------------------------------------
function NeatPlates:DisableCastBars() ShowCastBars = false end
function NeatPlates:EnableCastBars() ShowCastBars = true end
function NeatPlates:ToggleEmulatedTargetPlate(show) if not show then toggleNeatPlatesTarget(false) end; ShowEmulatedTargetPlate = show end

function NeatPlates:SetCoreVariables(LocalVars)
	ShowCastSpellName = LocalVars.CastSpellNameEnable
	ShowIntCast = LocalVars.IntCastEnable
	ShowIntWhoCast = LocalVars.IntCastWhoEnable
	ShowFriendlyPowerBar = LocalVars.StyleShowFriendlyPowerBar
	ShowEnemyPowerBar = LocalVars.StyleShowEnemyPowerBar
	ShowSpellTarget = LocalVars.SpellTargetEnable
	ThreatSoloEnable = LocalVars.ThreatSoloEnable
	ReplaceUnitNameArenaID = LocalVars.TextUnitNameArenaID
	NameplateNoStackingFriendly = LocalVars.NameplateNoStackingFriendly

	ForceDefaultNameplates = {
		["HOSTILE"] = {
			["PLAYER"] = LocalVars.DefaultEnemyNameplatesOnPlayers,
			["NPC"] = LocalVars.DefaultEnemyNameplatesOnNPCs
		},
		["FRIENDLY"] = {
			["PLAYER"] = LocalVars.DefaultFriendlyNameplatesOnPlayers,
			["NPC"] = LocalVars.DefaultFriendlyNameplatesOnNPCs
		},
		["NEUTRAL"] = {
			["PLAYER"] = false, -- Shouldn't be possible to be a neutral player?
			["NPC"] = LocalVars.DefaultNeutralNameplatesOnNPCs
		},
	}
end

function NeatPlates:ShowNameplateSize(show, width, height) ForEachPlate(function(plate) UpdateNameplateSize(plate, show, width, height) end) end

function NeatPlates:ForceUpdate() ForEachPlate(OnResetNameplate) end
function NeatPlates:ResetWidgets() ForEachPlate(OnResetWidgets) end
function NeatPlates:Update() SetUpdateAll() end

function NeatPlates:RequestUpdate(plate) if plate then SetUpdateMe(plate) else SetUpdateAll() end end

function NeatPlates:ActivateTheme(theme) if theme and type(theme) == 'table' then NeatPlates.ActiveThemeTable, activetheme = theme, theme; ResetPlates = true; end end
function NeatPlates.OverrideFonts(enable) OverrideFonts = enable; end
function NeatPlates.OverrideOutline(enable) OverrideOutline = enable; end

function NeatPlates.UpdateNameplateSize() UpdateNameplateSize() end

-- Old and needing deleting - Just here to avoid errors
function NeatPlates:EnableFadeIn() EnableFadeIn = true; end
function NeatPlates:DisableFadeIn() EnableFadeIn = nil; end
NeatPlates.RequestWidgetUpdate = NeatPlates.RequestUpdate
NeatPlates.RequestDelegateUpdate = NeatPlates.RequestUpdate

function NeatPlates.ToggleHealthTicker(enabled)
	if HealthTicker then HealthTicker:Cancel() end
	if enabled then
		HealthTicker = C_Timer.NewTicker(0.25, function() SetUpdateAllHealth() end)
	end
end