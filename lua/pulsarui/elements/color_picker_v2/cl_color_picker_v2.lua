
local PANEL = {}
AccessorFunc(PANEL, "AlphaBarEnabled", "AlphaBar", FORCE_BOOL)
AccessorFunc(PANEL, "ShowTextEntries", "ShowTextEntries", FORCE_BOOL)
AccessorFunc(PANEL, "AutoHeight", "AutoHeight", FORCE_BOOL)
AccessorFunc(PANEL, "Hue", "Hue")
AccessorFunc(PANEL, "Saturation", "Saturation")
AccessorFunc(PANEL, "Luminosity", "Luminosity")
AccessorFunc(PANEL, "Alpha", "Alpha")
AccessorFunc(PANEL, "R", "R")
AccessorFunc(PANEL, "G", "G")
AccessorFunc(PANEL, "B", "B")
PulsarUI.RegisterFont("UI.ColorPickerNumberEntry", "Rubik", 12)

function PANEL:Init()
	self:SetShowTextEntries(true)
	self:SetSize(PulsarUI.Scale(256), PulsarUI.Scale(50))
	self.ColorBox = vgui.Create("EditablePanel", self)
	self.ColorBox:Dock(LEFT)
	self.ColorBox:SetWide(self:GetTall())
	self.ColorBox:DockMargin(0, 0, PulsarUI.Scale(10), 0)

	self.ColorBox.Paint = function(s, w, h)
		local alpha = self:GetAlpha()
		if alpha < 255 then
			PulsarUI.Mask(function()
				PulsarUI.DrawFullRoundedBox(8, 0, 0, w, h, color_white)
			end, function()
				PulsarUI.DrawImage(0, 0, w, h, "https://pixel-cdn.lythium.dev/i/transparent-squares", color_white)
			end)
		end

		local color = PulsarUI.SetColorTransparency(self:GetColor(), alpha)
		PulsarUI.DrawRoundedBox(8, 0, 0, w, h, color)
	end

	self.HueBar = vgui.Create("PulsarUI.HueBar", self)
	self.HueBar:Dock(TOP)
	self.HueBar:SetTall(PulsarUI.Scale(20))
	self.HueBar:DockMargin(0, 0, 0, 0)
	self.SaturationBar = vgui.Create("PulsarUI.SaturationBar", self)
	self.SaturationBar:Dock(TOP)
	self.SaturationBar:SetTall(PulsarUI.Scale(20))
	self.SaturationBar:DockMargin(0, PulsarUI.Scale(10), 0, 0)
	self.LuminosityBar = vgui.Create("PulsarUI.LuminosityBar", self)
	self.LuminosityBar:Dock(TOP)
	self.LuminosityBar:SetTall(PulsarUI.Scale(20))
	self.LuminosityBar:DockMargin(0, PulsarUI.Scale(10), 0, 0)
	self.AlphaBar = vgui.Create("PulsarUI.AlphaBar", self)
	self.AlphaBar:Dock(TOP)
	self.AlphaBar:SetTall(PulsarUI.Scale(20))
	self.AlphaBar:DockMargin(0, PulsarUI.Scale(10), 0, 0)

	self.HueBar.OnChange = function(_, hue)
		local s, l, a = self:GetSaturation(), self:GetLuminosity(), self:GetAlpha()
		local color = HSLToColor(hue, s, l)
		color.a = a
		self:UpdateColor(hue, s, l, a, color)
	end

	self.SaturationBar.OnChange = function(_, saturation)
		local h, l, a = self:GetHue(), self:GetLuminosity(), self:GetAlpha()
		local color = HSLToColor(h, saturation, l)
		color.a = a
		self:UpdateColor(h, saturation, l, a, color)
	end

	self.LuminosityBar.OnChange = function(_, luminosity)
		local h, s, a = self:GetHue(), self:GetSaturation(), self:GetAlpha()
		local color = HSLToColor(h, s, luminosity)
		color.a = a
		self:UpdateColor(h, s, luminosity, a, color)
	end

	self.AlphaBar.OnChange = function(_, alpha)
		local h, s, l = self:GetHue(), self:GetSaturation(), self:GetLuminosity()
		local color = HSLToColor(h, s, l)
		color.a = alpha
		self:UpdateColor(h, s, l, alpha, color)
	end

	self:SetColor(Color(0, 0, 255))
	self:SetAlphaBar(true)
	self:SetAutoHeight(true)
	self:InvalidateLayout()
