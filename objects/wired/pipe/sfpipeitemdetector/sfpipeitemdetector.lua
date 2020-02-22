function init()
    if storage.state == nil then
        storage.state = false
    end

    if storage.timer == nil then
        storage.timer = 0
    end

    self.detectCooldown = config.getParameter("detectCooldown")

    updateAnimationState()

    self.connectionMap = {}
    self.connectionMap[1] = 2
    self.connectionMap[2] = 1
    self.connectionMap[3] = 4
    self.connectionMap[4] = 3

    pipes.init({itemPipe})
    datawire.init()
end

function onNodeConnectionChange()
    datawire.onNodeConnectionChange()
end

--------------------------------------------------------------------------------
function update(dt)
    datawire.update()
    pipes.update(dt)

    if storage.timer > 0 then
        storage.timer = storage.timer - dt

        if storage.timer <= 0 then
            deactivate()
        end
    end
end

function updateAnimationState()
    if storage.state then
        animator.setAnimationState("switchState", "on")
    else
        animator.setAnimationState("switchState", "off")
    end
end

function activate()
    storage.timer = self.detectCooldown
    storage.state = true
    object.setAllOutputNodes(true)
    updateAnimationState()
end

function deactivate()
    storage.state = false
    updateAnimationState()
    object.setAllOutputNodes(false)
end

function output(item)
    if item.count then
        datawire.sendData(item.count, "number", "all")
    end
end

function beforeItemPush(item, nodeId)
    local ret = peekPushItem(self.connectionMap[nodeId], item)

    if ret then return ret[2] end
    
    return nil
end

function onItemPush(item, nodeId)
    local peek = peekPushItem(self.connectionMap[nodeId], item)

    if peek then
        local result = pushItem(self.connectionMap[nodeId], peek[1])

        if result then
            activate()
            output(result[2])

            return result[2]
        end
    end

    return nil
end

function beforeItemPull(filters, nodeId)
    local ret = peekPullItem(self.connectionMap[nodeId], filters)

    if ret then return ret[2] end

    return nil
end

function onItemPull(item, nodeId)
    local res = nil
    local peek = peekPullItem(self.connectionMap[nodeId], {{
        item = item,
        amount = {item.count, item.count}
    }})

    if peek then
        local result = pullItem(self.connectionMap[nodeId], peek[1])

        if result then
            res = result[2]
            activate()
            output(res)
        end
    end

    return res
end
