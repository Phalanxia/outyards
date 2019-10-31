local ReplicatedStorage = game:GetService("ReplicatedStorage")

local common = ReplicatedStorage:WaitForChild("common")
local util = common:WaitForChild("util")

local by = require(util:WaitForChild("by"))

local catagories = {
    {
        id = "weapon",
        name = "Weapon",
        icon = "",
    },
    {
        id = "armor",
        name = "Armor",
        icon = "",
    },
    {
        id = "hat",
        name = "Hat",
        icon = "",
    },
    {
        id = "feet",
        name = "Feet",
        icon = "",
    },
    {
        id = "trinket",
        name = "Trinket",
        icon = "",
    },
}

return {
    all = catagories,
    byId = by("id", catagories),
}