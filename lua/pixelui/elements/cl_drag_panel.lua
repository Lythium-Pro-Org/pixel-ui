local abs = math.abs
local clamp = math.Clamp
local scale = PulsarUI.Scale
local gradientMat = Material("gui/gradient")
local PANEL = {}

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetCursor("sizeall")
	self.LargeNum = 3
	self.Sized = false

	self.Hit = false
	self.ParentW = 0
	self.ParentH = 0

	self.DraggedPastX = 0
	self.DraggedPastY = 0
end

local headerCol = PulsarUI.Colors.Header
local gridCol = PulsarUI.OffsetColor(headerCol, 4)
local middleLine = PulsarUI.OffsetColor(headerCol, 8)

function PANEL:Paint(w, h)
	PulsarUI.DrawRoundedBox(8, 0, 0, w, h, headerCol)

	for i = 0, h do
		if i % 16 == 0 then
			PulsarUI.DrawRoundedBox(0, 0, i, w, 2, gridCol)
		end
	end

	for i = 0, w do
		if i % 16 == 0 then
			PulsarUI.DrawRoundedBox(0, i, 0, 2, h, gridCol)
		end
	end

	PulsarUI.DrawRoundedBox(0, (w / 2) - scale(2), 0, 2, h, middleLine)
	PulsarUI.DrawRoundedBox(0, 0, (h / 2) + scale(1), w, 2, middleLine)

	if not self.DraggedPastY or not self.DraggedPastX then return end
	surface.SetMaterial(gradientMat)
	surface.SetDrawColor(PulsarUI.Colors.Negative)
	local maxPastY = clamp(self.DraggedPastY, 0, 512)
	local maxPastX = clamp(self.DraggedPastX, 0, 512)
	surface.DrawTexturedRectRotated(0, 0, maxPastY, w * 2, 270) -- Top
	surface.DrawTexturedRectRotated(0, h, maxPastY, w * 2, 90) -- Bottom
	surface.DrawTexturedRectRotated(0, 0, maxPastX, h * 2, 0) -- Left
	surface.DrawTexturedRectRotated(w, 0, maxPastX, h * 2, 180) -- Right
end

function PANEL:DragThink()
	self.Hit = false
	local mousex, mousey = gui.MouseX(), gui.MouseY()
	local width, height = self:GetSize()

	if self.Dragging then
		local x = mousex - self.Dragging[1]
		local y = mousey - self.Dragging[2]

		local oldX = x
		x = clamp(x, (-width) + abs(width / self.LargeNum), 0)
		self.DraggedPastX = abs(x - oldX)

		local oldY = y
		y = clamp(y, (-height) + abs(height / self.LargeNum), 0)
		self.DraggedPastY = abs(y - oldY)

		self:SetPos(x, y)
	end

	local _, screenY = self:LocalToScreen(0, 0)

	if self.Hovered and mousey < (screenY + scale(30)) then
		self:SetCursor("sizeall")

		return true
	end
end

function PANEL:Think()
	self:DragThink()
	if self.LoweringDraggedPast then
		self.DraggedPastX = Lerp(FrameTime() * 10, self.DraggedPastX, 0)
		self.DraggedPastY = Lerp(FrameTime() * 10, self.DraggedPastY, 0)
	end
end

function PANEL:OnMousePressed()
	local mouseX, mouseY = gui.MouseX(), gui.MouseY()
	self.Dragging = {mouseX - self.x, mouseY - self.y}
	self.LoweringDraggedPast = false
	self:MouseCapture(true)

	return
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	self.LoweringDraggedPast = true
	self:MouseCapture(false)
end

function PANEL:PerformLayout()
	if self.Sized then return end
	self.Sized = true
	local parent = self:GetParent()
	local parentW, parentH = parent:GetSize()
	self.ParentW  = parentW
	self.ParentH = parentH
	self:SetSize(parentW * self.LargeNum, parentH * self.LargeNum)
	self:Center()
end


vgui.Register("PulsarUI.InnerDragPanel", PANEL, "EditablePanel")

PANEL = {}

function PANEL:Recenter()
	self.Inner:Center()
end

function PANEL:Init()
	self.HasLayouted = false
	self.OldW = false
	self.OldH = false
	self.Inner = vgui.Create("PulsarUI.InnerDragPanel", self)

	self.RecenterButton = vgui.Create("PulsarUI.ImageButton", self)
	self.RecenterButton:SetSize(scale(32), scale(32))
	self.RecenterButton:SetImageURL("https://pixel-cdn.lythium.dev/i/center-icon")
	self.RecenterButton:SetNormalColor(PulsarUI.Colors.PrimaryText)
	self.RecenterButton:SetHoverColor(PulsarUI.Colors.Primary)
	self.RecenterButton:SetClickColor(PulsarUI.OffsetColor(PulsarUI.Colors.Primary, 50))
	self.RecenterButton:SetDisabledColor(PulsarUI.Colors.DisabledText)
	self.RecenterButton:SetFrameEnabled(true)
	self.RecenterButton:SetRounded(8)
	self.RecenterButton.DoClick = function()
		self:Recenter()
	end
end

function PANEL:PerformLayout(w, h)
	self.RecenterButton:SetPos(w - scale(40), h - scale(40))

	if not self.OldW or not self.OldH then
		self.OldW = w
		self.OldH = h
	end

	if self.OldW == w and self.OldH == h then return end
	self.Inner:InvalidateLayout()
	self.Inner:Center()
	self:LayoutContent(w, h)
end

function PANEL:LayoutContent(w, h)
end

vgui.Register("PulsarUI.DragPanel", PANEL, "EditablePanel")
