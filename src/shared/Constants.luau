-- src/shared/Constants.luau
local Constants = {
    COLORS = {
        BACKGROUND = Color3.fromRGB(15, 15, 18), -- Fondo ultra oscuro
        CARD = Color3.fromRGB(30, 30, 35),       -- Color tarjeta profesional
        TEXT = Color3.fromRGB(255, 255, 255),
        ACCENT = Color3.fromRGB(0, 122, 255),    -- Azul iOS
    },
    UI_SETTINGS = {
        CORNER_RADIUS = UDim.new(0, 15),
    }
}

return Constants