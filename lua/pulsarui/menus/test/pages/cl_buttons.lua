PulsarUI = PulsarUI or {}
local sc = PulsarUI.Scale
local PANEL = {}

function PANEL:Init()
	self.Button = vgui.Create("PulsarUI.Button", self)
	self.Button:Dock(TOP)
	self.Button:DockMargin(sc(10), sc(10), sc(10), sc(10))
	self.Button:SetTall(sc(50))

	self.Button.DoClick = function()
		notification.AddLegacy("Normal Button!", NOTIFY_GENERIC, 5)
	end

	self.TextButton = vgui.Create("PulsarUI.TextButton", self)
	self.TextButton:Dock(TOP)
	self.TextButton:DockMargin(sc(10), sc(10), sc(10), sc(10))
	self.TextButton:SetTall(sc(50))
	self.TextButton:SetText("Text Button!")

	self.TextButton.DoClick = function()
		notification.AddLegacy("Text button!", NOTIFY_GENERIC, 5)
	end

	self.ImageButton = vgui.Create("PulsarUI.ImageButton", self)
	self.ImageButton:Dock(TOP)
	self.ImageButton:DockMargin(sc(10), sc(10), sc(10), sc(10))
	self.ImageButton:SetSize(sc(50), sc(50))
	self.ImageButton:SetImageURL("https://pixel-cdn.lythium.dev/i/pixellogo")
	self.ImageButton:SetNormalColor(PulsarUI.Colors.PrimaryText)
	self.ImageButton:SetHoverColor(PulsarUI.Colors.Negative)
	self.ImageButton:SetClickColor(PulsarUI.Colors.Positive)
	self.ImageButton:SetDisabledColor(PulsarUI.Colors.DisabledText)

	self.ImageButton.DoClick = function()
		notification.AddLegacy("Image Button!", NOTIFY_GENERIC, 5)
	end
end

function PANEL:PaintOver(w, h)
end

vgui.Register("PulsarUI.Test.Buttons", PANEL)