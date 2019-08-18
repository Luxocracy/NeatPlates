local Lib = LibStub:GetLibrary("ClassicThreat")
Lib.locales = {
    ["enUS"] = {
        ["spell"] = {
            ["Sinister Strike"] = "Sinister Strike"
        },
    },
    ["deDE"] = {
        ["spell"] = {
            -- 0 threat mods
            ["holynova"] = "Heilige Nova", -- no heal or damage threat
            ["siphonlife"] = "Lebensentzug", -- no heal threat
            
            
            ["drainlife"] = "Blutsauger", -- no heal threat
            ["lifetap"] = "Aderlass", -- no mana gain threat
            ["holyshield"] = "Heiliger Schild", -- multiplier
            ["tranquility"] = "Gelassenheit",
            ["distractingshot"] = "Ablenkender Schuss", 
            ["earthshock"] = "Erdschock",
            ["rockbiter"] = "Felsbei\195\159er",
            ["fade"] = "Verblassen",
            ["thunderfury"] = "Donnerzorn",
            
            ["deathcoil"] = "Todesmantel",
    
    
            ["heroicstrike"] = "Heldenhafter Sto\195\159",
            ["maul"] = "Zermalmen",
            ["swipe"] = "Prankenhieb",
            ["shieldslam"] = "Schildschlag",
            ["revenge"] = "Rache",
            ["shieldbash"] = "Schildhieb",
            ["sunder"] = "R\195\188stung zerrei\195\159en",
            ["feint"] = "Finte",
            ["cower"] = "Ducken",
            ["taunt"] = "Spott",
            ["growl"] = "Knurren",
            ["vanish"] = "Verschwinden",
            ["frostbolt"] = "Frostblitz",
            ["fireball"] = "Feuerball",
            ["arcanemissiles"] = "Arkane Geschosse",
            ["scorch"] = "Versengen",
            ["cleave"] = "Spalten",
            -- Items / Buffs:
            ["arcaneshroud"] = "Arkaner Schleier",
            ["reducethreat"] = "Verringerte Bedrohung",
            -- Spell Sets
            -- warlock descruction
            ["shadowbolt"] = "Schattenblitz",
            ["immolate"] = "Feuerbrand",
            ["conflagrate"] = "Feuersbrunst",
            ["searingpain"] = "Sengender Schmerz",
            ["rainoffire"] = "Feuerregen",
            ["soulfire"] = "Seelenfeuer",
            ["shadowburn"] = "Schattenbrand",
            ["hellfire"] = "H\195\182llenfeuer",
            -- mage offensive arcane
            ["arcaneexplosion"] = "Arkane Explosion",
            ["counterspell"] = "Gegenzauber",
            -- priest shadow
            ["mindblast"] = "Gedankenschlag",
        },
        ["power"] = {
            ["mana"] = "Mana",
            ["rage"] = "Wut",
            ["energy"] = "Energie",
        },
        ["talent"] = {
		    ["defiance"] = "Trotz",
            ["impale"] = "Durchbohren",
            ["silentresolve"] = "Schweigsame Entschlossenheit",
            ["shadowaffinity"] = "Schattenaffinit\195\164t",
            ["druidsubtlety"] = "Druide Feingef\195\188hl",
            ["feralinstinct"] = "Instinkt der Wildnis",
            ["ferocity"] = "Wildheit",
            ["savagefury"] = "Ungez\195\164hmte Wut",
            ["masterdemonologist"] = "Meister der D\195\164monologie",
            ["arcanesubtlety"] = "Arkanes Feingef\195\188hl",
            ["righteousfury"] = "Zorn der Gerechtigkeit",
            ["tranquility"] = "Verbesserte Gelassenheit",
            ["healinggrace"] = "Geschick der Heilung",
            ["burningsoul"] = "Brennende Seele",
            ["frostchanneling"] = "Frost-Kanalisierung",
	    },
    },
    ["enUS"] = {
        ["spell"] = {

        }
    },
    ["frFR"] = {
        ["spell"] = {
            		-- 17.20
		["execute"] = "Ex\195\169cution",
		["heroicstrike"] = "Frappe h\195\169ro\195\175que",
		["maul"] = "Mutiler",
		["swipe"] = "Balayage",
		["shieldslam"] = "Heurt de bouclier",
		["revenge"] = "Vengeance",
		["shieldbash"] = "Coup de bouclier",
		["sunder"] = "Fracasser armure",
		["feint"] = "Feinte",
		["cower"] = "D\195\169robade", --"Effrayer une b\195\170te",
		["taunt"] = "Provocation",
		["growl"] = "Grondement",
		["vanish"] = "Disparition",
		["frostbolt"] = "Eclair de glace",
		["fireball"] = "Boule de feu",
		["arcanemissiles"] = "Projectiles des arcanes",
		["scorch"] = "Br\195\187lure",
		["cleave"] = "Fendre",
		-- Items / Buffs:
		["arcaneshroud"] = " Voile des arcanes",
		["reducethreat"] = "R\195\169duction de la menace",

		-- Fel Stamina and Fel Energy DO cause threat! GRRRRRRR!!!
		--["felstamina"] = "Endurance Corrompue", -- no heal threat
		--["felenergy"] = "Fel Energy",
		-- new in R16:
		["holynova"] = "Nova sacr\195\169e", -- no heal or damage threat 
		["siphonlife"] = "Siphon de Vie", -- no heal threat 
		["drainlife"] = "Drainer la Vie", -- no heal threat 
		["lifetap"] = "Connexion", -- no heal threat 
		["holyshield"] = "Bouclier Sacr\195\169", -- multiplier 
		["tranquility"] = "Tranquilit\195\169", 
		["distractingshot"] = "Trait Provocateur", 
		["earthshock"] = "Horion de Terre", 
		["rockbiter"] = "Arme Croque-Roc", 
		["fade"] = "Oubli",
		["deathcoil"] = "Voile mortel",
		["thunderfury"] = "	Lame-tonnerre",

		-- Items / Buffs:
		--["burningadrenaline"] = "Burning Adrenaline",
		--["arcaneshroud"] = "Arcane Shroud",
		--["reducethreat"] = "Reduce Threat",

		["bloodsiphon"] = "Siphon de sang", -- poisoned blood vs Hakkar
		-- Spell Sets
		-- warlock descruction
		["shadowbolt"] = "Trait de l'ombre",
		["immolate"] = "Immolation",
		["conflagrate"] = "Conflagration",
		["searingpain"] = "Douleur br\195\187lante",
		["rainoffire"] = "Pluie de Feu",
		["soulfire"] = "Feu de l'\195\162me",
		["shadowburn"] = "Br\195\187lure de l'ombre",
		["hellfire"] = "Flammes infernales",

		-- mage offensive arcane
		["arcaneexplosion"] = "Explosion des arcanes",
		["counterspell"] = "Contresort",

		-- priest shadow
		["mindblast"] = "Attaque Mentale",
		--[[[
		"mindflay"] = "Fouet Mental",
		["devouringplague"] = "Peste D\195\169vorante",
		["shadowwordpain"] = "Mot des T\195\169n\195\168bres: Douleur",
		["manaburn"] = "Br\195\187lure de mana",
		]]
        },
        ["power"] = {
            ["mana"] = "Mana",
            ["rage"] = "Rage",
            ["energy"] = "Energie",
        },
        ["talent"] = {
            ["defiance"] = "D\195\169fi",
            ["impale"] = "Empaler",
            ["silentresolve"] = "R\195\169solution silencieuse",
            ["shadowaffinity"] = "Affinit\195\169 avec les t\195\169nebres",
            ["druidsubtlety"] = "Discr\195\169tion",
            ["feralinstinct"] = "Instinct farouche",
            ["ferocity"] = "F\195\169rocit\195\169",
            ["healinggrace"] = "Gr\195\162ce gu\195\169risseuse",
            ["savagefury"] = "Furie sauvage",
            ["masterdemonologist"] = "Ma\195\174tre d\195\169monologue",
            ["arcanesubtlety"] = "Subtilit\195\169 des arcanes",
            ["righteousfury"] = "Fureur vertueuse",
            ["tranquility"] = "Tranquilit\195\169 am\195\169lior\195\169e",
            ["burningsoul"] = "Ame ardente",
            ["frostchanneling"] = "Canalisation du givre",
        }
    },
    ["koKR"] = {
        ["spell"] = {
            ["heroicstrike"] = "영웅의 일격",
            ["maul"] = "후려치기",
            ["swipe"] = "휘둘러치기",
            ["shieldslam"] = "방패 밀쳐내기",
            ["revenge"] = "복수",
            ["shieldbash"] = "방패 가격",
            ["sunder"] = "방어구 가르기",
            ["feint"] = "교란",
            ["cower"] = "웅크리기",
            ["taunt"] = "도발",
            ["growl"] = "포효",
            ["vanish"] = "소멸",
            ["frostbolt"] = "얼음 화살",
            ["fireball"] = "화염구",
            ["arcanemissiles"] = "신비한 화살",
            ["scorch"] = "불태우기",
            ["cleave"] = "회전베기",
            hemorrhage = "과다출혈",
            backstab = "기습",
            sinisterstrike = "사악한 일격",
            eviscerate = "절개",
            -- Items / Buffs:
            ["arcaneshroud"] = "신비의 장막",
            ["reducethreat"] = "위협 수준 감소",
            -- new in R16
            ["holynova"] = "신성한 폭발", -- no heal or damage threat
            ["siphonlife"] = "생명력 착취", -- no heal threat
            ["drainlife"] = "생명력 흡수", -- no heal threat
            ["deathcoil"] = "죽음의 고리",
            -- no threat for fel stamina. energy unknown.
            --["felstamina"] = "마의 체력",
            --["felenergy"] = "마의 에너지",
            ["bloodsiphon"] = "생명력 착취", -- poisoned blood vs Hakkar
    
    
            ["lifetap"] = "생명력 전환", -- no mana gain threat
            ["holyshield"] = "신성한 방패", -- multiplier
            ["tranquility"] = "평온",
            ["distractingshot"] = "견제 사격",
            ["earthshock"] = "대지 충격",
            ["rockbiter"] = "대지의 무기",
            ["fade"] = "소실",
            ["thunderfury"] = "우레폭풍",
            -- Spell Sets
            -- warlock descruction
            ["shadowbolt"] = "어둠의 화살",
            ["immolate"] = "제물",
            ["conflagrate"] = "점화",
            ["searingpain"] = "불타는 고통", -- 2 threat per damage
            ["rainoffire"] = "불의 비",
            ["soulfire"] = "영혼의 불꽃",
            ["shadowburn"] = "어둠의 연소",
            ["hellfire"] = "지옥의 불길",
            -- mage offensive arcane
            ["arcaneexplosion"] = "신비한 폭발",
            ["counterspell"] = "마법 반사",
            -- priest shadow
            ["mindblast"] = "정신 분열", 	-- 2 threat per damage
        },
        ["power"] = {
            ["mana"] = "마나",
            ["rage"] = "분노",
            ["energy"] = "기력",
        },
    },
    ["zhCN"] = {
        ["spell"] = {
            ["heroicstrike"] = "英勇打击",
            ["maul"] = "槌击",
            ["swipe"] = "挥击",
            ["shieldslam"] = "盾牌猛击",
            ["revenge"] = "复仇",
            ["shieldbash"] = "盾击",
            ["sunder"] = "破甲攻击",
            ["feint"] = "佯攻",
            ["cower"] = "畏缩",
            ["taunt"] = "嘲讽",
            ["growl"] = "低吼",
            ["vanish"] = "消失",
            ["frostbolt"] = "寒冰箭",
            ["fireball"] = "火球术",
            ["arcanemissiles"] = "奥术飞弹",
            ["scorch"] = "灼烧",
            -- Items / Buffs:
            ["burningadrenaline"] = "燃烧刺激",
            ["arcaneshroud"] = "Arcane Shroud",
            ["reducethreat"] = "Reduce Threat",
            ["twinteleport"] = "Twin Teleport",
            -- Spell Sets
            -- warlock descruction
            ["shadowbolt"] = "暗影箭",
            ["immolate"] = "献祭",
            ["conflagrate"] = "燃烧",
            ["searingpain"] = "灼热之痛",
            ["rainoffire"] = "火焰之雨",
            ["soulfire"] = "灵魂之火",
            ["shadowburn"] = "暗影灼烧",
            ["hellfire"] = "地狱烈焰",
            -- mage offensive arcane
            ["arcaneexplosion"] = "魔爆术",
            ["counterspell"] = "法术反制",
            -- priest shadow
            ["mindflay"] = "精神鞭笞",
            ["devouringplague"] = "吸血鬼的拥抱",
            ["shadowwordpain"] = "暗言术：痛",
            ["mindblast"] = "心灵震爆",
            ["manaburn"] = "法力燃烧",
	    },
	    ["power"] = {
            ["mana"] = "法力",
            ["rage"] = "怒气",
            ["energy"] = "能量",
	    },
    },
    ["zhTW"] = {
        ["spell"] = {
            -- 17.20
            ["execute"] = "斬殺",
            ["heroicstrike"] = "英勇打擊",
            ["maul"] = "搥擊",
            ["swipe"] = "揮擊",
            ["shieldslam"] = "盾牌猛擊",
            ["revenge"] = "復仇",
            ["shieldbash"] = "盾擊",
            ["sunder"] = "破甲攻擊",
            ["feint"] = "佯攻",
            ["cower"] = "畏縮",
            ["taunt"] = "嘲諷",
            ["growl"] = "低吼",
            ["vanish"] = "消失",
            ["frostbolt"] = "寒冰箭",
            ["fireball"] = "火球術",
            ["arcanemissiles"] = "祕法飛彈",
            ["scorch"] = "灼燒",
            ["cleave"] = "順劈斬",
            ["hemorrhage"] = "出血",
            ["backstab"] = "背刺",
            ["sinisterstrike"] = "邪惡攻擊",
            ["eviscerate"] = "剔骨",
            -- Items / Buffs:
            ["arcaneshroud"] = "秘法環繞",
            ["reducethreat"] = "降低威脅",

            -- Leeches: no threat from heal
            ["holynova"] = "神聖新星", -- no heal or damage threat
            ["siphonlife"] = "生命虹吸", -- no heal threat
            ["drainlife"] = "吸取生命", -- no heal threat
            ["deathcoil"] = "死亡纏繞",

            -- Fel Stamina and Fel Energy DO cause threat! GRRRRRRR!!!
            --["felstamina"] = "惡魔耐力",
            --["felenergy"] = "惡魔能量",

            ["bloodsiphon"] = "血液虹吸", -- poisoned blood vs Hakkar

            ["lifetap"] = "生命分流", -- no mana gain threat
            ["holyshield"] = "神聖之盾", -- multiplier
            ["tranquility"] = "寧靜",
            ["distractingshot"] = "擾亂射擊",
            ["earthshock"] = "地震術",
            ["rockbiter"] = "石化",
            ["fade"] = "漸隱術",
            ["thunderfury"] = "雷霆之怒",

            -- Spell Sets
            -- warlock descruction
            ["shadowbolt"] = "暗影箭",
            ["immolate"] = "獻祭",
            ["conflagrate"] = "燃燒",
            ["searingpain"] = "灼熱之痛", -- 2 threat per damage
            ["rainoffire"] = "火焰之雨",
            ["soulfire"] = "靈魂之火",
            ["shadowburn"] = "暗影灼燒",
            ["hellfire"] = "地獄烈焰",

            -- mage offensive arcane
            ["arcaneexplosion"] = "魔爆術",
            ["counterspell"] = "法術法制",

            -- priest shadow. No longer used (R17).
            ["mindblast"] = "心靈震爆",	-- 2 threat per damage
            --[[
            ["mindflay"] = "精神鞭笞",
            ["devouringplague"] = "吸血鬼的擁抱",
            ["shadowwordpain"] = "暗言術：痛",
            ,
            ["manaburn"] = "法力燃燒",
            ]]
        },
        ["power"] = {
            ["mana"] = "法力",
            ["rage"] = "怒氣",
            ["energy"] = "能量",
        },
    },
}