end

function PANEL:SetAlphaBar(enabled)
	self.AlphaBarEnabled = enabled

	if IsValid(self.AlphaBar) then
		self.AlphaBar:SetVisible(enabled)
	end

	self:InvalidateLayout()
end

function PANEL:CalculateHeight()
	local height = self.HueBar:GetTall() + self.SaturationBar:GetTall() + self.LuminosityBar:GetTall() + PulsarUI.Scale(20)

	if self.AlphaBar:IsVisible() then
		height = height + self.AlphaBar:GetTall() + PulsarUI.Scale(10)
	end

	return height
end

function PANEL:PerformLayout()
	if self:GetAutoHeight() then
		self:SetTall(self:CalculateHeight())
	end

	self.ColorBox:SetWide(self:GetTall() or 0)
end

function PANEL:TranslateValues(x, y)
end

function PANEL:SetColor(color)
	local h, s, l = ColorToHSL(color)
	self:UpdateColor(h, s, l, color.a or 255, color)
end

function PANEL:SetVector(vec)
	self:SetColor(Color(vec.x * 255, vec.y * 255, vec.z * 255, 255))
end

function PANEL:UpdateColor(h, s, l, a, color)
	self:SetHue(h)
	self:SetSaturation(s)
	self:SetLuminosity(l)
	self:SetAlpha(a)

	if not color then
		color = HSLToColor(h, s, l)
	end

	local baseColor = PulsarUI.CopyColor(color)
	baseColor.a = 255

	if IsValid(self.HueBar) then
		self.HueBar:SetHue(h)
		self.HueBar:SetSaturation(s)
		self.HueBar:SetLuminosity(l)
	end

	if IsValid(self.SaturationBar) then
		self.SaturationBar:SetBaseColor(baseColor)
		self.SaturationBar:SetHue(h)
		self.SaturationBar:SetSaturation(s)
		self.SaturationBar:SetLuminosity(l)
	end

	if IsValid(self.LuminosityBar) then
		self.LuminosityBar:SetBaseColor(baseColor)
		self.LuminosityBar:SetHue(h)
		self.LuminosityBar:SetSaturation(s)
		self.LuminosityBar:SetLuminosity(l)
	end

	if IsValid(self.AlphaBar) then
		self.AlphaBar:SetBaseColor(baseColor)
		self.AlphaBar:SetAlpha(a)
	end

	self:ValueChanged(color)
	self.Color = color
	self.R = color.r
	self.G = color.g
	self.B = color.b
end

function PANEL:ValueChanged(color)
end

function PANEL:GetColor()
	local h = self:GetHue()
	local s = self:GetSaturation()
	local l = self:GetLuminosity()
	local color = HSLToColor(h, s, l)

	return color
end

function PANEL:GetVector()
	local col = self:GetColor()

	return Vector(col.r / 255, col.g / 255, col.b / 255)
end

function PANEL:Think()
	self:ConVarThink()
end

function PANEL:ConVarThink()
	if input.IsMouseDown(MOUSE_LEFT) then return end
end

function PANEL:DoConVarThink(convar)
	if not convar then return end
	local value = GetConVar(convar):GetInt()
	local oldValue = self["ConVarOld" .. convar]
	if oldValue and value == oldValue then return oldValue, false end
	self["ConVarOld" .. convar] = value

	return value, true
end

vgui.Register("PulsarUI.ColorPickerV2", PANEL, "EditablePanel")