levels = {}
local StartNames = {}
local PowerNames = {}
local MainNames = {}
local EndNames = {}
local BonusNames = {}
local StartGrassNames = {
"start1",
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
}
local BonusCastleNames = {
}

local StartWaterNames = {
"startWater1",
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
}
local BonusWaterNames = {
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
}
levels.AIS = {}
SaveData.levelCounter = SaveData.levelCounter or 1
SaveData.worldCounter = SaveData.worldCounter or 1
local bgoCounter = 1
local times = 0
function addObjects(levelScript,sectn,yoff,xoff)
	local bounds = sectn.boundary
	times = times+20
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
			local spawned = NPC.spawn(currBlock[1],currBlock[2]+offSet,currBlock[3]+yoff,sectn.idx,true)
			if currBlock[9] ~= nil then
				spawned:mem(0xD8,FIELD_FLOAT,currBlock[9])
				spawned.direction = currBlock[9]
			end
			if currBlock[1] == 176 or currBlock[1] == 177 then
				spawned:mem(0xDE,FIELD_WORD,currBlock[4])
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
		for n=1,RNG.randomInt(3,4) do
			for a=1,1 do
				local chose = RNG.randomInt(1,tablelength(possiblePowers))
				if tablelength(possiblePowers) > 0 then
					local levelScript = possiblePowers[chose]
					local sec = Section(0)
					sec.boundary = addObjects(levelScript,sec,0,0)
				end
			end
			for a=1,RNG.randomInt(2,3) do
				local chose = RNG.randomInt(1,tablelength(possibleMain))
				if tablelength(possibleMain) > 0 then
					local levelScript = possibleMain[chose]
					local sec = Section(0)
					sec.boundary = addObjects(levelScript,sec,0,0)
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
		Timer.activate(times)
	end
end

function levels.loadLevels()
	if SaveData.levelCounter == 1 or SaveData.levelCounter == 3 then chosenBiome = "grass" end
	if SaveData.levelCounter == 4 then chosenBiome = "castle" end
	if SaveData.levelCounter == 2 then chosenBiome = "water" end
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