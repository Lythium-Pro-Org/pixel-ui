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

	self.ImgurButton = vgui.Create("PIXEL.ImgurButton", self)
	self.ImgurButton:Dock(TOP)
	self.ImgurButton:DockMargin(sc(10), sc(10), sc(10), sc(10))
	self.ImgurButton:SetSize(sc(50), sc(50))
	self.ImgurButton:SetImgurID("8bKjn4t")
	self.ImgurButton:SetNormalColor(PIXEL.Colors.PrimaryText)
	self.ImgurButton:SetHoverColor(PIXEL.Colors.Negative)
	self.ImgurButton:SetClickColor(PIXEL.Colors.Positive)
	self.ImgurButton:SetDisabledColor(PIXEL.Colors.DisabledText)

	self.ImgurButton.DoClick = function()
		notification.AddLegacy("Imgur Button!", NOTIFY_GENERIC, 5)
	end
end

function PANEL:PaintOver(w, h)
end

vgui.Register("PIXEL.Test.Buttons", PANEL)