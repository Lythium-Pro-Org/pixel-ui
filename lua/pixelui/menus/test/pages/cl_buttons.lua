PIXEL = PIXEL or {}
local sc = PIXEL.Scale
local PANEL = {}

function PANEL:Init()
	self.Button = vgui.Create("PIXEL.Button", self)
	self.Button:Dock(TOP)
	self.Button:DockMargin(sc(10), sc(10), sc(10), sc(10))
	self.Button:SetTall(sc(50))

	self.Button.DoClick = function()
		notification.AddLegacy("Normal Button!", NOTIFY_GENERIC, 5)
	end

	self.TextButton = vgui.Create("PIXEL.TextButton", self)
	self.TextButton:Dock(TOP)
	self.TextButton:DockMargin(sc(10), sc(10), sc(10), sc(10))
	self.TextButton:SetTall(sc(50))
	self.TextButton:SetText("Non Clicky Button!")

	self.TextButton.DoClick = function()
		notification.AddLegacy("Non Clicky Text button!", NOTIFY_GENERIC, 5)
	end

	self.ImageButton = vgui.Create("PIXEL.ImageButton", self)
	self.ImageButton:Dock(TOP)
	self.ImageButton:DockMargin(sc(10), sc(10), sc(10), sc(10))
	self.ImageButton:SetSize(sc(50), sc(50))
	self.ImageButton:SetImgurID("https://pixel-cdn.lythium.dev/i/pixellogo")
	self.ImageButton:SetNormalColor(PIXEL.Colors.PrimaryText)
	self.ImageButton:SetHoverColor(PIXEL.Colors.Negative)
	self.ImageButton:SetClickColor(PIXEL.Colors.Positive)
	self.ImageButton:SetDisabledColor(PIXEL.Colors.DisabledText)

	self.ImageButton.DoClick = function()
		notification.AddLegacy("Image Button!", NOTIFY_GENERIC, 5)
	end
end

function PANEL:PaintOver(w, h)
end

vgui.Register("PIXEL.Test.Buttons", PANEL)