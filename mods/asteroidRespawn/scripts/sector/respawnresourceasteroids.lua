if onServer() then

package.path = package.path .. ";data/scripts/lib/?.lua"
local SectorGenerator = require("SectorGenerator")
local Placer = require("placer")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace RespawnResourceAsteroids
RespawnResourceAsteroids = {}

function RespawnResourceAsteroids.initialize()
    local numRichAsteroids = Sector():getValue("numRichAsteroids")
    richAsteroids = {Sector():getEntitiesByComponent(ComponentType.MineableMaterial)}
    if not numRichAsteroids then
        Sector():setValue("numRichAsteroids", #richAsteroids)
    end
    if numRichAsteroids and numRichAsteroids >= 5 then   -- only respanw asteroids in sectors with more than 5 resource asteroids
        RespawnResourceAsteroids.respawn()
    end
end

function RespawnResourceAsteroids.getUpdateInterval()
    return 1800.0
end

function RespawnResourceAsteroids.updateServer(timestep)
    local numRichAsteroids = Sector():getValue("numRichAsteroids")
    if numRichAsteroids and numRichAsteroids >= 5 then   -- only respanw asteroids in sectors with more than 5 resource asteroids
        RespawnResourceAsteroids.respawn()
    end
end

function RespawnResourceAsteroids.respawn()     -- respawns a single asteroid

    local numRichAsteroids = Sector():getValue("numRichAsteroids")
    local richAsteroids = {Sector():getEntitiesByComponent(ComponentType.MineableMaterial)}
    if numRichAsteroids <= #richAsteroids then return end    -- enough asteroids in sector
    -- respawn them
    local asteroids = {Sector():getEntitiesByType(EntityType.Asteroid)}
    local generator = SectorGenerator(Sector():getCoordinates())


    local size = random():getFloat(5.0, 15.0)
    local index = random():getInt(1, #asteroids)

    local astro = asteroids[index]
    if not astro then return end
    local sphere = Sphere(astro.translationf, 200.0)
    local translation = sphere.center + random():getDirection() * sphere.radius
    local asteroid = generator:createSmallAsteroid(translation, size, true, generator:getAsteroidType())
end

end
