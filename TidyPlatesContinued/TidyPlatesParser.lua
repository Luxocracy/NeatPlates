
-- Requires:
-- TidyPlatesContUtility
-- TidyPlatesContDefaults
-- TidyPlatesContThemeList, TidyPlatesContInternal.ThemeTemplate

local addonName, TidyPlatesContInternal = ...
local UseTheme = TidyPlatesContInternal.UseTheme

local copytable = TidyPlatesContUtility.copyTable
local mergetable = TidyPlatesContUtility.mergeTable

local function SetTheme(...)
	local arg1, arg2 = ...

	if arg1 == TidyPlatesCont then themeName = arg2
	else themeName = arg1 end

	local theme 	-- This will store the pointer to the theme table

	-- Sends a nil notification to all available themes to encourage cleanup
	for themename, themetable in pairs(TidyPlatesContThemeList) do
		if themetable.OnActivateTheme then themetable.OnActivateTheme(nil) end
	end

	-- Get theme table
	if type(TidyPlatesContThemeList) == "table" then
		if type(themeName) == 'string' then
			theme = TidyPlatesContThemeList[themeName]
		end
	end

	-- Verify & Scrub theme data, then attempt to load...
	if type(theme) == 'table' then

		-- Multi-Style Theme   (Hub / ThreatPlates Format)
		if theme.SetStyle and type(theme.SetStyle) == "function" then
			local style, stylename

			for stylename, style in pairs(theme) do
				if type(style) == "table" and style._meta then						-- _meta tag skips parsing
					theme[stylename] = copytable(style)
				elseif type(style) == "table" then									-- merge style with template style
					theme[stylename] = mergetable(TidyPlatesContInternal.ThemeTemplate, style)		-- ie. fill in the blanks
				end
			end
		else
			-- Single-Style Theme  (Old School!)
			local newvalue, propertyname, oldvalue

			for propertyname, oldvalue in pairs(TidyPlatesContInternal.ThemeTemplate) do
				newvalue = theme[propertyname]
				if type(newvalue) == "table" then theme[propertyname] = mergetable(oldvalue, newvalue)
				else theme[propertyname] = copytable(oldvalue) end
			end
		end

		-- Choices: Overwrite themeName as it's processed, or Overwrite after the processing is done
		UseTheme(theme)

		-- ie. (Theme Table, Theme Name) -- nil is sent for all themes, to reset everything (^ above ^) and then the current theme is activated
		if theme.OnActivateTheme then theme.OnActivateTheme(theme) end
		TidyPlatesContInternal.activeThemeName = themeName

		TidyPlatesContOptions.ActiveTheme = TidyPlatesContInternal.activeThemeName
		TidyPlatesCont:ForceUpdate()
		return theme
	else
		-- This block falls back to the template, and leaves the field blank...
		TidyPlatesContInternal.activeThemeName = nil
		TidyPlatesContOptions.ActiveTheme = ""

		UseTheme(TidyPlatesContInternal.ThemeTemplate)
		return nil
	end


end

-- /run TidyPlatesCont:SetTheme("Neon")

TidyPlatesCont.SetTheme = SetTheme
TidyPlatesContInternal.SetTheme = SetTheme

-- Placeholders..  Here to avoid Threat Plates error;  Will be removed at some point.
local function Dummy() end
TidyPlatesCont.ActivateTheme = Dummy
TidyPlatesCont.ReloadTheme = Dummy
