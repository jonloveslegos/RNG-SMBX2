levels = {}
local StartNames = {}
local PowerNames = {}
local MainNames = {}
levelMaker = require("levelMaker")
local EndNames = {}
levels.grassLength = 8
levels.startingTime = 500
levels.maxLevelCountPerWorld = 4
levels.undergroundLength = 8
levels.waterLength = 8
levels.islandLength = 5
levels.castleLength = 5

levels.grassMaxPowers = 3
levels.undergroundMaxPowers = 3
levels.waterMaxPowers = 1
levels.islandMaxPowers = 2
levels.castleMaxPowers = 2

levels.grassMinPowers = 1
levels.undergroundMinPowers = 2
levels.waterMinPowers = 0
levels.islandMinPowers = 1
levels.castleMinPowers = 1
local BonusNames = {
"bonus1",
"bonus2",
"bonus3",
"bonus4",
"bonus5",
}

local StartGrassNames = {
"start1",
"start2",
}
local PowerGrassNames = {
"power1",
"power2",
"power3",
}
local MainGrassNames = {
"main1",
"main2",
"main3",
"main4",
"main5",
"main6",
"main7",
"main8",
"main9",
"main10",
}
local EndGrassNames = {
"end1",
"end2",
}

local StartCastleNames = {
"startCastle1",
"startCastle2",
}
local PowerCastleNames = {
"powerCastle1",
"powerCastle2",
"powerCastle3",
}
local MainCastleNames = {
"mainCastle1",
"mainCastle2",
"mainCastle3",
"mainCastle4",
"mainCastle5",
"mainCastle6",
"mainCastle7",
"mainCastle8",
"mainCastle9",
"mainCastle10",
}
local EndCastleNames = {
"endCastle1",
"endCastle2",
}

local StartWaterNames = {
"startWater1",
"startWater2",
}
local PowerWaterNames = {
"powerWater1",
"powerWater2",
"powerWater3",
}
local MainWaterNames = {
"mainWater1",
"mainWater2",
"mainWater3",
"mainWater4",
"mainWater5",
"mainWater6",
"mainWater7",
"mainWater8",
"mainWater9",
"mainWater10",
}
local EndWaterNames = {
"endWater1",
"endWater2",
}

local StartUndergroundNames = {
"startGround1",
"startGround2",
}
local PowerUndergroundNames = {
"powerGround1",
"powerGround2",
"powerGround3",
}
local MainUndergroundNames = {
"mainGround1",
"mainGround2",
"mainGround3",
"mainGround4",
"mainGround5",
"mainGround6",
"mainGround7",
"mainGround8",
"mainGround9",
"mainGround10",
}
local EndUndergroundNames = {
"endGround1",
"endGround2",
}

local StartIslandNames = {
"startIsland1",
"startIsland2",
}
local PowerIslandNames = {
"powerIsland1",
"powerIsland2",
"powerIsland3",
}
local MainIslandNames = {
"mainIsland1",
"mainIsland2",
"mainIsland3",
"mainIsland4",
"mainIsland5",
"mainIsland6",
"mainIsland7",
"mainIsland8",
"mainIsland9",
"mainIsland10",
}
local EndIslandNames = {
"endIsland1",
"endIsland2",
}

possibleStarts = {}
possiblePowers = {}
possibleMain = {}
possibleBonus = {}
possibleEnd = {}
chosenBiome = ""
possibleBiomes = {
"grass",
"castle",
"water",
"underground",
"island",
}
levels.createCode = {}
SaveData.lastCreated = SaveData.lastCreated or {}
levels.AIS = {}
SaveData.levelCounter = SaveData.levelCounter or 1
SaveData.worldCounter = SaveData.worldCounter or 1
local bgoCounter = 1
local times = 0
function levels.AddToLevels(type,biome,fileName)
	if biome == "grass" then
		if type == "start" then table.insert(StartGrassNames,fileName) end
		if type == "end" then table.insert(EndGrassNames,fileName) end
		if type == "filler" then table.insert(MainGrassNames,fileName) end
		if type == "powerup" then table.insert(PowerGrassNames,fileName) end
	end
	if biome == "water" then
		if type == "start" then table.insert(StartWaterNames,fileName) end
		if type == "end" then table.insert(EndWaterNames,fileName) end
		if type == "filler" then table.insert(MainWaterNames,fileName) end
		if type == "powerup" then table.insert(PowerWaterNames,fileName) end
	end
	if biome == "underground" then
		if type == "start" then table.insert(StartUndergroundNames,fileName) end
		if type == "end" then table.insert(EndUndergroundNames,fileName) end
		if type == "filler" then table.insert(MainUndergroundNames,fileName) end
		if type == "powerup" then table.insert(PowerUndergroundNames,fileName) end
	end
	if biome == "island" then
		if type == "start" then table.insert(StartIslandNames,fileName) end
		if type == "end" then table.insert(EndIslandNames,fileName) end
		if type == "filler" then table.insert(MainIslandNames,fileName) end
		if type == "powerup" then table.insert(PowerIslandNames,fileName) end
	end
	if biome == "castle" then
		if type == "start" then table.insert(StartCastleNames,fileName) end
		if type == "end" then table.insert(EndCastleNames,fileName) end
		if type == "filler" then table.insert(MainCastleNames,fileName) end
		if type == "powerup" then table.insert(PowerCastleNames,fileName) end
	end
	if biome == "bonus" then
		table.insert(BonusNames,fileName)
	end
