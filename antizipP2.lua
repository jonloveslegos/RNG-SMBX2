local az = {}
local playerManager = require("playerManager")
az.enabled = true

local stuckTimer = 0
local stuckx
local lastPlayerX = 0
local hasPressedDown = false
local wasOnSlope = false
local unduckCollider = Colliders.Box(0,0,0,0)
local regularPlayerHeight = 0
local duckingPlayerHeight = 0
local lastCharacter = nil
local lastPowerup = nil
local lastForcedState = 0
local isDuckPowering = false
local previousY = 0
local freezeState = {
    [1] = true,
    [2] = true,
    [4] = true,
    [5] = true,
    [11] = true,
    [12] = true,
    [41] = true,
}

local function blockcheck(offset)
	local y = player2.y
	local blocks = Block.getIntersecting(player2.x, y + offset, player2.x + player2.width, y + offset + player2.height)
	local goodblocks = {}
	for k,v in ipairs(blocks) do
		if (Block.SOLID_MAP[v.id] or Block.PLAYERSOLID_MAP[v.id]) and (not v.isHidden) and v:mem(0x5C, FIELD_WORD) == 0 then
			if Colliders.collide(player2, v) then
				table.insert(goodblocks, v)
			end
		end
	end
	return #goodblocks > 0, goodblocks
end

local function miniBlockCheck(x1, y1, blocks)
	local collisionZone = Colliders.Box(x1, y1, player2.width, player2.height)

	for k,v in ipairs(blocks) do
		if (not Block.SLOPE_MAP[v.id]) and Colliders.collide(collisionZone, v) then
			return true
		end
	end
	return false
end

local function expandBlockChecks()
    if wasOnSlope ~= 0 then return false end

    local x1 = player2.x - 8
    local y1 = player2.y - 8
    local x2 = player2.x + player2.width + 8
    local y2 = player2.y + player2.height + 8
    local blocks = Colliders.getColliding{
        a = Colliders.Box(x1, y1, player2.width + 16, player2.height + 16),
        b = Block.SOLID .. Block.PLAYERSOLID,
        btype = Colliders.BLOCK,
        filter = function(other)
            if other.isHidden then return false end
            if other:mem(0x5A, FIELD_WORD) == -1 then return false end
            if other:mem(0x1C, FIELD_WORD) == -1 then return false end
            if other:mem(0x1C, FIELD_WORD) == -1 then return false end
            return true
        end
    }
    x1 = x1 - player2.width
    y1 = y1 - player2.height
    local dodged = false
    for i=x1, x2, 2 do
        for j=y1, y2, 2 do
            if not miniBlockCheck(i, j, blocks) then
                if dodged then
                    local xw, yh = player2.x, player2.y
                    local vec = vector(i-xw, j-yh)
                    if vec.sqrlength < vector(dodged.x-xw, dodged.y-yh).sqrlength then
                        dodged = vector(i,j)
                    end
                else
                    dodged = vector(i,j)
                end
            end
        end
    end
    if not dodged then
        if hasPressedDown == false then
            player2.y = previousY + duckingPlayerHeight
            player2:mem(0xD0, FIELD_DFLOAT, 14)
            player2.downKeyPressing = true
            local x1 = player2.x - 8
            local y1 = player2.y - 8
            local x2 = player2.x + player2.width + 8
            local y2 = player2.y + player2.height + 8
            local blocks = Colliders.getColliding{
                a = Colliders.Box(x1, y1, player2.width + 16, player2.height + 16),
                b = Block.SOLID .. Block.PLAYERSOLID,
                btype = Colliders.BLOCK,
                filter = function(other)
                    if other.isHidden then return false end
                    if other:mem(0x5A, FIELD_WORD) == -1 then return false end
                    if other:mem(0x1C, FIELD_WORD) == -1 then return false end
                    if other:mem(0x1C, FIELD_WORD) == -1 then return false end
                    return true
                end
            }
            x1 = x1 - player2.width
            y1 = y1 - player2.height
            local dodged = false
            for i=x1, x2, 2 do
                for j=y1, y2, 2 do
                    if not miniBlockCheck(i, j, blocks) then
                        if dodged then
                            local xw, yh = player2.x, player2.y
                            local vec = vector(i-xw, j-yh)
                            if vec.sqrlength < vector(dodged.x-xw, dodged.y-yh).sqrlength then
                                dodged = vector(i,j)
                            end
                        else
                            dodged = vector(i,j)
                        end
                    end
                end
            end
            if not dodged then
                player2:kill()
            else
                if hasPressedDown == false then
                    player2.y = previousY + duckingPlayerHeight
                    player2:mem(0xD0, FIELD_DFLOAT, 14)
                    hasPressedDown = true
                    isDuckPowering = true
                    player2.downKeyPressing = hasPressedDown
                end
            end
        end
    else
        if vector(dodged.x-player2.x, dodged.y-player2.y).length > 16 then
            player2:harm()
        end
        player2.x = dodged.x
        player2.y = dodged.y
        isStuckAtAll = false
        return true
    end
	return false
