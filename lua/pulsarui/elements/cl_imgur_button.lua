

local PANEL = {}

AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING)
AccessorFunc(PANEL, "ImgurSize", "ImgurSize", FORCE_NUMBER)

function PANEL:SetImgurID(id)
    assert(type(id) == "string", "bad argument #1 to 'SetImgurID' (string expected, got " .. type(id))
    print("[PulsarUI] PulsarUI.ImgurButton:SetImgurID is deprecated, use PulsarUI.ImageButton:SetImageURL instead.")
    self.ImgurID = id
    self:SetImageURL("https://i.imgur.com/" .. id .. ".png")
end

function PANEL:GetImgurID()
    print("[PulsarUI] PulsarUI.ImgurButton:GetImgurID is deprecated, use PulsarUI.ImageButton:GetImgurID instead.")
    return (self:GetImageURL() or ""):match("https://i.imgur.com/(.*).png")
end

function PANEL:SetImgurSize(size)
    assert(type(size) == "number", "bad argument #1 to 'SetImgurSize' (number expected, got " .. type(size))
    print("[PulsarUI] PulsarUI.ImgurButton:SetImgurSize is deprecated, use PulsarUI.ImageButton:SetImageSize instead.")
    self.ImgurSize = size
    self:SetImageSize(size, size)
end

function PANEL:GetImgurSize()
    print("[PulsarUI] PulsarUI.ImgurButton:GetImgurSize is deprecated, use PulsarUI.ImageButton:GetImageSize instead.")
    return self:GetImageSize()
end

function PANEL:Init()
    print("[PulsarUI] PulsarUI.ImgurButton is deprecated, use PulsarUI.ImageButton instead.")
end

vgui.Register("PulsarUI.ImgurButton", PANEL, "PulsarUI.ImageButton")