end

function addObjects(levelScript,sectn,yoff,xoff)
	local bounds = sectn.boundary
	times = times+30
	local offSet = math.abs(sectn.boundary.left-sectn.boundary.right)+xoff
	bounds.right = bounds.right+levelScript.width
	for b=1,tablelength(levelScript.blocks) do
			local currBlock = levelScript.blocks[b]
			local spawned = Block.spawn(currBlock[1],currBlock[2]+offSet,currBlock[3]+yoff)
			spawned.width = currBlock[4]
			spawned.height = currBlock[5]
			spawned.contentID = currBlock[6]
			--spawned.isHidden = currBlock[8]
			spawned:mem(0x5A,FIELD_BOOL,currBlock[8])
			spawned.slippery = currBlock[9]
	end
	for b=1,tablelength(levelScript.npc) do
		local currBlock = levelScript.npc[b]
		if currBlock[1] ~= 30 and currBlock[1] ~= 87 then
			local spawned = NPC.spawn(currBlock[1],currBlock[2]+offSet,currBlock[3]+yoff,sectn.idx,true)
			if currBlock[9] ~= nil then
				spawned:mem(0xD8,FIELD_FLOAT,currBlock[9])
				spawned.direction = currBlock[9]
			end
			if currBlock[1] == 176 or currBlock[1] == 177 then
				spawned:mem(0xDE,FIELD_WORD,currBlock[4])
				spawned.ai1 = currBlock[4]
			end
		end
	end
	for b=1,tablelength(levelScript.bgo) do
			if bgoCounter > tablelength(BGO.get()) then
				bgoCounter = 1
			end
			local currBlock = levelScript.bgo[b]
			if currBlock[1] ~= 161 then
				local spawned = BGO.get()[bgoCounter]:transform(currBlock[1])
				BGO.get()[bgoCounter].x = currBlock[2]+offSet
				BGO.get()[bgoCounter].y = currBlock[3]+yoff
				bgoCounter = bgoCounter+1
			end
	end
	return bounds
end

function levels.tick()
end

