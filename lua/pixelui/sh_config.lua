--[[
PIXEL UI
Copyright (C) 2021 Tom O'Sullivan (Tom.bat)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

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
    Should we disable The UI Sounds?
]]
PIXEL.DisableUISounds = false

--[[
    The Imgur ID of the progress image you want to appear when Imgur content is loading.
]]
PIXEL.ProgressImageID = "w72Iz3n"