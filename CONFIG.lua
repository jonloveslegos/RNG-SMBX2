config = {}
levels = require("levels")

--[[
To change the length of levels, you change these numbers to how many powerups/fille sections there will be.
The length is how many powerups and filler sections combined there will be, not including the start and end sections.
]]

config.grassLength = 8
config.undergroundLength = 8
config.waterLength = 8
config.islandLength = 5
config.castleLength = 5

config.grassMaxPowers = 3
config.undergroundMaxPowers = 3
config.waterMaxPowers = 1
config.islandMaxPowers = 2
config.castleMaxPowers = 2

config.grassMinPowers = 1
config.undergroundMinPowers = 2
config.waterMinPowers = 0
config.islandMinPowers = 1
config.castleMinPowers = 1

--[[
These variables change mechanics about the game itself.
]]

config.canGrab = false
config.powersFromBlocksAlwaysMoveRight = true
config.disableItemBox = true
config.disableSpinJump = true
config.maxWorldCount = 8
config.maxLevelCountPerWorld = 4
config.startingTime = 500

--[[
To add to the list of screens, Put 'addToLvls("biome name","level type","filename of txt")' in the function called addLevels.

The possible biomes are grass, underground, water, island, castle, bonus.
The possible level types are start, filler, end, powerup.

If the biome is 'bonus' then it will only appear in enterable pipes as 1 screen, and you put a blank for level type,
make sure to pue a down-facing pipe and a left-facing pipe in the bonus screen otherwise it will not work.
]]
--Ex. addToLvls("grass","filler","main1")

function config.addLevels()
	return
end


--The function above is where you put the information


function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function addToLvls(biome,type,fileName)
	levels.AddToLevels(type,biome,fileName)
end

return config