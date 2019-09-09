local MAJOR_VERSION = "ThreatClassic-1.0"
local MINOR_VERSION = 4

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then _G.ThreatLib_MINOR_VERSION = MINOR_VERSION end

local error = _G.error
local max = _G.math.max
local tinsert, tremove = _G.tinsert, _G.tremove
local GetTime = _G.GetTime
local pairs = _G.pairs
local type = _G.type
local tonumber = _G.tonumber

ThreatLib_funcs[#ThreatLib_funcs + 1] = function()
	local ThreatLib = _G.ThreatLib

	local timers = {}
	local new, del, newHash, newSet = ThreatLib.new, ThreatLib.del, ThreatLib.newHash, ThreatLib.newSet

	function ThreatLib:CancelTPSReset()
		if timers.ResetTPSTimerTables ~= nil then self:CancelTimer(timers.ResetTPSTimerTables, true) end
		if timers.ResetThreat ~= nil then self:CancelTimer(timers.ResetThreat, true)	end
	end

	function ThreatLib:ScheduleTPSReset()
		timers.ResetTPSTimerTables = self:ScheduleTimer("ResetTPS", 3)
		timers.ResetThreat = self:ScheduleTimer("_clearAllThreat", 5)
	end

	------------------------------------------
	-- TPS calculations
	------------------------------------------
	ThreatLib.tpsSigma 		= ThreatLib.tpsSigma or {}
	ThreatLib.tpsSamples 	= ThreatLib.tpsSamples or 25
	local tpsSigma 			= ThreatLib.tpsSigma
	local tpsSamples 		= ThreatLib.tpsSamples

	function ThreatLib:UpdateTPS(source_guid, target_guid, targetThreat)
		if not source_guid then
			error("Invalid parameter #1 passed to UpdateTPS: expected string, got nil", 2)
		end
		if not target_guid then
			error("Invalid parameter #2 passed to UpdateTPS: expected string, got nil", 2)
		end
		if not targetThreat then
			error("Invalid parameter #3 passed to UpdateTPS: expected number, got nil", 2)
		end
		local playerTable = tpsSigma[source_guid]
		if not playerTable then
			playerTable = new()
			tpsSigma[source_guid] = playerTable
			playerTable["FIGHT_START"] = GetTime()
		end
		local sigma = playerTable[target_guid]
		if not sigma then
			-- average, last threat, avg sum, sample 1, sample time 1, ..., sample n, sample time n
			sigma = new(targetThreat, targetThreat, 0)
			playerTable[target_guid] = sigma
		end
		local removedVal, removedTime, period, delta, total, tt = 0, nil, nil, targetThreat - sigma[2], 0, GetTime()

		if targetThreat - sigma[2] == 0 then return end
		tinsert(sigma, delta)
		tinsert(sigma, tt)
		local nPoints = (#sigma - 3) / 2
		while nPoints >= tpsSamples do
			removedVal = tremove(sigma, 4)
			removedTime = tremove(sigma, 4)
			sigma[3] = sigma[3] - removedVal
			nPoints = (#sigma - 3) / 2
		end
		sigma[3] = sigma[3] + delta

		period = tt - (removedTime or sigma[5])
		period = period == 0 and 1 or period
		sigma[1] = sigma[3] / period
		sigma[2] = targetThreat
	end

	--[[----------------------------------------------------------
	-- Returns:
	--	The current number of threat samples used to calculate TPS
	------------------------------------------------------------]]
	function ThreatLib:GetTPSSamples()
		return ThreatLib.tpsSamples
	end

	--[[----------------------------------------------------------
	Arguments:
		integer - number of threat events to consider for TPS calculations
	Notes:
		Default is 15

		A larger sample size will produce a TPS reading for a longer slice of combat, which means that it'll be more stable, but won't reflect your TPS-at-the-moment as accurately.
	------------------------------------------------------------]]
	function ThreatLib:SetTPSSamples(samples)
		ThreatLib.tpsSamples = tonumber(samples)
	end

	function ThreatLib:ResetPlayerTPSOnTarget(player, target)
		local t = tpsSigma[player]
		if t then
			local tt = t[target]
			if tt then
				t[target] = del(tt)
			end
		end
	end

	function ThreatLib:ResetTPS(resetOn, force)
		if self.inCombat() and not force then return end
		for k, v in pairs(tpsSigma) do
			for k2, v2 in pairs(v) do
				if resetOn then
					if k2 == resetOn and type(v2) == "table" then
						v[k2] = del(v2)
					end
				else
					if type(v2) == "table" then
						v[k2] = del(v2)
					end
				end
			end
			v["FIGHT_START"] = GetTime()
			if not resetOn then
				tpsSigma[k] = del(v)
			end
		end
	end

	-------------------------------------------------------
	-- Arguments:
	--	string - name of the player to get TPS for
	--	string - name of the target to get TPS on
	-- Returns:
	--	* Local TPS (float)
	--	* Encounter TPS (float)
	-------------------------------------------------------
	function ThreatLib:GetTPS(source_guid, target_guid)
		local pSigma = tpsSigma[source_guid]
		if not pSigma then return 0, 0 end
		-- self:Debug("Target is global: %s (%s, %s)", target == PUBLIC_GLOBAL_HASH, target, PUBLIC_GLOBAL_HASH)
		local tt = GetTime()
		local tTPS = pSigma[target_guid]
		local td, ftd = 0, 0
		if tTPS then
			local ttd = tt - tTPS[#tTPS]
			td = tTPS[1] * max(0, 1 - (ttd / 10))
			ftd = tTPS[2] / (tt - pSigma["FIGHT_START"])
		end
		return td, ftd
	end
end
