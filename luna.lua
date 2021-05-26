--------------------------------------------------
-- Episode code for every level
-- Created 15:48 2021-5-20
--------------------------------------------------
local hudoverride = require("hudoverride")
levelMaker = require("levelMaker")
levels = require("levels")
config = require("CONFIG")
generateLevel = false
local musFake = false
local setup = false
local musReal = false
local playing = -1
local musSect = 0
SaveData.lastCreated = SaveData.lastCreated or {}
local antiZip = require("antizip")
local antiZipP2 = require("antizipP2")
local handycam = require("handycam")
local npcManager = require("npcManager")
endTimer = -100
SaveData.totalWins = SaveData.totalWins or 0
GameData.playerWon = false
Debug = false
local music = nil
GameData.wonPlayer = -1
local wonPlayer = player
-- Run code on the first frame
function onStart()
    Defines.player_grabSideEnabled = false
    Defines.player_grabTopEnabled = false
    Defines.player_grabShellEnabled = false
end
function onInputUpdate()
    if endTimer > -100 then
        player.keys.right = false
        player.keys.left = false
        player.keys.down = false
        player.keys.up = false
        player.keys.jump = false
        player.keys.run = false
        player.keys.altJump = false
        player.keys.altRun = false
        player.speedX = 0
        if player2 ~= nil then
            player2.keys.right = false
            player2.keys.left = false
            player2.keys.down = false
            player2.keys.up = false
            player2.keys.jump = false
            player2.keys.run = false
            player2.keys.altJump = false
            player2.keys.altRun = false
            player2.speedX = 0
        end
    end
end

function onDraw()
    if Debug == true then
        local imge = Graphics.loadImage("background-752.png")
        for i=1,tablelength(Warp.get()) do
            Graphics.drawBox{x=Warp.get()[i].entranceX,y=Warp.get()[i].entranceY,w=32,h=16,sceneCoords=true,color=Color.green}
            Graphics.drawBox{x=Warp.get()[i].exitX,y=Warp.get()[i].exitY+16,w=32,h=16,sceneCoords=true,color=Color.red}
        end
        local blocks = Block.get(188)
        for i=1,tablelength(blocks) do
            if blocks[i].contentID == 1186 then
                Graphics.drawBox{x=blocks[i].x+8,y=blocks[i].y+8,w=16,h=16,sceneCoords=true,color=Color.green}
            end
            if blocks[i].contentID == 1293 then
                Graphics.drawBox{x=blocks[i].x+8,y=blocks[i].y+8,w=16,h=16,sceneCoords=true,color=Color.yellow}
            end
        end
        local blocks = Block.get(60)
        for i=1,tablelength(blocks) do
            if blocks[i].contentID == 1186 then
                Graphics.drawBox{x=blocks[i].x+8,y=blocks[i].y+8,w=16,h=16,sceneCoords=true,color=Color.green}
            end
            if blocks[i].contentID == 1293 then
                Graphics.drawBox{x=blocks[i].x+8,y=blocks[i].y+8,w=16,h=16,sceneCoords=true,color=Color.yellow}
            end
        end
    end
end

function onHUDDraw(camIdx)
    local offset = 0
    if Camera.get()[camIdx].width < 800 then offset = (Camera.get()[camIdx].width/2)-40 end
    if Camera.get()[camIdx].height < 600 then offset = -40 end
    if player2 == nil then offset = -40 end
    Text.print(SaveData.worldCounter.."-"..SaveData.levelCounter,195-offset,45)
end
function onPlayerHarm(eventToken,harmedPlayer)
    if GameData.playerWon == true then
        eventToken.cancelled = true
    end
end
function onPlayerKill(eventToken,harmedPlayer)
    if GameData.playerWon == true then
        eventToken.cancelled = true
    end
