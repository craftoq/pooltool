local newtab = require("table.new")
local cleartab = require("table.clear")

local pooltool = {}
pooltool.__index = pooltool

function pooltool.new(maxsize, constructor)
	assert(maxsize > 0)
	local p = newtab(0, 3)
	p.maxsize = maxsize
	p.constructor = constructor
	return setmetatable(p, pooltool)
end

pooltool.cleartable = cleartab

--push方法不负责清理留存的数据，所以调用之前应当自行清理，避免再次使用该对象时出现bug
function pooltool:push(item)
	assert(item ~= nil)

	if self.items == nil then
		self.items = newtab(self.maxsize, 0)
		table.insert(self.items, item)
	elseif #self.items < self.maxsize then
		table.insert(self.items, item)
	end
end

function pooltool:isempty()
	return #self.items == 0
end

function pooltool:isfull()
	return #self.items >= self.maxsize
end

function pooltool:pop()
	if self.items ~= nil then
		local n = #self.items
		if n > 0 then
			local item = self.items[n]
			table.remove(self.items, n)
			-- printf("pool hit")
			return item
		end
	end
	return self.constructor ~= nil and self.constructor() or nil
end

function pooltool:clear(clearfunc)
	if self.items ~= nil then
		if clearfunc ~= nil then
			for i = #self.items, 1, -1 do
				clearfunc(self.items[i])
			end
		end
		cleartab(self.items)
	end
end

return pooltool
