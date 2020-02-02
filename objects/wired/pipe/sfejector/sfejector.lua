function init(virtual)
    pipes.init({itemPipe})

    self.dropPoint = {entity.position()[1] + 0.5, entity.position()[2] + 0.5} --TODO: Temporarily spawn inside until someone bothers adding several drop points based on orientation

    self.usedNode = 0
end

--------------------------------------------------------------------------------
function update(dt)
    pipes.update(dt)

    local position = entity.position()
    local checkDirs = {}
    checkDirs[0] = {-1, 0}
    checkDirs[1] = {0, -1}
    checkDirs[2] = {1, 0}
    checkDirs[3] = {0, 1}

    if #pipes.nodeEntities["item"] > 0 then
        for i=0,3 do 
            local angle = (math.pi / 2) * i
            if #pipes.nodeEntities["item"][i+1] > 0 then
                animator.rotateGroup("ejector", angle)
                self.usedNode = i + 1
            end
        end
    elseif i == 3 then --Not connected to an object, look for pipes instead
        for i=0,3 do 
            local angle = (math.pi / 2) * i
            local tilePos = {position[1] + checkDirs[i][1], position[2] + checkDirs[i][2]}
            local pipeDirections = pipes.getPipeTileData("item", tilePos, "foreground")
            if pipeDirections then
                animator.rotateGroup("ejector", angle)
                self.usedNode = i + 1
            end
        end
    end
end

function beforeItemPush(item, nodeId)
    if nodeId == self.usedNode then
        return item
    end
end

function onItemPush(item, nodeId)
    if item and nodeId == self.usedNode then
        local position = entity.position()

        if next(item.data) == nil then 
            world.spawnItem(item.name, self.dropPoint, item.count)
        else
            world.spawnItem(item.name, self.dropPoint, item.count, item.data)
        end

        return item
    end

    return nil
end
