levels = {}
local StartNames = {}
local PowerNames = {}
local MainNames = {}
local EndNames = {}
local BonusNames = {}
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
}
local EndGrassNames = {
"end1",
"end2",
}
local BonusGrassNames = {
"bonus1",
"bonus2",
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
}
local EndCastleNames = {
"endCastle1",
"endCastle2",
}
local BonusCastleNames = {
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
}
local EndWaterNames = {
"endWater1",
"endWater2",
}
local BonusWaterNames = {
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
}
local EndUndergroundNames = {
"endGround1",
"endGround2",
}
local BonusUndergroundNames = {
"bonus1",
"bonus2",
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
}
local EndIslandNames = {
"endIsland1",
"endIsland2",
}
local BonusIslandNames = {
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
levels.AIS = {}
SaveData.levelCounter = SaveData.levelCounter or 1
SaveData.worldCounter = SaveData.worldCounter or 1
local bgoCounter = 1
local times = 0
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

function levels.generate()
	if Level.filename() == "levelGenRoom.lvlx" then
		
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
		if chosenBiome == "castle" then powerus = RNG.randomInt(1,2) end
		if chosenBiome == "underground" then powerus = RNG.randomInt(2,3) end
		if chosenBiome == "bridge" then powerus = RNG.randomInt(1,2) end
		if chosenBiome == "island" then powerus = RNG.randomInt(1,2) end
		if chosenBiome == "water" then powerus = RNG.randomInt(0,1); end
		if chosenBiome == "grass" then powerus = RNG.randomInt(1,3); end
		local powersPlaced = 0
		local length = 8
		if chosenBiome == "castle" then length = 5 end
		if chosenBiome == "island" then length = 5 end
		if chosenBiome == "underground" then length = 8 end
		if chosenBiome == "bridge" then length = 8 end
		if chosenBiome == "water" then length = 8 end
		if chosenBiome == "grass" then length = 8 end
		if powerus > 0 then
			local chose = RNG.randomInt(1,tablelength(possiblePowers))
			if tablelength(possiblePowers) > 0 then
						local levelScript = possiblePowers[chose]
						local sec = Section(0)
						sec.boundary = addObjects(levelScript,sec,0,0)
			end
			length = length-1
			powerus = powerus-1
		end
		for n=1,powerus+1 do
			if powerus > 0 then
				for a=1,math.floor(length/(powerus+1)) do
					local chose = RNG.randomInt(1,tablelength(possibleMain))
					if tablelength(possibleMain) > 0 then
						local levelScript = possibleMain[chose]
						local sec = Section(0)
						sec.boundary = addObjects(levelScript,sec,0,0)
					end
				end
				if powersPlaced < powerus then
					powersPlaced = powersPlaced+1
					local chose = RNG.randomInt(1,tablelength(possiblePowers))
					if tablelength(possiblePowers) > 0 then
						local levelScript = possiblePowers[chose]
						local sec = Section(0)
						sec.boundary = addObjects(levelScript,sec,0,0)
					end
				end
			else
				for a=1,length-1 do
					local chose = RNG.randomInt(1,tablelength(possibleMain))
					if tablelength(possibleMain) > 0 then
							local levelScript = possibleMain[chose]
							local sec = Section(0)
							sec.boundary = addObjects(levelScript,sec,0,0)
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
					if table.contains(Section.getFromCoords(blockChose.x, blockChose.y, 32, 32),Section(0)) then break end
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
			sec.backgroundID = levelScript.background
			sec.musicID = levelScript.music
			if levelScript.water ~= nil then
				sec.isUnderwater = levelScript.water
			end
			sec.boundary = addObjects(levelScript,sec,20000,20000)
			warp.exitX = levelScript.playerX+20000
			warp.exitY = levelScript.playerY-32+(20000)
			chose = 1
			if tablelength(Block.get(376)) > 0 then
				blockChose = Block.get(376)[chose]
				for p=1,50 do
					chose = chose+1
					if chose > tablelength(Block.get(376)) then chose = 1 end
					blockChose = Block.get(376)[chose]
					if table.contains(Section.getFromCoords(blockChose.x, blockChose.y, 32, 32),Section(1)) then break end
				end
				warp = Warp.get()[2]
				warp.entranceX = blockChose.x-32
				warp.entranceY = blockChose.y+32
				chose = startChose
				blockChose = Block.get(196)[chose]
				for p=1,50 do
					chose = chose+1
					if chose > tablelength(Block.get(196)) then chose = 1 end
					blockChose = Block.get(196)[chose]
					if table.contains(Section.getFromCoords(blockChose.x, blockChose.y, 32, 32),Section(0)) then break end
				end
				warp.exitX = blockChose.x+16
				warp.exitY = blockChose.y-32
			end
		end
		if tablelength(Block.get(196)) > 2 and tablelength(possibleBonus) > 0 then
			local chose = RNG.randomInt(1,tablelength(Block.get(196)))
			local blockChose = Block.get(196)[chose]
			local startChose = chose
			for p=1,50 do
					chose = RNG.randomInt(1,tablelength(Block.get(196)))
					blockChose = Block.get(196)[chose]
					if table.contains(Section.getFromCoords(blockChose.x, blockChose.y, 32, 32),Section(0)) then break end
			end
			local warp = Warp.get()[3]
			local sec = Section(2)
			local bounds = sec.boundary
			bounds.right = bounds.left
			sec.boundary = bounds
			warp.entranceX = blockChose.x+16
			warp.entranceY = blockChose.y-32
			chose = RNG.randomInt(1,tablelength(possibleBonus))
			local levelScript = possibleBonus[chose]
			sec.backgroundID = levelScript.background
			sec.musicID = levelScript.music
			sec.boundary = addObjects(levelScript,sec,40000,40000)
			warp.exitX = levelScript.playerX+40000
			warp.exitY = levelScript.playerY-32+(40000)
			chose = 1
			if tablelength(Block.get(376)) > 1 then
				blockChose = Block.get(376)[chose]
				for p=1,50 do
					chose = chose+1
					if chose > tablelength(Block.get(376)) then chose = 1 end
					blockChose = Block.get(376)[chose]
					if table.contains(Section.getFromCoords(blockChose.x, blockChose.y, 32, 32),Section(2)) then break end
				end
				warp = Warp.get()[4]
				warp.entranceX = blockChose.x-32+20000
				warp.entranceY = blockChose.y+32+20000
				chose = startChose
				blockChose = Block.get(196)[chose]
				for p=1,50 do
					chose = chose+1
					if chose > tablelength(Block.get(196)) then chose = 1 end
					blockChose = Block.get(196)[chose]
					if table.contains(Section.getFromCoords(blockChose.x, blockChose.y, 32, 32),Section(0)) then break end
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
		for i=1,RNG.randomInt(1,3) do
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
		Timer.activate(times)
	end
end

function levels.loadLevels()
	if SaveData.levelCounter == 1 or SaveData.levelCounter == 3 then chosenBiome = "grass" end
	if SaveData.levelCounter == 4 then chosenBiome = "castle" end
	if SaveData.levelCounter == 2 then 
		if SaveData.worldCounter/2 ~= math.floor(SaveData.worldCounter/2) then chosenBiome = "underground" else chosenBiome = "water" end
	end
	if SaveData.levelCounter == 3 then 
		if SaveData.worldCounter/2 ~= math.floor(SaveData.worldCounter/2) then chosenBiome = "island" else chosenBiome = "island" end
	end
	if chosenBiome == "grass" then StartNames = StartGrassNames end
	if chosenBiome == "grass" then MainNames = MainGrassNames end
	if chosenBiome == "grass" then PowerNames = PowerGrassNames end
	if chosenBiome == "grass" then EndNames = EndGrassNames end
	if chosenBiome == "grass" then BonusNames = BonusGrassNames end
	if chosenBiome == "castle" then StartNames = StartCastleNames end
	if chosenBiome == "castle" then MainNames = MainCastleNames end
	if chosenBiome == "castle" then PowerNames = PowerCastleNames end
	if chosenBiome == "castle" then EndNames = EndCastleNames end
	if chosenBiome == "castle" then BonusNames = BonusCastleNames end
	if chosenBiome == "water" then StartNames = StartWaterNames end
	if chosenBiome == "water" then MainNames = MainWaterNames end
	if chosenBiome == "water" then PowerNames = PowerWaterNames end
	if chosenBiome == "water" then EndNames = EndWaterNames end
	if chosenBiome == "water" then BonusNames = BonusWaterNames end

	if chosenBiome == "underground" then StartNames = StartUndergroundNames end
	if chosenBiome == "underground" then MainNames = MainUndergroundNames end
	if chosenBiome == "underground" then PowerNames = PowerUndergroundNames end
	if chosenBiome == "underground" then EndNames = EndUndergroundNames end
	if chosenBiome == "underground" then BonusNames = BonusUndergroundNames end

	if chosenBiome == "island" then StartNames = StartIslandNames end
	if chosenBiome == "island" then MainNames = MainIslandNames end
	if chosenBiome == "island" then PowerNames = PowerIslandNames end
	if chosenBiome == "island" then EndNames = EndIslandNames end
	if chosenBiome == "island" then BonusNames = BonusIslandNames end
	possibleStarts = {}
	if Level.filename() == "levelGenRoom.lvlx" then
		if tablelength(StartNames) > 0 then
			for i=1,tablelength(StartNames) do
				local dataFile = io.open(Misc.episodePath()..StartNames[i]..".txt", "r" )
				possibleStarts[i] = require(Misc.episodePath()..StartNames[i]..".txt")
			end
		end
	end
	possiblePowers = {}
	if Level.filename() == "levelGenRoom.lvlx" then
		if tablelength(PowerNames) > 0 then
			for i=1,tablelength(PowerNames) do
				local dataFile = io.open(Misc.episodePath()..PowerNames[i]..".txt", "r" )
				possiblePowers[i] = require(Misc.episodePath()..PowerNames[i]..".txt")
			end
		end
	end
	possibleMain = {}
	if Level.filename() == "levelGenRoom.lvlx" then
		if tablelength(MainNames) > 0 then
			for i=1,tablelength(MainNames) do
				local dataFile = io.open(Misc.episodePath()..MainNames[i]..".txt", "r" )
				possibleMain[i] = require(Misc.episodePath()..MainNames[i]..".txt")
			end
		end
	end
	possibleEnd = {}
	if Level.filename() == "levelGenRoom.lvlx" then
		if tablelength(EndNames) > 0 then
			for i=1,tablelength(EndNames) do
				local dataFile = io.open(Misc.episodePath()..EndNames[i]..".txt", "r" )
				possibleEnd[i] = require(Misc.episodePath()..EndNames[i]..".txt")
			end
		end
	end
	possibleBonus = {}
	if Level.filename() == "levelGenRoom.lvlx" then
		if tablelength(BonusNames) > 0 then
			for i=1,tablelength(BonusNames) do
				local dataFile = io.open(Misc.episodePath()..BonusNames[i]..".txt", "r" )
				possibleBonus[i] = require(Misc.episodePath()..BonusNames[i]..".txt")
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