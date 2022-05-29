function HexColor(hex, alpha)
    hex = hex:gsub("#","")
    return Color ( tonumber("0x" .. hex:sub(1,2)), tonumber("0x" .. hex:sub(3,4)), tonumber("0x" .. hex:sub(5,6)), alpha or 255 )
end

--[[
	PIXEL UI - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

--[[
    Should we override the default derma popups for the PIXEL UI reskins?
    0 = No - forced off.
    1 = No - but users can opt in via convar (pixel_ui_override_popups).
    2 = Yes - but users must opt in via convar.
    3 = Yes - forced on.
]]
PIXEL.OverrideDermaMenus = 0

--[[
    The Imgur ID of the progress image you want to appear when Imgur content is loading.
]]
PIXEL.ProgressImageID = "635PPvg"

--[[
    The location at which downloaded assets should be stored (relative to the data folder).
]]
PIXEL.DownloadPath = "pixel/images/"

--[[
    Colour definitions.
]]

PIXEL.DefaultTheme = "Dark"

PIXEL.Themes = PIXEL.Themes or {} -- do not touch
PIXEL.Themes["Dark"] = {
    Background = Color(22, 22, 22),
    Header = Color(28, 28, 28),
    SecondaryHeader = Color(43, 43, 43),
    Scroller = Color(61, 61, 61),

    PrimaryText = Color(255, 255, 255),
    SecondaryText = Color(220, 220, 220),
    DisabledText = Color(40, 40, 40),

    Primary = Color(77, 79, 199),
    Disabled = Color(180, 180, 180),
    Positive = Color(68, 235, 124),
    Negative = Color(235, 68, 68),

    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),

    Transparent = Color(0, 0, 0, 0)
}

PIXEL.Themes["Light"] = {
    Background = HexColor("#F7F8FA"),
    Header = HexColor("#edf1f5"),
    SecondaryHeader = HexColor("#DFE1E4"),
    Scroller = HexColor("#edf1f5"),

    PrimaryText = HexColor("#292D31"),
    SecondaryText = HexColor("#808080"),
    DisabledText = HexColor("#9ba0a3"),

    Primary = HexColor("#6f42c1"),
    Disabled = HexColor("#9ba0a3"),
    Positive = HexColor("#79CB60"),
    Negative = HexColor("#d73a49"),

    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),

    Transparent = Color(0, 0, 0, 0)
}

PIXEL.Themes["GitHubDark"] = {
    Background = HexColor("#24292e"),
    Header = HexColor("#2f363d"),
    SecondaryHeader = HexColor("#2b3036"),
    Scroller = HexColor("#2f363d"),

    PrimaryText = HexColor("#b7d1d9"),
    SecondaryText = HexColor("#c9d1d9"),
    DisabledText = HexColor("#39414a"),

    Primary = HexColor("#b392f0"),
    Disabled = HexColor("#6a737d"),
    Positive = HexColor("#85e89d"),
    Negative = HexColor("#f97583"),

    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),

    Transparent = Color(0, 0, 0, 0)
}

PIXEL.Themes["NightOwl"] = {
    Background = HexColor("#011627"), -- Background
    Header = HexColor("#0b2942"), -- Seccond Background
    SecondaryHeader = HexColor("#13344f"), -- Active
    Scroller = HexColor("#0b2942"), -- Seccond Background

    PrimaryText = HexColor("#FBFBFB"), -- Text
    SecondaryText = HexColor("#d9d9d9"), -- Buttons
    DisabledText = HexColor("#697098"), -- Disabled

    Primary = HexColor("#c792ea"), -- Purple
    Disabled = HexColor("#697098"), -- Disabled
    Positive = HexColor("#addb67"), -- Green
    Negative = HexColor("#ff6363"), -- Red

    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),

    Transparent = Color(0, 0, 0, 0)
}