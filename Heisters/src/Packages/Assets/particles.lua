function health_bar_mist()
    local psystem = love.graphics.newParticleSystem(particles.sheet, 1000)
    psystem:setQuads(particles[1])
    psystem:setParticleLifetime(0.5, 1)
    psystem:setEmissionRate(1000)
	psystem:setSizeVariation(0.5)
	psystem:setLinearAcceleration(-10, -90, 10, 0)
    psystem:setColors(0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0)

    return psystem
end

function garbage_mist()
    local psystem = love.graphics.newParticleSystem(particles.sheet, 1000)
    psystem:setEmissionArea('uniform', 4,4)
    psystem:setQuads(particles[2])
    psystem:setParticleLifetime(1, 2)
    psystem:setEmissionRate(25)
	psystem:setSizeVariation(0.5)
	psystem:setLinearAcceleration(-11, -21, 11, 0)
    psystem:setColors(0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0)

    return psystem
end