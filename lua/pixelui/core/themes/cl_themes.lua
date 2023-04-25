PIXEL = PIXEL or {}
PIXEL.Themes = PIXEL.Themes or {}

PIXEL.DefaultThemes = PIXEL.DefaultThemes or {"Dark", "Light", "GitHubDark", "NightOwl", "DiscordDark", "DiscordLight"}

PIXEL.Themes["Dark"] = {
    included = true,
    Background = Color(22, 22, 22),
    Header = Color(28, 28, 28),
    SecondaryHeader = Color(43, 43, 43),
    Scroller = Color(61, 61, 61),
    PrimaryText = Color(255, 255, 255),
    SecondaryText = Color(220, 220, 220),
    DisabledText = Color(40, 40, 40),
    Primary = Color(2, 153, 204),
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
    included = true,
    Background = PIXEL.HexToColor("#F7F8FA"),
    Header = PIXEL.HexToColor("#edf1f5"),
    SecondaryHeader = PIXEL.HexToColor("#DFE1E4"),
    Scroller = PIXEL.HexToColor("#edf1f5"),
    PrimaryText = PIXEL.HexToColor("#292D31"),
    SecondaryText = PIXEL.HexToColor("#808080"),
    DisabledText = PIXEL.HexToColor("#9ba0a3"),
    Primary = Color(2, 153, 204),
    Disabled = PIXEL.HexToColor("#9ba0a3"),
    Positive = PIXEL.HexToColor("#79CB60"),
    Negative = PIXEL.HexToColor("#d73a49"),
    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),
    Transparent = Color(0, 0, 0, 0)
}

PIXEL.Themes["GitHubDark"] = {
    included = true,
    Background = PIXEL.HexToColor("#24292e"),
    Header = PIXEL.HexToColor("#2f363d"),
    SecondaryHeader = PIXEL.HexToColor("#2b3036"),
    Scroller = PIXEL.HexToColor("#2f363d"),
    PrimaryText = Color(255, 255, 255),
    SecondaryText = PIXEL.HexToColor("#c9d1d9"),
    DisabledText = PIXEL.HexToColor("#39414a"),
    Primary = Color(2, 153, 204),
    Disabled = PIXEL.HexToColor("#6a737d"),
    Positive = PIXEL.HexToColor("#85e89d"),
    Negative = PIXEL.HexToColor("#f97583"),
    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),
    Transparent = Color(0, 0, 0, 0)
}

PIXEL.Themes["NightOwl"] = {
    included = true,
    Background = PIXEL.HexToColor("#011627"), -- Background
    Header = PIXEL.HexToColor("#0b2942"), -- Seccond Background
    SecondaryHeader = PIXEL.HexToColor("#13344f"), -- Active
    Scroller = PIXEL.HexToColor("#0b2942"), -- Seccond Background
    PrimaryText = PIXEL.HexToColor("#FBFBFB"), -- Text
    SecondaryText = PIXEL.HexToColor("#d9d9d9"), -- Buttons
    DisabledText = PIXEL.HexToColor("#697098"), -- Disabled
    Primary = Color(2, 153, 204),
    Disabled = PIXEL.HexToColor("#697098"), -- Disabled
    Positive = PIXEL.HexToColor("#addb67"), -- Green
    Negative = PIXEL.HexToColor("#ff6363"), -- Red
    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),
    Transparent = Color(0, 0, 0, 0)
}

PIXEL.Themes["DiscordDark"] = {
    included = true,
    Background = Color(54, 57, 63),
    Header = Color(47, 49, 54),
    SecondaryHeader = Color(51, 54, 59),
    Scroller = Color(32, 34, 37),
    PrimaryText = Color(255, 255, 255),
    SecondaryText = Color(185, 187, 190),
    DisabledText = Color(40, 40, 40),
    Primary = Color(2, 153, 204),
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
    included = true,
    Background = Color(255, 255, 255),
    Header = Color(242, 243, 245),
    SecondaryHeader = Color(220, 223, 227),
    Scroller = Color(204, 204, 204),
    PrimaryText = Color(6, 6, 7),
    SecondaryText = Color(79, 86, 96),
    DisabledText = Color(79, 86, 96),
    Primary = Color(2, 153, 204),
    Disabled = Color(79, 86, 96),
    Positive = Color(87, 242, 135),
    Negative = Color(237, 66, 69),
    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),
    Transparent = Color(0, 0, 0, 0)
}