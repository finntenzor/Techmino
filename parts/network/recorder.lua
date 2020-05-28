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
    print(self)
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
