if onClient() then print("Why u on client?") --[[return]] end

local config = require("data/config/simpleasteroidRespawn")

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
    return config.respawnTime
end

function RespawnResourceAsteroids.updateServer(timestep)
    local maxSpawnableAsteroids = Sector():getValue("maxSpawnableAsteroids")
    if maxSpawnableAsteroids then
        RespawnResourceAsteroids.respawn()
    end
end

function RespawnResourceAsteroids.respawn()     -- respawns a % of the original Asteroid #
    local maxSpawnableAsteroids = Sector():getValue("maxSpawnableAsteroids") or 0
    local numRichAsteroids = RespawnResourceAsteroids.getRichAsteroids()
    if numRichAsteroids >= maxSpawnableAsteroids then return end    -- enough asteroids in sector
    -- respawn them
    local asteroids = {Sector():getEntitiesByType(EntityType.Asteroid)}
    local generator = SectorGenerator(Sector():getCoordinates())
    local spawned = {}

    local amount = maxSpawnableAsteroids * config.respawnAmount
    if amount < 1 then amount = 1 end
    local c = 0
    for i=1, amount do
        local size = random():getFloat(5.0, 15.0)
        local index = random():getInt(1, #asteroids)

        local astro = asteroids[index]
        if valid(astro) then
            c= c+1
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
    local turns = time / config.respawnTime
    for i=1,math.abs(math.min(turns,1/config.respawnAmount)) do -- We don't do more than the max required respawn cycles per load
        RespawnResourceAsteroids.respawn()
    end
end
