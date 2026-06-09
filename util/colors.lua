-- Базовая палитра: описательные имена, без дублей
local base = {
    -- фоны
    black  = 0x000000,
    ink    = 0x090C11,
    navy   = 0x232F42,
    frame  = 0x2B3A52,

    -- нейтральные
    slate  = 0x5B6776,
    silver = 0xCDD6E4,
    white  = 0xFFFFFF,

    -- тёплые
    coral  = 0xFF5D5D,
    rose   = 0xF5625B,
    ember  = 0xFF9D4D,
    gold   = 0xFFCF3F,

    -- холодные
    emerald = 0x5AD15A,
    sky     = 0x5AA8FF,
    teal    = 0x37C0E0,
    amber   = 0xE6B450,
}

-- Кастомная палитра — все уникальные базовые цвета автоматически.
-- gpu.setPaletteColor не даст квантователю схлопнуть близкие тёмные оттенки.
local palette = {}
for _, v in pairs(base) do
    palette[#palette + 1] = v
end
base.palette = palette

-- Семантические алиасы: указывают на base-цвета, доступны как colors.bgCard и т.д.
local aliases = {
    bgScreen  = base.ink,
    bgCard    = base.navy,
    bgFrame   = base.frame,

    textPrimary   = base.white,
    textSecondary = base.silver,
    textMuted     = base.slate,

    statusOn    = base.emerald,
    statusWarn  = base.amber,
    statusError = base.coral,
    statusOff   = base.slate,

    accentCoolant = base.teal,
    accentAir     = base.sky,
    accentTemp    = base.ember,
    accentEnergy  = base.emerald,
    accentFuel    = base.gold,
    accentError   = base.rose,
}

-- base-имена тоже доступны через COLORS.ink, COLORS.teal, etc.
return setmetatable(aliases, { __index = base })