function genRoom()
			for b=1,tablelength(Block.get()) do Block.get()[b]:delete() end
			for b=1,tablelength(NPC.get()) do NPC.get()[b]:delete() end
			local start = RNG.randomInt(1,tablelength(possibleStarts))
			if tablelength(possibleStarts) > 0 then
				local levelScript = possibleStarts[start]
				local sec = Section(0)
				local bounds = sec.boundary
				bounds.right = bounds.left
				sec.boundary = bounds
				sec.backgroundID = levelScript.background
				sec.musicID = levelScript.music
				if levelScript.water ~= nil then
					sec.isUnderwater = levelScript.water
				end
				player.x = levelScript.playerX
				player.y = levelScript.playerY-32
				if player2 ~= nil then
					player2.x = levelScript.playerX-32
					player2.y = levelScript.playerY-32
				end
				sec.boundary = addObjects(levelScript,sec,0,0)
			end
			local powerus = 0
			if chosenBiome == "castle" then powerus = RNG.randomInt(levels.castleMinPowers,levels.castleMinPowers) end
			if chosenBiome == "underground" then powerus = RNG.randomInt(levels.undergroundMinPowers,levels.undergroundMaxPowers) end
			if chosenBiome == "island" then powerus = RNG.randomInt(levels.islandMinPowers,levels.islandMaxPowers) end
			if chosenBiome == "water" then powerus = RNG.randomInt(levels.waterMinPowers,levels.waterMaxPowers); end
			if chosenBiome == "grass" then powerus = RNG.randomInt(levels.grassMinPowers,levels.grassMaxPowers); end
			local powersPlaced = 0
			local length = 8
			if chosenBiome == "castle" then length = levels.castleLength end
			if chosenBiome == "island" then length = levels.islandLength end
			if chosenBiome == "underground" then length = levels.undergroundLength end
			if chosenBiome == "water" then length = levels.waterLength end
			if chosenBiome == "grass" then length = levels.grassLength end
			if powerus > 0 then
				local chose = RNG.randomInt(1,tablelength(possiblePowers))
				if tablelength(possiblePowers) > 0 then
							local levelScript = possiblePowers[chose]
							local sec = Section(0)
							sec.boundary = addObjects(levelScript,sec,0,0)
							table.remove(possiblePowers,chose)
							if tablelength(possiblePowers) <= 0 then
								makePowerTable()
							end
				end
				powersPlaced = powersPlaced+1
				length = length-1
			end
			for n=1,powerus+1 do
				if powerus > 0 then
					for a=1,math.ceil(length/(powerus+1)) do
						local chose = RNG.randomInt(1,tablelength(possibleMain))
						if tablelength(possibleMain) > 0 then
							local levelScript = possibleMain[chose]
							local sec = Section(0)
							sec.boundary = addObjects(levelScript,sec,0,0)
							table.remove(possibleMain,chose)
							if tablelength(possibleMain) <= 0 then
								makeMainTable()
							end
						end
					end
					if powersPlaced < powerus then
						powersPlaced = powersPlaced+1
						local chose = RNG.randomInt(1,tablelength(possiblePowers))
						if tablelength(possiblePowers) > 0 then
							local levelScript = possiblePowers[chose]
							local sec = Section(0)
							sec.boundary = addObjects(levelScript,sec,0,0)
							table.remove(possiblePowers,chose)
							if tablelength(possiblePowers) <= 0 then
								makePowerTable()
							end
						end
					end
				else
					for a=1,length-1 do
						local chose = RNG.randomInt(1,tablelength(possibleMain))
						if tablelength(possibleMain) > 0 then
								local levelScript = possibleMain[chose]
								local sec = Section(0)
								sec.boundary = addObjects(levelScript,sec,0,0)
								table.remove(possibleMain,chose)
								if tablelength(possibleMain) <= 0 then
									makeMainTable()
								end
						end
					end
				end
			end
			if tablelength(Block.get(196)) > 0 and tablelength(possibleBonus) > 0 then
				local chose = RNG.randomInt(1,tablelength(Block.get(196)))
				local blockChose = Block.get(196)[chose]
				for p=1,50 do
						chose = RNG.randomInt(1,tablelength(Block.get(196)))
						blockChose = Block.get(196)[chose]
						if Section.getFromCoords(blockChose.x, blockChose.y, 32, 32)[1]==Section(0) then break end
				end
				local warp = Warp.get()[1]
				local startChose = chose
				local sec = Section(1)
				local bounds = sec.boundary
				bounds.right = bounds.left
				sec.boundary = bounds
				warp.entranceX = blockChose.x+16
				warp.entranceY = blockChose.y-32
				chose = RNG.randomInt(1,tablelength(possibleBonus))
				local levelScript = possibleBonus[chose]
				table.remove(possibleBonus,chose)
				if tablelength(possibleBonus) <= 0 then
					makeBonusTable()
				end
				sec.backgroundID = levelScript.background
				sec.musicID = levelScript.music
				if levelScript.water ~= nil then
					sec.isUnderwater = levelScript.water
				end
				sec.boundary = addObjects(levelScript,sec,20000,20000)
				local chose = RNG.randomInt(1,tablelength(Block.get(1076)))
				local blockChose = Block.get(1076)[chose]
				for p=1,50 do
						chose = chose+1
						if chose > tablelength(Block.get(1076)) then chose = 1 end
						blockChose = Block.get(1076)[chose]
						if Section.getFromCoords(blockChose.x, blockChose.y, 32, 32)[1]==Section(1) then break end
				end
				warp.exitX = blockChose.x+16--+20000
				warp.exitY = blockChose.y+32--+(20000)
				chose = 1
				if tablelength(Block.get(376)) > 0 then
					blockChose = Block.get(376)[chose]
					for p=1,50 do
						chose = chose+1
						if chose > tablelength(Block.get(376)) then chose = 1 end
						blockChose = Block.get(376)[chose]
						if Section.getFromCoords(blockChose.x, blockChose.y, 32, 32)[1]==Section(1) then break end
					end
					warp = Warp.get()[2]
					warp.entranceX = blockChose.x-32
					warp.entranceY = blockChose.y+32
					chose = RNG.randomInt(1,tablelength(Block.get(196)))
					blockChose = Block.get(196)[chose]
					for p=1,50 do
						chose = chose+1
						if chose > tablelength(Block.get(196)) then chose = 1 end
						blockChose = Block.get(196)[chose]
						if Section.getFromCoords(blockChose.x, blockChose.y, 32, 32)[1]==Section(0) then break end
					end
					warp.exitX = blockChose.x+16
					warp.exitY = blockChose.y-32
				end
			end
			if tablelength(Block.get(196)) > 1 and tablelength(possibleBonus) > 0 then
				local chose = RNG.randomInt(1,tablelength(Block.get(196)))
				local blockChose = Block.get(196)[chose]
				for p=1,50 do
						chose = RNG.randomInt(1,tablelength(Block.get(196)))
						blockChose = Block.get(196)[chose]
						if Section.getFromCoords(blockChose.x, blockChose.y, 32, 32)[1]==Section(0) then break end
				end
				local startChose = chose
				local warp = Warp.get()[3]
				local sec = Section(2)
				local bounds = sec.boundary
				bounds.right = bounds.left
				sec.boundary = bounds
				warp.entranceX = blockChose.x+16
				warp.entranceY = blockChose.y-32
				chose = RNG.randomInt(1,tablelength(possibleBonus))
				local levelScript = possibleBonus[chose]
				table.remove(possibleBonus,chose)
				if tablelength(possibleBonus) <= 0 then
					makeBonusTable()
				end
				sec.backgroundID = levelScript.background
				sec.musicID = levelScript.music
				sec.boundary = addObjects(levelScript,sec,40000,40000)
				local chose = RNG.randomInt(1,tablelength(Block.get(1076)))
				local blockChose = Block.get(1076)[chose]
				for p=1,50 do
						chose = chose+1
						if chose > tablelength(Block.get(1076)) then chose = 1 end
						blockChose = Block.get(1076)[chose]
						if Section.getFromCoords(blockChose.x, blockChose.y, 32, 32)[1]==Section(2) then break end
				end
				warp.exitX = blockChose.x+16--+20000
				warp.exitY = blockChose.y+32--+(20000)
				chose = 1
				if tablelength(Block.get(376)) > 1 then
					blockChose = Block.get(376)[chose]
					for p=1,50 do
						chose = chose+1
						if chose > tablelength(Block.get(376)) then chose = 1 end
						blockChose = Block.get(376)[chose]
						if Section.getFromCoords(blockChose.x, blockChose.y, 32, 32)[1]==Section(2) then break end
					end
					warp = Warp.get()[4]
					warp.entranceX = blockChose.x-32+20000
					warp.entranceY = blockChose.y+32+20000
					chose = RNG.randomInt(1,tablelength(Block.get(196)))
					blockChose = Block.get(196)[chose]
					for p=1,50 do
						chose = chose+1
						if chose > tablelength(Block.get(196)) then chose = 1 end
						blockChose = Block.get(196)[chose]
						if Section.getFromCoords(blockChose.x, blockChose.y, 32, 32)[1]==Section(0) then break end
					end
					warp.exitX = blockChose.x+16
					warp.exitY = blockChose.y-32
				end
			end
			local chose = RNG.randomInt(1,tablelength(possibleEnd))
			if tablelength(possibleEnd) > 0 then
				local levelScript = possibleEnd[chose]
				local sec = Section(0)
				sec.boundary = addObjects(levelScript,sec,0,0)
			end
			for i=1,RNG.randomInt(0,1) do
				local blocks = Block.get(188)
				local complete = false
				local blcks = {}
				for i=1,tablelength(blocks) do
					if tablelength(Block.getIntersecting(blocks[i].x,blocks[i].y+96+32,blocks[i].x+blocks[i].width,blocks[i].y+96+32+32)) >= 1 and blocks[i].contentID <= 0 and tablelength(Block.getIntersecting(blocks[i].x,blocks[i].y+33,blocks[i].x+blocks[i].width,blocks[i].y+96)) < 1 then
						table.insert(blcks,blocks[i])
					end
				end
				blocks = Block.get(60)
				for i=1,tablelength(blocks) do
						if tablelength(Block.getIntersecting(blocks[i].x,blocks[i].y+96+32,blocks[i].x+blocks[i].width,blocks[i].y+96+32+32)) >= 1 and blocks[i].contentID <= 0 and tablelength(Block.getIntersecting(blocks[i].x,blocks[i].y+33,blocks[i].x+blocks[i].width,blocks[i].y+96)) < 1 then
							table.insert(blcks,blocks[i])
						end
				end
				if tablelength(blcks) > 0 then
					local chose = RNG.randomInt(1,tablelength(blcks))
					blcks[chose].contentID = 1293
				end
			end
			for i=1,RNG.randomInt(1,2) do
				local blocks = Block.get(188)
				local complete = false
				local blcks = {}
				for i=1,tablelength(blocks) do
					if tablelength(Block.getIntersecting(blocks[i].x,blocks[i].y+96+32,blocks[i].x+blocks[i].width,blocks[i].y+96+32+32)) >= 1 and blocks[i].contentID <= 0 and tablelength(Block.getIntersecting(blocks[i].x,blocks[i].y+33,blocks[i].x+blocks[i].width,blocks[i].y+96)) < 1 then
						table.insert(blcks,blocks[i])
					end
				end
				blocks = Block.get(60)
				for i=1,tablelength(blocks) do
						if tablelength(Block.getIntersecting(blocks[i].x,blocks[i].y+96+32,blocks[i].x+blocks[i].width,blocks[i].y+96+32+32)) >= 1 and blocks[i].contentID <= 0 and tablelength(Block.getIntersecting(blocks[i].x,blocks[i].y+33,blocks[i].x+blocks[i].width,blocks[i].y+96)) < 1 then
							table.insert(blcks,blocks[i])
						end
				end
				if tablelength(blcks) > 0 then
					local chose = RNG.randomInt(1,tablelength(blcks))
					blcks[chose].contentID = 1186
				end
			end
			Timer.activate(levels.startingTime)
			levelMaker.onTickMake(true)
