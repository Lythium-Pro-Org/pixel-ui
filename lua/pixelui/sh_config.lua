--[[
    Should we override the default derma popups for the PIXEL UI reskins?
    0 = No - forced off.
    1 = No - but users can opt in via convar (pixel_ui_override_popups).
    2 = Yes - but users must opt in via convar.
    3 = Yes - forced on.
]]
PIXEL.OverrideDermaMenus = 0

--[[
    Should we disable the PIXEL UI Reskin of the notification?
]]
PIXEL.DisableNotification = false

--[[
    The Image URL of the progress image you want to appear when image content is loading.
]]
PIXEL.ProgressImageURL = "https://pixel-cdn.lythium.dev/i/47qh6kjjh"

--[[
    The location at which downloaded assets should be stored (relative to the data folder).
]]
PIXEL.DownloadPath = "pixel/images/"

--[[
    Colour definitions.
]]
PIXEL.Colors = {
    Background = Color(22, 22, 22),
    Header = Color(28, 28, 28),
    Scroller = Color(61, 61, 61),

    PrimaryText = Color(255, 255, 255),
    SecondaryText = Color(220, 220, 220),
    DisabledText = Color(40, 40, 40),

    Primary = Color(47, 128, 200),
    Disabled = Color(180, 180, 180),
    Positive = Color(66, 134, 50),
    Negative = Color(164, 50, 50),

    Gold = Color(214, 174, 34),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),

    Transparent = Color(0, 0, 0, 0)
}