# simpleAsteroidReplenisher
A simple Asteroid respawner script. It's an extension of the *vanilla* script to let it respawn asteroids not only when you enter  a Sector, but continously. This should be handy for your mining fleets ^^.

It requires at least one asteroid (with or without resources) to (still) be in the sector.

By default additionally 5 resource asteroids are required (this can be changed in the config).

This won't spawn more asteroids than the sector initially had.

The delay between respawns and the amount that get respawned can be configured. The amount is always a % of the initial # asteroids the sector had.

## Installation

Copy the content into their respective folders. This will overwrite _/data/scripts/sector/respawnresourceasteroids.lua_.
