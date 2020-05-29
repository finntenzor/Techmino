-- @module reception

-- 依赖
-- 用mock则不使用ws协议 而是模拟一个服务器
local client = require('client')
local netMsg = require('parts/network/message')

-- 连接
local conn, connErr = client.connect('ws://127.0.0.1:8966')
assert(connErr == nil, connErr)

-- 当前这个本地玩家的客户端ID
local localClientID = 0

--- 一个简单的变换 相当于交换1号和当前客户端的编号
-- 由于仅交换两个玩家的ID 所以显然正向反向转换是一样的
local function idconvertV1(input)
    if input == 1 then
        return localClientID
    elseif input == localClientID then
        return 1
    else
        return input
    end
end

-- 给定客户端ID 转成PlayerID
local function cid2pid(cid)
    return idconvertV1(cid)
end

-- 给定PlayerID 转成客户端ID
local function pid2cid(pid)
    return idconvertV1(pid)
end

--- 每次收到一个消息
local function onReceiveMessage(message)
    --- 添加元表
    local msg = netMsg.makeMessage(message)
    if msg.messageType == 1 then
        localClientID = msg.clientID
    else
        local clientID = msg.clientID
        local playerID = cid2pid(clientID)
        local P = players[playerID]
        P:applyMessage(msg)
    end
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
-- 发送消息时不带发送者的客户端ID 由服务器添加
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
    cid2pid = cid2pid,
    pid2cid = pid2cid,
    poll = poll,
    send = send,
}

return export
