
local PANEL = {}
AccessorFunc(PANEL, "Name", "Name", FORCE_STRING)
AccessorFunc(PANEL, "Selected", "Selected", FORCE_BOOL)
AccessorFunc(PANEL, "ImageURL", "ImageURL") -- Deprecated
AccessorFunc(PANEL, "ImageScale", "ImageScale") -- Deprecated

AccessorFunc(PANEL, "ImgurID", "ImgurID") -- Deprecated
AccessorFunc(PANEL, "ImgurScale", "ImgurScale") -- Deprecated

function PANEL:SetImgurID(id)
    self:SetImageURL("https://i.imgur.com/" .. id .. ".png")
    print("[PulsarUI] PulsarUI.NavbarItem:SetImgurID is deprecated, use PulsarUI.NavbarItem:SetImageURL instead.")
    self.ImgurID = id
end

function PANEL:GetImgurID()
    print("[PulsarUI] PulsarUI.NavbarItem:GetImgurID is deprecated, use PulsarUI.NavbarItem:GetImageURL instead.")
    return (self:GetImageURL() or ""):match("i.imgur.com/(.-).png")
end

function PANEL:SetImgurScale(scale)
    self:SetImageScale(scale)
    print("[PulsarUI] PulsarUI.NavbarItem:SetImgurScale is deprecated, use PulsarUI.NavbarItem:SetImageScale instead.")
    self.ImgurScale = scale
end

function PANEL:GetImgurScale()
    print("[PulsarUI] PulsarUI.NavbarItem:GetImgurScale is deprecated, use PulsarUI.NavbarItem:GetImageScale instead.")
    return self:GetImageScale()
end

PulsarUI.RegisterFont("UI.NavbarItem", "Rubik", 22, 600)

function PANEL:SetColor(col)
    self.BackgroundCol = PulsarUI.Colors.Transparent
    self.BackgroundHoverCol = ColorAlpha(col, 40)
    self.BackgroundSelectCol = ColorAlpha(col, 80)
end

function PANEL:Init()
    self:SetName("N/A")
    self:SetColor(PulsarUI.Colors.Primary)
    self:SetImageScale(0.2)
    self.NormalCol = PulsarUI.Colors.PrimaryText
    self.HoverCol = PulsarUI.Colors.SecondaryText
    self.TextCol = PulsarUI.CopyColor(self.NormalCol)
    self.BackgroundCol = PulsarUI.Colors.Transparent
    self.BackgroundHoverCol = ColorAlpha(PulsarUI.Colors.Primary, 40)
    self.BackgroundSelectCol = ColorAlpha(PulsarUI.Colors.Primary, 80)
end

function PANEL:GetItemSize()
    PulsarUI.SetFont("UI.NavbarItem")

    return PulsarUI.GetTextSize(self:GetName())
end

function PANEL:Paint(w, h)
    local textCol = self.NormalCol
    local backgroundCol = self.BackgroundCol

    if self:IsHovered() then
        textCol = self.HoverCol
        backgroundCol = self.BackgroundHoverCol
    end

    if self:IsDown() or self:GetToggle() then
        backgroundCol = self.BackgroundSelectCol
    end

    local animTime = FrameTime() * 12
    self.TextCol = PulsarUI.LerpColor(animTime, self.TextCol, textCol)
    local imageURL = self:GetImageURL()

    if imageURL then
        local imageSize = w * self:GetImageScale()
        PulsarUI.DrawImage(0, (self:GetTall() / 2) - (imageSize / 2), imageSize, imageSize, imageURL, color_white)
        PulsarUI.DrawSimpleText(self:GetName(), "UI.NavbarItem", imageSize + PulsarUI.Scale(3), h / 2, self.TextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        return
    end

    local boxW, boxH = w - PulsarUI.Scale(16), h - PulsarUI.Scale(16)
    PulsarUI.DrawRoundedBox(8, PulsarUI.Scale(8), PulsarUI.Scale(8), boxW, boxH, backgroundCol)
    PulsarUI.DrawSimpleText(self:GetName(), "UI.NavbarItem", w / 2, h / 2, self.TextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("PulsarUI.NavbarItem", PANEL, "PulsarUI.Button")
PANEL = {}

function PANEL:Init()
    self.Items = {}
    self.SelectionX = 0
    self.SelectionW = 0
    self.SelectionColor = Color(0, 0, 0)
    self.BackgroundCol = PulsarUI.Colors.Header
end

function PANEL:AddItem(id, name, doClick, order, color, imageURL)
    local btn = vgui.Create("PulsarUI.NavbarItem", self)
    local imgurMatch = (imageURL or ""):match("^[a-zA-Z0-9]+$")
    if imgurMatch then
        imageURL = "https://i.imgur.com/" .. imageURL .. ".png"
    end

    btn:SetImageURL(imageURL)
    btn:SetName(name)
    btn:SetZPos(order or table.Count(self.Items) + 1)
    btn:SetColor((IsColor(color) and color) or PulsarUI.Colors.Primary)
    btn.Function = doClick

    btn.DoClick = function(s)
        self:SelectItem(id)
    end

    self.Items[id] = btn
end

function PANEL:RemoveItem(id)
    local item = self.Items[id]
    if not item then return end
    item:Remove()
    self.Items[id] = nil
    if self.SelectedItem ~= id then return end
    self:SelectItem(next(self.Items))
end

function PANEL:SelectItem(id)
    local item = self.Items[id]
    if not item then return end
    if self.SelectedItem and self.SelectedItem == id then return end
    item:SetSelected(false)
    self.SelectedItem = id

    for k, v in pairs(self.Items) do
        v:SetToggle(false)
    end

    item:SetToggle(true)
    item.Function(item)
    item:SetSelected(true)
end

function PANEL:PerformLayout(w, h)
    self:DockMargin(PulsarUI.Scale(8), PulsarUI.Scale(8), PulsarUI.Scale(8), PulsarUI.Scale(8))

    for k, v in pairs(self.Items) do
        v:Dock(LEFT)
        v:SetWide(v:GetItemSize() + PulsarUI.Scale(50))
    end
end

function PANEL:Paint(w, h)
    PulsarUI.DrawRoundedBox(8, 0, 0, w, h, self.BackgroundCol)

    if not self.SelectedItem then
        self.SelectionX = Lerp(FrameTime() * 10, self.SelectionX, 0)
        self.SelectionW = Lerp(FrameTime() * 10, self.SelectionX, 0)
        self.SelectionColor = PulsarUI.LerpColor(FrameTime() * 10, self.SelectionColor, PulsarUI.Colors.Primary)

        return
    end
end

vgui.Register("PulsarUI.Navbar", PANEL, "Panel")