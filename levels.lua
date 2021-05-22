levels = {}
possibleStarts = {}
local StartNames = {
"start1",
}
possiblePowers = {}
local PowerNames = {
"power1",
"power2",
"power3",
}
possibleMain = {}
local MainNames = {
"main1",
"main2",
"main3",
"main4",
}
possibleEnd = {}
local EndNames = {
"end1",
}
possibleBonus = {}
local BonusNames = {
"bonus1",
"bonus2",
}
local bgoCounter = 1
function addObjects(levelScript,sectn,yoff,xoff)
	local bounds = sectn.boundary
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
			spawned.direction = -1
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
			player.x = levelScript.playerX
			player.y = levelScript.playerY-(32)
			if player2 ~= nil then
				player.x = levelScript.playerX-32
				player.y = levelScript.playerY-(32)
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
			for a=1,RNG.randomInt(1,2) do
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
			sec.boundary = addObjects(levelScript,sec,20000,20000)
			warp.exitX = levelScript.playerX+20000
			warp.exitY = levelScript.playerY-32+(20000)
			chose = RNG.randomInt(1,tablelength(Block.get(376)))
			if tablelength(Block.get(376)) > 0 then
				blockChose = Block.get(376)[chose]
				for p=1,50 do
					chose = RNG.randomInt(1,tablelength(Block.get(376)))
					blockChose = Block.get(376)[chose]
					if table.contains(Section.getFromCoords(blockChose.x, blockChose.y, 32, 32),Section(1)) then break end
				end
				warp = Warp.get()[2]
				warp.entranceX = blockChose.x-32
				warp.entranceY = blockChose.y+32
				chose = RNG.randomInt(1,tablelength(Block.get(196)))
				blockChose = Block.get(196)[chose]
				for p=1,50 do
					chose = RNG.randomInt(1,tablelength(Block.get(196)))
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
	end
end

function levels.loadLevels()
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