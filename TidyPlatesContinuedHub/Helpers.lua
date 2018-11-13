
----------------------------------
-- Helpers
----------------------------------

local function CallForStyleUpdate()

	-- This happens when the Okay button is pressed, or a UI element is used

	--print("CallForStyleUpdate")

	local theme = TidyPlatesCont:GetTheme()
	--print("CallForStyleUpdate, Theme,", theme)

	if theme.ApplyProfileSettings
		then theme:ApplyProfileSettings("From CallForStyleUpdate")
	end

end

local CachedVars = {}
local function UpdateCVars(LocalVars, profile)
	local activeProfile = "HubPanelSettings"..TidyPlatesCont.GetProfile()
	local combatLockdown = InCombatLockdown()
	local CVarChanged = false
	local CVars = {
		["NameplateMaxDistance"] = "nameplateMaxDistance",
		["NameplateTargetClamp"] = "nameplateTargetRadialPosition",
		["NameplateStacking"] = "nameplateMotion",
		["NameplateOverlapH"] = "nameplateOverlapH",
		["NameplateOverlapV"] = "nameplateOverlapV",
	}

	local function tobool(number) if number and (number == 1 or number == true) then return true else return false end end

	if profile and profile == activeProfile then
		--print(profile)
		CachedVars = CachedVars[profile] or TidyPlatesContUtility.GetCacheSet(profile)

		for TPName, actualName in pairs(CVars) do
			local currentCVar = tonumber(GetCVar(actualName))
			if CachedVars[TPName] == true or CachedVars[TPName] == false then currentCVar = tobool(currentCVar) end --Check if Boolean, If yes, convert current to boolean.

			-- If Tidyplates CVar didn't change,
			if CachedVars[TPName] == LocalVars[TPName] then
				-- but actual CVar did
				if LocalVars[TPName] ~= currentCVar then
					LocalVars[TPName], CachedVars[TPName] = currentCVar, currentCVar
					CVarChanged = true
				end
			-- Else set CVar normally
			else
				if not combatLockdown then
					SetCVar(actualName, LocalVars[TPName])
					CachedVars[TPName] = LocalVars[TPName]
				end
			end
		end
		if CVarChanged then TidyPlatesContHubMenus.RefreshPanel(TidyPlatesCont.GetProfile()) end -- Refresh Settings Panel
	end
end

local function GetPanelValues(panel, targetTable)
	-- First, clean up the target table
	-- Not yet implemented

	-- Update with values
	if panel and targetTable then
		local index
		targetTable["Theme"] = TidyPlatesCont:GetThemeName() -- Store active theme

		for index in pairs(targetTable) do
			if panel[index] then
				local value = panel[index]:GetValue()
				if tonumber(value) ~= nil then
					if panel[index].isActual then
						value = panel[index].ceil(value)	-- Use slider rounding method
					else
						value = math.ceil(value*100-0.5)/100	-- Round to 2 decimals
					end
				end
				targetTable[index] = value
			end
		end
	end
end

local function SetPanelValues(panel, sourceTable)
	for index, value in pairs(sourceTable) do
		if panel[index] then
			panel[index]:SetValue(value)
		end
	end
end


local function MergeProfileValues(target, defaults)
	local i, v
	for i, v in pairs(defaults) do
		if target[i] == nil then
			target[i] = v
		end
	end
end

local function ListToTable( ... )
	local t = {}
	local index, line
	for index = 1, select("#", ...) do
		line = select(index, ...)
		if line ~= "" then t[index] = line end
	end
	return t
end

local function ConvertStringToTable(source, target )
	local temp = ListToTable(strsplit("\n", source))
	target = wipe(target)

	for index = 1, #source do
		local str = temp[index]
		if str then target[str] = true end
	end
end


local function ConvertDebuffListTable(source, target, order)
	if source == nil then return end
	local temp = ListToTable(strsplit("\n", source))
	target = wipe(target)
	if order then order = wipe(order) end

	for index = 1, #temp do
		local str = temp[index]
		local item
		local prefix, suffix

		if str then
			prefix, suffix = select(3, string.find( str, "(%w+)[%s%p]*(.*)"))
			if prefix then
				if TidyPlatesContHubPrefixList[prefix] then
					item = suffix
					-- CONVERT
					target[item] = TidyPlatesContHubPrefixList[prefix]
				else -- If no prefix is listed, assume 1
					if suffix and suffix ~= "" then item = prefix.." "..suffix
					else item = prefix end
					-- CONVERT
					target[item] = 1
				end
				if order then order[item] = index end
			end
		end
	end

end

local function ConvertColorListTable(source, target)
	if source == nil then return end
	--local temp = ListToTable(strsplit("\n", source))
	local temp = {strsplit("\n", source)}
	target = wipe(target)

	for index = 1, #temp do
		if temp[index] then
			local hex, str = select(3, string.find(temp[index], "(#%x+)[%s%p]*(.*)"))
			--local str = temp[index]
			if hex and str then target[str] = hex end
		end
	end
end

local function AddHubFunction(functionTable, menuTable, functionPointer, functionDescription, functionKey )
	if functionTable then
		functionTable[functionKey or (#functionTable+1)] = functionPointer
	end

	if menuTable then
		menuTable[#menuTable+1] = { text = functionDescription, value = functionKey }
	end
end

TidyPlatesContHubHelpers = {}
TidyPlatesContHubHelpers.CallForStyleUpdate = CallForStyleUpdate
TidyPlatesContHubHelpers.UpdateCVars = UpdateCVars
TidyPlatesContHubHelpers.GetPanelValues = GetPanelValues
TidyPlatesContHubHelpers.SetPanelValues = SetPanelValues
TidyPlatesContHubHelpers.MergeProfileValues = MergeProfileValues
TidyPlatesContHubHelpers.ListToTable = ListToTable
TidyPlatesContHubHelpers.ConvertStringToTable = ConvertStringToTable
TidyPlatesContHubHelpers.ConvertDebuffListTable = ConvertDebuffListTable
TidyPlatesContHubHelpers.ConvertColorListTable = ConvertColorListTable
TidyPlatesContHubHelpers.AddHubFunction = AddHubFunction


local function fromCSV (s)
  s = s .. ','        -- ending comma
  local t = {}        -- table to collect fields
  local fieldstart = 1
  repeat
    -- next field is quoted? (start with `"'?)
    if string.find(s, '^"', fieldstart) then
      local a, c
      local i  = fieldstart
      repeat
        -- find closing quote
        a, i, c = string.find(s, '"("?)', i+1)
      until c ~= '"'    -- quote not followed by quote?
      if not i then error('unmatched "') end
      local f = string.sub(s, fieldstart+1, i-1)
      table.insert(t, (string.gsub(f, '""', '"')))
      fieldstart = string.find(s, ',', i) + 1
    else                -- unquoted; find next comma
      local nexti = string.find(s, ',', fieldstart)
      table.insert(t, string.sub(s, fieldstart, nexti-1))
      fieldstart = nexti + 1
    end
  until fieldstart > string.len(s)
  return t
end
--[[
local function EvaluateExpression(expression)
	print(expression)
	-- /eval oh blah, dee, oh , blah ,do
	local t = fromCSV(expression)
	for i,v in pairs(t) do
		print(i,v)
	end

end


SLASH_EVAL1 = '/eval'
SlashCmdList['EVAL'] = EvaluateExpression
--]]









