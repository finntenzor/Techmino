-- @module reception

-- 依赖
-- 用mock则不使用ws协议 而是模拟一个服务器
local client = require('mock_client')
local netMsg = require('parts/network/message')

-- 连接
local conn, connErr = client.connect('ws://127.0.0.1:8966')
assert(connErr == nil, connErr)

--- 每次收到一个消息
local function onReceiveMessage(message)
    local msg = netMsg.makeMessage(message)
    local clientID = msg.clientID
    local P = players[clientID]
    P:applyMessage(msg)
end

--- 轮询
-- 查询有没有服务器发来的消息 有则逐个交给OnReceiveMessage
-- 如果发生错误 则返回错误 没有错误返回nil
local function poll()
    local data, err = client.read(conn)
    if err ~= nil then
        return err
    end
    if data ~= nil then
        for i = 1, #data do
            local message = data[i]
            onReceiveMessage(message)
        end
    end
    return nil
end

--- 返回当前用户正在操作的Player
local function getCurrentControlPlayer()
    for i = 1, #players do
        local P = players[i]
        local online = P.gameEnv.online
        if online then
            if P.remote ~= true then
                return P
            end
        end
    end
    return nil
end

--- 把当前用户的所控制的玩家的所有消息都发出去
local function send()
    local P = getCurrentControlPlayer()
    if P then
        local R = P.recorder
        -- 注：这里的weakMerge不能删
        -- 由于我把harddrop定义为瞬移至最下并锁定
        -- 所以必须在发送前删除多余的锁定操作
        R:merge()
        local actions = R.actions
        -- if #actions > 0 then
        --     R:dump()
        -- end

        for i = 1, #actions do
            -- writeR:pushRaw(actions[i])
            client.write(conn, actions[i])
        end

        R:clear()

        -- writeR:dump()
        -- readR:dump()
    end
end

-- 模块导出
local export = {
    poll = poll,
    send = send,
}

return export
