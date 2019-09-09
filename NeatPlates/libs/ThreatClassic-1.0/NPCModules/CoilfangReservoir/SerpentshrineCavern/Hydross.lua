local MAJOR_VERSION = "ThreatClassic-1.0"
local MINOR_VERSION = 4

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then _G.ThreatLib_MINOR_VERSION = MINOR_VERSION end

ThreatLib_funcs[#ThreatLib_funcs + 1] = function()
	local ThreatLib = _G.ThreatLib

	local HYDROSS_ID = 21216

	ThreatLib:GetModule("NPCCore"):RegisterModule(HYDROSS_ID, function(Hydross)
		Hydross:RegisterTranslation("enUS", function() return {
			["Aaghh, the poison..."] = "Aaghh, the poison...",
			["Better, much better."] = "Better, much better.",
		} end)

		Hydross:RegisterTranslation("deDE", function() return {
			["Aaghh, the poison..."] = "Aahh, das Gift...",
			["Better, much better."] = "Besser, viel besser.",
		} end)

		Hydross:RegisterTranslation("frFR", function() return {
			["Aaghh, the poison..."] = "Aaarrgh, le poison…",
			["Better, much better."] = "Ça va mieux. Beaucoup mieux.",
		} end)

		Hydross:RegisterTranslation("koKR", function() return {
			["Aaghh, the poison..."] = "으아아, 독이...",
			["Better, much better."] = "아... 기분이 훨씬 좋군.",
		} end)

		Hydross:RegisterTranslation("zhTW", function() return {
			["Aaghh, the poison..."] = "啊，毒……",
			["Better, much better."] = "很好，舒服多了。",
		} end)

		Hydross:RegisterTranslation("zhCN", function() return {
			["Aaghh, the poison..."] = "啊……毒性侵袭了我……",
			["Better, much better."] = "感觉好多了。",
		} end)

		local poisonPhase = Hydross:GetTranslation("Aaghh, the poison...")
		local waterPhase = Hydross:GetTranslation("Better, much better.")

		Hydross:UnregisterTranslations()

		function Hydross:Init()
			self:RegisterCombatant(HYDROSS_ID, true)
			self:RegisterChatEvent("yell", poisonPhase, self.phaseTransition)
			self:RegisterChatEvent("yell", waterPhase, self.phaseTransition)
		end

		function Hydross:phaseTransition()
			self:WipeRaidThreatOnMob(HYDROSS_ID)
		end
	end)
end
