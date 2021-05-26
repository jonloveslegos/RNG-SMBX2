levelMaker = {}
playerStartY = 0
playerStartX = 0
savedCode = {}
if SaveData.savedGeneration == nil then
    SaveData.savedGeneration = {}
end
function levelMaker.onStartMake()
    playerStartY = player.y
    playerStartX = player.x
end
function levelMaker.onTickMake(retrns)
    savedCode = {}
    local savedNPC = {}
    local savedBGO = {}
    local savedWARP = {}
    saving = Block.get()
    for i=1,tablelength(saving) do
        local tosave = {}
        table.insert(tosave,saving[i].id)
        table.insert(tosave,saving[i].x)
        table.insert(tosave,saving[i].y)
        table.insert(tosave,saving[i].width)
        table.insert(tosave,saving[i].height)
        table.insert(tosave,saving[i].contentID)
        table.insert(tosave,saving[i].isHidden)
        table.insert(tosave,saving[i]:mem(0x5A,FIELD_BOOL))
        table.insert(tosave,saving[i].slippery)
        table.insert(savedCode,tosave)
    end
    saving = NPC.get()
    for i=1,tablelength(saving) do
        local tosave = {}
        table.insert(tosave,saving[i].id)
        table.insert(tosave,saving[i]:mem(0xA8,FIELD_DFLOAT))
        table.insert(tosave,saving[i]:mem(0xB0,FIELD_DFLOAT))
        table.insert(tosave,saving[i]:mem(0xDE,FIELD_WORD))
        table.insert(tosave,saving[i].ai2)
        table.insert(tosave,saving[i].ai3)
        table.insert(tosave,saving[i].ai4)
        table.insert(tosave,saving[i].ai5)
        table.insert(tosave,saving[i]:mem(0xD8,FIELD_FLOAT))
        table.insert(savedNPC,tosave)
    end
    saving = BGO.get()
    for i=1,tablelength(saving) do
        local tosave = {}
        table.insert(tosave,saving[i].id)
        table.insert(tosave,saving[i].x)
        table.insert(tosave,saving[i].y)
        table.insert(savedBGO,tosave)
    end
    saving = Warp.get()
    for i=1,tablelength(saving) do
        local tosave = {}
        table.insert(tosave,i)
        table.insert(tosave,saving[i].entranceX)
        table.insert(tosave,saving[i].entranceY)
        table.insert(tosave,saving[i].exitX)
        table.insert(tosave,saving[i].exitY)
        table.insert(savedWARP,tosave)
    end
    if (retrns == false) then
        local dataFile = io.open(Misc.episodePath()..Level.name()..".txt", "w+" )
        dataFile:write(Level.name().." = {}".."\n".."\n"..Level.name()..".water = "..createStringFromBool(Section.get(1).isUnderwater).."\n"..Level.name()..".width = "..math.abs(Section.get(1).boundary.left-Section.get(1).boundary.right).."\n"..Level.name()..".playerY = "..playerStartY.."\n"..Level.name()..".playerX = "..playerStartX.."\n"..Level.name()..".background = "..Section.get(1).backgroundID.."\n"..Level.name()..".music = "..Section.get(1).musicID.."\n"..Level.name()..".warp = {\n"..createStringFromTable(savedWARP).."}".."\n"..Level.name()..".bgo = {\n"..createStringFromTable(savedBGO).."}".."\n"..Level.name()..".npc = {\n"..createStringFromTable(savedNPC).."}".."\n"..Level.name()..".blocks = {\n"..createStringFromTable(savedCode).."}\nreturn "..Level.name())
        dataFile:close()
    elseif Misc.saveSlot() ~= 0 then
        playerStartX = player.x
        playerStartY = player.y
        local scene1back = Section(1).backgroundID
        local scene1mus = Section(1).musicID
        local scene2back = Section(2).backgroundID
        local scene2mus = Section(2).musicID
        local scene1width = math.abs(Section(1).boundary.left-Section(1).boundary.right)
        local scene2width = math.abs(Section(2).boundary.left-Section(2).boundary.right)
        local dataFile = io.open(Misc.episodePath().."LastLevelSave"..Misc.saveSlot()..".txt", "w+" )
        local txt = Level.name().." = {}".."\n".."\n"..Level.name()..".water = "..createStringFromBool(Section.get(1).isUnderwater).."\n"..Level.name()..".width = "..math.abs(Section.get(1).boundary.left-Section.get(1).boundary.right).."\n"..Level.name()..".playerY = "..playerStartY.."\n"..Level.name()..".playerX = "..playerStartX.."\n"..Level.name()..".background = "..Section.get(1).backgroundID.."\n"..Level.name()..".music = "..Section.get(1).musicID.."\n"..Level.name()..".warp = {\n"..createStringFromTable(savedWARP).."}".."\n"..Level.name()..".bgo = {\n"..createStringFromTable(savedBGO).."}".."\n"..Level.name()..".npc = {\n"..createStringFromTable(savedNPC).."}".."\n"..Level.name()..".blocks = {\n"..createStringFromTable(savedCode).."}"
        txt = txt.."\n"..Level.name()..".sec1back = "..scene1back
        txt = txt.."\n"..Level.name()..".sec1mus = "..scene1mus
        txt = txt.."\n"..Level.name()..".sec2back = "..scene2back
        txt = txt.."\n"..Level.name()..".sec2mus = "..scene2mus
        txt = txt.."\n"..Level.name()..".sec1width = "..scene1width
        txt = txt.."\n"..Level.name()..".sec2width = "..scene2width
        txt = txt.."\nreturn "..Level.name()
        dataFile:write(txt)
        dataFile:close()
    end
end

function createStringFromBool(t)
    local str = ""
    if t == true then str = str.."true".."" end
    if t == false then str = str.."false".."" end
    return str
end

function createStringFromTable(t)
    local str = ""
    for i=1,tablelength(t) do
        if type(t[i]) == "string" then
            str = str.."'"..t[i].."'"..",\n"
        elseif type(t[i]) == "number" then
            str = str..t[i]..",\n"
        elseif type(t[i]) == "table" then
            str = str.."{\n"..createStringFromTable(t[i]).."},\n"
        elseif type(t[i]) == "boolean" then
         if t[i] == true then str = str.."true"..",\n" end
         if t[i] == false then str = str.."false"..",\n" end
        end
    end
    return str
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

return levelMaker