PIXEL = PIXEL or {}
PIXELConfigurator = PIXELConfigurator or {}

local sc = PIXEL.Scale

local PANEL = {}

AccessorFunc(PANEL, "Description", "Description", FORCE_STRING)
AccessorFunc(PANEL, "Version", "Version", FORCE_STRING)
AccessorFunc(PANEL, "Developer", "Developer", FORCE_STRING)

PIXEL.GenerateFont(20)
PIXEL.GenerateFont(19)

function PANEL:Init()
	self:SetSize(sc(900), sc(600))
	self:Center()
	self:MakePopup()

	self:SetTitle("PIXEL Configurator")
	self:SetVersion("1.0")
	self:SetDescription("Some description")
	self:SetDeveloper("PIXEL")

	self.Sidebar = self:CreateSidebar("PIXEL.Test.Avatar")

	function self.Sidebar:Paint(w, h)
		PIXEL.DrawRoundedBoxEx(PIXEL.Scale(6), 0, sc(30), w, h, self.BackgroundCol, false, false, true)
	end

	for k, v in pairs(PIXELConfigurator.RegisteredAddons) do
		self.Sidebar:AddItem(v.vguiID, v.name, v.icon, function()
			self:ChangeTab(v.vguiID)
		end)
	end

	function self.Sidebar.Scroller:LayoutContent(w, h)
		self:DockMargin(0, sc(20),0, 0)
		local spacing = PIXEL.Scale(8)
		local height = PIXEL.Scale(35)
		for k,v in pairs(self:GetParent().Items) do
			v:SetTall(height)
			v:Dock(TOP)
			v:DockMargin(0, sc(0), 0, spacing)
		end
	end
end

function PANEL:PaintHeader(x, y, w, h)
	PIXEL.DrawRoundedBoxEx(PIXEL.Scale(6), x, y, w, h, PIXEL.Colors.Header, true, true)

	PIXEL.DrawSimpleText(self:GetTitle() .. " - v" .. self:GetVersion(), "PIXEL.Font.Size20", x + PIXEL.Scale(8), sc(15), PIXEL.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER)
	PIXEL.DrawSimpleText(self:GetDescription() .. " - By " .. self:GetDeveloper(), "PIXEL.Font.Size19", x + PIXEL.Scale(16), sc(35), PIXEL.Colors.SecondaryText, nil, TEXT_ALIGN_CENTER)
end

function PANEL:Paint(w, h)
	PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, PIXEL.Colors.Background)
	self:PaintHeader(0, 0, w, PIXEL.Scale(60))
	self:PaintMore(w, h)
end

vgui.Register("PIXEL.Configurator.Menu", PANEL, "PIXEL.Frame")

if IsValid(pixelmenu) then
	pixelmenu:Remove()
	pixelmenu = vgui.Create("PIXEL.Configurator.Menu")
else
	pixelmenu = vgui.Create("PIXEL.Configurator.Menu")
end