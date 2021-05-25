local npcManager = require("npcManager")
local megaMush = require("npcs/ai/megashroom")
local starman = require("npcs/ai/starman")

local flagpoleNPC = {}
flagpoleNPC.touched = false
flagpoleNPC.playerAlpha = {}
flagpoleNPC.exitType = 8
flagpoleNPC.stopPlayer = true

flagpoleNPC.castleBGOs = {}
for i = 1, 16000 do
	flagpoleNPC.castleBGOs[i] = false
end
flagpoleNPC.castleBGOs[16] = true
flagpoleNPC.castleBGOs[17] = true

local npcID = NPC_ID

local flagpoleNPCSettings = {
	id = npcID,
	frames = 3,
	framestyle = 0,
	framespeed = 8,
	nogravity = true,
	noblockcollision = true,
	nohurt = true,
	jumphurt = true,
	notcointransformable = true
}

npcManager.setNpcSettings(flagpoleNPCSettings)

function flagpoleNPC.onInitAPI()
	npcManager.registerEvent(npcID, flagpoleNPC, "onTickEndNPC")
	--npcManager.registerEvent(npcID, flagpoleNPC, "onDrawNPC")
end

local function stop_player(v)
	local data = v.data

	if data.collider == nil or flagpoleNPC.touched == true then return end
	
	local c = data.collider
	
	for i,p in ipairs(Player.get()) do
		if (p.x + (p.width / 1.5)) > c.x then
			p.x = p.x-p.speedX
			p.speedX = 0
		end
	end
end

local function stick(p_id, v)
	local p = Player(p_id)
	
	p.x = v.x + ((p.width / 2.0) * -1)
	
	if p.mount == 0 and p.character < 3 then 
		p.frame = 30
	end
	
	p.speedX = v.speedX
	p.direction = 1
	
	local tempLocationY = p.y + (p.height / 2)
	
	for k,b in ipairs(Block.getIntersecting(p.x, tempLocationY,
	p.x + p.width, tempLocationY + p.height)) do
		if p.character >= 3 or p.powerup ~= 1 or p.mount ~= 0 then break end
		p.y = b.y - (p.height * 1.5)
	end
	
	if #Block.getIntersecting(p.x, tempLocationY,
	p.x + p.width, tempLocationY + p.height) <= 0 then
		if p.mount == 0 and p.character < 3 then
			p.speedY = v.speedY
		end
	end
end

local function score(p_id, v)
	local p = Player(p_id)
	local c = v.data.collider
	local distance = math.abs(p.y - (c.y + c.height))
	local ponts = math.floor(distance / 32)
	if ponts <= 1 then ponts = 2
	elseif ponts > 1 and ponts <= 4 then ponts = 4
	elseif ponts > 4 and ponts <= 6 then ponts = 6
	elseif ponts > 6 then ponts = 8 end
	Misc.givePoints(ponts, vector(p.x, p.y), false)
end

local function enter_castle(p_id)
	local v = Player(p_id)
	
	if v.mount == 1 or v.mount == 2 then return end
	
	if v.alpha == nil then v.alpha = 2 end
	
	if vframe == nil then
		if v.mount == 0 and v.character ~= 5 and v.character ~= 16 then vframe = 15 else vframe = 30 end
	end
	
	if v.alpha <= 0 then
		v.forcedState = 8
	end
	
	v.frame = -50 * v.direction
	v.alpha = v.alpha - 0.05
	
	v:render{
	ignoreState = true,
	color = Color.white..v.alpha,
	frame = vframe
	}
	
	v:mem(0x142,FIELD_BOOL, true)
end

