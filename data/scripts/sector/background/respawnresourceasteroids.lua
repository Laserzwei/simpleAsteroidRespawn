if onClient() then return end
-- TODO addShipProblem("respawning", entityId, "Asteroids respawn in this sector."%_t, "data/textures/icons/valuables-detected.png", highlightColor)

local config = include("data/config/simpleasteroidRespawn")
local highlightColor = ColorRGB(0.70, 0.73, 0.77) -- silver
--overwriting vanilla initialize()
function RespawnResourceAsteroids.initialize()
    local maxSpawnableAsteroids = Sector():getValue("maxSpawnableAsteroids")
    if not maxSpawnableAsteroids then
        maxSpawnableAsteroids = RespawnResourceAsteroids.getRichAsteroids()
        Sector():setValue("maxSpawnableAsteroids", maxSpawnableAsteroids)
    end
    Sector():registerCallback("onRestoredFromDisk", "onRestoredFromDisk")
end

function RespawnResourceAsteroids.getUpdateInterval()
    return config.respawnTime / 2
end

function RespawnResourceAsteroids.updateServer(timestep)
    local maxSpawnableAsteroids = Sector():getValue("maxSpawnableAsteroids")
    if maxSpawnableAsteroids then
        RespawnResourceAsteroids.respawn(timestep)
    end
end

function RespawnResourceAsteroids.respawn(timestep)     -- respawns a % of the original Asteroid #
    local maxSpawnableAsteroids = Sector():getValue("maxSpawnableAsteroids") or 0
    if (maxSpawnableAsteroids == 0) then return end
    local numRichAsteroids = RespawnResourceAsteroids.getRichAsteroids()
    if numRichAsteroids >= maxSpawnableAsteroids then return end    -- enough asteroids in sector
    local numRespawns = (timestep / config.respawnTime)
    local amount = maxSpawnableAsteroids * config.respawnAmount * numRespawns
    if (amount < 1) then return end -- not enough time passed or config.respawnAmount too low

    -- respawn them
    local asteroids = {Sector():getEntitiesByType(EntityType.Asteroid)}
    local generator = SectorGenerator(Sector():getCoordinates())
    local spawned = {}
    for i=1, amount do
        local size = random():getFloat(5.0, 25.0)
        local index = random():getInt(1, #asteroids)
        local astro = asteroids[index]
        if valid(astro) then
            local sphere = Sphere(astro.translationf, random():getFloat(180, 250))
            local translation = sphere.center + random():getDirection() * sphere.radius
            local asteroid = generator:createSmallAsteroid(translation, size, true, generator:getAsteroidType())
            spawned[#spawned+1] = asteroid
        end
    end
    Placer.resolveIntersections(spawned)
end

function RespawnResourceAsteroids.getRichAsteroids()
    local asteroids = {}
    local a = {Sector():getEntitiesByType(EntityType.Asteroid)} or {}
    for _, astro in ipairs(a) do
        local r = astro:getMineableResources()
        if r then
            asteroids[#asteroids+1] = astro
        end
    end
    return #asteroids
end

function RespawnResourceAsteroids.onRestoredFromDisk(time)
    local maxSpawnableAsteroids = Sector():getValue("maxSpawnableAsteroids")
    if not maxSpawnableAsteroids then
        maxSpawnableAsteroids = RespawnResourceAsteroids.getRichAsteroids()
        Sector():setValue("maxSpawnableAsteroids", maxSpawnableAsteroids)
    end
    RespawnResourceAsteroids.respawn(time)
end
