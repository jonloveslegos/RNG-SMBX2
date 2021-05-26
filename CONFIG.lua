config = {}
levels = require("levels")


--[[
To add to the list of screens, Put 'addToLvls("biome name","level type","filename of txt")' in the function called addLevels.

The possible biomes are grass, underground, water, island, castle, bonus.
The possible level types are start, filler, end, powerup.

If the biome is 'bonus' then it will only appear in enterable pipes as 1 screen, and you put a blank for level type,
make sure to pue a down-facing pipe and a left-facing pipe in the bonus screen otherwise it will not work.
]]
--Ex. addToLvls("grass","filler","main1")

function config.addLevels()
	
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