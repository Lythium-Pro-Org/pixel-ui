
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
    Should we disable the PIXEL UI Reskin of the notification?
]]
PIXEL.DisableNotification = false

--[[
    The Imgur ID of the progress image you want to appear when Imgur content is loading.
]]
PIXEL.ProgressImageID = "635PPvg"

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

    Primary = Color(74, 61, 255),
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

    Primary = Color(74, 61, 255),
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

    PrimaryText = Color(74, 61, 255),
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

    Primary = Color(74, 61, 255),
    Disabled = HexColor("#697098"), -- Disabled
    Positive = HexColor("#addb67"), -- Green
    Negative = HexColor("#ff6363"), -- Red

    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),

    Transparent = Color(0, 0, 0, 0)
}

PIXEL.Themes["DiscordDark"] = {
    Background = Color(54, 57, 63),
    Header = Color(47, 49, 54),
    SecondaryHeader = Color(51, 54, 59),
    Scroller = Color(32, 34, 37),

    PrimaryText = Color(255, 255, 255),
    SecondaryText = Color(185, 187, 190),
    DisabledText = Color(40, 40, 40),

    Primary = Color(88, 101, 242),
    Disabled = Color(114, 118, 125),
    Positive = Color(87, 242, 135),
    Negative = Color(237, 66, 69),

    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),

    Transparent = Color(0, 0, 0, 0)
}

PIXEL.Themes["DiscordLight"] = {
    Background = Color(255, 255, 255),
    Header = Color(242, 243, 245),
    SecondaryHeader = Color(220, 223, 227),
    Scroller = Color(204, 204, 204),

    PrimaryText = Color(6, 6, 7),
    SecondaryText = Color(79, 86, 96),
    DisabledText = Color(79, 86, 96),

    Primary = Color(88, 101, 242),
    Disabled = Color(79, 86, 96),
    Positive = Color(87, 242, 135),
    Negative = Color(237, 66, 69),

    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),

    Transparent = Color(0, 0, 0, 0)
}