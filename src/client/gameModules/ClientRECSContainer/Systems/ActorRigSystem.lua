local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lib = ReplicatedStorage:WaitForChild("lib")
local common = ReplicatedStorage:WaitForChild("common")
-- local util = common:WaitForChild("util")
local model = ReplicatedStorage:WaitForChild("model")
local npcModel = model:WaitForChild("npc")

local npcModels = {}

for _,child in pairs(npcModel:GetDescendants()) do
    if child:IsA("Model") and child:FindFirstChild("AnimationController") then
        npcModels[child.Name] = child
    end
end

local Animations = require(common:WaitForChild("Animations"))
local NPCS = require(common:WaitForChild("NPCS"))
local RECS = require(lib:WaitForChild("RECS"))
local RecsComponents = require(common:WaitForChild("RecsComponents"))

local ActorRigSystem = RECS.System:extend("ActorRigSystem")

function ActorRigSystem:onComponentAdded(instance, component)
    local npcComponent = self.core:getComponent(instance, RecsComponents.NPC)
    local aiComponent = self.core:getComponent(instance, RecsComponents.AI)
    if not npcComponent then return end

    local npcType = npcComponent.npcType

    local rig = npcModels[npcType]
    if not rig then return end

    rig = rig:Clone()
    rig.PrimaryPart.Anchored = false
    rig:SetPrimaryPartCFrame(instance.CFrame)

    local weld = Instance.new("Motor6D")
    weld.Part0 = rig.PrimaryPart
    weld.Part1 = instance
    weld.Parent = rig.PrimaryPart

    rig.Parent = self.rigBin

    if aiComponent then
        local animationController = rig:FindFirstChildOfClass("AnimationController")

        local animations = {
            chase = animationController:LoadAnimation(Animations.r6run),
            attack = animationController:LoadAnimation(Animations.r6attack),
            idle = animationController:LoadAnimation(Animations.r6idle),
        }

        local npcDescription = NPCS.byType[npcType]

        local playingAnimation

        aiComponent.changed:connect(function(key, newValue, oldValue)
            if key == "aiState" then
                local newState = newValue.state
                if playingAnimation then playingAnimation:Stop() end
                if animations[newState] then
                    playingAnimation = animations[newState]
                    animations[newState]:Play()
                end
            end
        end)

        animations.idle:Play(0.2)
    end

    self.rigs[instance] = rig

    instance.Transparency = 1
end

function ActorRigSystem:onComponentRemoving(instance, component)
    local rig = self.rigs[instance]
    if rig then rig:Destroy() end
end

function ActorRigSystem:init()
    self.rigBin = Instance.new("Folder")
    self.rigBin.Name = "rigbin"
    self.rigBin.Parent = workspace

    self.rigs = {}

    for instance,component in self.core:components(RecsComponents.AI) do
        self:onComponentAdded(instance, component)
    end

    self.core:getComponentAddedSignal(RecsComponents.AI):connect(function(instance,component)
        self:onComponentAdded(instance, component)
    end)
    self.core:getComponentRemovingSignal(RecsComponents.AI):connect(function(instance,component)
        self:onComponentRemoving(instance, component)
    end)
end

function ActorRigSystem:step()
end

return ActorRigSystem