local MESSAGE_OPEN = 1
local MESSAGE_MOVE = 2
local MESSAGE_DOWN = 3
local MESSAGE_SPIN = 4
local MESSAGE_HARD_DROP = 5
local MESSAGE_LOCK = 6
local MESSAGE_HOLD = 7
local MESSAGE_GARBAGE_SEND = 8
local MESSAGE_GARBAGE_RECEIVE = 9
local MESSAGE_GARBAGE_EFFECT = 10
local MESSAGE_STEP = 11
local MESSAGE_MAP = {
    [MESSAGE_MOVE] = 'move', -- 水平移动
    [MESSAGE_DOWN] = 'down', -- 垂直移动
    [MESSAGE_SPIN] = 'spin', -- 旋转
    [MESSAGE_HARD_DROP] = 'hard_drop', -- 硬降
    [MESSAGE_LOCK] = 'lock', -- 锁定
    [MESSAGE_HOLD] = 'hold', -- hold
    [MESSAGE_GARBAGE_SEND] = 'garbage_send', -- 发送垃圾行
    [MESSAGE_GARBAGE_RECEIVE] = 'garbage_receive', -- 收到垃圾行(开始倒计时)
    [MESSAGE_GARBAGE_EFFECT] = 'garbage_effect', -- 垃圾行生效(开始闪烁)
    [MESSAGE_STEP] = 'step', -- 步进操作 直接给定落块的位置朝向（还没开始写）
}

local Message = {}
local MessageMeta = {
    __index = Message,
    __tostring = Message.__tostring,
}

local function new(clientID, messageType)
    local instance = {
        clientID = clientID,
        messageType = messageType,
    }
    setmetatable(instance, MessageMeta)
    return instance
end

function Message:__tostring()
    local msgType = MESSAGE_MAP[self.messageType] or 'unknown'
    local header = '<' .. msgType
    local body = ''
    for k, v in pairs(self) do
        if k == 'messageType' then
            -- pass
        else
            body = body .. ' ' .. k .. '=' .. v
        end
    end
    return header .. body .. '>'
end

--- 是否是空白操作
-- 可能合并一会儿就合并成空操作了
function Message:isEmpty()
    if self.action == MESSAGE_MOVE then
        return self.dx == 0
    elseif self.action == MESSAGE_DOWN then
        return self.dy == 0
    end
    return false
end

--- 弱操作合并 用于合并一帧内的连续操作
function Message:weakMerge(other)
    if self.clientID ~= other.clientID then
        return nil
    end
    if self.messageType == MESSAGE_MOVE then
        -- 合并连续的水平移动
        if other.messageType == MESSAGE_MOVE then
            local result = new(self.clientID, MESSAGE_MOVE)
            result.dx = self.dx + other.dx
            return result
        end
    elseif self.messageType == MESSAGE_DOWN then
        -- 合并连续的竖直移动
        if other.messageType == MESSAGE_DOWN then
            local result = new(self.clientID, MESSAGE_DOWN)
            result.dy = self.dy + other.dy
            return result
        end
    -- elseif self.messageType == MESSAGE_SPIN then
        -- 旋转和旋转不能合并 比如DT炮需要连续好几个同方向的旋转
    elseif self.messageType == MESSAGE_HARD_DROP then
        -- 将硬降和相邻的锁定合并 即删除硬降后的锁定

        -- 注：这里的逻辑不要改
        -- 由于我把harddrop定义为瞬移至最下并锁定
        -- 所以必须在发送前删除多余的锁定操作
        if other.messageType == MESSAGE_LOCK then
            return self
        end
    -- elseif self.messageType == MESSAGE_LOCK then
    -- elseif self.messageType == MESSAGE_HOLD then
    -- elseif self.messageType == MESSAGE_SEND_GARBAGE then
    -- elseif self.messageType == MESSAGE_RECEIVE_GARBAGE then
    -- elseif self.messageType == MESSAGE_RISE_GARBAGE then
    end
    return nil
end

local function makeMessage(data)
    setmetatable(data, MessageMeta)
    return data
end

local function move(dx)
    local msg = new(0, MESSAGE_MOVE)
    msg.dx = dx
    return msg
end

local function down(dy)
    local msg = new(0, MESSAGE_DOWN)
    msg.dy = dy
    return msg
end

local function spin(spin)
    local msg = new(0, MESSAGE_SPIN)
    msg.spin = spin
    return msg
end

local function hardDrop()
    return new(0, MESSAGE_HARD_DROP)
end

local function lock()
    return new(0, MESSAGE_LOCK)
end

local function hold()
    return new(0, MESSAGE_HOLD)
end

local function garbageSend(target, send, time)
    local msg = new(0, MESSAGE_GARBAGE_SEND)
    msg.garbageID = 0
    -- msg.from = 0 -- 似乎是不必要的
    msg.target = target
    msg.send = send
    msg.time = time
    msg.position = 0
    return msg
end

local function garbageReceive(garbageID)
    local msg = new(0, MESSAGE_GARBAGE_RECEIVE)
    msg.garbageID = garbageID
    return msg
end

local function garbageEffect(garbageID)
    local msg = new(0, MESSAGE_GARBAGE_EFFECT)
    msg.garbageID = garbageID
    return msg
end

local exports = {
    MESSAGE_OPEN = MESSAGE_OPEN,
    MESSAGE_MOVE = MESSAGE_MOVE,
    MESSAGE_DOWN = MESSAGE_DOWN,
    MESSAGE_SPIN = MESSAGE_SPIN,
    MESSAGE_HARD_DROP = MESSAGE_HARD_DROP,
    MESSAGE_LOCK = MESSAGE_LOCK,
    MESSAGE_HOLD = MESSAGE_HOLD,
    MESSAGE_GARBAGE_SEND = MESSAGE_GARBAGE_SEND,
    MESSAGE_GARBAGE_RECEIVE = MESSAGE_GARBAGE_RECEIVE,
    MESSAGE_GARBAGE_EFFECT = MESSAGE_GARBAGE_EFFECT,
    MESSAGE_MAP = MESSAGE_MAP,

    new = new,
    makeMessage = makeMessage,
    move = move,
    down = down,
    spin = spin,
    hardDrop = hardDrop,
    lock = lock,
    hold = hold,
    garbageSend = garbageSend,
    garbageReceive = garbageReceive,
    garbageEffect = garbageEffect,
}
return exports