local function player_collided(v)
	local data = v.data

	if data.collider == nil or flagpoleNPC.touched == true then return end
	
	local c = data.collider
	
	for i,p in ipairs(Player.get()) do
		local vx = 0
		
		local px = p.x + (p.width)
		local py = p.y + (p.height)
		
		if p.mount == 2 then
			vx = (NPC.config[56].width / 2) or 64
		end
		
		if (px >= c.x and py >= c.y and
			p.x <= c.x + c.width and p.y <= c.y + c.height) then
			if data.player == nil then 
				if p.isMega then
					megaMush.StopMega(p, true)
				end
				
				starman.stop(p)
				
				Audio.MusicStop();
				Audio.SeizeStream(-1);
				Misc.npcToCoins()
				score(p.idx, v)
				SFX.play("smb-exit.ogg")
				flagpoleNPC.touched = true
				p.keys.altJump = true
				data.player = p 
			end
		end
	end
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function onInputUpdate()
	for e=1,tablelength(flagpoleNPC) do
		local v = flagpoleNPC[e]
		local data = v.data
		if data.timer ~= nil then
			if data.timer >= 25 then
					for i = 1, Player.count() do 
						local v = Player(i)
						v.keys.right = true
						v.keys.left = false
						v.keys.down = false
						v.keys.up = false
						v.keys.jump = false
						v.keys.run = false
						v.keys.altJump = false
						v.keys.altRun = false
					end
			end
		end
	end
end

function flagpoleNPC.onTickEndNPC(v)
	
	local data = v.data
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		return
	end
	data.animating = data.animating or false
	if not data.initialized then
		data.player = nil
		data.collided = false
		data.col_y = v.y - (v.height / 2.0)
		data.col_h = data.col_y + v.height
		data.collider = Colliders.Box(v.x, v.y - (v.height * 4), v.width, v.height)
		data.timer = 0
		data.initialized = true
	end
	
	if data.collider ~= nil and data.timer <= 26 then
		local c = data.collider
		c.x = v.x - (v.width / 2)
		c.y = v.y - (v.height / 1.25)
		c.height = c.height + 32
		
		for k,b in ipairs(Block.getIntersecting(c.x,c.y,
		c.x+c.width,c.y+c.height)) do
			if c.y + c.height > b.y then
				c.height = c.height - 32
			end
		end
	end
	
	player_collided(v)
	
	if flagpoleNPC.stopPlayer then
		stop_player(v)
	end
	
	if data.player ~= nil and data.collided == false then
		data.col_y = v.y + (v.height / 3)
		data.col_h = data.col_y + v.height
		
		stick(data.player.idx, v)
		
		v.speedY = 4
		
		for k,b in ipairs(Block.getIntersecting(v.x, data.col_y, v.x + v.width, data.col_h)) do
			if Block.config[b.id].passthrough == false then
				data.collided = true
			end
		end
		
		Level.winState(2)
		mem(0xB2C5A0, FIELD_WORD, 0)
	elseif data.player ~= nil and data.collided == true then
		data.timer = data.timer + 1
		data.animating = true
		if data.timer ~= 0 then
			mem(0xB2C5A0, FIELD_WORD, 0)
		end
		
		if data.timer < 25 then
			stick(data.player.idx, v)
			
			v.speedY = 0
		elseif data.timer >= 25 then
			for i = 1, Player.count() do 
				local v = Player(i)
				realwidth, realheight = v.x + v.width, v.y + v.height
				
				for k,b in ipairs(BGO.getIntersecting(v.x, v.y, realwidth, realheight)) do
					if flagpoleNPC.castleBGOs[b.id] == true then
						local vx, vy, vw, vh = b.x + ((b.width / 2) - 32), b.y + (b.height - 64), 32, 64
						
						if v.x >= vx and
						v.y >= vy and
						v.x <= vx + vw and
						v.y <= vy + vh then
							if v.mount == 1 or v.mount == 2 then break end
							v.keys.right = false
							v.speedX = 0
							v.speedY = 0
							v.x = vx + (data.player.width / 1.25)
							enter_castle(i)
						end
					end
				end
				v.speedX = Defines.player_walkspeed
			end
		end
		
		if data.timer >= 480 then
			mem(0xB2C5D4, FIELD_WORD, 8)
			Level.exit(flagpoleNPC.exitType)
	    end
		
		v.speedY = 0
	end
end

return flagpoleNPC