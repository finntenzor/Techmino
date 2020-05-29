local MODE_IMMEDIATE = 1
local MODE_STEP = 2

local ActionRecorder = {}
local ActionRecorderMeta = {
    __index = ActionRecorder,
    __tostring = ActionRecorder.__tostring,
}

local function new()
    local instance = {
        actions = {},
        mode = MODE_IMMEDIATE,
    }
    setmetatable(instance, ActionRecorderMeta)
    return instance
end

--- 加入一个msg
function ActionRecorder:push(msg)
    table.insert(self.actions, msg)
end

--- 输出目前所有的action
function ActionRecorder:dump()
    print(self:__tostring())
end

--- 对ActionRecorder内所有相邻动作做弱合并
function ActionRecorder:weakMerge()
    local i = 1
    while i <= #self.actions do
        local curr = self.actions[i]
        if curr:isEmpty() then
            table.remove(self.actions, i)
        else
            local next = self.actions[i + 1]
            if next then
                local mer = curr:weakMerge(next)
                if mer ~= nil then
                    self.actions[i] = mer
                    table.remove(self.actions, i + 1)
                    i = i - 1
                end
            end
        end
        i = i + 1
    end
end

--- 持续合并 直到落块为一个操作 然后继续下一次合并
function ActionRecorder:strongMerge()
end

--- 按当前模式合并操作
function ActionRecorder:merge()
    if self.mode == MODE_IMMEDIATE then
        self:weakMerge()
    elseif self.mode == MODE_STEP then
        self:strongMerge()
    else
        -- 未知模式默认弱合并
        -- 也可以抛出错误
        self:weakMerge()
    end
end

--- 清空
function ActionRecorder:clear()
    self.actions = {}
end

--- 字符串化 方便print
function ActionRecorder:__tostring()
    local n = #self.actions
    local str = '<ActionRecorder actions=['
    for i = 1, n do
        local actionItem = self.actions[i]
        str = str .. '\n  ' .. actionItem:__tostring()
    end
    if n > 0 then
        str = str .. '\n]>'
    else
        str = str .. ']>'
    end
    return str
end

local exports = {
    MODE_IMMEDIATE = MODE_IMMEDIATE,
    MODE_STEP = MODE_STEP,

    new = new,
}
return exports
