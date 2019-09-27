local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local common = ReplicatedStorage:WaitForChild("common")
local lib = ReplicatedStorage:WaitForChild("lib")
local event = ReplicatedStorage:WaitForChild("event")

local Roact = require(lib:WaitForChild("Roact"))
local RoactRodux = require(lib:WaitForChild("RoactRodux"))
local Items = require(common:WaitForChild("Items"))
local Sprites = require(common:WaitForChild("Sprites"))
local Actions = require(common:WaitForChild("Actions"))
local Selectors = require(common:WaitForChild("Selectors"))

local eRequestEquip = event:WaitForChild("eRequestEquip")

local ItemLabel = Roact.Component:extend("ItemLabel")

local errors = {
    invalidItemId = "Invalid itemId [%s]!",
    invalidSpriteSheet = "Invalid sprite sheet [%s]!",
}

function ItemLabel:init()
end

function ItemLabel:didMount()
end

function ItemLabel:render()
    local itemId = self.props.itemId
    local quantity = self.props.quantity
    local isGray = self.props.isGray
    local layoutOrder = self.props.layoutOrder or 0
    local showTooltip = self.props.showTooltip or true
    local activatable = self.props.activatable or false
    local equipped = self.props.isEquipped and activatable

    local item = Items.byId[itemId]
    local spriteSheet = Sprites[item.spriteSheet or "materials"]
    assert(item, errors.invalidItemId:format(tostring(itemId)))
    assert(spriteSheet, errors.invalidSpriteSheet:format(tostring(spriteSheet)))

    local spriteRectSize = spriteSheet.spriteSize * spriteSheet.scaleFactor
    local spriteRectOffset = Vector2.new(
        (item.spriteCoords.X-1) * spriteSheet.spriteSize.X,
        (item.spriteCoords.Y-1) * spriteSheet.spriteSize.Y
    )   * spriteSheet.scaleFactor

    local itemName = item.name or itemId

    local quantityLabel
    if quantity then
        quantityLabel = Roact.createElement("TextLabel", {
            Size = UDim2.new(0,24,0,24),
            AnchorPoint = Vector2.new(1,1),
            Position = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Text = quantity,
            TextSize = 18,
            TextColor3 = Color3.new(1,1,1),
            TextStrokeTransparency = 0,
            Font = Enum.Font.GothamBlack,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Bottom,
        })
    end

    local equippedLabel
    if equipped then
        equippedLabel = Roact.createElement("Frame", {
            Size = UDim2.new(0,12,0,12),
            Position = UDim2.new(0,4,0,4),
            BackgroundColor3 = Color3.fromRGB(0, 207, 0),
            BorderSizePixel = 2,
            Rotation = 45,
        })
    end

    local statStrings = {}

    for stat,value in pairs(item.stats or {}) do
        local newString = ("%s: %s"):format(stat,tostring(value))
        table.insert(statStrings,newString)
    end

    return Roact.createElement(activatable and "ImageButton" or "ImageLabel", {
        Size = UDim2.new(0,spriteSheet.spriteSize.X * 3,0,spriteSheet.spriteSize.Y * 3),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,

        Image = spriteSheet.assetId,
        ImageRectSize = spriteRectSize,
        ImageRectOffset = spriteRectOffset,

        Selectable = activatable,

        ImageColor3 = isGray and Color3.new(0.3,0.3,0.3) or Color3.new(1,1,1),
        [Roact.Event.MouseEnter] = showTooltip and function() self.props.showTooltip(itemName,unpack(statStrings)) end or nil,
        [Roact.Event.MouseLeave] = showTooltip and function() self.props.hideTooltip() end or nil,
        [Roact.Event.SelectionGained] = showTooltip and function() self.props.showTooltip(itemName,unpack(statStrings)) end or nil,
        [Roact.Event.SelectionLost] = showTooltip and function() self.props.hideTooltip() end or nil,
        [Roact.Event.Activated] = activatable and function() eRequestEquip:FireServer(itemId) end or nil,
    }, {
        quantityLabel = quantityLabel,
        equippedLabel = equippedLabel,
    })
end

ItemLabel = RoactRodux.connect(function(state,props)
    return {
        isEquipped = Selectors.getIsEquipped(state,LocalPlayer,props.itemId)
    }
end, function(dispatch)
    return {
        showTooltip = function(...)
            local strings = {...}
            dispatch(Actions.TOOLTIP_STRINGS_SET(strings))
            dispatch(Actions.TOOLTIP_VISIBLE_SET(true))
        end,
        hideTooltip = function()
            dispatch(Actions.TOOLTIP_VISIBLE_SET(false))
        end
    }
end)(ItemLabel)

return ItemLabel