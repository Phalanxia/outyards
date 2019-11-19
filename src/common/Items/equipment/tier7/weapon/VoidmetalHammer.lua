local targetDPS = 250
local fireRate = 1.3

return {
    id = "hammerVoidmetal",
    name = "Voidmetal Hammer",
    tier = 7,

    equipmentType = "weapon",
    behaviorType = "melee",
    rendererType = "oneHandedWeapon",

    spriteSheet = "weapon",
    spriteCoords = Vector2.new(8,2),

    onlyOne = true,
    recipe = {
        ingotVoidmetal = 10,
    },

    stats = {
        baseDamage = math.floor(targetDPS/fireRate),
    },

    metadata = {
        fireRate = fireRate,
        attackRange = 14,
        attackArc = 90, -- in degrees
    },

    tags = {
        "weapon",
        "melee",
    },
}