end

function levels.generate()
	if Level.filename() == "levelGenRoom.lvlx" then
		if file_exists(Misc.episodePath().."LastLevelSave"..Misc.saveSlot()..".txt") == true then
			local dataFile = io.open(Misc.episodePath().."LastLevelSave"..Misc.saveSlot()..".txt", "r" )
			if dataFile:read() ~= "null" then
				local levelScript = require(Misc.episodePath().."LastLevelSave"..Misc.saveSlot()..".txt")
				local sec = Section(0)
				local bounds = sec.boundary
				bounds.right = bounds.left
				sec.boundary = bounds
				sec.backgroundID = levelScript.background
				sec.musicID = levelScript.music
				if levelScript.water ~= nil then
						sec.isUnderwater = levelScript.water
				end
				player.x = levelScript.playerX
				player.y = levelScript.playerY-32
				if player2 ~= nil then
						player2.x = levelScript.playerX-32
						player2.y = levelScript.playerY-32
				end
				sec2 = Section(1)
				sec2.boundary.right = sec2.boundary.left+levelScript.sec1width
				sec2.backgroundID = levelScript.sec1back
				sec2.musicID = levelScript.sec1mus
				sec3 = Section(2)
				sec3.boundary.right = sec3.boundary.left+levelScript.sec2width
				sec3.backgroundID = levelScript.sec2back
				sec3.musicID = levelScript.sec2mus
				sec.boundary = addObjects(levelScript,sec,0,0)
				for i=1,tablelength(levelScript.warp) do
					Warp.get()[i].entranceX = levelScript.warp[i][2]
					Warp.get()[i].entranceY = levelScript.warp[i][3]
					Warp.get()[i].exitX = levelScript.warp[i][4]
					Warp.get()[i].exitY = levelScript.warp[i][5]
				end
				Timer.activate(levels.startingTime)
			else
				genRoom()
			end
		else
			genRoom()
		end
	end
