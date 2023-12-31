PulsarUI = PulsarUI or {}
local sc = PulsarUI.Scale
local PANEL = {}
PulsarUI.GenerateFont(50)

function PANEL:Init()
	self.Avatar = vgui.Create("PulsarUI.Avatar", self)
	self.Avatar:SetPlayer(LocalPlayer(), sc(200))
	self.Avatar:SetRounding(sc(8))
	self.Avatar:SetDrawOnTop(true)
	self.Avatar:SetSize(sc(200), sc(200))
	self.Avatar:SetPos(sc(250), sc(100))

	self.Label = vgui.Create("PulsarUI.Label", self)
	self.Label:SetText("Hey " .. LocalPlayer():Nick() .. "!")
	self.Label:SetWide(sc(500))
	self.Label:SetTall(sc(100))
	self.Label:SetFont("PulsarUI.Font.Size50")
	self.Label:SetPos(sc(230), sc(300))


end

function PANEL:PaintMore(w,h)

end

function PANEL:LayoutContent(w,h)
end

vgui.Register("PulsarUI.Test.Avatar", PANEL)