end

local function unstuck(px)
	local isStuckAtAll, defaults = blockcheck(0)
	if not isStuckAtAll and player2.deathTimer == 0 then
		stuckx = nil
		return false
	end
	return expandBlockChecks()
end

function az.onInitAPI()
    registerEvent(az, "onTick")
    registerEvent(az, "onDrawEnd")
end
function az.onDrawEnd()
    if player2 == nil then return end
    previousY = player2.y
    if isDuckPowering then
        previousY = previousY - duckingPlayerHeight
    end
end

function az.onTick()
    if player2 == nil then return end
    if not az.enabled then return end
    if freezeState[player2.forcedState] then
        if hasPressedDown then
            player2.y = previousY + duckingPlayerHeight
            player2:mem(0xD0, FIELD_DFLOAT, 14)
            hasPressedDown = true
            isDuckPowering = true
        end
        player2.downKeyPressing = hasPressedDown
    end

    if player2.character ~= lastCharacter or (player2.powerup ~= lastPowerup and lastForcedState ~= player2.forcedState) then
        local ps = PlayerSettings.get(playerManager.getBaseID(player2.character),player2.powerup)
        lastCharacter = player2.character
        lastPowerup = player2.powerup
        regularPlayerHeight = ps.hitboxHeight
        unduckCollider.width = player2.width
        unduckCollider.height = ps.hitboxDuckHeight
    end

    lastForcedState = player2.forcedState
    if hasPressedDown and player2.forcedState == 0 then
        unduckCollider.x = player2.x
        unduckCollider.y = player2.y + player2.height - regularPlayerHeight
        local _, _, blocks = Colliders.collideBlock(unduckCollider, Colliders.BLOCK_SOLID)
        local cancel = false
        for k,v in ipairs (blocks) do
            if not v.isHidden then
                cancel = true
                break
            end
        end
        if cancel then
            player2.keys.down = true
            player2:mem(0x12E, FIELD_WORD, -1)
        end
    end
    if (not Defines.cheat_shadowmario) and player2.deathTimer == 0 and player2.forcedState == 0 and #Colliders.getColliding{
		a = player2,
		b = Block.SOLID,
		btype = Colliders.BLOCK,
		filter = function(other)
			if other.isHidden then return false end
			if other:mem(0x5A, FIELD_WORD) == -1 then return false end
			if other:mem(0x1C, FIELD_WORD) == -1 then return false end
			if other:mem(0x5C, FIELD_WORD) == -1 then return false end
			return true
		end
    } > 0 then
		if stuckx == nil then
			stuckx = lastPlayerX
		end
		stuckTimer = stuckTimer + 1
		local px = player2.x
		player2.x = stuckx
		if stuckTimer >= 1 then
			if not unstuck(px) then
				player2.x = px
			end
		end
	else
		stuckTimer = 0
		stuckx = nil
	end
	lastPlayerX = player2.x
    wasOnSlope = player2:mem(0x48, FIELD_WORD)
		
    if player2.forcedState == 0 then
        if isDuckPowering then
            player2.y = player2.y - duckingPlayerHeight
        end
        isDuckPowering = false
        hasPressedDown = player2.downKeyPressing
    end
end

return az