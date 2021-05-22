local npcManager = require("npcManager")

local GreenSpringboard = {}
local npcID = NPC_ID

local GreenSpringboardSettings = {
	id = npcID,
	gfxwidth = 32,
	gfxheight = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 1,
	speed = 0,
	npcblock = true,
	npcblocktop = true,
	playerblock = true,
	playerblocktop = false,
	nohurt=true,
	nogravity = true,
	noblockcollision = false,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = false,
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false
}
npcManager.setNpcSettings(GreenSpringboardSettings)
npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

npcManager.registerHarmTypes(npcID,{HARM_TYPE_LAVA},{[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5}})

function GreenSpringboard.onInitAPI()
	npcManager.registerEvent(npcID, GreenSpringboard, "onTickNPC")
	npcManager.registerEvent(npcID, GreenSpringboard, "onDrawNPC")
end

function GreenSpringboard.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data

	v.data.frames = v.data.frames or 0
	v.data.bounced = v.data.bounced or false
	v.data.reverseframe = v.data.reverseframe or false
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		v.data.frames = 0
		v.data.bounced = false
		v.data.reverseframe = false
		return
	end

	if v:mem(0x12C, FIELD_WORD) > 0	or v:mem(0x136, FIELD_BOOL) or v:mem(0x138, FIELD_WORD) > 0 then
		v.data.frames = 0
		v.data.bounced = false
		v.data.reverseframe = false
	end

	if (not NPC.config[npcID].playerblocktop) then
		if Colliders.speedCollide(player,v) and player.speedY > 1 and player.y < v.y - (player.height/2) then
			if player.jumpKeyPressing or player.altJumpKeyPressing then
				player.speedY = -80
			else
				player.speedY = -10
			end
			v.data.bounced = true
			SFX.play(24)
		end
		if player2 then
			if Colliders.speedCollide(player2,v) and player2.speedY > 1 and player2.y < v.y - (player2.height/2) then
				if player2.jumpKeyPressing or player2.altJumpKeyPressing then
					player2.speedY = -80
				else
					player2.speedY = -10
				end
					v.data.bounced = true
				SFX.play(24)
			end
		end
	end
	if v.data.bounced then
		if not v.data.reverseframe then
			if v.data.frames < 6 then
				v.data.frames = v.data.frames + 1
			else
				v.data.reverseframe = true
			end
		else
			if v.data.reverseframe and v.data.frames > 0 then
				v.data.frames = v.data.frames - 1
			else
				v.data.reverseframe = false
				v.data.bounced = false
			end
		end
	end
end

function GreenSpringboard.onDrawNPC(v)
	local data = v.data
	v.data.frames = v.data.frames or 0
	v.animationFrame = math.ceil(v.data.frames/4)
end

return GreenSpringboard