end
-- Run code every frame (~1/65 second)
-- (code will be executed before game logic will be processed)
function onTick()
    if setup == false then
        config:addLevels()
        levelMaker:onStartMake()
        levels:loadLevels()
        levels:generate()
        setup = true
    end
    levels:tick()
    for i=1,tablelength(NPC.get(178)) do
        if player ~= nil then
            if player.x > NPC.get(178)[i].x then player.x = NPC.get(178)[i].x end
        end
        if player2 ~= nil then
            if player2.x > NPC.get(178)[i].x then player2.x = NPC.get(178)[i].x end
        end
    end
    Progress.value = SaveData.totalWins
    for i=1,tablelength(NPC.get()) do
        if NPC.get()[i]:mem(0x138,FIELD_WORD) == 1 then
            NPC.get()[i].direction = 1
        end
    end
    if GameData.wonPlayer ~= -1 then 
        wonPlayer = Player(GameData.wonPlayer)
        GameData.wonPlayer = -1
    end
    if GameData.playerWon == true then
        for n=1,Player.count() do
				local v = Player(n)
				if Player(n) ~= wonPlayer then
					v.x = v.x - v.speedX
					v.speedX = 0
					v.y = v.y - v.speedY
					v.speedY = 0
				end
		end
    end
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
        levelMaker.onTickMake(false)
        generateLevel = false
    end
    endTimer = endTimer-1
    if endTimer <= 0 and endTimer > -100 then 
        if SaveData.worldCounter >= 8 then
            SaveData.worldCounter = 1
            SaveData.levelCounter = 1
            SaveData.totalWins=SaveData.totalWins+1
            local dataFile = io.open(Misc.episodePath().."LastLevelSave"..Misc.saveSlot()..".txt", "w+" )
            dataFile:write("null")
            dataFile:close()
            Level.finish(5,true)
        else
            Level.finish(2,false)
        end
        endTimer = -100
    end
    if musFake == true and playing ~= -1 then
        if playing:isplaying() == false then
            playing = -1
            Audio.MusicChange(musSect, "fakeLoop.mp3")
        end
    end
    if musReal == true and playing ~= -1 then
        if playing:isplaying() == false then
            playing = -1
            Audio.MusicChange(musSect, "realLoop.mp3")
        end
    end
    local npcs = NPC.getIntersecting(camera.x, camera.y, camera.x+camera.width, camera.y+camera.height)
    for i=1,tablelength(npcs) do
        if npcs[i].id == 200 then
            if npcs[i].x < player.x+camera.width then
                if SaveData.worldCounter >= 8 and musReal == false then
                    Audio.MusicChange(player.section, 0)
                    playing = SFX.play("RealStart.mp3",0.4)
                    musSect = player.section
                    musReal = true
                elseif SaveData.worldCounter < 8 and musFake == false then
                    Audio.MusicChange(player.section, 0)
                    playing = SFX.play("FakeStart.mp3",0.4)
                    musSect = player.section
                    musFake = true
                end
                break
            elseif camera2 ~= nil and player2 ~= nil then
                if npcs[i].x < player2.x+camera2.width then
                    if SaveData.worldCounter >= 8 and musReal == false then
                        Audio.MusicChange(player2.section, 0)
                        playing = SFX.play("RealStart.mp3",0.4)
                        musSect = player2.section
                        musReal = true
                    elseif SaveData.worldCounter < 8 and musFake == false then
                        Audio.MusicChange(player2.section, 0)
                        playing = SFX.play("FakeStart.mp3",0.4)
                        musSect = player2.section
                        musFake = true
                    end
                    break
                end
            end
        end
    end
    if tablelength(NPC.get(200)) > 0 and SaveData.worldCounter < 6 then
        for i=1,tablelength(NPC.get(200)) do
            NPC.get(200)[i].ai4 = 100000
        end
    end
    if tablelength(NPC.get(200)) > 0 and SaveData.worldCounter >= 6 and SaveData.worldCounter < 8 then
        for i=1,tablelength(NPC.get(200)) do
            NPC.get(200)[i].ai1 = 0
            NPC.get(200)[i].ai3 = 60
        end
    end
    if tablelength(Animation.get(105)) > 0 then
        for i=1,tablelength(Animation.get(105)) do
            local anim = Animation.get(105)[i]
            if SaveData.worldCounter < 8 then
                anim.id = 53
                anim.width = 32
                anim.height = 32
                anim.speedY = -10
            end
        end
    end
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function onExitLevel(win)
    if win > 0 then 
        SaveData.levelCounter = SaveData.levelCounter+1
        GameData.playerWon = true
        if SaveData.levelCounter > 4 then 
            SaveData.levelCounter = 1 
            SaveData.worldCounter = SaveData.worldCounter+1 
        end
        SaveData.totalWins=SaveData.totalWins+1
        local dataFile = io.open(Misc.episodePath().."LastLevelSave"..Misc.saveSlot()..".txt", "w+" )
        dataFile:write("null")
        dataFile:close()
    end
end
function onNPCKill(eventToken,killedNPC,harmType)
    if killedNPC.id == 178 and harmType == HARM_TYPE_VANISH and tablelength(Player.getIntersecting(killedNPC.x,killedNPC.y,killedNPC.x+killedNPC.width,killedNPC.y+killedNPC.height)) > 0 then
        Audio.MusicStop();
		Audio.SeizeStream(-1);
        GameData.playerWon = true
        wonPlayer = Player.getIntersecting(killedNPC.x,killedNPC.y,killedNPC.x+killedNPC.width,killedNPC.y+killedNPC.height)[1]
        if SaveData.worldCounter < 8 then
            SFX.play("110 World Clear.mp3")
            if music ~= nil then music:stop() end
            endTimer = 590
            for i=1,tablelength(Block.get(401)) do
                Block.get(401)[i]:remove(true)
            end
        else
            endTimer = 0
            for i=1,tablelength(Block.get(401)) do
                Block.get(401)[i]:remove(true)
            end
        end
    end
end
-- Run code when internal event of the SMBX Engine has been triggered
-- eventName - name of triggered event
function onEvent(eventName)
    --Your code here
end


