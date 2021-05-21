--------------------------------------------------
-- Episode code for every level
-- Created 15:48 2021-5-20
--------------------------------------------------
local hudoverride = require("hudoverride")
levelMaker = require("levelMaker")
levels = require("levels")
generateLevel = false
-- Run code on the first frame
function onStart()
    levelMaker:onStartMake()
    levels:loadLevels()
    levels:generate()
end

-- Run code every frame (~1/65 second)
-- (code will be executed before game logic will be processed)
function onTick()
    if player.mount == MOUNT_NONE then
        player:mem(0x120,FIELD_BOOL,false)
    end
    player.reservePowerup = 0
    if player2 ~= nil then
        if player2.mount == MOUNT_NONE then
            player2:mem(0x120,FIELD_BOOL,false)
        end
        player2.reservePowerup = 0
    end
    hudoverride.visible.itembox = false
    if generateLevel == true then
        levelMaker:onTickMake(levelType)
        generateLevel = false
    end
    for i=1,tablelength(NPC.get(177)) do
        NPC.get(177)[i].ai1 = 3
    end
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
-- Run code when internal event of the SMBX Engine has been triggered
-- eventName - name of triggered event
function onEvent(eventName)
    --Your code here
end


