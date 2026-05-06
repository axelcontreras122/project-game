-- src/client/modules/CardAnimator.luau
local CardAnimator = {}
CardAnimator.__index = CardAnimator

function CardAnimator.new(mass, force, damping)
    local self = setmetatable({}, CardAnimator)
    self.Target = Vector2.new(0, 0)
    self.Position = Vector2.new(0, 0)
    self.Velocity = Vector2.new(0, 0)
    
    self.Mass = mass or 5
    self.Force = force or 50
    self.Damping = damping or 4
    
    return self
end

function CardAnimator:Update(dt)
    local displacement = self.Target - self.Position
    local springForce = displacement * self.Force
    local dampingForce = self.Velocity * self.Damping
    
    local acceleration = (springForce - dampingForce) / self.Mass
    self.Velocity = self.Velocity + acceleration * dt
    self.Position = self.Position + self.Velocity * dt
    
    return self.Position
end

return CardAnimator