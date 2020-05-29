local netRandom = require('parts/network/random')

local function consistentSequence(seed)
	local rs = {}
	for i = 1, 5 do
		rs[i] = netRandom.new(seed)
	end

	local function makeBag(playerID)
		local bag = {1,2,3,4,5,6,7}
		local result = {}
		local r = rs[playerID]
		for i = 1, 7 do
			local choose = table.remove(bag, math.ceil(r:next() * #bag))
			table.insert(result, choose)
		end
		return result
	end

	local function sequence(P)
		rs[P.id]:reset()
		local bag = makeBag(P.id)
		for i = 1, 7 do
			P:getNext(bag[i])
		end
	end

	local function freshMethod(P)
		local bag = makeBag(P.id)
		for i = 1, 7 do
			P:getNext(bag[i])
		end
	end
	return sequence, freshMethod
end

local sequence, freshMethod = consistentSequence(626)

return{
	color=color.white,
	env={
		drop=60,lock=60,
		freshLimit=15,
		bg="none",bgm="way",
		online=true,

		sequence=sequence,
		freshMethod=freshMethod,
		-- sequence=function(P)
        --     for i = 1, #minos do
        --         P:getNext(minos[i])
        --     end
        -- end,
        -- freshMethod=function(P)
        --     P:getNext(7)
        -- end,
	},
	load=function()
		PLY.newPlayer(1,10,10,1)
		PLY.newRemotePlayer(2,650,50,.4)
		PLY.newRemotePlayer(3,935,50,.4)
		PLY.newRemotePlayer(4,650,400,.4)
		PLY.newRemotePlayer(5,935,400,.4)
	end,
	mesDisp=function(P,dx,dy)
	end,
}
