local Random = {}
local RandomMeta = {
    __index = Random,
    __tostring = Random.__tostring,
}

local function new(seed, arg0, arg1)
    local instance = {
        seed = seed,
        arg0 = arg0,
        arg1 = arg1,
        curr = 0,
        block = -1,
        list = {},
        slice = 3,
    }
    setmetatable(instance, RandomMeta)
    return instance
end

--- 根据初始化参数生成下一个随机数
function Random:_next()
    if self.arg0 == nil then
        return math.random()
    elseif self.arg1 == nil then
        return math.random(self.arg0)
    else
        return math.random(self.arg0, self.arg1)
    end
end

--- 生成第x个块的若干个随机数
-- 块号从0开始 每次生成大小为slice
function Random:_generate(block)
    assert(block >= 0, 'block must bigger than zero, got ' .. block)
    -- 先把随机数种子重置到这个块开始位置的随机数位置
    math.randomseed(self.seed)
    for i = 1, block do
        math.random(1, 2e9) -- skip some random
    end
    local blockSeed = math.random(1, 2e9)
    math.randomseed(blockSeed)
    -- 生成slice个随机数
    local list = {}
    for i = 1, self.slice do
        table.insert(list, self:_next())
    end
    -- 保存
    self.block = block
    self.list = list
end

--- 返回下一个随机数
function Random:next()
    -- 求商与余数
    local r = self.curr % self.slice
    local q = (self.curr - r) / self.slice
    -- 生成这一块的所有随机数
    if q ~= self.block then
        self:_generate(q)
    end
    -- 返回并自增
    local index = r + 1
    self.curr = self.curr + 1
    return self.list[index]
end

--- 回到某个位置
function Random:seek(pos)
    self.curr = pos
end

--- 回到最开始的位置
function Random:reset()
    self:seek(0)
end

local exports = {
    new = new,
}
return exports
