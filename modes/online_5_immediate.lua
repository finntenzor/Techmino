local function consistentSequence(seed)
	local history = {}
	local indexMap = {}
	math.randomseed(seed)

	local function pushBag()
		local bag = {1,2,3,4,5,6,7}
		for i = 1, 7 do
			local choose = table.remove(bag, math.random(#bag))
			table.insert(history, choose)
		end
	end

	local function get(index)
		while #history < index do
			pushBag()
		end
		return history[index]
	end

	local function next(id)
		if indexMap[id] == nil then
			indexMap[id] = 1
		end
		local num = get(indexMap[id])
		indexMap[id] = indexMap[id] + 1
		return num
	end

	local function sequence(P)
		for i = 1, 7 do
			P:getNext(next(P.id))
		end
	end
	local function freshMethod(P)
		P:getNext(next(P.id))
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