end

function levels.loadLevels()
	local lvlCounter = SaveData.levelCounter
	for i=1,100 do
		if lvlCounter > 4 then lvlCounter = lvlCounter-4 end
		if lvlCounter <= 4 then break end
	end
	if lvlCounter == 1 then chosenBiome = "grass" end
	if lvlCounter == 2 then 
		if SaveData.worldCounter/2 ~= math.floor(SaveData.worldCounter/2) then chosenBiome = "underground" else chosenBiome = "water" end
	end
	if lvlCounter == 3 then chosenBiome = "island" end
	if lvlCounter == 4 or SaveData.levelCounter >= levels.maxLevelCountPerWorld then chosenBiome = "castle" end
	if chosenBiome == "grass" then StartNames = StartGrassNames end
	if chosenBiome == "grass" then MainNames = MainGrassNames end
	if chosenBiome == "grass" then PowerNames = PowerGrassNames end
	if chosenBiome == "grass" then EndNames = EndGrassNames end

	if chosenBiome == "castle" then StartNames = StartCastleNames end
	if chosenBiome == "castle" then MainNames = MainCastleNames end
	if chosenBiome == "castle" then PowerNames = PowerCastleNames end
	if chosenBiome == "castle" then EndNames = EndCastleNames end

	if chosenBiome == "water" then StartNames = StartWaterNames end
	if chosenBiome == "water" then MainNames = MainWaterNames end
	if chosenBiome == "water" then PowerNames = PowerWaterNames end
	if chosenBiome == "water" then EndNames = EndWaterNames end

	if chosenBiome == "underground" then StartNames = StartUndergroundNames end
	if chosenBiome == "underground" then MainNames = MainUndergroundNames end
	if chosenBiome == "underground" then PowerNames = PowerUndergroundNames end
	if chosenBiome == "underground" then EndNames = EndUndergroundNames end

	if chosenBiome == "island" then StartNames = StartIslandNames end
	if chosenBiome == "island" then MainNames = MainIslandNames end
	if chosenBiome == "island" then PowerNames = PowerIslandNames end
	if chosenBiome == "island" then EndNames = EndIslandNames end
	makeStartTable()
	makePowerTable()
	makeMainTable()
	makeEndTable()
	makeBonusTable()
