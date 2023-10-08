module 'aux'

if _VERSION then
	function M.GetItemInfo(id)
		local name, itemstring, quality, _, level, class, subclass, max_stack, slot, texture = _G.GetItemInfo(id)
		return name, itemstring, quality, level, class, subclass, max_stack, slot, texture
	end
	function M.GetAuctionInvTypes(i, j, displayed)
		local t = temp-A(_G.GetAuctionInvTypes(i, j))
		local types = temp-T
		for i = 1, select('#', _G.GetAuctionInvTypes(i, j)), 2 do
			if not displayed or t[i + 1] == 1 then
				tinsert(types, t[i])
			end
		end
		return unpack(types)
	end
else
	M.select = vararg-function(arg)
		for _ = 1, arg[1] do
			tremove(arg, 1)
		end
		return unpack(arg)
	end
end

M.tonumber = function(v)
	return _G.tonumber(v or nil)
end

M.immutable = setmetatable(T, {
	__metatable = false,
	__newindex = nop,
	__sub = function(_, t)
		return setmetatable(T, O('__metatable', false, '__newindex', nop, '__index', t))
	end
})

M.join = table.concat

function M.range(arg1, arg2)
	local i, n = arg2 and arg1 or 1, arg2 or arg1
	if i <= n then return first, range(i + 1, n) end
end

function M.replicate(count, value)
	if count > 0 then return value, replicate(count - 1, value) end
end

M.index = vararg-function(arg)
	local t = tremove(arg, 1)
	for _, v in ipairs(arg) do
		t = t and t[v]
	end
	return t
end

M.huge = 1.8 * 10 ^ 308

function M.get_modified()
	return IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown()
end

function M.copy(t)
	local copy = T
	for k, v in pairs(t) do
		copy[k] = v
	end
	return setmetatable(copy, getmetatable(t))
end

function M.size(t)
	local size = 0
	for _ in pairs(t) do
		size = size + 1
	end
	return size
end

function M.key(t, value)
	for k, v in pairs(t) do
		if v == value then
			return k
		end
	end
end

function M.keys(t)
	local keys = T
	for k in pairs(t) do
		tinsert(keys, k)
	end
	return keys
end

function M.values(t)
	local values = T
	for _, v in pairs(t) do
		tinsert(values, v)
	end
	return values
end

function M.eq(t1, t2)
	if not t1 or not t2 then return false end
	for key, value in pairs(t1) do
		if t2[key] ~= value then return false end
	end
	for key, value in pairs(t2) do
		if t1[key] ~= value then return false end
	end
	return true
end

function M.any(t, predicate)
	for _, v in pairs(t) do
		if predicate then
			if predicate(v) then return true end
		elseif v then
			return true
		end
	end
	return false
end

function M.all(t, predicate)
	for _, v in pairs(t) do
		if predicate then
			if not predicate(v) then return false end
		elseif not v then
			return false
		end
	end
	return true
end

function M.filter(t, predicate)
	for k, v in pairs(t) do
		if not predicate(v, k) then t[k] = nil end
	end
	return t
end

function M.map(t, f)
	for k, v in pairs(t) do
		t[k] = f(v, k)
	end
	return t
end

function M.trim(str)
	return gsub(str, '^%s*(.-)%s*$', '%1')
end

function M.split(str, separator)
	local parts = T
	while true do
		local start_index = strfind(str, separator, 1, true)
		if start_index then
			local part = strsub(str, 1, start_index - 1)
			tinsert(parts, part)
			str = strsub(str, start_index + 1)
		else
			local part = strsub(str, 1)
			tinsert(parts, part)
			return parts
		end
	end
end

function M.tokenize(str)
	local tokens = T
	for token in string.gfind(str, '%S+') do tinsert(tokens, token) end
	return tokens
end

function M.bounded(lower_bound, upper_bound, number)
	return max(lower_bound, min(upper_bound, number))
end

function M.round(x)
	return floor(x + .5)
end

function M.later(t, t0)
	t0 = t0 or GetTime()
	return function() return GetTime() - t0 > t end
end

function M.signal()
	local params
	return vararg-function(arg)
		static(arg)
		params = arg
	end, function()
		return params
	end
end