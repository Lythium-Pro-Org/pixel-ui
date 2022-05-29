
local sc = PIXEL.Scale
local Notices = {}
local notifAmount = 0
surface.CreateFont("PIXEL.NotifyFont", {
	font = "Open Sans Bold",
	size = 25,
	weight = 500,
	antialias = true,
})


function PIXEL.Notify(text, type, length)
	local parent = nil
	if ( GetOverlayPanel ) then parent = GetOverlayPanel() end

	local notif = vgui.Create("PIXEL.Notification", parent)
	notif:SetLength(math.max(length, 0))
	notif:SetText(text)

	if notifAmount > 0 then
		notif:SetPos(ScrW() - notif:GetWide() - sc(25), ScrH() - sc(200) - (sc(50) * notifAmount))
	else
		notif:SetPos(ScrW() - notif:GetWide() - sc(25), ScrH() - sc(200))
	end
	table.insert(Notices, notif)
end

hook.Add("Initialize", "NotificationOverride", function()
	local oldNotification = notification.AddLegacy

	function notification.AddLegacy(text, type, length)
		if PIXEL.DisableNotification then
			oldNotification(text, type, length)
		else
			PIXEL.Notify(text, type, length)
		end
	end
end)

local PANEL = {}

function PANEL:SetText(txt)
	self.NotifyText = txt
	surface.SetFont("PIXEL.NotifyFont")
	self:SetWide(surface.GetTextSize(txt) + sc(25))
end

function PANEL:SetLength(sec)
	sec = sec + .2
	self.Length = sec

	timer.Simple(sec, function()
		self:Close()
	end)
end

function PANEL:Init()
	notifAmount = notifAmount + 1
	self:SetTall(sc(40))
	self:SetWide(sc(40))
	self.NotifyText = ""
	self:SetVisible(false)
	self:Open()
end

function PANEL:SizeToContents()
end

function PANEL:SetLegacyType()
end

function PANEL:Paint(w, h)
	local shouldDraw = not (LocalPlayer and IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera")
	if not shouldDraw then return end

	PIXEL.DrawRoundedBoxEx(sc(6), sc(5), 0, w, h, Color(0, 0, 0, 200), false, true, false, true)
	PIXEL.DrawRoundedBoxEx(sc(6), 0, 0, sc(5), h, PIXEL.Colors.Primary, true, false, true, false)
	PIXEL.DrawSimpleText(self.NotifyText, "PIXEL.NotifyFont", w / 2, h / 2 - sc(1), PIXEL.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function PANEL:SetProgress(frac)
end

function PANEL:KillSelf()
end

function PANEL:Open()
	self:SetAlpha(0)
	self:SetVisible(true)
	self:AlphaTo(255, .1, 0)
end

function PANEL:Close()
	self:AlphaTo(0, .1, 0, function(anim, pnl)
		if not IsValid(pnl) then return end
		pnl:SetVisible(false)
		pnl:Remove()
	end)

	notifAmount = notifAmount - 1
end


vgui.Register("PIXEL.Notification", PANEL, "EditablePanel")