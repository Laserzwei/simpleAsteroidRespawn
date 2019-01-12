local Config = {}

Config.Author = "Laserzwei"
Config.ModName = "Simple Asteroid Respawn"
Config.version = {
    major=1, minor=0, patch = 0,
    string = function()
        return  Config.version.major .. '.' ..
                Config.version.minor .. '.' ..
                Config.version.patch
    end
}

-- Time between respawn tries in seconds
Config.respawnTime = 1800   -- Default: 1800 (= 30 min)
-- Percentage of the original amount, of rich asteroids, to respawn. (0.01 = 1%)
Config.respawnAmount = 0.10     --Defaul: 0.10

return Config
