local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local event = ReplicatedStorage.event
local common = ReplicatedStorage.common

local ParticleCreator = require(common.ParticleCreator)

local eAttackActor = event.eAttackActor

return {
    id = "rocket",
    speed = 120,
    gravityScale = 0.05,

    onFire = function(entity, component, pzCore)
        ParticleCreator.spawnParticle("spark", {
            cFrame = entity.CFrame,
            scale = 0.3,
            amount = 1
        })
    end,

    onHit = function(entity, component, pzCore, hit, hitPos, normal)
        -- if its an enemy do damage

        ParticleCreator.spawnParticle("circle", {
            cFrame = entity.CFrame,
            scale = 4,
            amount = 1
        })

        ParticleCreator.spawnParticle("ring", {
            cFrame = entity.CFrame,
            scale = 8,
            amount = 1
        })
            -- find npcs
        local cornerOffset = Vector3.new(1,1,1)*16
        local topCorner = entity.CFrame.p + cornerOffset
        local bottomCorner = entity.CFrame.p - cornerOffset
        local testRegion = Region3.new(bottomCorner,topCorner)

        local parts = Workspace:FindPartsInRegion3WithWhiteList(testRegion, CollectionService:GetTagged("ActorStats"))

        if component.owned then
            if CollectionService:HasTag(hit, "ActorStats") then
                eAttackActor:FireServer(hit)
            end

            for _,v in pairs(parts) do
                if v ~= hit then
                    eAttackActor:FireServer(v)
                end
            end
        end
    end,
}