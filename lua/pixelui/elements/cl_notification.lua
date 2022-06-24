
local sc = PIXEL.Scale
local Notices = {}
local notifyAmount = 0

surface.CreateFont("PIXEL.NotifyFont", {
	font = "Open Sans Bold",
	size = 25,
	weight = 500,
	antialias = true,
})


function PIXEL.Notify(text, type, length)
	local ply = LocalPlayer()
	if not ply.NotifyAmount then ply.NotifyAmount = 0 end
	ply.NotifyAmount = ply.NotifyAmount + 1
	local parent = nil
	if ( GetOverlayPanel ) then parent = GetOverlayPanel() end
	local notif = vgui.Create("PIXEL.Notification", parent)
	notif:SetLength(math.max(length, 0))
	notif:SetText(text)
	notif:SetType(type)
	table.insert(Notices, notif)

	if ply.NotifyAmount > 0 then
		notif:SetPos(ScrW() - notif:GetWide() - sc(25), ScrH() - sc(200) - (sc(50) * ply.NotifyAmount))
	else
		notif:SetPos(ScrW() - notif:GetWide() - sc(25), ScrH() - sc(200))
	end
end

hook.Add("Initialize", "PIXEL.NotificationOverride", function()
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
	self:SetWide(PIXEL.GetTextSize(txt, "PIXEL.NotifyFont") + sc(25))
end

function PANEL:SetType(type)
	self.NotifyType = type
	if type == NOTIFY_GENERIC then
		PIXEL.PlayNotify()
	elseif type == NOTIFY_ERROR then
		PIXEL.PlayError(1)
	elseif type == NOTIFY_UNDO then
		PIXEL.PlayError(2)
	elseif type == NOTIFY_HINT then
		PIXEL.PlaySuccess(1)
	elseif type == NOTIFY_CLEANUP then
		PIXEL.PlayError(5)
	end
end

function PANEL:SetLength(sec)
	sec = sec + .2
	self.Length = sec

	timer.Simple(sec, function()
		self:Close()
	end)
end

function PANEL:Init()
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

function PANEL:Open()
	self:SetAlpha(0)
	self:SetVisible(true)
	self:AlphaTo(255, .1, 0)
end

function PANEL:Close()
	local ply = LocalPlayer()
	self:AlphaTo(0, .1, 0, function(anim, pnl)
		if not IsValid(pnl) then return end
		pnl:SetVisible(false)
		pnl:Remove()
	end)

	ply.NotifyAmount = ply.NotifyAmount - 1
end

function PANEL:SetProgress(frac) end

function PANEL:KillSelf() end

vgui.Register("PIXEL.Notification", PANEL, "EditablePanel")
