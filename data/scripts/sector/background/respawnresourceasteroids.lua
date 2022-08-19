if onClient() then return end

local config = include("data/config/simpleasteroidRespawn")

self.respawnTime = config.respawnTime
self.respawnAmount = config.respawnAmount  
self.maxSpawnableAsteroids = nil

--overwriting vanilla initialize()
function RespawnResourceAsteroids.initialize()
    local sector = Sector()
    RespawnResourceAsteroids.updateVars()
    if self.maxSpawnableAsteroids == nil or self.maxSpawnableAsteroids == 0 then
        self.maxSpawnableAsteroids = RespawnResourceAsteroids.getRichAsteroids()
        --print("Found respawnable Asteroids:", self.maxSpawnableAsteroids, sector:getCoordinates())
        sector:setValue("maxSpawnableAsteroids", self.maxSpawnableAsteroids)
    end
    
    sector:registerCallback("onRestoredFromDisk", "onRestoredFromDisk")
end

function RespawnResourceAsteroids.updateVars() 
    local sector = Sector()
    local maxSpawnableAsteroids = sector:getValue("maxSpawnableAsteroids")
    if maxSpawnableAsteroids ~= nil then
        self.maxSpawnableAsteroids = maxSpawnableAsteroids
    end
    local respawnTime = sector:getValue("rra_respawnTime")
    if respawnTime ~= nil then
        self.respawnTime = respawnTime
    end
    local respawnAmount = sector:getValue("rra_respawnAmount")
    if respawnAmount ~= nil then
        self.respawnAmount = respawnAmount
    end
end

function RespawnResourceAsteroids.getUpdateInterval()
    return self.respawnTime / 2
end

function RespawnResourceAsteroids.updateServer(timestep)
    RespawnResourceAsteroids.updateVars()
    if self.maxSpawnableAsteroids then
        RespawnResourceAsteroids.respawn(timestep)
    end
end

function RespawnResourceAsteroids.respawn(timestep)     -- respawns a % of the original Asteroid #
    if self.maxSpawnableAsteroids == nil or self.maxSpawnableAsteroids == 0 then return end
    local numRichAsteroids = RespawnResourceAsteroids.getRichAsteroids()
    if numRichAsteroids >= self.maxSpawnableAsteroids then return end    -- enough asteroids in sector
    local numRespawns = (timestep / self.respawnTime)
    local amount = self.maxSpawnableAsteroids * self.respawnAmount * numRespawns
    if (numRichAsteroids + amount) >= self.maxSpawnableAsteroids then
        amount = self.maxSpawnableAsteroids - numRichAsteroids
    end
    if (amount < 1) then return end -- not enough time passed or self.respawnAmount too low
    --print("Restored to:", math.floor(numRichAsteroids) .. "/" .. self.maxSpawnableAsteroids, "asteroids")

    -- respawn them
    local sector = Sector()
    local asteroids = {sector:getEntitiesByType(EntityType.Asteroid)}
    local generator = SectorGenerator(sector:getCoordinates())
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
    RespawnResourceAsteroids.updateVars()
    RespawnResourceAsteroids.respawn(time)
end
