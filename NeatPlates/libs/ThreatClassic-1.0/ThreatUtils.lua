local MAJOR_VERSION = "ThreatClassic-1.0"
local MINOR_VERSION = 4
local tconcat = _G.table.concat
local tostring = _G.tostring
local error = _G.error
local UnitName = _G.UnitName
local UnitIsUnit = _G.UnitIsUnit
local setmetatable = _G.setmetatable
local GetRaidRosterInfo = _G.GetRaidRosterInfo
local GetNumGroupMembers = _G.GetNumGroupMembers
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local IsInRaid = _G.IsInRaid
local type = _G.type
local select = _G.select
local next = _G.next
local pairs = _G.pairs
local tremove = _G.tremove
local strmatch = _G.string.match
local strsplit = _G.string.split

_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
_G.ThreatLib_funcs = {}

ThreatLib_funcs[#ThreatLib_funcs + 1] = function()
	local ThreatLib = _G.ThreatLib

	local playerName = UnitName("player")
	local tableCount, usedTableCount = 0, 0
	---------------------------------------------------------
	-- Utility functions
	---------------------------------------------------------

	-- #NODOC
	function ThreatLib:Debug(msg, ...)
		if self.DebugEnabled then
			if _G.ChatFrame5 then
				local a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p = ...
				_G.ChatFrame5:AddMessage(("|cffffcc00ThreatLib-Debug: |r" .. msg):format(
					tostring(a),
					tostring(b),
					tostring(c),
					tostring(d),
					tostring(e),
					tostring(f),
					tostring(g),
					tostring(h),
					tostring(i),
					tostring(j),
					tostring(k),
					tostring(l),
					tostring(m),
					tostring(n),
					tostring(o),
					tostring(p)
				))
			else
				_G.DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00ThreatLib-Debug: |rPlease create ChatFrame5 for ThreatLib debug messages.")
			end
		end
	end

	function ThreatLib:GroupDistribution()
		if GetNumGroupMembers() > 0 and IsInRaid() then
			return "RAID"
		else
			return "PARTY"
		end
	end

	function ThreatLib:toliteral(q)
		if type(q) == "string" then
			return ("%q"):format(q)
		else
			return tostring(q)
		end
	end

	-- Table recycling
	local new, newHash, newSet, del
	do
		local list = setmetatable({}, {__mode = 'k'})

		function new(...)
			usedTableCount = usedTableCount + 1
			local t = next(list)
			if t then
				list[t] = nil
				for i = 1, select('#', ...) do
					t[i] = select(i, ...)
				end
			else
				tableCount = tableCount + 1
				t = {...}
			end
			return t
		end
		ThreatLib.new = new
		function newHash(...)
			usedTableCount = usedTableCount + 1
			local t = next(list)
			if t then
				list[t] = nil
			else
				tableCount = tableCount + 1
				t = {}
			end
			for i = 1, select('#', ...), 2 do
				t[select(i, ...)] = select(i + 1, ...)
			end
			return t
		end
		ThreatLib.newHash = newHash
		function newSet(...)
			usedTableCount = usedTableCount + 1
			local t = next(list)
			if t then
				list[t] = nil
			else
				tableCount = tableCount + 1
				t = {}
			end
			for i = 1, select('#', ...) do
				t[select(i, ...)] = true
			end
			return t
		end
		ThreatLib.newSet = newSet
		function del(t)
			usedTableCount = usedTableCount - 1
			setmetatable(t, nil)
			for k in pairs(t) do
				t[k] = nil
			end
			t[''] = true
			t[''] = nil
			list[t] = true
			return nil
		end
		ThreatLib.del = del
	end

	function ThreatLib:TableStats()
		return usedTableCount, tableCount
	end

	function ThreatLib:IsGroupOfficer(unit)
		if GetNumGroupMembers() == 0 then return unit == "player" end
		if GetNumGroupMembers() > 0 and IsInRaid() then
			for i = 1, GetNumGroupMembers() do
				if UnitIsUnit("raid" .. i, unit) then
					local _, rank = GetRaidRosterInfo(i)
					if rank > 0 then
						return true
					end
				end
			end
		elseif GetNumGroupMembers() > 0 then
			if UnitIsGroupLeader("player") and unit == "player" then
				return true
			else
				for i = 1, 4 do
					if UnitIsGroupLeader("party" .. i) then
						return UnitIsUnit(unit, "party" .. i)
					end
				end
			end
		end
		return false
	end

	------------------------------------
	-- Memoization stuffs
	------------------------------------
	ThreatLib.memoizations = ThreatLib.memoizations or {}
	ThreatLib.reverse_memoizations = ThreatLib.reverse_memoizations or {}
	local memoizations = ThreatLib.memoizations
	local reverse_memoizations = ThreatLib.reverse_memoizations

	function ThreatLib:RegisterMemoizations(t)
		for k, v in pairs(t) do
			memoizations[k] = v
			reverse_memoizations[v] = k
		end
	end

	function ThreatLib:Memoize(s)
		if not memoizations[s] then
			error(("Invalid memoization: %s"):format(s))
		end
		return memoizations[s]
	end

	function ThreatLib:Dememoize(b)
		if not reverse_memoizations[b] then
			error(("Invalid reverse memoization: %s"):format(b))
		end
		return reverse_memoizations[b]
	end

	function ThreatLib:OnCommReceived(prefix, message, distribution, sender)
		if sender == playerName then return end
		local isAce = strmatch(message, "^%^")
		if not isAce then
			local cmd, msg = strmatch(message, "^(..)(.*)$")
			if msg then
				local func = self.OnCommReceive[reverse_memoizations[cmd]]
				if func then
					func(self, sender, distribution, msg)
				end
			end
		else
			local success,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p = self:Deserialize(message)
			if success then
				self.OnCommReceive[reverse_memoizations[a]](self, sender, distribution, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
			end
		end
	end

	function ThreatLib:SendComm(distribution, command, ...)
		self:SendCommMessage(self.prefix, self:Serialize(self:Memoize(command), ...), distribution)
	end

	function ThreatLib:SendCommRaw(distribution, command, data)
		local str = self:Memoize(command) .. data
		self:SendCommMessage(self.prefix, str, distribution)
	end

	function ThreatLib:SendCommWhisper(distribution, to, command, ...)
		self:SendCommMessage(self.prefix, self:Serialize(self:Memoize(command), ...), distribution, to)
	end

	-- needs rework
	local st = {}
	function ThreatLib:SerializeThreatTable(pgid, t)
		local l, nl = #st, 2
		-- for i = 1, #st do tremove(st) end
		st[1] = select(6, strsplit("-", pgid)) or select(3, strsplit("-", pgid))
		st[2] = ":"
		for k, v in pairs(t) do
			nl = nl + 1
			st[nl] = ("%s=%x,"):format(select(6, strsplit("-", k)) or select(3, strsplit("-", k)), v)
		end
		for i = nl + 1, l do
			tremove(st)
		end
		return tconcat(st)
	end

	function ThreatLib:NPCID(guid)
		local unitType, _, _, _, _, npcID = strsplit("-", guid)
		if unitType ~= "Player" then
			return npcID
		end
	end

	function ThreatLib:Log(action, from, to, threat)
		self.threatLog[from] = self.threatLog[from] or {}
		local t = self.threatLog[from]
		tinsert(t, GetTime())
		tinsert(t, action)
		tinsert(t, to)
		tinsert(t, threat)
		ThreatLib.callbacks:Fire(action, GetTime(), from, to, threat)
	end

	function ThreatLib:GetSpellID(spellName, unit, auraType)
		-- change localized MELEE string into the appropriate spellID
		if spellName == MELEE then
			return 6603
		-- get spellID from auras
		elseif auraType and unit then
			if auraType == AURA_TYPE_DEBUFF then
				return select(10, AuraUtil.FindAuraByName(spellName, unit, "HARMFUL")) or 0
			else
				return select(10, AuraUtil.FindAuraByName(spellName, unit)) or 0
			end
		-- get spellID from cache/spellbook
		else
			-- eventually build a cache from UNIT_SPELLCAST_* events to track lower ranks
			-- for now, we just assume max rank and get that spellID from the spellbook
			return select(7, GetSpellInfo(spellName))
		end
	end

	local localizedNPCSpells = {}

	local npcSpells = {
		-- threat * 0.5
		[23339] = true,	-- Wing Buffet
		[10101] = true,	-- Knock Away

		-- threat * 0.75
		[19633] = true,	-- Knock Away
		[20566] = true,	-- Wrath of Ragnaros

		-- wipe threat
		[26102] = true,	-- Sand Blast

		-- Other
		[23138] = true,	-- Gate of Shazzrah
		[28410] = true,	-- Chains of Kel'Thuzad
		[29211] = true,	-- Blink
	}

	for id in pairs(npcSpells) do
		local n = GetSpellInfo(id)
		if n then
			localizedNPCSpells[n] = id
		end
	end
	npcSpells = nil

	function ThreatLib:GetNPCSpellID(spellName)
		-- need to write a way to make sure we get the right "Knock Away"
		-- one is 0.5 and the other is 0.75
		-- mainly an issue on Onyxia
		return localizedNPCSpells[spellName] or 0
	end
end