end

function makeStartTable()
	possibleStarts = {}
	if Level.filename() == "levelGenRoom.lvlx" then
		if tablelength(StartNames) > 0 then
			for i=1,tablelength(StartNames) do
				local dataFile = io.open(Misc.episodePath()..StartNames[i]..".txt", "r" )
				possibleStarts[i] = require(Misc.episodePath()..StartNames[i]..".txt")
				dataFile:close()
			end
		end
	end
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function makePowerTable()
	possiblePowers = {}
	if Level.filename() == "levelGenRoom.lvlx" then
		if tablelength(PowerNames) > 0 then
			for i=1,tablelength(PowerNames) do
				local dataFile = io.open(Misc.episodePath()..PowerNames[i]..".txt", "r" )
				possiblePowers[i] = require(Misc.episodePath()..PowerNames[i]..".txt")
				dataFile:close()
			end
		end
	end
end

function makeEndTable()
	possibleEnd = {}
	if Level.filename() == "levelGenRoom.lvlx" then
		if tablelength(EndNames) > 0 then
			for i=1,tablelength(EndNames) do
				local dataFile = io.open(Misc.episodePath()..EndNames[i]..".txt", "r" )
				possibleEnd[i] = require(Misc.episodePath()..EndNames[i]..".txt")
				dataFile:close()
			end
		end
	end
end

function makeBonusTable()
	possibleBonus = {}
	if Level.filename() == "levelGenRoom.lvlx" then
		if tablelength(BonusNames) > 0 then
			for i=1,tablelength(BonusNames) do
				local dataFile = io.open(Misc.episodePath()..BonusNames[i]..".txt", "r" )
				possibleBonus[i] = require(Misc.episodePath()..BonusNames[i]..".txt")
				dataFile:close()
			end
		end
	end
end

function makeMainTable()
	possibleMain = {}
	if Level.filename() == "levelGenRoom.lvlx" then
		if tablelength(MainNames) > 0 then
			for i=1,tablelength(MainNames) do
				local dataFile = io.open(Misc.episodePath()..MainNames[i]..".txt", "r" )
				possibleMain[i] = require(Misc.episodePath()..MainNames[i]..".txt")
				dataFile:close()
			end
		end
	end
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

return levels